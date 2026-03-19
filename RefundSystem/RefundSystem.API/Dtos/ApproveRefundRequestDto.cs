namespace RefundSystem.API.Dtos;

/// <summary>גוף בקשה לאישור או דחיית בקשת החזר (POST approve).</summary>
public sealed class ApproveRefundRequestDto
{
    /// <summary>מזהה הבקשה.</summary>
    public int RequestId { get; set; }

    /// <summary>true = אישור, false = דחייה.</summary>
    public bool IsApproved { get; set; }

    /// <summary>סכום מאושר – רלוונטי רק באישור; בדחייה null.</summary>
    public decimal? ApprovedAmount { get; set; }
}

