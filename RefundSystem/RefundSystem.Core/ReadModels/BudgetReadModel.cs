namespace RefundSystem.Core.ReadModels;

/// <summary>תקציב חודשי: סה"כ, מנוצל, זמין (להצגה בצד מסך הפקיד).</summary>
public sealed record BudgetReadModel(
    decimal TotalBudget,
    decimal UsedBudget,
    decimal AvailableBudget);

