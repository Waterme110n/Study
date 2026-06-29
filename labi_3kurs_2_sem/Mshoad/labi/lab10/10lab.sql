SELECT * FROM sys.assemblies WHERE name = 'MyClrAssembly';
ALTER DATABASE MyDatabase SET TRUSTWORTHY ON;

CREATE ASSEMBLY MyClrAssembly
FROM 'C:\Users\user\source\repos\MyClrAssembly\MyClrAssembly\bin\Debug\MyClrAssembly.dll'
WITH PERMISSION_SET = UNSAFE;

DROP ASSEMBLY MyClrAssembly;
Drop procedure CopyFile;
DROP TYPE MyUserDefinedType;
Drop table Users

CREATE PROCEDURE CopyFile
    @sourcePath NVARCHAR(255),
    @destinationPath NVARCHAR(255)
AS EXTERNAL NAME MyClrAssembly.MyUserDefinedType.CopyFile;

EXEC CopyFile @sourcePath = 'C:\labi_3kurs_2_sem\Mshoad\123.txt', @destinationPath = 'C:\labi_3kurs_2_sem\Mshoad\12345.txt';


CREATE TYPE MyUserDefinedType EXTERNAL NAME MyClrAssembly.MyUserDefinedType;


CREATE TABLE Users (
    Id INT IDENTITY PRIMARY KEY,
    UserInfo MyUserDefinedType
);

INSERT INTO Users (UserInfo)
VALUES (MyUserDefinedType.Parse('123,123'));

select * from Users

CREATE FUNCTION dbo.GetUserInfoString (@userInfo MyUserDefinedType)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN @userInfo.ToString();
END

SELECT Id, dbo.GetUserInfoString(UserInfo) AS UserInfoString
FROM Users;