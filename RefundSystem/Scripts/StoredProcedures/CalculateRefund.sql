-- יצירת פרצדורה שמחשבת זכאות להחזר

CREATE PROCEDURE [dbo].[CalculateRefund]
    @RequestId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- שליפת סטטוסים פעם אחת

        DECLARE 
            @StatusPendingId INT,
            @StatusApprovedId INT,
            @StatusCalculatedId INT;

        SELECT @StatusPendingId = Id 
        FROM RequestStatuses 
        WHERE Name = 'Pending';

        SELECT @StatusApprovedId = Id 
        FROM RequestStatuses 
        WHERE Name = 'Approved';

        SELECT @StatusCalculatedId = Id 
        FROM RequestStatuses 
        WHERE Name = 'Calculated';


        -- שליפת נתוני הבקשה פעם אחת

        DECLARE 
            @CitizenId INT,
            @TaxYear INT,
            @CurrentStatusId INT,
            @CalculatedAmount DECIMAL(12,2);

        SELECT 
            @CitizenId = CitizenId,
            @TaxYear = TaxYear,
            @CurrentStatusId = StatusId,
            @CalculatedAmount = CalculatedAmount
        FROM RefundRequests
        WHERE Id = @RequestId;

        IF @CitizenId IS NULL
        BEGIN
            RAISERROR('הבקשה לא קיימת',16,1);
            RETURN;
        END

        -- בדיקה שאין כבר בקשה מאושרת לאותה שנה
        IF EXISTS (
            SELECT 1
            FROM RefundRequests
            WHERE CitizenId = @CitizenId
              AND TaxYear = @TaxYear
              AND StatusId = @StatusApprovedId
        )
        BEGIN
            RAISERROR('כבר קיימת בקשה מאושרת לשנה זו',16,1);
            RETURN;
        END

        -- בדיקה שהבקשה במצב Pending

        IF @CurrentStatusId <> @StatusPendingId
        BEGIN
            RAISERROR('ניתן לחשב רק בקשה במצב Pending',16,1);
            RETURN;
        END

        -- בדיקת חודשי הכנסה + ממוצע 

        DECLARE 
            @MonthsCount INT,
            @AvgIncome DECIMAL(12,2);

        SELECT 
            @MonthsCount = COUNT(*),
            @AvgIncome = AVG(Amount)
        FROM MonthlyIncomes
        WHERE CitizenId = @CitizenId
          AND TaxYear = @TaxYear;

        IF @MonthsCount < 6
        BEGIN
            RAISERROR('לא קיימים מספיק חודשי הכנסה',16,1);
            RETURN;
        END


        -- חישוב החזר לפי מדרגות

        DECLARE @Refund DECIMAL(12,2) = 0;

        IF @AvgIncome <= 5000
            SET @Refund = @AvgIncome * 0.15;

        ELSE IF @AvgIncome <= 8000
            SET @Refund = (5000 * 0.15) 
                        + ((@AvgIncome - 5000) * 0.10);

        ELSE IF @AvgIncome <= 9000
            SET @Refund = (5000 * 0.15)
                        + (3000 * 0.10)
                        + ((@AvgIncome - 8000) * 0.05);


        -- עדכון הבקשה

        UPDATE RefundRequests
        SET CalculatedAmount = @Refund,
            CalculatedAt = GETDATE(),
            StatusId = @StatusCalculatedId
        WHERE Id = @RequestId;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH

END
GO
