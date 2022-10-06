SELECT * 
FROM Production.Product

SELECT ProductID, Name, ProductNumber, Color, SafetyStockLevel 
FROM Production.Product

SELECT ProductID, Name, ProductNumber, Color 
FROM Production.Product 
WHERE Color = 'Silver'

SELECT ProductID, Name, ProductNumber, ListPrice 
FROM Production.Product 
WHERE ListPrice BETWEEN 100.00 AND 400.00 
ORDER BY ListPrice

--Data Definition Language (DDL):

USE master GO
CREATE DATABASE Company GO

USE Company 
GO

CREATE SCHEMA Dept 
GO

CREATE TABLE Dept.Department ( Department_Id INT PRIMARY KEY, Department_Name VARCHAR(30) ) 
GO

ALTER DATABASE Company MODIFY NAME = Company_Db

--Data Manipulation Language (DML):

 INSERT INTO Dept.Department (Department_Id, Department_Name) 
 VALUES 
	(1,'Marketing'), 
	(2,'Development'), 
	(3,'Sales'), 
	(4,'Human Resources'), 
	(5,'Customer Support'), 
	(6,'Project Management'), 
	(7,'Information Technology'), 
	(8,'Finance/Payroll'), 
	(9,'Research and Development') 
GO


UPDATE Dept.Department 
SET Department_Name = 'Accounting' 
WHERE Department_Id = 8

DELETE FROM Dept.Department 
WHERE Department_Id = 9 
GO

--Transforming Data
SELECT MIN(Prod_Total_Cost) AS 'Lowest Total' 
FROM Sales.Product_Sales

SELECT PS.Transaction_Id, PS.Product_Id, PS.Customer_Id, C.Customer_Name, PS.Quantity, PS.Prod_Total_Cost, PS.Date_Purchased 
FROM Sales.Product_Sales AS PS 
INNER JOIN Cust.Customers AS C 
ON PS.Customer_Id = C.Customer_Id

SELECT DISTINCT Prod_Total_Cost 
FROM Sales.Product_Sales

SELECT Sales.Product_Id ModuleId, Sales.Quantity 'Quantity Purchased', Sales.Prod_Total_Cost AS 'Total Cost' 
FROM Sales.Product_Sales AS Sales

CREATE PROCEDURE Sales.Quantity_Forecast @Quantity INT 
AS 
SELECT Transaction_Id, Product_Id, Unit_Price, Quantity, Prod_Total_Cost 
FROM Sales.Product_Sales 
WHERE Quantity >= @Quantity 

EXEC Sales.Quantity_Forecast 3

CREATE VIEW Sales.vwCurrentForecast 
AS 
SELECT Transaction_Id, Product_Id, Unit_Price, Quantity, Prod_Total_Cost, Customer_Id, Date_Purchased 
FROM Sales.Product_Sales 

SELECT * FROM Sales.vwCurrentForecast

SELECT TOP 10 Product_Id, Unit_Price, Quantity, Prod_Total_Cost, Customer_Id, Date_Purchased 
FROM Sales.Product_Sales 
ORDER BY Date_Purchased DESC

SELECT TOP 10 PS.Product_Id, PS.Unit_Price, PS.Quantity, PS.Prod_Total_Cost, C.Customer_Name, PS.Date_Purchased 
FROM Sales.Product_Sales AS PS 
INNER JOIN Cust.Customers AS C 
ON C.Customer_Id = PS.Customer_Id 
ORDER BY PS.Date_Purchased DESC

SELECT Product_Id, Quantity, Customer_Id, Supt_Pkg_Id, Prod_Total_Cost, Date_Purchased 
FROM Sales.Product_Sales 
WHERE Prod_Total_Cost = (SELECT MAX(Prod_Total_Cost) FROM Sales.Product_Sales)

SELECT Module_Name, Mod_Descr, CAST(Unit_Price AS INT) AS Module_Price, CONVERT(VARCHAR(11), Date_Modified, 0) AS Date_Modified 
FROM Prod.Products

SELECT Module_Name,Mod_Descr, Unit_Price 
FROM Prod.Products 
UNION 
SELECT Pkg_Name, Pkg_Descr, Pkg_Cost 
FROM Prod.Support_Packages

--Database Administration:
ALTER DATABASE Company_Db SET RECOVERY FULL GO

--Performing a backup of the database Company_Db to this location 
BACKUP DATABASE Company_Db TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backups\Company_Db.bak' 
GO

USE Company_Db GO

--Deleting data from the Sales.Product_Sales table 
DELETE FROM Sales.Product_Sales GO

--Verify that the data no longer exists here 
SELECT * FROM Sales.Product_Sales GO

--Use the master database first to close connection to Company_Db
USE master GO

--Sets the database to an inactive state in order to perform the restore
ALTER DATABASE Company_Db SET SINGLE_USER WITH ROLLBACK IMMEDIATE 
GO

--Restore the Company_Db database in full
RESTORE DATABASE Company_Db 
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backups\Company_Db.bak' WITH REPLACE, RECOVERY 
GO

--Sets the database back in an active state 
ALTER DATABASE Company_Db SET MULTI_USER GO

--Switching back in order to view the data from Sales. 
USE Company_Db GO

--Retrieving all data from Sales.Product_Sales 
SELECT *FROM Sales.Product_Sales GO

USE master GO
ALTER DATABASE AdventureWorks2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

EXEC sp_detach_db @dbname = 'AdventureWorks2012', @skipchecks = 'false' GO


CREATE DATABASE AdventureWorks2012 
ON (FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorks2012_Data.mdf') 
FOR ATTACH 
GO

--Logins, Users and Roles:
USE [master] 
GO

CREATE LOGIN [Server User] WITH PASSWORD = N'123456', DEFAULT_DATABASE = [master] 
GO

ALTER SERVER ROLE serveradmin ADD MEMBER [Server User] 
GO

USE [Company_Db] 
GO

CREATE USER [Server User] FOR LOGIN [Server User] 
GO

USE [Company_Db] 
GO

ALTER ROLE [db_datareader] ADD MEMBER [Server User] 
GO
