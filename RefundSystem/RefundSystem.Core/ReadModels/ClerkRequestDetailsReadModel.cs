namespace RefundSystem.Core.ReadModels;

/// <summary>נתוני מסך פרטי בקשה לפקיד: הבקשה הנוכחית, הכנסות לפי חודשים, היסטוריית בקשות, תקציב החודש.</summary>
public sealed record ClerkRequestDetailsReadModel(
    RefundRequestSummaryReadModel CurrentRequest,
    IReadOnlyList<MonthlyIncomeReadModel> Incomes,
    IReadOnlyList<RefundRequestSummaryReadModel> PastRequests,
    BudgetReadModel? CurrentMonthBudget);

