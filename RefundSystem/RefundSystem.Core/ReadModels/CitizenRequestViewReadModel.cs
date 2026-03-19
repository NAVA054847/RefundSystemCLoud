namespace RefundSystem.Core.ReadModels;

/// <summary>נתוני תצוגה לאזרח: רשימת כל הבקשות (ממוינות מהאחרונה לראשונה). האלמנט הראשון = הבקשה האחרונה.</summary>
public sealed record CitizenRequestViewReadModel(
    IReadOnlyList<RefundRequestSummaryReadModel> Requests);
