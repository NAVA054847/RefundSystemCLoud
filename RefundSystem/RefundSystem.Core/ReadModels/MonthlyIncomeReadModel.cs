namespace RefundSystem.Core.ReadModels;

/// <summary>הכנסה חודשית אחת: שנת מס, חודש, סכום (להצגת הכנסות האזרח לפי שנה).</summary>
public sealed record MonthlyIncomeReadModel(
    int TaxYear,
    byte Month,
    decimal Amount);

