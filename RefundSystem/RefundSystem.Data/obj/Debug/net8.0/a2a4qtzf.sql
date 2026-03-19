IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [Budgets] (
    [Id] int NOT NULL IDENTITY,
    [Year] int NOT NULL,
    [Month] tinyint NOT NULL,
    [TotalBudget] decimal(14,2) NOT NULL,
    [UsedBudget] decimal(14,2) NOT NULL,
    [RowVersion] rowversion NOT NULL,
    CONSTRAINT [PK__Budgets__3214EC076E605BA9] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Citizens] (
    [Id] int NOT NULL IDENTITY,
    [IdentityNumber] nvarchar(20) NOT NULL,
    [FullName] nvarchar(100) NOT NULL,
    CONSTRAINT [PK__Citizens__3214EC0759D72142] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Clerks] (
    [Id] int NOT NULL IDENTITY,
    [IdentityNumber] nvarchar(9) NOT NULL,
    [FullName] nvarchar(100) NOT NULL,
    CONSTRAINT [PK__Clerks__3214EC07D29DFD59] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [RequestStatuses] (
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(50) NOT NULL,
    CONSTRAINT [PK__RequestS__3214EC07FC1C8A09] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [MonthlyIncomes] (
    [Id] int NOT NULL IDENTITY,
    [CitizenId] int NOT NULL,
    [TaxYear] int NOT NULL,
    [Month] tinyint NOT NULL,
    [Amount] decimal(12,2) NOT NULL,
    CONSTRAINT [PK__MonthlyI__3214EC0794180316] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_MonthlyIncomes_Citizens] FOREIGN KEY ([CitizenId]) REFERENCES [Citizens] ([Id])
);
GO

CREATE TABLE [RefundRequests] (
    [Id] int NOT NULL IDENTITY,
    [CitizenId] int NOT NULL,
    [TaxYear] int NOT NULL,
    [StatusId] int NOT NULL,
    [CalculatedAmount] decimal(12,2) NULL,
    [ApprovedAmount] decimal(12,2) NULL,
    [CreatedAt] datetime2 NOT NULL DEFAULT ((getdate())),
    [CalculatedAt] datetime2 NULL,
    CONSTRAINT [PK__RefundRe__3214EC074AC54EF6] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_RefundRequests_Citizens] FOREIGN KEY ([CitizenId]) REFERENCES [Citizens] ([Id]),
    CONSTRAINT [FK_RefundRequests_Status] FOREIGN KEY ([StatusId]) REFERENCES [RequestStatuses] ([Id])
);
GO

CREATE UNIQUE INDEX [UQ_Budget] ON [Budgets] ([Year], [Month]);
GO

CREATE UNIQUE INDEX [UQ__Citizens__6354A73F6DD81155] ON [Citizens] ([IdentityNumber]);
GO

CREATE UNIQUE INDEX [IX_Clerks_IdentityNumber] ON [Clerks] ([IdentityNumber]);
GO

CREATE UNIQUE INDEX [UQ_MonthlyIncome] ON [MonthlyIncomes] ([CitizenId], [TaxYear], [Month]);
GO

CREATE INDEX [IX_RefundRequests_StatusId] ON [RefundRequests] ([StatusId]);
GO

CREATE UNIQUE INDEX [UQ_RefundRequests] ON [RefundRequests] ([CitizenId], [TaxYear]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260310104425_InitialCreate', N'8.0.0');
GO

COMMIT;
GO

