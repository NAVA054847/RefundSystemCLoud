using Microsoft.AspNetCore.Mvc;
using RefundSystem.API.Dtos;
using RefundSystem.Core.Interfaces;

namespace RefundSystem.API.Controllers;

/// <summary>בקר התחברות – מקבל ת.ז. ומחזיר תפקיד (פקיד/אזרח) ופרטים ללקוח.</summary>
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    /// <summary>התחברות: POST עם ת.ז. – מחזיר 200 עם Role, Id, FullName או 404 אם לא נמצא.</summary>
    [HttpPost("login")]
    public async Task<ActionResult<LoginResponseDto>> Login(
        [FromBody] LoginRequestDto dto,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(dto.IdentityNumber))
        {
            return BadRequest("IdentityNumber is required.");
        }

        var result = await _authService.LoginByIdentityNumberAsync(
            dto.IdentityNumber,
            cancellationToken);

        if (result is null)
        {
            return NotFound();
        }

        var response = new LoginResponseDto
        {
            Role = result.Role,
            Id = result.Id,
            FullName = result.FullName
        };

        return Ok(response);
    }
}

