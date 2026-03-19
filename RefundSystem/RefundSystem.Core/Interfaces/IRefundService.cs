using RefundSystem.Core.ReadModels;

namespace RefundSystem.Core.Interfaces
{
    /// <summary>ממשק שירות ההחזרים – חושף פעולות להחזרים ל-API (יצירה, חישוב, שליפות, אישור/דחייה).</summary>
    public interface IRefundService
    {
        /// <summary>יוצר בקשת החזר חדשה.</summary>
        Task CreateRefundRequestAsync(int citizenId, int taxYear, CancellationToken cancellationToken = default);
        /// <summary>מריץ חישוב זכאות לבקשה.</summary>
        Task CalculateRefundAsync(int requestId, CancellationToken cancellationToken = default);

        /// <summary>בקשות ממתינות לפקיד.</summary>
        Task<IReadOnlyList<PendingRequestReadModel>> GetPendingRequestsForClerkAsync(
            CancellationToken cancellationToken = default);

        /// <summary>פרטי בקשה לפקיד.</summary>
        Task<ClerkRequestDetailsReadModel> GetRequestDetailsForClerkAsync(
            int requestId,
            CancellationToken cancellationToken = default);

        /// <summary>אישור או דחיית בקשת החזר.</summary>
        Task ApproveOrRejectRefundRequestAsync(
            int requestId,
            bool isApproved,
            decimal? approvedAmount,
            CancellationToken cancellationToken = default);

        /// <summary>תצוגת אזרח לפי ת.ז.</summary>
        Task<CitizenRequestViewReadModel?> GetCitizenRequestViewAsync(
            string identityNumber,
            CancellationToken cancellationToken = default);
    }
}
