-- פרצדורה לאישור/דחייה של בקשה ע"י פקיד

CREATE PROCEDURE ApproveOrRejectRefundRequest
(
    @RequestId INT,
    @IsApproved BIT,
    @ApprovedAmount DECIMAL(12,2) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        ----------------------------------------------------
        -- שלב 1: שליפת סטטוסים
        ----------------------------------------------------
        DECLARE 
            @StatusCalculatedId INT,
            @StatusApprovedId INT,
            @StatusRejectedId INT,
            @StatusPendingId INT;

        SELECT
            @StatusCalculatedId = MAX(CASE WHEN Name='Calculated' THEN Id END),
            @StatusApprovedId   = MAX(CASE WHEN Name='Approved'   THEN Id END),
            @StatusRejectedId   = MAX(CASE WHEN Name='Rejected'   THEN Id END),
            @StatusPendingId    = MAX(CASE WHEN Name='Pending'   THEN Id END)
        FROM RequestStatuses;

        ----------------------------------------------------
        -- שליפת הבקשה
        ----------------------------------------------------
        DECLARE 
            @CurrentStatusId INT,
            @CalculatedAmount DECIMAL(12,2);

        SELECT 
            @CurrentStatusId = StatusId,
            @CalculatedAmount = CalculatedAmount
        FROM RefundRequests WITH (UPDLOCK, ROWLOCK)
        WHERE Id = @RequestId;

        IF @CurrentStatusId IS NULL
        BEGIN
            RAISERROR('הבקשה לא קיימת',16,1);
            ROLLBACK;
            RETURN;
        END

        ----------------------------------------------------
        -- טיפול בדחייה
        ----------------------------------------------------
        IF @IsApproved = 0
        BEGIN
            IF @CurrentStatusId NOT IN (@StatusPendingId, @StatusCalculatedId)
            BEGIN
                RAISERROR('לא ניתן לדחות בקשה במצב זה',16,1);
                ROLLBACK;
                RETURN;
            END

            UPDATE RefundRequests
            SET StatusId = @StatusRejectedId,
                ApprovedAmount = 0
            WHERE Id = @RequestId;

            COMMIT;
            RETURN;
        END

        ----------------------------------------------------
        -- בדיקות אישור
        ----------------------------------------------------
        IF @CurrentStatusId <> @StatusCalculatedId
        BEGIN
            RAISERROR('ניתן לאשר רק בקשה במצב Calculated',16,1);
            ROLLBACK;
            RETURN;
        END

        IF @ApprovedAmount IS NULL OR @ApprovedAmount <= 0
        BEGIN
            RAISERROR('יש להזין סכום מאושר תקין',16,1);
            ROLLBACK;
            RETURN;
        END

        IF @ApprovedAmount > @CalculatedAmount
        BEGIN
            RAISERROR('לא ניתן לאשר סכום גבוה מהסכום המחושב',16,1);
            ROLLBACK;
            RETURN;
        END

        ----------------------------------------------------
        -- שלב 2: שליפת התקציב
        ----------------------------------------------------
        DECLARE 
            @Year INT = YEAR(GETDATE()),
            @Month INT = MONTH(GETDATE()),
            @TotalBudget DECIMAL(14,2),
            @RowVersion VARBINARY(8);

        SELECT 
            @TotalBudget = TotalBudget,
            @RowVersion = RowVersion
        FROM Budgets
        WHERE [Year] = @Year
          AND [Month] = @Month;

        IF @TotalBudget IS NULL
        BEGIN
            RAISERROR('לא קיים תקציב לחודש זה',16,1);
            ROLLBACK;
            RETURN;
        END

        ----------------------------------------------------
        -- עדכון התקציב (Atomic Update)
        ----------------------------------------------------
        UPDATE Budgets
        SET UsedBudget = UsedBudget + @ApprovedAmount
        WHERE [Year] = @Year
          AND [Month] = @Month
          AND RowVersion = @RowVersion
          AND (TotalBudget - UsedBudget) >= @ApprovedAmount;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('אין מספיק תקציב פנוי או שהתקציב עודכן על ידי משתמש אחר',16,1);
            ROLLBACK;
            RETURN;
        END

        ----------------------------------------------------
        -- עדכון הבקשה
        ----------------------------------------------------
        UPDATE RefundRequests
        SET StatusId = @StatusApprovedId,
            ApprovedAmount = @ApprovedAmount
        WHERE Id = @RequestId
          AND StatusId = @StatusCalculatedId;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('הבקשה שונתה על ידי משתמש אחר.',16,1);
            ROLLBACK;
            RETURN;
        END

        COMMIT;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH
END
