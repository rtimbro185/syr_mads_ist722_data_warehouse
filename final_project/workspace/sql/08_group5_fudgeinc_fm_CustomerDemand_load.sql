/*
Course: IST 722 Data Warehouse
Assignment: Group 5 - Final Project - Implementing Dimensional Models
Author: Ryan Timbrook
NetID: RTIMBROO
Date: 2/28/2020

Objective:
Step 3: 
Finally, load the data. 
	a. 

Load From Stage Into the Data Warehouse
** Note: Document findings along the way. This will be used for planning out the ETL process in the next steps.
For example, if you need to combine two columns into one or replace NULL with a value, then this will need to happen in the ETL tooling.

Processes for loading data into the dimension tables:
1. Identify the requirements of the dimension
2. Write a select statement using the staged data to source the dimension
3. Create an INSERT INTO ... SELECT statement to populate the data


** Star Schema Details **
** Star Schema Details **
Source System: 			fudgemart_v3
Business Process: 	Customer Demand Analysis
Fact Table:		  		FactFmCustomerDemand
Fact Grain Type:  	
Granularity:	  	
Facts:            

Target Dimensions:
	 -DimFmCustomers
	 -DimFmProducts
	 -DimFmCustomerProductReviews
	 -DimFmOrders
	 -FactFmCustomerDemand
*/

-- DECLARE CONFIG VARIABLES --

-- IN SQL Server Manager Studio - Under 'Query' select SQLCMD Mode - to utilize command line variables for configurations
-- DATABASE CONFIGURATIONS -- UNCOMMENT ONLY ONE DATABASE
--                           
--:setvar use_database ist722_rtimbroo_dw         -- my local development DW database
--:setvar use_database ist722_rtimbroo_stage    -- my local development STAGE database
--:setvar use_database ist722_grblock_oa5_dw    -- group 5 common DW database
--:setvar use_database ist722_grblock_oa5_stage -- group 5 common STAGE database
--print(N'$(use_database)')
:setvar stage_db ist722_rtimbroo_stage
:setvar dw_db ist722_rtimbroo_dw
--

-- SCHEMA CONFIGURATIONS -- UNCOMMENT ONLY ONE SCHEMA
--
:setvar use_schema dev_fudgeinc       -- development schema
--:setvar use_schema test_fudgeinc			-- testing/validation schema
--:setvar use_schema fudgeinc						-- production schema
print(N'$(use_schema)')

-- #################################################### --

-- STEP 1: DROP VIEWS IF THEY EXIST --




-- STEP 2: DROP TABLES IF THEY EXIST --
---------------------------------------
USE $(dw_db)
GO
/* Drop table fudgeinc.FactFmCustomerDemand */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).FactFmCustomerDemand') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).FactFmCustomerDemand 
;

/* Drop table fudgeinc.DimFmCustomers */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).DimFmCustomers') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).DimFmCustomers 
;

/* Drop table fudgeinc.DimFmCustomerProductReviews */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).DimFmCustomerProductReviews') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).DimFmCustomerProductReviews 
;

/* Drop table fudgeinc.DimFmOrders */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).DimFmOrders') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).DimFmOrders 
;

/* Drop table fudgeinc.DimFmProducts */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).DimFmProducts') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).DimFmProducts 
;



-- STEP 5: CREAT TABLES  --
---------------------------

/* Create table fudgeinc.DimFmCustomers */
CREATE TABLE $(use_schema).DimFmCustomers (
   [CustomerKey]  int IDENTITY  NOT NULL
,  [CustomerID]  int   NOT NULL
,  [FirstName]  varchar(50)   NOT NULL
,  [LastName]  varchar(50)   NOT NULL
,  [FullName]  varchar(50)   NOT NULL
,  [CustomerAliasName]  varchar(100)   NOT NULL
,  [Email]  varchar(100)   NOT NULL
,  [Phone]  varchar(30)   NOT NULL
,  [CustomerCity]  varchar(50)   NOT NULL
,  [CustomerState]  char(2)   NOT NULL
,  [CustomerZipCode]  varchar(20)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_$(use_schema).DimFmCustomers] PRIMARY KEY CLUSTERED 
( [CustomerKey] )
) ON [PRIMARY]
;

SET IDENTITY_INSERT $(use_schema).DimFmCustomers ON
;
INSERT INTO $(use_schema).DimFmCustomers (CustomerKey, CustomerID, FirstName, LastName, FullName, CustomerAliasName, Email, Phone, CustomerCity, CustomerState, CustomerZipCode, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'None', 'None', 'None', 'None', 'None', 'None', 'None', 'NA', 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT $(use_schema).DimFmCustomers OFF
;

/* Create table fudgeinc.DimFmCustomerProductReviews */
CREATE TABLE $(use_schema).DimFmCustomerProductReviews (
   [CustomerProductReviewKey]  int IDENTITY  NOT NULL
,  [CustomerID]  int   NOT NULL
,  [CustomerFullName]  varchar(50)   NOT NULL
,  [CustomerAliasName]  varchar(100)   NOT NULL
,  [ProductID]  int   NOT NULL
,  [ProductName]  varchar(50)   NOT NULL
,  [ReviewDateKey]  int   NOT NULL
,  [ReviewStars]  int   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_$(use_schema).DimFmCustomerProductReviews] PRIMARY KEY CLUSTERED 
( [CustomerProductReviewKey] )
) ON [PRIMARY]
;

SET IDENTITY_INSERT $(use_schema).DimFmCustomerProductReviews ON
;
INSERT INTO $(use_schema).DimFmCustomerProductReviews (CustomerProductReviewKey, CustomerID, CustomerFullName, CustomerAliasName, ProductID, ProductName, ReviewDateKey, ReviewStars, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'None','None', -1, 'None', -1, 0, 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT $(use_schema).DimFmCustomerProductReviews OFF
;

/* Create table fudgeinc.DimFmOrders */
CREATE TABLE $(use_schema).DimFmOrders (
   [OrderKey]  int IDENTITY  NOT NULL
,  [OrderID]  int   NOT NULL
,  [CustomerID]  int   NOT NULL
,  [CustomerFullName]  varchar(50)   NOT NULL
,  [CustomerAliasName]  varchar(100)   NOT NULL
,  [OrderDateKey]  int   NOT NULL
,  [ShippedDateKey]  int   NOT NULL
,  [ShippingCompanyName]  varchar(20)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_$(use_schema).DimFmOrders] PRIMARY KEY CLUSTERED 
( [OrderKey] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT $(use_schema).DimFmOrders ON
;
INSERT INTO $(use_schema).DimFmOrders (OrderKey, OrderID, CustomerID, CustomerFullName,CustomerAliasName, OrderDateKey, ShippedDateKey, ShippingCompanyName, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 0, 'None','None', -1, -1, 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT $(use_schema).DimFmOrders OFF
;

/* Create table fudgeinc.DimFmProducts */
CREATE TABLE $(use_schema).DimFmProducts (
   [ProductKey]  int IDENTITY  NOT NULL
,  [ProductID]  int   NOT NULL
,  [ProductDepartment]  varchar(20)   NOT NULL
,  [ProductName]  varchar(50)   NOT NULL
,  [RetailPrice]  decimal(25,2)   NOT NULL
,  [WholesalePrice]  decimal(25,2)   NOT NULL
,  [IsProductActive]  nchar(1)   NOT NULL
,  [ProductLiveDateKey]  int   NOT NULL
,  [VendorName]  varchar(50)   NOT NULL
,  [VendorPhone]  varchar(20)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_$(use_schema).DimFmProducts] PRIMARY KEY CLUSTERED 
( [ProductKey] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT $(use_schema).DimFmProducts ON
;
INSERT INTO $(use_schema).DimFmProducts (ProductKey, ProductID, ProductDepartment, ProductName, RetailPrice, WholesalePrice, IsProductActive, ProductLiveDateKey, VendorName, VendorPhone, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'None', 'None', 0, 0, 'N', -1, 'None', 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT $(use_schema).DimFmProducts OFF
;


/* Create table fudgeinc.FactFmCustomerDemand */
CREATE TABLE $(use_schema).FactFmCustomerDemand (
   [ProductKey]  int   NOT NULL
,  [CustomerKey]  int   NOT NULL
,  [OrderID]  int   NOT NULL
,  [OrderDateKey]  int   NOT NULL
,  [ShippedDateKey]  int   NULL
,  [OrderQuantity]  int   NOT NULL
,  [ProductRetailPrice]  decimal(25,2)   NOT NULL
,  [ProductWholesalePrice]  decimal(25,2)   NOT NULL
,  [ProductProfitMargin]  decimal(25,2)   NOT NULL
,  [ProductLiveDateKey]  int   NOT NULL
,	 [ProductReviewAvgScore] decimal(3,2) NOT NULL
,	 [ProductReviewCount] int NOT NULL
, CONSTRAINT [PK_$(use_schema).FactFmCustomerDemand] PRIMARY KEY NONCLUSTERED 
( [ProductKey], [OrderID] )
) ON [PRIMARY]
;


-- STEP 6: ADD TABLE CONSTRAINTS  --

ALTER TABLE $(use_schema).DimFmCustomerProductReviews ADD CONSTRAINT
   FK_$(use_schema)_DimFmCustomerProductReviews_ReviewDateKey FOREIGN KEY
   (
   ReviewDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;

ALTER TABLE $(use_schema).DimFmOrders ADD CONSTRAINT
   FK_$(use_schema)_DimFmOrders_OrderDateKey FOREIGN KEY
   (
   OrderDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).DimFmOrders ADD CONSTRAINT
   FK_$(use_schema)_DimFmOrders_ShippedDateKey FOREIGN KEY
   (
   ShippedDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).DimFmProducts ADD CONSTRAINT
   FK_$(use_schema)_DimFmProducts_ProductLiveDateKey FOREIGN KEY
   (
   ProductLiveDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;


ALTER TABLE $(use_schema).FactFmCustomerDemand ADD CONSTRAINT
   FK_$(use_schema)_FactFmCustomerDemand_ProductKey FOREIGN KEY
   (
   ProductKey
   ) REFERENCES $(use_schema).DimFmProducts
   ( ProductKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).FactFmCustomerDemand ADD CONSTRAINT
   FK_$(use_schema)_FactFmCustomerDemand_CustomerKey FOREIGN KEY
   (
   CustomerKey
   ) REFERENCES $(use_schema).DimFmCustomers
   ( CustomerKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).FactFmCustomerDemand ADD CONSTRAINT
   FK_$(use_schema)_FactFmCustomerDemand_OrderDateKey FOREIGN KEY
   (
   OrderDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).FactFmCustomerDemand ADD CONSTRAINT
   FK_$(use_schema)_FactFmCustomerDemand_ShippedDateKey FOREIGN KEY
   (
   ShippedDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).FactFmCustomerDemand ADD CONSTRAINT
   FK_$(use_schema)_FactFmCustomerDemand_ProductLiveDateKey FOREIGN KEY
   (
   ProductLiveDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;



/*--------------- LOAD DIMENSION Tables ----------------------------------------- */
-----------------------------------------------------------------------------------

/* Load Dimension table fudgeinc.DimFmCustomers */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[DimFmCustomers]
	(
		[CustomerID]
	  ,[FirstName]
	  ,[LastName]
	  ,[FullName]
	  ,[CustomerAliasName]
	  ,[Email]
	  ,[Phone]
	  ,[CustomerCity]
	  ,[CustomerState]
	  ,[CustomerZipCode]
	)
	SELECT 
			[CustomerID]
      ,[FirstName]
      ,[LastName]
      ,[FullName]
      ,[CustomerAliasName]
      ,[Email]
      ,[Phone]
      ,[CustomerCity]
      ,[CustomerState]
      ,[CustomerZip]
FROM $(stage_db).$(use_schema).[StgFmCustomers]

SELECT TOP(10) * FROM $(dw_db).$(use_schema).[DimFmCustomers];
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

/* Load Dimension table fudgeinc.DimFmProducts */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[DimFmProducts]
	(
			[ProductID]
      ,[ProductDepartment]
      ,[ProductName]
      ,[RetailPrice]
      ,[WholesalePrice]
      ,[IsProductActive]
      ,[ProductLiveDateKey]
      ,[VendorName]
      ,[VendorPhone]
	)
	SELECT 
			 [ProductID]
      ,[ProductDepartment]
      ,[ProductName]
      ,ROUND(CAST([RetailPrice]+0.00 as decimal(25,2)),2) as [RetailPrice]
      ,ROUND(CAST([WholesalePrice]+0.00 as decimal(25,2)),2) as [WholesalePrice]
    ,case when [IsProductActive] = 0 then 'N' else 'Y' end
      ,case when [ExternalSources2].[dbo].[getDateKey](ProductLiveDate) is null then -1
				else [ExternalSources2].[dbo].[getDateKey](ProductLiveDate) end as [ProductLiveDate]
      ,[VendorName]
      ,[VendorPhone]
FROM $(stage_db).$(use_schema).[StgFmProducts]

SELECT TOP(10) * FROM $(dw_db).$(use_schema).[DimFmProducts];
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


/* Load Dimension table fudgeinc.DimFmCustomerProductReviews */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[DimFmCustomerProductReviews]
	(
			[CustomerID]
      ,[CustomerFullName]
      ,[CustomerAliasName]
      ,[ProductID]
      ,[ProductName]
      ,[ReviewDateKey]
      ,[ReviewStars]
	)
	SELECT 
			[CustomerID]
      ,[CustomerFullName]
      ,[CustomerAliasName]
      ,[ProductID]
      ,[ProductName]
      ,case when [ExternalSources2].[dbo].[getDateKey](ReviewDate) is null then -1
				else [ExternalSources2].[dbo].[getDateKey](ReviewDate) end as [ReviewDateKey]
      ,[ReviewStars]
FROM $(stage_db).$(use_schema).[StgFmCustomerProductReviews]

SELECT TOP(10) * FROM $(dw_db).$(use_schema).[DimFmCustomerProductReviews];
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


/* Load Dimension table fudgeinc.DimFmOrders */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[DimFmOrders]
	(
			[OrderID]
      ,[CustomerID]
      ,[CustomerFullName]
      ,[CustomerAliasName]
      ,[OrderDateKey]
      ,[ShippedDateKey]
      ,[ShippingCompanyName]
	)
	SELECT 
			[OrderID]
      ,[CustomerID]
      ,[CustomerFullName]
      ,[CustomerAliasName]
      ,case when [ExternalSources2].[dbo].[getDateKey](OrderDate) is null then -1
				else [ExternalSources2].[dbo].[getDateKey](OrderDate) end as [OrderDateKey]
      ,case when [ExternalSources2].[dbo].[getDateKey](ShippedDate) is null then -1
				else [ExternalSources2].[dbo].[getDateKey](ShippedDate) end as [ShippedDateKey]
      ,[ShippingCompanyName]
FROM $(stage_db).$(use_schema).[StgFmOrders]

SELECT TOP(10) * FROM $(dw_db).$(use_schema).[DimFmOrders];
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


/* Load Dimension table fudgeinc.FactFmCustomerDemand */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[FactFmCustomerDemand]
	(
			[ProductKey]
      ,[CustomerKey]
      ,[OrderID]
      ,[OrderDateKey]
      ,[ShippedDateKey]
      ,[OrderQuantity]
      ,[ProductRetailPrice]
      ,[ProductWholesalePrice]
      ,[ProductProfitMargin]
      ,[ProductLiveDateKey]
      ,[ProductReviewAvgScore]
      ,[ProductReviewCount]
	)
	SELECT 
      p.[ProductKey]
      ,c.[CustomerKey]
      ,cd.[OrderID]
      ,case when [ExternalSources2].[dbo].[getDateKey](cd.OrderDate) is null then -1
				else [ExternalSources2].[dbo].[getDateKey](cd.OrderDate) end as [OrderDateKey]
      ,case when [ExternalSources2].[dbo].[getDateKey](cd.ShippedDate) is null then -1
				else [ExternalSources2].[dbo].[getDateKey](cd.ShippedDate) end as [ShippedDateKey]
      ,cd.[OrderQuantity]
      ,cd.[ProductRetailPrice]
      ,cd.[ProductWholesalePrice]
      ,(cd.[ProductRetailPrice] - cd.[ProductWholesalePrice]) as [ProductProfitMargin]
      ,case when [ExternalSources2].[dbo].[getDateKey](cd.ProductLiveDate) is null then -1
				else [ExternalSources2].[dbo].[getDateKey](cd.ProductLiveDate) end as [ProductLiveDateKey]
      ,[ProductReviewAvgScore]
      ,[ProductReviewCount]
FROM $(stage_db).$(use_schema).[StgFactFmCustomerDemand] cd
	JOIN $(dw_db).$(use_schema).[DimFmProducts] p
		ON cd.ProductID = p.ProductID
	JOIN $(dw_db).$(use_schema).[DimFmCustomers] c
		ON cd.CustomerID = c.CustomerID
--ORDER BY cd.CustomerID

SELECT TOP(10) * FROM $(dw_db).$(use_schema).[FactFmCustomerDemand];
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


--################################################################################################################################################################################
--			CREATE VIEW of Customer Demand Analysis
--################################################################################################################################################################################
/*
	Create a Simple SQL View that joins the dimensions and facts together. 
	This view should include all the rows from each dimension table and just the facts and degenerate dimensions from the fact table
*/
--Drop View if exists
IF EXISTS(SELECT * FROM sys.views WHERE name = 'FmCustomerDemand' and schema_id = SCHEMA_ID(N'$(use_schema)'))
DROP VIEW $(use_schema).[FmCustomerDemand]
GO


-- Create VIEW of Customer Demand ROLAP --
CREATE VIEW $(use_schema).[FmCustomerDemand]
AS
SELECT 
	cd.[OrderID]
	,od.[FullDateUSA] as [OrderDate]
	,cd.[OrderQuantity]
	,p.[ProductID]
	,p.[ProductName]
	,p.[ProductDepartment]
	,p.[IsProductActive]
	,pld.[FullDateUSA] as [ProductLiveDate]
	,cd.[ProductRetailPrice]
	,cd.[ProductWholesalePrice]
	,cd.[ProductProfitMargin]
	,cd.[ProductReviewAvgScore]
	,cd.[ProductReviewCount]
	,p.[VendorName] as [ProductVendorName]
	,c.[CustomerID]
	,c.[FullName] as [CustomerFullName]
	,c.[CustomerAliasName] as [CustomerAliasName]
	,c.[CustomerCity] as [CustomerCity]
	,c.[CustomerState] as [CustomerState]
	,c.[CustomerZipCode] as [CustomerZipCode]
	,od.[MonthName] as [OrderMonth]
	,od.[MonthOfYear] as [OrderMonthOfYear]
	,od.[QuarterName] as [OrderQuarterName]
	,od.[Quarter] as [OrderQuarter]
	,od.[Year] as [OrderYear]
	,sd.[MonthName] as [ShippedMonth]
	,sd.[MonthOfYear] as [ShippedMonthOfYear]
	,sd.[QuarterName] as [ShippedQuarterName]
	,sd.[Quarter] as [ShippedQuarter]
	,sd.[Year] as [ShippedYear]
	,pld.[MonthName] as [ProductLiveMonth]
	,pld.[MonthOfYear] as [ProductLiveMonthOfYear]
	,pld.[QuarterName] as [ProductLiveQuarterName]
	,pld.[Quarter] as [ProductLiveQuarter]
	,pld.[Year] as [ProductLiveYear]
FROM $(use_schema).[FactFmCustomerDemand] cd
	JOIN $(use_schema).[DimFmProducts] p
		ON cd.ProductKey = p.ProductKey
	JOIN $(use_schema).[DimFmCustomers] c
		ON cd.CustomerKey = c.CustomerKey
	JOIN $(use_schema).[DimDate] od
		ON od.DateKey = cd.OrderDateKey
	JOIN $(use_schema).[DimDate] sd
		ON sd.DateKey = cd.ShippedDateKey
	JOIN $(use_schema).[DimDate] pld
		ON pld.DateKey = cd.ProductLiveDateKey
ORDER BY c.CustomerID ASC OFFSET 0 ROWS
;
GO


-- Test the VIEW --
SELECT * FROM $(use_schema).[FmCustomerDemand];

