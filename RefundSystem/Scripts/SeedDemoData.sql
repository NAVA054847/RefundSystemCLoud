
-- הזנת נתוני דמה – אזרחים, פקידים, הכנסות, בקשות, תקציב
-- להריץ אחרי CreateDatabase.sql (ולאחר יצירת הפרוצדורות אופציונלי)
-- מאפשר למי שבודק את הפרויקט להריץ ולוודא שהמערכת עובדת עם נתוני דמה


USE [RefundSystemDB];
GO

-- סטטוסי בקשה (אם עדיין ריק)
IF NOT EXISTS (SELECT 1 FROM RequestStatuses WHERE Name = N'Pending')
    INSERT INTO RequestStatuses (Name) VALUES (N'Pending'), (N'Calculated'), (N'Approved'), (N'Rejected');

-- אזרחים
IF NOT EXISTS (SELECT 1 FROM Citizens WHERE IdentityNumber = N'123446789')
    INSERT INTO Citizens (IdentityNumber, FullName) VALUES
    (N'123446789', N'יוסי כהן'),
    (N'987654321', N'דנה לוי');

-- פקידים
IF NOT EXISTS (SELECT 1 FROM Clerks WHERE IdentityNumber = N'999999999')
    INSERT INTO Clerks (IdentityNumber, FullName) VALUES
    (N'999999999', N'פקידת ניסוי'),
    (N'888888888', N'פקיד בדיקה');

-- הכנסות חודשיות (אזרח 1 ואזרח 2 – 2024)
IF NOT EXISTS (SELECT 1 FROM MonthlyIncomes WHERE CitizenId = 1 AND TaxYear = 2024 AND [Month] = 1)
BEGIN
    INSERT INTO MonthlyIncomes (CitizenId, TaxYear, [Month], Amount) VALUES
    (1, 2024, 1, 4000),
    (1, 2024, 2, 5000),
    (1, 2024, 3, 4500),
    (1, 2024, 4, 4800),
    (1, 2024, 5, 5200),
    (1, 2024, 6, 4700),
    (2, 2024, 1, 9000),
    (2, 2024, 2, 9500),
    (2, 2024, 3, 10000),
    (2, 2024, 4, 11000),
    (2, 2024, 5, 10500),
    (2, 2024, 6, 10200);
END

-- בקשות החזר (סטטוס Pending)
IF NOT EXISTS (SELECT 1 FROM RefundRequests WHERE CitizenId = 1 AND TaxYear = 2024)
    INSERT INTO RefundRequests (CitizenId, TaxYear, StatusId, CalculatedAmount)
    VALUES
        (1, 2024, (SELECT Id FROM RequestStatuses WHERE Name = N'Pending'), NULL),
        (2, 2024, (SELECT Id FROM RequestStatuses WHERE Name = N'Pending'), NULL);

-- תקציב חודש נוכחי
IF NOT EXISTS (SELECT 1 FROM Budgets WHERE [Year] = YEAR(GETDATE()) AND [Month] = MONTH(GETDATE()))
    INSERT INTO Budgets ([Year], [Month], TotalBudget, UsedBudget)
    VALUES (YEAR(GETDATE()), MONTH(GETDATE()), 15000, 0);

GO
