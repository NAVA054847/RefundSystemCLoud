using System;
using System.Collections.Generic;

namespace RefundSystem.Core.Entities;

public partial class Citizen
{
    public int Id { get; set; }

    public string IdentityNumber { get; set; } = null!;

    public string FullName { get; set; } = null!;

    public virtual ICollection<MonthlyIncome> MonthlyIncomes { get; set; } = new List<MonthlyIncome>();

    public virtual ICollection<RefundRequest> RefundRequests { get; set; } = new List<RefundRequest>();
}
