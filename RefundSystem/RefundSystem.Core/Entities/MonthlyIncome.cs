using System;
using System.Collections.Generic;

namespace RefundSystem.Core.Entities;

public partial class MonthlyIncome
{
    public int Id { get; set; }

    public int CitizenId { get; set; }

    public int TaxYear { get; set; }

    public byte Month { get; set; }

    public decimal Amount { get; set; }

    public virtual Citizen Citizen { get; set; } = null!;
}
