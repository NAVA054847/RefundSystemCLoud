-- פרצדורה שמציגה לפקיד את כל הבקשות שממתינות לאישור שלו

CREATE PROCEDURE GetPendingRequestForClerk
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.Id AS RequestId,
        c.FullName,
        c.IdentityNumber,
        r.CalculatedAmount,
        r.CreatedAt,
        r.TaxYear,
        rs.Name AS Status
    FROM RefundRequests r
    INNER JOIN Citizens c ON r.CitizenId = c.Id
    INNER JOIN RequestStatuses rs ON r.StatusId = rs.Id
    WHERE rs.Name IN ('Pending', 'Calculated')
    ORDER BY r.CreatedAt;
END;
