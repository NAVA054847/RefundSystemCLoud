using System;
using System.Collections.Generic;

namespace RefundSystem.Core.Entities;

public partial class Budget
{
    public int Id { get; set; }

    public int Year { get; set; }

    public byte Month { get; set; }

    public decimal TotalBudget { get; set; }

    public decimal UsedBudget { get; set; }

    public byte[] RowVersion { get; set; } = null!;
}
