-- יצירת מסד
CREATE DATABASE RefundSystemDB
GO

-- מעבר לשימוש במסד
USE RefundSystemDB
GO

-- יצירת יישות אזרח
CREATE TABLE Citizens (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdentityNumber NVARCHAR(20) NOT NULL UNIQUE,
    FullName NVARCHAR(100) NOT NULL
);

-- יצירת יישות של פקיד
CREATE TABLE Clerks (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdentityNumber NVARCHAR(9) NOT NULL,
    FullName NVARCHAR(100) NOT NULL
);

CREATE UNIQUE INDEX IX_Clerks_IdentityNumber
ON Clerks (IdentityNumber);

-- יצירת יישות הכנסה חודשית
CREATE TABLE MonthlyIncomes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CitizenId INT NOT NULL,
    TaxYear INT NOT NULL,
    [Month] TINYINT NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,

    CONSTRAINT FK_MonthlyIncomes_Citizens
        FOREIGN KEY (CitizenId) REFERENCES Citizens(Id),

    CONSTRAINT UQ_MonthlyIncome
        UNIQUE (CitizenId, TaxYear, [Month])
);

-- ייצירת יישות סטטוס בקשה
CREATE TABLE RequestStatuses (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

-- ייצירת יישות בקשת החזר
CREATE TABLE RefundRequests (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CitizenId INT NOT NULL,
    TaxYear INT NOT NULL,
    StatusId INT NOT NULL,
    CalculatedAmount DECIMAL(12,2) NULL,
    ApprovedAmount DECIMAL(12,2) NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    CalculatedAt DATETIME2 NULL,

    CONSTRAINT FK_RefundRequests_Citizens
        FOREIGN KEY (CitizenId) REFERENCES Citizens(Id),

    CONSTRAINT FK_RefundRequests_Status
        FOREIGN KEY (StatusId) REFERENCES RequestStatuses(Id),

    CONSTRAINT UQ_RefundRequests UNIQUE (CitizenId, TaxYear)
);

-- ייצירת יישות תקציב חודשי
CREATE TABLE Budgets (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    [Year] INT NOT NULL,
    [Month] TINYINT NOT NULL,
    TotalBudget DECIMAL(14,2) NOT NULL,
    UsedBudget DECIMAL(14,2) NOT NULL DEFAULT 0,

    RowVersion ROWVERSION,

    CONSTRAINT UQ_Budget UNIQUE ([Year], [Month])
);

-- הזנת נתונים ליישות סטטוס
INSERT INTO RequestStatuses (Name) VALUES ('Pending'), ('Calculated'), ('Approved'), ('Rejected');

-- הזנת נתונים ליישות של אזרח
INSERT INTO Citizens (IdentityNumber, FullName) VALUES
('123446789', 'יוסי כהן'),
('987654321', 'דנה לוי');

-- הזנת נתונים ליישות פקיד
INSERT INTO [RefundSystemDB].[dbo].[Clerks]
    ([IdentityNumber], [FullName])
VALUES
    ('999999999', N'פקידת ניסוי'),
    ('888888888', N'פקיד בדיקה');

-- הזנת נתונים ליישות של הכנסה חודשית
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

-- הזנת נתונים ליישות של בקשת החזר
INSERT INTO RefundRequests (CitizenId, TaxYear, StatusId, CalculatedAmount)
VALUES
    (1, 2024, (SELECT Id FROM RequestStatuses WHERE Name='Pending'), NULL),
    (2, 2024, (SELECT Id FROM RequestStatuses WHERE Name='Pending'), NULL);

-- הזנת נתונים ליישות תקציב חודשי
INSERT INTO Budgets ([Year],[Month], TotalBudget, UsedBudget) VALUES
(YEAR(GETDATE()), MONTH(GETDATE()), 15000, 0);
