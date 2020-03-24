/*
	Northind ROLAP Bus Architecture
	By: Michael Fudge (mafudge@syr.edu)

	This script creates two conformed dimensional models in the northwind schema
		- FactSales
		- FactInventoryDailySnapshot			
	
	For use with the ETL Lab (SSIS) and OLAP Lab (SSAS)
	
	IMPORTANT: Execute this script in your data warehouse (dw) database
*/
-- Create the schema if it does not exist
IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'northwind')) 
BEGIN
    EXEC ('CREATE SCHEMA [northwind] AUTHORIZATION [dbo]')
	PRINT 'CREATE SCHEMA [northwind] AUTHORIZATION [dbo]'
END
go 
-- delete all the fact tables in the schema
DECLARE @fact_table_name varchar(100)
DECLARE cursor_loop CURSOR FAST_FORWARD READ_ONLY FOR 
	select TABLE_NAME from INFORMATION_SCHEMA.TABLES 
		where TABLE_SCHEMA='northwind' and TABLE_NAME like 'Fact%'
OPEN cursor_loop
FETCH NEXT FROM cursor_loop  INTO @fact_table_name
WHILE @@FETCH_STATUS= 0
BEGIN
	EXEC ('DROP TABLE [northwind].[' + @fact_table_name + ']')
	PRINT 'DROP TABLE [northwind].[' + @fact_table_name + ']'
	FETCH NEXT FROM cursor_loop  INTO @fact_table_name
END
CLOSE cursor_loop
DEALLOCATE cursor_loop
go
-- delete all the other tables in the schema
DECLARE @table_name varchar(100)
DECLARE cursor_loop CURSOR FAST_FORWARD READ_ONLY FOR 
	select TABLE_NAME from INFORMATION_SCHEMA.TABLES 
		where TABLE_SCHEMA='northwind' and TABLE_TYPE = 'BASE TABLE'
OPEN cursor_loop
FETCH NEXT FROM cursor_loop INTO @table_name
WHILE @@FETCH_STATUS= 0
BEGIN
	EXEC ('DROP TABLE [northwind].[' + @table_name + ']')
	PRINT 'DROP TABLE [northwind].[' + @table_name + ']'
	FETCH NEXT FROM cursor_loop  INTO @table_name
END
CLOSE cursor_loop
DEALLOCATE cursor_loop
go

-- Employee Dimension
PRINT 'CREATE TABLE northwind.DimEmployee'
CREATE TABLE northwind.DimEmployee (
   [EmployeeKey]  int IDENTITY  NOT NULL
   --attributes
,  [EmployeeID]  int   NOT NULL
,  [EmployeeName]  nvarchar(40)   NOT NULL
,  [EmployeeTitle]  nvarchar(30)   NOT NULL
,  [HireDateKey] int NULL
,  [SupervisorID]  int   NULL
,  [SupervisorName]  nvarchar(40)  NULL
,  [SupervsorTitle]  nvarchar(30)  NULL	
-- metadata
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [pkNorthwindDimEmployee] PRIMARY KEY ( [EmployeeKey] )
);

-- Customer Dimension
PRINT 'CREATE TABLE northwind.DimCustomer'
CREATE TABLE northwind.DimCustomer (
   [CustomerKey]  int IDENTITY  NOT NULL
   -- Attributes
,  [CustomerID]  nvarchar(5)   NOT NULL
,  [CompanyName]  nvarchar(40)   NOT NULL
,  [ContactName]  nvarchar(30)   NOT NULL
,  [ContactTitle]  nvarchar(30)   NOT NULL
,  [CustomerCountry]  nvarchar(15)   NOT NULL
,  [CustomerRegion]  nvarchar(15)  DEFAULT 'N/A' NOT NULL
,  [CustomerCity]  nvarchar(15)   NOT NULL
,  [CustomerPostalCode]  nvarchar(10)   NOT NULL
	-- metadata
,  [RowIsCurrent]  bit  DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT pkNorthwindDimCustomer PRIMARY KEY ( [CustomerKey] )
);


-- Product Dimension
PRINT 'CREATE TABLE northwind.DimProduct'
create table northwind.DimProduct
(
	ProductKey int identity not null,
	-- attributes
	ProductID int not null, 
	ProductName nvarchar(40) not null,
	Discontinued nchar(1) default('N') not null,
	SupplierName nvarchar(40) not null,
	CategoryName nvarchar(15) not null,
	-- metadata
	RowIsCurrent bit default(1) not null,
	RowStartDate datetime default('1/1/1900') not null,
	RowEndDate datetime default('12/31/9999') not null,
	RowChangeReason nvarchar(200) default ('N/A') not null,
	-- keys
	constraint pkNorthwindDimProductKey primary key (ProductKey),	
);

-- Supplier
PRINT 'CREATE TABLE northwind.DimSupplier'
create table northwind.DimSupplier
(
	SupplierKey int identity not null,
	-- attrivbutes
	SupplierID int not null,
	CompanyName nvarchar(40) not null,
	ContactName nvarchar(30) not null,
	ContactTitle nvarchar(30) not null,
	City nvarchar(15) not null,
	Region nvarchar(15) not null,
	Country nvarchar(15) not null,
	-- metadata
	RowIsCurrent bit default(1) not null,
	RowStartDate datetime default('1/1/1900') not null,
	RowEndDate datetime default('12/31/9999') not null,
	RowChangeReason nvarchar(200) default ('N/A') not null,
	-- keys
	constraint pkNorthwindDimSupplierKey primary key (SupplierKey),
);

-- date dimension
PRINT 'CREATE TABLE northwind.DimDate'
CREATE TABLE [northwind].[DimDate](
	[DateKey] [int] NOT NULL,
	[Date] [datetime] NULL,
	[FullDateUSA] [nchar](11) NOT NULL,
	[DayOfWeek] [tinyint] NOT NULL,
	[DayName] [nchar](10) NOT NULL,
	[DayOfMonth] [tinyint] NOT NULL,
	[DayOfYear] [int] NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[MonthName] [nchar](10) NOT NULL,
	[MonthOfYear] [tinyint] NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[QuarterName] [nchar](10) NOT NULL,
	[Year] [int] NOT NULL,
	[IsAWeekday] varchar(1) NOT NULL DEFAULT (('N')),
	constraint pkNorthwindDimDate PRIMARY KEY ([DateKey])
)

-- Periodic Snapshot for Inventory analysis
PRINT 'CREATE TABLE northwind.FactInventoryDailySnapshot'
create table northwind.FactInventoryDailySnapshot
(
	ProductKey int not null,
	SupplierKey int not null,
	DateKey int not null,
	-- facts
	UnitsInStock int not null,
	UnitsOnOrder int not null
	-- keys
	constraint pkNorthwindFactInventoryKey primary key (DateKey, ProductKey),

	constraint fkNorthwindFactInventoryProductKey foreign key (ProductKey) 
		references northwind.DimProduct(ProductKey),
	constraint fkNorthwindFactInventorySupplierKey foreign key (SupplierKey) 
		references northwind.DimSupplier(SupplierKey),
	constraint fkNorthwindFactInventoryDateKey foreign key (DateKey) 
		references northwind.DimDate(DateKey),
);

-- sales fact table
PRINT 'CREATE TABLE northwind.FactSales'
CREATE TABLE northwind.FactSales (
   [ProductKey]  int   NOT NULL
,  [OrderID]  int   NOT NULL
	-- dimensions
,  [CustomerKey]  int   NOT NULL
,  [EmployeeKey]  int   NOT NULL
,  [OrderDateKey]  int   NOT NULL
,  [ShippedDateKey]  int   NOT NULL
	-- facts
,  [Quantity]  smallint   NOT NULL
,  [ExtendedPriceAmount]  decimal(25,4) NOT NULL
,  [DiscountAmount]  decimal(25,4)  DEFAULT 0 NOT NULL
,  [SoldAmount]  decimal(25,4)  NOT NULL
,  [OrderToShippedLagInDays] smallint null
   --keys
, CONSTRAINT pkNorthwindFactSales PRIMARY KEY ( ProductKey, OrderID )
, CONSTRAINT fkNorthwindFactSalesProductKey FOREIGN KEY ( ProductKey )
	REFERENCES northwind.DimProduct (ProductKey)
, CONSTRAINT fkNorthwindFactSalesCustomerKey FOREIGN KEY ( CustomerKey )
	REFERENCES northwind.DimCustomer (CustomerKey)
, CONSTRAINT fkNorthwindFactSalesEmployeeKey FOREIGN KEY ( EmployeeKey )
	REFERENCES northwind.DimEmployee (EmployeeKey)
, CONSTRAINT fkNorthwindFactSalesOrderDateKey FOREIGN KEY (OrderDateKey )
	REFERENCES northwind.DimDate (DateKey)
, CONSTRAINT fkNorthwindFactSalesShippedDateKey FOREIGN KEY (ShippedDateKey )
	REFERENCES northwind.DimDate (DateKey)
) 
;

PRINT 'Insert special dimension values for null'
go
-- Unknown Customer
SET IDENTITY_INSERT [northwind].[DimCustomer] ON
go
INSERT INTO [northwind].[DimCustomer]
           ([CustomerKey]
		   ,[CustomerID]
           ,[CompanyName]
           ,[ContactName]
           ,[ContactTitle]
           ,[CustomerCountry]
           ,[CustomerRegion]
           ,[CustomerCity]
           ,[CustomerPostalCode])
     VALUES
           (-1
		   ,'UNK-1'
           ,'Unknown Company'
           ,'Unknown Contact'
           ,'Unknown Title'
           ,'None'
           ,'None'
           ,'None'
           ,'None')
GO
SET IDENTITY_INSERT [northwind].[DimCustomer] OFF
go
-- Unknown Date Value
INSERT INTO [northwind].[DimDate]
           ([DateKey]
           ,[Date]
           ,[FullDateUSA]
           ,[DayOfWeek]
           ,[DayName]
           ,[DayOfMonth]
           ,[DayOfYear]
           ,[WeekOfYear]
           ,[MonthName]
           ,[MonthOfYear]
           ,[Quarter]
           ,[QuarterName]
           ,[Year]
           ,[IsAWeekday])
     VALUES
           (-1
           ,null
           ,'Unknown'
           ,0
           ,'Unknown'
           ,0
           ,0
           ,0
           ,'Unknown'
           ,0
           ,0
           ,'Unknown'
           ,0
           ,'?')
GO
-- unknown Employee
SET IDENTITY_INSERT [northwind].[DimEmployee] ON
GO
INSERT INTO [northwind].[DimEmployee]
           ([EmployeeKey]
		   ,[EmployeeID]
           ,[EmployeeName]
           ,[EmployeeTitle]
           ,[HireDateKey]
           ,[SupervisorID]
           ,[SupervisorName]
           ,[SupervsorTitle])
     VALUES
           (-1
		   ,-1
           ,'Unknown'
           ,'Unknown'
           ,-1
           ,-1
           ,'Unknown'
           ,'Unknown')
GO
SET IDENTITY_INSERT [northwind].[DimEmployee] OFF
GO
USE [ist722_rtimbroo_dw]
GO
SET IDENTITY_INSERT [northwind].[DimProduct] ON
GO
INSERT INTO [northwind].[DimProduct]
           ([ProductKey]
		   ,[ProductID]
           ,[ProductName]
           ,[Discontinued]
           ,[SupplierName]
           ,[CategoryName])
     VALUES
           (-1
		   ,-1
           ,'Unknown'
           ,'?'
           ,'Unknown'
           ,'Unknown')
GO
SET IDENTITY_INSERT [northwind].[DimProduct] OFF
GO
USE [ist722_rtimbroo_dw]
GO
-- Default for Supplier
SET IDENTITY_INSERT [northwind].[DimSupplier] ON
GO
INSERT INTO [northwind].[DimSupplier]
           ([SupplierKey]
		   ,[SupplierID]
           ,[CompanyName]
           ,[ContactName]
           ,[ContactTitle]
           ,[City]
           ,[Region]
           ,[Country])
     VALUES
           (-1
		   ,-1
           ,'Unknown'
           ,'Unknown'
           ,'Unknown'
           ,'Unknown'
           ,'Unknown'
           ,'Unknown')
GO
SET IDENTITY_INSERT [northwind].[DimSupplier] OFF
GO
PRINT 'SCRIPT COMPLETE'
GO




