using System.ComponentModel.DataAnnotations;

namespace RefundSystem.Core.Entities;

public partial class Clerk
{
    
    public int Id { get; set; }

 
    public string IdentityNumber { get; set; } = null!;

    
    public string FullName { get; set; } = null!;
}
