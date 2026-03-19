-- פרצדורה שמקבלת תז ומחזירה את כל ההיסטוריה – מזמנת את GetCitizenRequestsHistory

CREATE PROCEDURE GetCitizenRequestView
    @IdentityNumber NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CitizenId INT;

    -- מציאת האזרח לפי ת"ז
    SELECT @CitizenId = Id
    FROM Citizens
    WHERE IdentityNumber = @IdentityNumber;

    -- אם לא נמצא אזרח – החזרת תוצאה ריקה
    IF @CitizenId IS NULL
    BEGIN
        RETURN;
    END

    -- החזרת כל הבקשות של האזרח
    -- ממוינות מהאחרונה לראשונה
    EXEC GetCitizenRequestsHistory @CitizenId;

END;
GO
