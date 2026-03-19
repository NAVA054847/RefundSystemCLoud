using Microsoft.EntityFrameworkCore;
using RefundSystem.Core.Entities;
using RefundSystem.Core.Interfaces;
using RefundSystem.Data.Context;

namespace RefundSystem.Data.Repository;

/// <summary>גישה לנתוני התחברות – שליפת פקיד או אזרח לפי תעודת זהות (EF Core).</summary>
public class AuthRepository : IAuthRepository
{
    private readonly RefundSystemDbContext _context;

    public AuthRepository(RefundSystemDbContext context)
    {
        _context = context;
    }

    /// <summary>מחזיר פקיד לפי ת.ז. או null.</summary>
    public async Task<Clerk?> GetClerkByIdentityNumberAsync(
        string identityNumber,
        CancellationToken cancellationToken = default)
    {
        return await _context.Clerks
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.IdentityNumber == identityNumber, cancellationToken);
    }

    /// <summary>מחזיר אזרח לפי ת.ז. או null.</summary>
    public async Task<Citizen?> GetCitizenByIdentityNumberAsync(
        string identityNumber,
        CancellationToken cancellationToken = default)
    {
        return await _context.Citizens
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.IdentityNumber == identityNumber, cancellationToken);
    }
}

