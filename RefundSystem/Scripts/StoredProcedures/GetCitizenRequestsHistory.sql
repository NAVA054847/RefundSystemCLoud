-- פרצדורה שמקבלת מזהה אזרח ומחזירה את היסטוריית הבקשות שלו

CREATE PROCEDURE GetCitizenRequestsHistory
    @CitizenId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.Id AS RequestId,
        r.TaxYear,
        r.CalculatedAmount,   -- גובה הזכאות שחושב
        r.ApprovedAmount,     -- הסכום שאושר בפועל
        rs.Name AS Status,    -- החלטת הפקיד
        r.CreatedAt
    FROM RefundRequests r
    INNER JOIN RequestStatuses rs ON r.StatusId = rs.Id
    WHERE r.CitizenId = @CitizenId
    ORDER BY r.CreatedAt DESC;

END;
