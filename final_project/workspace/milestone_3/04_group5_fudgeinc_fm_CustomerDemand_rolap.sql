/*
Course: IST 722 Data Warehouse
Assignment: Group 5 - Final Project - Implementing Dimensional Models
Author: Ryan Timbrook
NetID: RTIMBROO
Date: 2/28/2020

Objective:
Create the star schema /detailed dimensional model worksheet: 
	a: Plan Profitability Analysis
Business users (Fudgeflix) need to be able to analyze plan usage popularity and profitability (based on delivery method)
	

** Star Schema Details **
Business Process: 
Fact Table:		  	
Fact Grain Type:  
Granularity:	  	
Facts:            

Source Dependencies:
	 
*/

-- DECLARE CONFIG VARIABLES --

-- IN SQL Server Manager Studio - Under 'Query' select SQLCMD Mode - to utilize command line variables for configurations
-- DATABASE CONFIGURATIONS -- UNCOMMENT ONLY ONE DATABASE
--                           
:setvar use_database ist722_rtimbroo_dw         -- my local development DW database
--:setvar use_database ist722_rtimbroo_stage    -- my local development STAGE database
--:setvar use_database ist722_grblock_oa5_dw    -- group 5 common DW database
--:setvar use_database ist722_grblock_oa5_stage -- group 5 common STAGE database
print(N'$(use_database)')
--

-- SCHEMA CONFIGURATIONS -- UNCOMMENT ONLY ONE SCHEMA
--
:setvar use_schema dev_fudgeinc       -- development schema
--:setvar use_schema test_fudgeinc			-- testing/validation schema
--:setvar use_schema fudgeinc						-- production schema
print(N'$(use_schema)')

-- #################################################### --


-- ROLAP Start Schema Creation --
--if(@use_database = 'ist722_rtimbroo_dw')
USE $(use_database);
GO

-- STEP 1: DROP VIEWS IF THEY EXIST --




-- STEP 2: DROP TABLES IF THEY EXIST --
---------------------------------------

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

-- STEP 3: DROP SCHEMAS IF THEY EXIST --
----------------------------------------
/*
IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'$(use_schema)')
	DROP SCHEMA $(use_schema);
GO
*/


-- STEP 4: CREAT SCHEMAS  --
----------------------------
--IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'$(use_schema)')
--	EXEC('CREATE SCHEMA $(use_schema)');
--GO


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


-- STEP 7: CREATE VIEWS  --