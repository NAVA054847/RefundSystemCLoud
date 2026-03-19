using Microsoft.EntityFrameworkCore;
using RefundSystem.Core.Entities;
using RefundSystem.Core.ReadModels;

namespace RefundSystem.Data.Context;

public partial class RefundSystemDbContext : DbContext
{
    public RefundSystemDbContext()
    {
    }

    public RefundSystemDbContext(DbContextOptions<RefundSystemDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Budget> Budgets { get; set; }

    public virtual DbSet<Citizen> Citizens { get; set; }

    public virtual DbSet<Clerk> Clerks { get; set; }

    public virtual DbSet<MonthlyIncome> MonthlyIncomes { get; set; }

    public virtual DbSet<RefundRequest> RefundRequests { get; set; }

    public virtual DbSet<RequestStatus> RequestStatuses { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<PendingRequestReadModel>(entity =>
        {
            entity.HasNoKey();
            entity.ToView(null);
            entity.Property(e => e.CalculatedAmount).HasPrecision(12, 2);
        });

        modelBuilder.Entity<Clerk>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Clerks__3214EC07D29DFD59");

            entity.Property(e => e.IdentityNumber).HasMaxLength(9);
            entity.Property(e => e.FullName).HasMaxLength(100);

            entity.HasIndex(e => e.IdentityNumber, "IX_Clerks_IdentityNumber").IsUnique();
        });

        modelBuilder.Entity<Budget>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Budgets__3214EC076E605BA9");

            entity.HasIndex(e => new { e.Year, e.Month }, "UQ_Budget").IsUnique();

            entity.Property(e => e.RowVersion)
                .IsRowVersion()
                .IsConcurrencyToken();
            entity.Property(e => e.TotalBudget).HasColumnType("decimal(14, 2)");
            entity.Property(e => e.UsedBudget).HasColumnType("decimal(14, 2)");
        });

        modelBuilder.Entity<Citizen>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Citizens__3214EC0759D72142");

            entity.HasIndex(e => e.IdentityNumber, "UQ__Citizens__6354A73F6DD81155").IsUnique();

            entity.Property(e => e.FullName).HasMaxLength(100);
            entity.Property(e => e.IdentityNumber).HasMaxLength(20);
        });

        modelBuilder.Entity<MonthlyIncome>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__MonthlyI__3214EC0794180316");

            entity.HasIndex(e => new { e.CitizenId, e.TaxYear, e.Month }, "UQ_MonthlyIncome").IsUnique();

            entity.Property(e => e.Amount).HasColumnType("decimal(12, 2)");

            entity.HasOne(d => d.Citizen).WithMany(p => p.MonthlyIncomes)
                .HasForeignKey(d => d.CitizenId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_MonthlyIncomes_Citizens");
        });

        modelBuilder.Entity<RefundRequest>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__RefundRe__3214EC074AC54EF6");

            entity.HasIndex(e => new { e.CitizenId, e.TaxYear }, "UQ_RefundRequests").IsUnique();

            entity.Property(e => e.ApprovedAmount).HasColumnType("decimal(12, 2)");
            entity.Property(e => e.CalculatedAmount).HasColumnType("decimal(12, 2)");
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Citizen).WithMany(p => p.RefundRequests)
                .HasForeignKey(d => d.CitizenId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RefundRequests_Citizens");

            entity.HasOne(d => d.Status).WithMany(p => p.RefundRequests)
                .HasForeignKey(d => d.StatusId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RefundRequests_Status");
        });

        modelBuilder.Entity<RequestStatus>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__RequestS__3214EC07FC1C8A09");

            entity.Property(e => e.Name).HasMaxLength(50);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
