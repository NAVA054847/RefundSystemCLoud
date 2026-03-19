namespace RefundSystem.API.Dtos;

/// <summary>תגובת התחברות – תפקיד, מזהה ושם מלא (מה שה-API מחזיר ללקוח).</summary>
public sealed class LoginResponseDto
{
    /// <summary>תפקיד: Clerk או Citizen.</summary>
    public string Role { get; set; } = string.Empty;

    /// <summary>מזהה הפקיד או האזרח.</summary>
    public int Id { get; set; }

    /// <summary>שם מלא.</summary>
    public string FullName { get; set; } = string.Empty;
}

