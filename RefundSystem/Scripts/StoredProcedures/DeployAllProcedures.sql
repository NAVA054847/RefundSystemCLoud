-- פריסת כל הפרוצדורות על SQL בענן
-- להריץ: sqlcmd -S 34.57.39.107,1433 -U refundadmin -P ... -d RefundSystemDB -i DeployAllProcedures.sql

USE RefundSystemDB;
GO

-- 1. GetCitizenRequestsHistory (נקראת ע"י אחרות)
IF OBJECT_ID('GetCitizenRequestsHistory', 'P') IS NOT NULL DROP PROCEDURE GetCitizenRequestsHistory;
GO
CREATE PROCEDURE GetCitizenRequestsHistory @CitizenId INT
AS BEGIN SET NOCOUNT ON;
    SELECT r.Id AS RequestId, r.TaxYear, r.CalculatedAmount, r.ApprovedAmount, rs.Name AS Status, r.CreatedAt
    FROM RefundRequests r INNER JOIN RequestStatuses rs ON r.StatusId = rs.Id
    WHERE r.CitizenId = @CitizenId ORDER BY r.CreatedAt DESC;
END;
GO

-- 2. GetCitizenRequestView
IF OBJECT_ID('GetCitizenRequestView', 'P') IS NOT NULL DROP PROCEDURE GetCitizenRequestView;
GO
CREATE PROCEDURE GetCitizenRequestView @IdentityNumber NVARCHAR(20)
AS BEGIN SET NOCOUNT ON;
    DECLARE @CitizenId INT;
    SELECT @CitizenId = Id FROM Citizens WHERE IdentityNumber = @IdentityNumber;
    IF @CitizenId IS NOT NULL EXEC GetCitizenRequestsHistory @CitizenId;
END;
GO

-- 3. GetRequestDetailsForClerk
IF OBJECT_ID('GetRequestDetailsForClerk', 'P') IS NOT NULL DROP PROCEDURE GetRequestDetailsForClerk;
GO
CREATE PROCEDURE [dbo].[GetRequestDetailsForClerk] @RequestId INT
AS BEGIN SET NOCOUNT ON;
    DECLARE @CitizenId INT, @TaxYear INT;
    SELECT @CitizenId = CitizenId, @TaxYear = TaxYear FROM RefundRequests WHERE Id = @RequestId;
    SELECT r.Id AS RequestId, r.TaxYear, r.CalculatedAmount, r.ApprovedAmount, rs.Name AS Status, r.CreatedAt
    FROM RefundRequests r INNER JOIN RequestStatuses rs ON r.StatusId = rs.Id WHERE r.Id = @RequestId;
    SELECT m.TaxYear, m.Month, m.Amount FROM MonthlyIncomes m
    WHERE m.CitizenId = @CitizenId AND m.TaxYear = @TaxYear ORDER BY m.Month;
    EXEC GetCitizenRequestsHistory @CitizenId;
    SELECT TotalBudget, UsedBudget, TotalBudget - UsedBudget AS AvailableBudget
    FROM Budgets WHERE [Year] = YEAR(GETDATE()) AND [Month] = MONTH(GETDATE());
END;
GO

-- 4. GetPendingRequestForClerk
IF OBJECT_ID('GetPendingRequestForClerk', 'P') IS NOT NULL DROP PROCEDURE GetPendingRequestForClerk;
GO
CREATE PROCEDURE GetPendingRequestForClerk
AS BEGIN SET NOCOUNT ON;
    SELECT r.Id AS RequestId, c.FullName, c.IdentityNumber, r.CalculatedAmount, r.CreatedAt, r.TaxYear, rs.Name AS Status
    FROM RefundRequests r INNER JOIN Citizens c ON r.CitizenId = c.Id INNER JOIN RequestStatuses rs ON r.StatusId = rs.Id
    WHERE rs.Name IN ('Pending', 'Calculated') ORDER BY r.CreatedAt;
END;
GO

-- 5. CreateRefundRequest
IF OBJECT_ID('CreateRefundRequest', 'P') IS NOT NULL DROP PROCEDURE CreateRefundRequest;
GO
CREATE PROCEDURE CreateRefundRequest @CitizenId INT, @TaxYear INT AS
BEGIN SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM RefundRequests WHERE CitizenId = @CitizenId AND TaxYear = @TaxYear)
    BEGIN RAISERROR('בקשה לשנה זו כבר קיימת', 16, 1); RETURN; END
    INSERT INTO RefundRequests (CitizenId, TaxYear, StatusId)
    VALUES (@CitizenId, @TaxYear, (SELECT Id FROM RequestStatuses WHERE Name = 'Pending'));
END;
GO

-- 6. CalculateRefund
IF OBJECT_ID('CalculateRefund', 'P') IS NOT NULL DROP PROCEDURE CalculateRefund;
GO
CREATE PROCEDURE [dbo].[CalculateRefund] @RequestId INT
AS BEGIN SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @StatusPendingId INT, @StatusApprovedId INT, @StatusCalculatedId INT;
        SELECT @StatusPendingId = Id FROM RequestStatuses WHERE Name = 'Pending';
        SELECT @StatusApprovedId = Id FROM RequestStatuses WHERE Name = 'Approved';
        SELECT @StatusCalculatedId = Id FROM RequestStatuses WHERE Name = 'Calculated';
        DECLARE @CitizenId INT, @TaxYear INT, @CurrentStatusId INT, @CalculatedAmount DECIMAL(12,2);
        SELECT @CitizenId = CitizenId, @TaxYear = TaxYear, @CurrentStatusId = StatusId, @CalculatedAmount = CalculatedAmount
        FROM RefundRequests WHERE Id = @RequestId;
        IF @CitizenId IS NULL BEGIN RAISERROR('הבקשה לא קיימת',16,1); RETURN; END
        IF EXISTS (SELECT 1 FROM RefundRequests WHERE CitizenId = @CitizenId AND TaxYear = @TaxYear AND StatusId = @StatusApprovedId)
        BEGIN RAISERROR('כבר קיימת בקשה מאושרת לשנה זו',16,1); RETURN; END
        IF @CurrentStatusId <> @StatusPendingId BEGIN RAISERROR('ניתן לחשב רק בקשה במצב Pending',16,1); RETURN; END
        DECLARE @MonthsCount INT, @AvgIncome DECIMAL(12,2);
        SELECT @MonthsCount = COUNT(*), @AvgIncome = AVG(Amount)
        FROM MonthlyIncomes WHERE CitizenId = @CitizenId AND TaxYear = @TaxYear;
        IF @MonthsCount < 6 BEGIN RAISERROR('לא קיימים מספיק חודשי הכנסה',16,1); RETURN; END
        DECLARE @Refund DECIMAL(12,2) = 0;
        IF @AvgIncome <= 5000 SET @Refund = @AvgIncome * 0.15;
        ELSE IF @AvgIncome <= 8000 SET @Refund = (5000 * 0.15) + ((@AvgIncome - 5000) * 0.10);
        ELSE IF @AvgIncome <= 9000 SET @Refund = (5000 * 0.15) + (3000 * 0.10) + ((@AvgIncome - 8000) * 0.05);
        UPDATE RefundRequests SET CalculatedAmount = @Refund, CalculatedAt = GETDATE(), StatusId = @StatusCalculatedId WHERE Id = @RequestId;
    END TRY
    BEGIN CATCH THROW; END CATCH
END;
GO

-- 7. ApproveOrRejectRefundRequest
IF OBJECT_ID('ApproveOrRejectRefundRequest', 'P') IS NOT NULL DROP PROCEDURE ApproveOrRejectRefundRequest;
GO
CREATE PROCEDURE ApproveOrRejectRefundRequest @RequestId INT, @IsApproved BIT, @ApprovedAmount DECIMAL(12,2) = NULL
AS BEGIN SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @StatusCalculatedId INT, @StatusApprovedId INT, @StatusRejectedId INT, @StatusPendingId INT;
        SELECT @StatusCalculatedId = MAX(CASE WHEN Name='Calculated' THEN Id END),
               @StatusApprovedId = MAX(CASE WHEN Name='Approved' THEN Id END),
               @StatusRejectedId = MAX(CASE WHEN Name='Rejected' THEN Id END),
               @StatusPendingId = MAX(CASE WHEN Name='Pending' THEN Id END)
        FROM RequestStatuses;
        DECLARE @CurrentStatusId INT, @CalculatedAmount DECIMAL(12,2);
        SELECT @CurrentStatusId = StatusId, @CalculatedAmount = CalculatedAmount
        FROM RefundRequests WITH (UPDLOCK, ROWLOCK) WHERE Id = @RequestId;
        IF @CurrentStatusId IS NULL BEGIN RAISERROR('הבקשה לא קיימת',16,1); ROLLBACK; RETURN; END
        IF @IsApproved = 0
        BEGIN
            IF @CurrentStatusId NOT IN (@StatusPendingId, @StatusCalculatedId)
            BEGIN RAISERROR('לא ניתן לדחות בקשה במצב זה',16,1); ROLLBACK; RETURN; END
            UPDATE RefundRequests SET StatusId = @StatusRejectedId, ApprovedAmount = 0 WHERE Id = @RequestId;
            COMMIT; RETURN;
        END
        IF @CurrentStatusId <> @StatusCalculatedId BEGIN RAISERROR('ניתן לאשר רק בקשה במצב Calculated',16,1); ROLLBACK; RETURN; END
        IF @ApprovedAmount IS NULL OR @ApprovedAmount <= 0 BEGIN RAISERROR('יש להזין סכום מאושר תקין',16,1); ROLLBACK; RETURN; END
        IF @ApprovedAmount > @CalculatedAmount BEGIN RAISERROR('לא ניתן לאשר סכום גבוה מהסכום המחושב',16,1); ROLLBACK; RETURN; END
        DECLARE @Year INT = YEAR(GETDATE()), @Month INT = MONTH(GETDATE()), @TotalBudget DECIMAL(14,2), @RowVersion VARBINARY(8);
        SELECT @TotalBudget = TotalBudget, @RowVersion = RowVersion FROM Budgets WHERE [Year] = @Year AND [Month] = @Month;
        IF @TotalBudget IS NULL BEGIN RAISERROR('לא קיים תקציב לחודש זה',16,1); ROLLBACK; RETURN; END
        UPDATE Budgets SET UsedBudget = UsedBudget + @ApprovedAmount
        WHERE [Year] = @Year AND [Month] = @Month AND RowVersion = @RowVersion AND (TotalBudget - UsedBudget) >= @ApprovedAmount;
        IF @@ROWCOUNT = 0 BEGIN RAISERROR('אין מספיק תקציב פנוי או שהתקציב עודכן על ידי משתמש אחר',16,1); ROLLBACK; RETURN; END
        UPDATE RefundRequests SET StatusId = @StatusApprovedId, ApprovedAmount = @ApprovedAmount
        WHERE Id = @RequestId AND StatusId = @StatusCalculatedId;
        IF @@ROWCOUNT = 0 BEGIN RAISERROR('הבקשה שונתה על ידי משתמש אחר.',16,1); ROLLBACK; RETURN; END
        COMMIT;
    END TRY
    BEGIN CATCH IF @@TRANCOUNT > 0 ROLLBACK; THROW; END CATCH
END;
GO

PRINT 'All stored procedures deployed successfully!';
