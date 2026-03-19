using RefundSystem.Core.Entities;

namespace RefundSystem.Core.Interfaces;

/// <summary>ממשק גישת נתונים להתחברות – שליפת פקיד או אזרח לפי תעודת זהות.</summary>
public interface IAuthRepository
{
    /// <summary>מחזיר פקיד לפי ת.ז. או null.</summary>
    Task<Clerk?> GetClerkByIdentityNumberAsync(string identityNumber, CancellationToken cancellationToken = default);

    /// <summary>מחזיר אזרח לפי ת.ז. או null.</summary>
    Task<Citizen?> GetCitizenByIdentityNumberAsync(string identityNumber, CancellationToken cancellationToken = default);
}

