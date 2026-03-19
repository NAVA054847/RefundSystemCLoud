namespace RefundSystem.Core.ReadModels;

/// <summary>שורת בקשה ברשימת הממתינות לפקיד: פרטי אזרח, תאריך, שנת מס, סטטוס, סכום מחושב (אם יש).</summary>
public sealed record PendingRequestReadModel(
    int RequestId,
    string FullName,
    string IdentityNumber,
    decimal? CalculatedAmount,
    DateTime CreatedAt,
    int TaxYear,
    string Status);

