CREATE TABLE UserInteractions (
    InteractionID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    PostID INT NOT NULL,
    InteractionType VARCHAR(50) NOT NULL,
    InteractionDate DATETIME NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (PostID) REFERENCES Posts(PostID)
);

CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    UserName VARCHAR(100) NOT NULL,
    RegistrationDate DATETIME NOT NULL,
    Age INT,
    Gender VARCHAR(10)
);

CREATE TABLE Posts (
    PostID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    Content TEXT NOT NULL,
    PostDate DATETIME NOT NULL,
    Category VARCHAR(50),
	TimeID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
	FOREIGN KEY (TimeID) REFERENCES Time(TimeID)
);

CREATE TABLE Time (
    TimeID INT PRIMARY KEY IDENTITY(1,1),
    Date DATE NOT NULL,
    DayOfWeek VARCHAR(10),
    Month VARCHAR(20),
    Year INT,
    Quarter INT
);

INSERT INTO Users (UserName, RegistrationDate, Age, Gender) VALUES
('Alice', CAST(2023-01-15 AS DATETIME), 30, 'Female'),
('Bob', CAST(2023-02-20 AS DATETIME), 25, 'Male'),
('Charlie', CAST(2023-03-10 AS DATETIME), 28, 'Male');

select * from Users

INSERT INTO Time (Date, DayOfWeek, Month, Year, Quarter) VALUES
('2023-01-01', 'Sunday', 'January', 2023, 1),
('2023-01-02', 'Monday', 'January', 2023, 1),
('2023-02-01', 'Wednesday', 'February', 2023, 1),
('2023-02-15', 'Wednesday', 'February', 2023, 1),
('2023-03-01', 'Wednesday', 'March', 2023, 1);

INSERT INTO Posts (UserID, Content, PostDate, Category, TimeID) VALUES
(7, 'Hello World!', CAST(2023-01-16 AS datetime), 'General', 1),
(8, 'Learning SQL is fun!',  CAST(2023-02-21 AS datetime), 'Education', 3),
(9, 'MDX is powerful for data analysis.',  CAST(2023-03-11 AS datetime), 'Technology', 5),
(10, 'MDX is powerful for data analysis2.',  CAST(2023-03-12 AS datetime), 'Technology', 5);