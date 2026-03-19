namespace RefundSystem.API.Dtos;

/// <summary>גוף בקשה ליצירת בקשת החזר – מזהה אזרח ושנת מס (POST ליצירת בקשה).</summary>
public sealed class CreateRefundRequestDto
{
    /// <summary>מזהה האזרח.</summary>
    public int CitizenId { get; set; }

    /// <summary>שנת המס.</summary>
    public int TaxYear { get; set; }
}

