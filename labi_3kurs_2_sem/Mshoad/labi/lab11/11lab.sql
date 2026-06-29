CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100),
    email NVARCHAR(100),
    created_at DATETIME DEFAULT GETDATE()
);

INSERT INTO users (name, email) VALUES
('Осадчий Павел', 'pavelO@example.com');

GO

CREATE FUNCTION get_user_email (@userId INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @email NVARCHAR(100);
    SELECT @email = email FROM users WHERE id = @userId;
    RETURN @email;
END;

GO

CREATE TRIGGER set_timestamp
ON users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE users
    SET created_at = GETDATE()
    FROM inserted
    WHERE users.id = inserted.id;
END;
