using RefundSystem.Core.Interfaces;
using RefundSystem.Core.ReadModels;

namespace RefundSystem.Service.Services
{
    /// <summary>שיכבה לוגית להחזרים – מעבירה קריאות ל-Repository ללא לוגיקה נוספת.</summary>
    public class RefundService : IRefundService
    {
        private readonly IRefundRepository _repository;

        public RefundService(IRefundRepository repository)
        {
            _repository = repository;
        }

        /// <summary>יוצר בקשת החזר חדשה.</summary>
        public async Task CreateRefundRequestAsync(
            int citizenId,
            int taxYear,
            CancellationToken cancellationToken = default)
        {
            await _repository.CreateRefundRequestAsync(
                citizenId,
                taxYear,
                cancellationToken);
        }

        /// <summary>מריץ חישוב זכאות לבקשה.</summary>
        public async Task CalculateRefundAsync(
            int requestId,
            CancellationToken cancellationToken = default)
        {
            await _repository.CalculateRefundAsync(
                requestId,
                cancellationToken);
        }

        /// <summary>בקשות ממתינות לפקיד (Pending + Calculated).</summary>
        public async Task<IReadOnlyList<PendingRequestReadModel>> GetPendingRequestsForClerkAsync(
            CancellationToken cancellationToken = default)
        {
            return await _repository.GetPendingRequestsForClerkAsync(
                cancellationToken);
        }

        /// <summary>פרטי בקשה לפקיד – בקשה נוכחית, הכנסות, היסטוריה, תקציב.</summary>
        public async Task<ClerkRequestDetailsReadModel> GetRequestDetailsForClerkAsync(
            int requestId,
            CancellationToken cancellationToken = default)
        {
            return await _repository.GetRequestDetailsForClerkAsync(
                requestId,
                cancellationToken);
        }

        /// <summary>אישור או דחיית בקשת החזר.</summary>
        public async Task ApproveOrRejectRefundRequestAsync(
            int requestId,
            bool isApproved,
            decimal? approvedAmount,
            CancellationToken cancellationToken = default)
        {
            await _repository.ApproveOrRejectRefundRequestAsync(
                requestId,
                isApproved,
                approvedAmount,
                cancellationToken);
        }

        /// <summary>תצוגת אזרח – רשימת בקשות לפי ת.ז.</summary>
        public async Task<CitizenRequestViewReadModel?> GetCitizenRequestViewAsync(
            string identityNumber,
            CancellationToken cancellationToken = default)
        {
            return await _repository.GetCitizenRequestViewAsync(
                identityNumber,
                cancellationToken);
        }
    }
}