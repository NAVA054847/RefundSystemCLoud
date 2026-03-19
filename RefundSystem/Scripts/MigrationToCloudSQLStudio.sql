-- הרצה ב-Cloud SQL Studio על RefundSystemDB
-- GCP Console -> SQL -> refunddata -> Cloud SQL Studio

USE RefundSystemDB;
GO

-- טבלת היסטוריית migrations (חובה ל-EF Core)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = '__EFMigrationsHistory')
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END
GO

-- RequestStatuses
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestStatuses')
BEGIN
    CREATE TABLE [RequestStatuses] (
        [Id] int NOT NULL IDENTITY,
        [Name] nvarchar(50) NOT NULL,
        CONSTRAINT [PK__RequestS__3214EC07FC1C8A09] PRIMARY KEY ([Id])
    );
END
GO

-- Citizens
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Citizens')
BEGIN
    CREATE TABLE [Citizens] (
        [Id] int NOT NULL IDENTITY,
        [IdentityNumber] nvarchar(20) NOT NULL,
        [FullName] nvarchar(100) NOT NULL,
        CONSTRAINT [PK__Citizens__3214EC0759D72142] PRIMARY KEY ([Id])
    );
    CREATE UNIQUE INDEX [UQ__Citizens__6354A73F6DD81155] ON [Citizens] ([IdentityNumber]);
END
GO

-- Clerks
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Clerks')
BEGIN
    CREATE TABLE [Clerks] (
        [Id] int NOT NULL IDENTITY,
        [IdentityNumber] nvarchar(9) NOT NULL,
        [FullName] nvarchar(100) NOT NULL,
        CONSTRAINT [PK__Clerks__3214EC07D29DFD59] PRIMARY KEY ([Id])
    );
    CREATE UNIQUE INDEX [IX_Clerks_IdentityNumber] ON [Clerks] ([IdentityNumber]);
END
GO

-- Budgets
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Budgets')
BEGIN
    CREATE TABLE [Budgets] (
        [Id] int NOT NULL IDENTITY,
        [Year] int NOT NULL,
        [Month] tinyint NOT NULL,
        [TotalBudget] decimal(14,2) NOT NULL,
        [UsedBudget] decimal(14,2) NOT NULL DEFAULT 0,
        [RowVersion] rowversion NOT NULL,
        CONSTRAINT [PK__Budgets__3214EC076E605BA9] PRIMARY KEY ([Id])
    );
    CREATE UNIQUE INDEX [UQ_Budget] ON [Budgets] ([Year], [Month]);
END
GO

-- MonthlyIncomes
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MonthlyIncomes')
BEGIN
    CREATE TABLE [MonthlyIncomes] (
        [Id] int NOT NULL IDENTITY,
        [CitizenId] int NOT NULL,
        [TaxYear] int NOT NULL,
        [Month] tinyint NOT NULL,
        [Amount] decimal(12,2) NOT NULL,
        CONSTRAINT [PK__MonthlyI__3214EC0794180316] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_MonthlyIncomes_Citizens] FOREIGN KEY ([CitizenId]) REFERENCES [Citizens] ([Id])
    );
    CREATE UNIQUE INDEX [UQ_MonthlyIncome] ON [MonthlyIncomes] ([CitizenId], [TaxYear], [Month]);
END
GO

-- RefundRequests
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RefundRequests')
BEGIN
    CREATE TABLE [RefundRequests] (
        [Id] int NOT NULL IDENTITY,
        [CitizenId] int NOT NULL,
        [TaxYear] int NOT NULL,
        [StatusId] int NOT NULL,
        [CalculatedAmount] decimal(12,2) NULL,
        [ApprovedAmount] decimal(12,2) NULL,
        [CreatedAt] datetime2 NOT NULL DEFAULT (getdate()),
        [CalculatedAt] datetime2 NULL,
        CONSTRAINT [PK__RefundRe__3214EC074AC54EF6] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_RefundRequests_Citizens] FOREIGN KEY ([CitizenId]) REFERENCES [Citizens] ([Id]),
        CONSTRAINT [FK_RefundRequests_Status] FOREIGN KEY ([StatusId]) REFERENCES [RequestStatuses] ([Id])
    );
    CREATE INDEX [IX_RefundRequests_StatusId] ON [RefundRequests] ([StatusId]);
    CREATE UNIQUE INDEX [UQ_RefundRequests] ON [RefundRequests] ([CitizenId], [TaxYear]);
END
GO

-- רישום Migration ב-EF (כדי ש-EF לא ינסה להריץ שוב)
IF NOT EXISTS (SELECT * FROM [__EFMigrationsHistory] WHERE [MigrationId] = N'20260310104425_InitialCreate')
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260310104425_InitialCreate', N'8.0.0');
END
GO

PRINT 'Migration completed successfully!';
