using System;
using System.Collections.Generic;

namespace RefundSystem.Core.Entities;

public partial class RequestStatus
{
    public int Id { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<RefundRequest> RefundRequests { get; set; } = new List<RefundRequest>();
}
