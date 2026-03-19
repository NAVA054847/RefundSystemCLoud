-- פרצדורה שמציגה את כל הפרטים רלוונטים לקבלת החלטה של הנציג

CREATE PROCEDURE [dbo].[GetRequestDetailsForClerk]
    @RequestId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CitizenId INT;
    DECLARE @TaxYear INT;

    -- שליפה אחת בלבד של נתוני הבקשה
    SELECT 
        @CitizenId = CitizenId,
        @TaxYear = TaxYear
    FROM RefundRequests
    WHERE Id = @RequestId;


    -- פרטי הבקשה הנוכחית

    SELECT
        r.Id AS RequestId,
        r.TaxYear,
        r.CalculatedAmount,
        r.ApprovedAmount,
        rs.Name AS Status,
        r.CreatedAt
    FROM RefundRequests r
    INNER JOIN RequestStatuses rs ON r.StatusId = rs.Id
    WHERE r.Id = @RequestId;


    -- פרטי ההכנסות של האזרח לשנת הבקשה

    SELECT
        m.TaxYear,
        m.Month,
        m.Amount
    FROM MonthlyIncomes m
    WHERE m.CitizenId = @CitizenId
      AND m.TaxYear = @TaxYear
    ORDER BY m.Month;


    -- בקשות עבר של האזרח

    EXEC GetCitizenRequestsHistory @CitizenId;


    --  פרטי התקציב החודשי

    SELECT
        TotalBudget,
        UsedBudget,
        TotalBudget - UsedBudget AS AvailableBudget
    FROM Budgets
    WHERE [Year] = YEAR(GETDATE())
      AND [Month] = MONTH(GETDATE());

END;
GO
