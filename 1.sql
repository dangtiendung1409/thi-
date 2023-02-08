
CREATE DATABASE AZBank
GO

USE AZBank
GO

CREATE TABLE Customer(
	CustomerId int PRIMARY KEY NOT NULL,
	Name nvarchar(50),
	City nvarchar(50),
	Country nvarchar(50),
	Phone nvarchar(15),
	Email nvarchar(50)
)
GO

CREATE TABLE CustomerAccount(
	AccountNumber char(9) PRIMARY KEY NOT NULL,
	CustomerId int FOREIGN KEY REFERENCES Customer(CustomerId) NOT NULL,
	Balance money NOT NULL,
	MinAccount money
)
GO

CREATE TABLE CustomerTransaction(
	TransactionId int PRIMARY KEY NOT NULL,
	AccountNumber char(9),
	TransactionDate smalldatetime,
	Amount money,
	DepositorWithdraw bit
)
GO
ALTER TABLE CustomerTransaction
ADD CONSTRAINT add_FK_CT
FOREIGN KEY (AccountNumber) REFERENCES CustomerAccount(AccountNumber)
GO
--3
INSERT INTO Customer (CustomerId, Name, City, Country, Phone, Email)
VALUES (4, 'Dung', 'Hanoi', 'VN', '324-854-34787', 'dung@email.com'),
       (5, 'Long', 'Hanoi', 'VN', '859-905-63455', 'long@email.com'),
       (3, 'Hieu', 'Bacgiang', 'France', '111-222-3333', 'uauwf@email.com'),
	   (1, 'Quan', 'Hanam', 'USA', '123-456-7890', 'iuweuf@email.com'),
       (2, 'Nam', 'Hanoi', 'UK', '098-765-4321', 'ijwjfe@email.com')
GO

INSERT INTO CustomerAccount(AccountNumber, CustomerId, Balance, MinAccount)
VALUES (1000, 1, 10000, 1000),
       (2000, 2, 20000, 1500),
       (3000, 3, 30000, 2000)
GO

INSERT INTO CustomerTransaction (TransactionId, AccountNumber, TransactionDate, Amount, DepositorWithdraw)
VALUES (1, 1000, '2022-11-01 19:30', 500, 1),
       (2, 2000, '2022-9-02 18:00', 1000, 0),
       (3, 3000, '2022-1-03 17:45', 1500, 1)
GO

--4 

SELECT * FROM Customer
WHERE City ='Hanoi'
GO

--5

SELECT Name, Phone, Email, AccountNumber, Balance
FROM Customer c
join CustomerAccount ca on c.CustomerId = ca.CustomerId
GO

--6
ALTER TABLE CustomerTransaction
ADD CONSTRAINT check_amount 
CHECK (Amount > 0 AND Amount <= 1000000 )
GO

--7
CREATE NONCLUSTERED INDEX index_name
ON Customer (Name)
GO

--8
CREATE VIEW vCustomerTransactions
as
	SELECT name, ct.AccountNumber, TransactionDate, Amount, DepositorWithdraw
	FROM Customer c 
	Join CustomerAccount ca on c.CustomerId = ca.CustomerId
	join CustomerTransaction ct on ca.AccountNumber = ca.AccountNumber
GO

SELECT * FROM vCustomerTransactions
GO
--9
CREATE PROCEDURE spAddCustomer (@CustomerId int, @Name nvarchar(50), @Country nvarchar(50), @Phone nvarchar(15), @Email nvarchar(50))
AS
BEGIN
		INSERT INTO Customer (CustomerId, Name, Country, Phone, Email)
		VALUES (@CustomerId, @Name, @Country, @Phone, @Email)
END
GO

EXEC spAddCustomer 6, 'Hai', 'VN', '555-555-1212', 'sjhvs@email.com';
EXEC spAddCustomer 7, 'Binh', 'Canada', '555-555-1213', 'sjhvs@email.com';
EXEC spAddCustomer 8, 'Canh', 'USA', '555-555-1214', 'sjhhs@email.com';
GO
--10
CREATE PROCEDURE spGetTransactions (@AccountNumber int, @FromDate smalldatetime, @ToDate smalldatetime)
AS
BEGIN
    SELECT TransactionDate, Amount,
           CASE WHEN DepositorWithdraw = 1 
			   THEN 'Deposit' ELSE 'Withdraw' END AS TransactionType
    FROM CustomerTransaction
    WHERE AccountNumber = @AccountNumber
      AND TransactionDate BETWEEN @FromDate AND @ToDate
END
GO

EXEC spGetTransactions 1000, '2022-1-01', '2023-02-08'
GO