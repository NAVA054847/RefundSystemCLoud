namespace RefundSystem.Core.Interfaces;

/// <summary>תוצאת התחברות: תפקיד (פקיד/אזרח), מזהה, שם מלא.</summary>
public sealed record LoginResult(
    string Role,
    int Id,
    string FullName);

