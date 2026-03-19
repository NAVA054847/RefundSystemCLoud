using RefundSystem.Core.Interfaces;

namespace RefundSystem.Service.Services;

/// <summary>שיכבה לוגית להתחברות – בודקת ת.ז. ומחזירה תפקיד (פקיד/אזרח) ופרטים.</summary>
public class AuthService : IAuthService
{
    private readonly IAuthRepository _repository;

    public AuthService(IAuthRepository repository)
    {
        _repository = repository;
    }

    /// <summary>התחברות לפי תעודת זהות – קודם פקיד, אם לא אז אזרח. null אם לא נמצא.</summary>
    public async Task<LoginResult?> LoginByIdentityNumberAsync(
        string identityNumber,
        CancellationToken cancellationToken = default)
    {
        var clerk = await _repository.GetClerkByIdentityNumberAsync(identityNumber, cancellationToken);

        if (clerk is not null)
        {
            return new LoginResult(
                Role: "Clerk",
                Id: clerk.Id,
                FullName: clerk.FullName);
        }

        var citizen = await _repository.GetCitizenByIdentityNumberAsync(identityNumber, cancellationToken);

        if (citizen is not null)
        {
            return new LoginResult(
                Role: "Citizen",
                Id: citizen.Id,
                FullName: citizen.FullName);
        }

        return null;
    }
}

