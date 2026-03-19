namespace RefundSystem.Core.Interfaces;

/// <summary>ממשק שירות ההתחברות – התחברות לפי תעודת זהות ומחזיר תפקיד ופרטים.</summary>
public interface IAuthService
{
    /// <summary>התחברות לפי ת.ז. – מחזיר פקיד או אזרח או null.</summary>
    Task<LoginResult?> LoginByIdentityNumberAsync(string identityNumber, CancellationToken cancellationToken = default);
}

