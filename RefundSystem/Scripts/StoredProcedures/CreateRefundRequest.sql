-- לא חלק מהדרישות נטו – בשביל שלבי הפיתוח
-- יצירת פרצדורה שיוצרת בקשת החזר ע"י אזרח

CREATE PROCEDURE CreateRefundRequest @CitizenId INT, @TaxYear INT AS

BEGIN

    SET NOCOUNT ON;

    -- בדיקה שאין בקשה קיימת לאותה שנת מס
    IF EXISTS (
        SELECT 1 FROM RefundRequests
        WHERE CitizenId = @CitizenId AND TaxYear = @TaxYear
    )
    BEGIN
        RAISERROR('בקשה לשנה זו כבר קיימת', 16, 1);
        RETURN;
    END

    -- יצירת בקשה חדשה עם סטטוס Pending
    INSERT INTO RefundRequests (CitizenId, TaxYear, StatusId)
    VALUES (
        @CitizenId,
        @TaxYear,
        (SELECT Id FROM RequestStatuses WHERE Name = 'Pending')
    );
END;
