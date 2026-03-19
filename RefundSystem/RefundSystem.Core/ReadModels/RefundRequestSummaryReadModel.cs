namespace RefundSystem.Core.ReadModels;

/// <summary>סיכום בקשת החזר אחת: מזהה, שנת מס, סכום מחושב/אושר, סטטוס, תאריך. משמש ברשימות והיסטוריה.</summary>
public sealed record RefundRequestSummaryReadModel(
    int RequestId,
    int TaxYear,
    decimal? CalculatedAmount,
    decimal? ApprovedAmount,
    string Status,
    DateTime CreatedAt);

