namespace RefundSystem.API.Dtos;

/// <summary>גוף בקשה להתחברות – תעודת זהות (POST login).</summary>
public sealed class LoginRequestDto
{
    /// <summary>תעודת זהות של המשתמש.</summary>
    public string IdentityNumber { get; set; } = string.Empty;
}

