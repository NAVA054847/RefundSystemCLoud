using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RefundSystem.Data.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Budgets",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Year = table.Column<int>(type: "int", nullable: false),
                    Month = table.Column<byte>(type: "tinyint", nullable: false),
                    TotalBudget = table.Column<decimal>(type: "decimal(14,2)", nullable: false),
                    UsedBudget = table.Column<decimal>(type: "decimal(14,2)", nullable: false),
                    RowVersion = table.Column<byte[]>(type: "rowversion", rowVersion: true, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Budgets__3214EC076E605BA9", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Citizens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    IdentityNumber = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Citizens__3214EC0759D72142", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Clerks",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    IdentityNumber = table.Column<string>(type: "nvarchar(9)", maxLength: 9, nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Clerks__3214EC07D29DFD59", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "RequestStatuses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__RequestS__3214EC07FC1C8A09", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "MonthlyIncomes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CitizenId = table.Column<int>(type: "int", nullable: false),
                    TaxYear = table.Column<int>(type: "int", nullable: false),
                    Month = table.Column<byte>(type: "tinyint", nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(12,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__MonthlyI__3214EC0794180316", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MonthlyIncomes_Citizens",
                        column: x => x.CitizenId,
                        principalTable: "Citizens",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "RefundRequests",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CitizenId = table.Column<int>(type: "int", nullable: false),
                    TaxYear = table.Column<int>(type: "int", nullable: false),
                    StatusId = table.Column<int>(type: "int", nullable: false),
                    CalculatedAmount = table.Column<decimal>(type: "decimal(12,2)", nullable: true),
                    ApprovedAmount = table.Column<decimal>(type: "decimal(12,2)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())"),
                    CalculatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__RefundRe__3214EC074AC54EF6", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RefundRequests_Citizens",
                        column: x => x.CitizenId,
                        principalTable: "Citizens",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_RefundRequests_Status",
                        column: x => x.StatusId,
                        principalTable: "RequestStatuses",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "UQ_Budget",
                table: "Budgets",
                columns: new[] { "Year", "Month" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ__Citizens__6354A73F6DD81155",
                table: "Citizens",
                column: "IdentityNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Clerks_IdentityNumber",
                table: "Clerks",
                column: "IdentityNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ_MonthlyIncome",
                table: "MonthlyIncomes",
                columns: new[] { "CitizenId", "TaxYear", "Month" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RefundRequests_StatusId",
                table: "RefundRequests",
                column: "StatusId");

            migrationBuilder.CreateIndex(
                name: "UQ_RefundRequests",
                table: "RefundRequests",
                columns: new[] { "CitizenId", "TaxYear" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Budgets");

            migrationBuilder.DropTable(
                name: "Clerks");

            migrationBuilder.DropTable(
                name: "MonthlyIncomes");

            migrationBuilder.DropTable(
                name: "RefundRequests");

            migrationBuilder.DropTable(
                name: "Citizens");

            migrationBuilder.DropTable(
                name: "RequestStatuses");
        }
    }
}
