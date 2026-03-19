using System.Data;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using RefundSystem.Core.Interfaces;
using RefundSystem.Core.ReadModels;
using RefundSystem.Data.Context;

namespace RefundSystem.Data.Repository
{
    /// <summary>גישה לנתוני החזרים – מריץ פרוצדורות ב-DB, מחזיר Read Models.</summary>
    public class RefundRepository : IRefundRepository
    {
        private readonly RefundSystemDbContext _context;

        public RefundRepository(RefundSystemDbContext context)
        {
            _context = context;
        }

        /// <summary>יוצר בקשת החזר חדשה (פרוצדורה).</summary>
        public async Task CreateRefundRequestAsync(
            int citizenId,
            int taxYear,
            CancellationToken cancellationToken = default)
        {
            // הרצת פרוצדורה – יוצרת בקשה בסטטוס Pending
            await _context.Database.ExecuteSqlRawAsync(
                "EXEC CreateRefundRequest @p0, @p1",
                new object[] { citizenId, taxYear },
                cancellationToken);
        }

        /// <summary>מריץ חישוב זכאות לבקשה (פרוצדורה).</summary>
        public async Task CalculateRefundAsync(
            int requestId,
            CancellationToken cancellationToken = default)
        {
            // הרצת פרוצדורה – מחשבת זכאות ומעדכנת סטטוס ל-Calculated
            await _context.Database.ExecuteSqlRawAsync(
                "EXEC CalculateRefund @p0",
                new object[] { requestId },
                cancellationToken);
        }

        /// <summary>בקשות ממתינות לפקיד (Pending + Calculated).</summary>
        public async Task<IReadOnlyList<PendingRequestReadModel>> GetPendingRequestsForClerkAsync(
            CancellationToken cancellationToken = default)
        {
            // פרוצדורה מחזירה רשימת בקשות Pending + Calculated
            return await _context
                .Set<PendingRequestReadModel>()
                .FromSqlRaw("EXEC GetPendingRequestForClerk")
                .ToListAsync(cancellationToken);
        }

        /// <summary>פרטי בקשה לפקיד: בקשה נוכחית, הכנסות, היסטוריה, תקציב חודשי.</summary>
        public async Task<ClerkRequestDetailsReadModel> GetRequestDetailsForClerkAsync(
            int requestId,
            CancellationToken cancellationToken = default)
        {
            // פתיחת חיבור והרצת הפרוצדורה – מחזירה 4 תוצאות
            var connection = _context.Database.GetDbConnection();
            if (connection.State != ConnectionState.Open)
                await connection.OpenAsync(cancellationToken);

            await using var command = connection.CreateCommand();
            command.CommandText = "EXEC GetRequestDetailsForClerk @RequestId";
            var param = command.CreateParameter();
            param.ParameterName = "@RequestId";
            param.Value = requestId;
            command.Parameters.Add(param);

            await using var reader = await command.ExecuteReaderAsync(cancellationToken);

            // תוצאה 1: הבקשה הנוכחית (שורה אחת)
            RefundRequestSummaryReadModel? currentRequest = null;
            if (await reader.ReadAsync(cancellationToken))
            {
                currentRequest = new RefundRequestSummaryReadModel(
                    reader.GetInt32(0),
                    reader.GetInt32(1),
                    reader.IsDBNull(2) ? null : reader.GetDecimal(2),
                    reader.IsDBNull(3) ? null : reader.GetDecimal(3),
                    reader.GetString(4),
                    reader.GetDateTime(5));
            }

            if (currentRequest == null)
                return null!; // בקשה לא נמצאה

            // תוצאה 2: הכנסות חודשיות (שנת מס, חודש, סכום)
            var incomes = new List<MonthlyIncomeReadModel>();
            await reader.NextResultAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                incomes.Add(new MonthlyIncomeReadModel(
                    reader.GetInt32(0),
                    reader.GetByte(1),
                    reader.GetDecimal(2)));
            }

            // תוצאה 3: כל בקשות האזרח (כולל הנוכחית – נסנן למטה)
            var pastRequests = new List<RefundRequestSummaryReadModel>();
            await reader.NextResultAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                pastRequests.Add(new RefundRequestSummaryReadModel(
                    reader.GetInt32(0),
                    reader.GetInt32(1),
                    reader.IsDBNull(2) ? null : reader.GetDecimal(2),
                    reader.IsDBNull(3) ? null : reader.GetDecimal(3),
                    reader.GetString(4),
                    reader.GetDateTime(5)));
            }

            // תוצאה 4: תקציב החודש הנוכחי (שורה אחת, אופציונלי)
            BudgetReadModel? currentMonthBudget = null;
            await reader.NextResultAsync(cancellationToken);
            if (await reader.ReadAsync(cancellationToken))
            {
                currentMonthBudget = new BudgetReadModel(
                    reader.GetDecimal(0),
                    reader.GetDecimal(1),
                    reader.GetDecimal(2));
            }

            // היסטוריה ללא הבקשה הנוכחית – להצגה בנפרד
            var pastRequestsOnly = pastRequests
                .Where(r => r.RequestId != currentRequest.RequestId)
                .ToList();

            return new ClerkRequestDetailsReadModel(
                currentRequest,
                incomes,
                pastRequestsOnly,
                currentMonthBudget);
        }

        /// <summary>אישור או דחיית בקשת החזר + עדכון תקציב (פרוצדורה).</summary>
        public async Task ApproveOrRejectRefundRequestAsync(
            int requestId,
            bool isApproved,
            decimal? approvedAmount,
            CancellationToken cancellationToken = default)
        {
            // פרוצדורה: מעדכנת סטטוס (אישור/דחייה) ובמקרה אישור – גם תקציב
            await _context.Database.ExecuteSqlRawAsync(
                "EXEC ApproveOrRejectRefundRequest @p0, @p1, @p2",
                new object[] { requestId, isApproved, approvedAmount },
                cancellationToken);
        }

        /// <summary>תצוגת אזרח: רשימת בקשות לפי ת.ז. (פרוצדורה). null אם אין נתונים.</summary>
        public async Task<CitizenRequestViewReadModel?> GetCitizenRequestViewAsync(
            string identityNumber,
            CancellationToken cancellationToken = default)
        {
            // חיבור + הרצת פרוצדורה (מחפשת אזרח לפי ת.ז. ומחזירה את כל הבקשות שלו)
            var connection = _context.Database.GetDbConnection();
            if (connection.State != ConnectionState.Open)
                await connection.OpenAsync(cancellationToken);

            await using var command = connection.CreateCommand();
            command.CommandText = "EXEC GetCitizenRequestView @IdentityNumber";
            var param = command.CreateParameter();
            param.ParameterName = "@IdentityNumber";
            param.Value = identityNumber;
            command.Parameters.Add(param);

            await using var reader = await command.ExecuteReaderAsync(cancellationToken);

            // קריאת כל השורות – כל שורה = בקשה אחת (ממוינות מהאחרונה)
            var requests = new List<RefundRequestSummaryReadModel>();
            while (await reader.ReadAsync(cancellationToken))
            {
                requests.Add(new RefundRequestSummaryReadModel(
                    reader.GetInt32(0),
                    reader.GetInt32(1),
                    reader.IsDBNull(2) ? null : reader.GetDecimal(2),
                    reader.IsDBNull(3) ? null : reader.GetDecimal(3),
                    reader.GetString(4),
                    reader.GetDateTime(5)));
            }

            if (requests.Count == 0)
                return null; // אזרח לא נמצא או אין בקשות

            return new CitizenRequestViewReadModel(requests);
        }
    }
}