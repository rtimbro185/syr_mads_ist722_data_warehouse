/****** Object:  Database ist722_grblock_oa5_dw    Script Date: 2/27/20 5:47:54 PM ******/
/*
Kimball Group, The Microsoft Data Warehouse Toolkit
Generate a database from the datamodel worksheet, version: 4

You can use this Excel workbook as a data modeling tool during the logical design phase of your project.
As discussed in the book, it is in some ways preferable to a real data modeling tool during the inital design.
We expect you to move away from this spreadsheet and into a real modeling tool during the physical design phase.
The authors provide this macro so that the spreadsheet isn't a dead-end. You can 'import' into your
data modeling tool by generating a database using this script, then reverse-engineering that database into
your tool.

Uncomment the next lines if you want to drop and create the database
*/
/*
DROP DATABASE ist722_grblock_oa5_dw
GO
CREATE DATABASE ist722_grblock_oa5_dw
GO
ALTER DATABASE ist722_grblock_oa5_dw
SET RECOVERY SIMPLE
GO
*/
USE ist722_grblock_oa5_dw
;
IF EXISTS (SELECT Name from sys.extended_properties where Name = 'Description')
    EXEC sys.sp_dropextendedproperty @name = 'Description'
EXEC sys.sp_addextendedproperty @name = 'Description', @value = 'IST 722 - Group 5 Project - FudgeInc'
;





-- Create a schema to hold user views (set schema name on home page of workbook).
-- It would be good to do this only if the schema doesn't exist already.
GO
CREATE SCHEMA FudgeInc
GO



/* Drop table FudgeInc.DimFfPlans */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.DimFfPlans') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.DimFfPlans 
;

/* Create table FudgeInc.DimFfPlans */
CREATE TABLE FudgeInc.DimFfPlans (
   [plan_key]  int IDENTITY  NOT NULL
,  [plan_id]  int   NOT NULL
,  [plan_name]  varchar(50)   NOT NULL
,  [plan_price]  money   NOT NULL
,  [plan_current]  nchar(1) DEFAULT 'Y' NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_FudgeInc.DimFfPlans] PRIMARY KEY CLUSTERED 
( [plan_key] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT FudgeInc.DimFfPlans ON
;
INSERT INTO FudgeInc.DimFfPlans (plan_key, plan_id, plan_name, plan_price, plan_current, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'None', 0, 'Y', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT FudgeInc.DimFfPlans ON
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[FfPlans]'))
DROP VIEW [FudgeInc].[FfPlans]
GO
CREATE VIEW [FudgeInc].[FfPlans] AS 
SELECT [plan_key] AS [plan_key]
, [plan_id] AS [plan_id]
, [plan_name] AS [plan_name]
, [plan_price] AS [plan_price]
, [plan_current] AS [plan_current]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM FudgeInc.DimFfPlans
GO



/* Drop table FudgeInc.DimFfAccounts */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.DimFfAccounts') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.DimFfAccounts 
;

/* Create table FudgeInc.DimFfAccounts */
CREATE TABLE FudgeInc.DimFfAccounts (
   [account_key]  int IDENTITY  NOT NULL
,  [account_id]  int   NOT NULL
,  [account_email]  varchar(200)   NOT NULL
,  [account_firstname]  varchar(50)   NOT NULL
,  [account_lastname]  varchar(50)   NOT NULL
,  [account_zipcode]  char(5)   NOT NULL
,  [plan_name]  varchar(50)   NOT NULL
,  [account_fullname]  varchar(100)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_FudgeInc.DimFfAccounts] PRIMARY KEY CLUSTERED 
( [account_key] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT FudgeInc.DimFfAccounts ON
;
INSERT INTO FudgeInc.DimFfAccounts (account_key, account_id, account_email, account_firstname, account_lastname, account_zipcode, plan_name, account_fullname, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'None', 'None', 'None', 'None', 'None', 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT FudgeInc.DimFfAccounts OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[FfAccounts]'))
DROP VIEW [FudgeInc].[FfAccounts]
GO
CREATE VIEW [FudgeInc].[FfAccounts] AS 
SELECT [account_key] AS [account_key]
, [account_id] AS [account_id]
, [account_email] AS [account_email]
, [account_firstname] AS [account_firstname]
, [account_lastname] AS [account_lastname]
, [account_zipcode] AS [account_zipcode]
, [plan_name] AS [plan_name]
, [account_fullname] AS [account_fullname]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM FudgeInc.DimFfAccounts
GO


/* Drop table FudgeInc.DimFfAccountBilling */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.DimFfAccountBilling') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.DimFfAccountBilling 
;

/* Create table FudgeInc.DimFfAccountBilling */
CREATE TABLE FudgeInc.DimFfAccountBilling (
   [ab_key]  int IDENTITY  NOT NULL
,  [ab_id]  int   NOT NULL
,  [ab_date]  datetime   NOT NULL
,  [ab_account_id]  int   NOT NULL
,  [ab_billed_amount]  money   NOT NULL
,  [plan_name]  varchar(50)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_FudgeInc.DimFfAccountBilling] PRIMARY KEY CLUSTERED 
( [ab_key] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT FudgeInc.DimFfAccountBilling ON
;
INSERT INTO FudgeInc.DimFfAccountBilling (ab_key, ab_id, ab_date, ab_account_id, ab_billed_amount, plan_name, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, '12/31/1899', 0, 0, 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT FudgeInc.DimFfAccountBilling OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[FfAccountBilling]'))
DROP VIEW [FudgeInc].[FfAccountBilling]
GO
CREATE VIEW [FudgeInc].[FfAccountBilling] AS 
SELECT [ab_key] AS [ab_key]
, [ab_id] AS [ab_id]
, [ab_date] AS [ab_date]
, [ab_account_id] AS [ab_account_id]
, [ab_billed_amount] AS [ab_billed_amount]
, [plan_name] AS [plan_name]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM FudgeInc.DimFfAccountBilling
GO



/* Drop table FudgeInc.DimFfAccountTitles */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.DimFfAccountTitles') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.DimFfAccountTitles 
;

/* Create table FudgeInc.DimFfAccountTitles */
CREATE TABLE FudgeInc.DimFfAccountTitles (
   [at_key]  int IDENTITY  NOT NULL
,  [at_id]  int   NOT NULL
,  [at_account_id]  int   NOT NULL
,  [at_queue_date]  datetime   NOT NULL
,  [at_shipped_date]  datetime   NOT NULL
,  [at_returned_date]  datetime   NOT NULL
,  [at_rating]  int   NOT NULL
,  [title_name]  varchar(200)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_FudgeInc.DimFfAccountTitles] PRIMARY KEY CLUSTERED 
( [at_key] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT FudgeInc.DimFfAccountTitles ON
;
INSERT INTO FudgeInc.DimFfAccountTitles (at_key, at_id, at_account_id, at_queue_date, at_shipped_date, at_returned_date, at_rating, title_name, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 0, '12/31/1899', '12/31/1899', '12/31/1899', 0, 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT FudgeInc.DimFfAccountTitles OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[FfAccountTitles]'))
DROP VIEW [FudgeInc].[FfAccountTitles]
GO
CREATE VIEW [FudgeInc].[FfAccountTitles] AS 
SELECT [at_key] AS [at_key]
, [at_id] AS [at_id]
, [at_account_id] AS [at_account_id]
, [at_queue_date] AS [at_queue_date]
, [at_shipped_date] AS [at_shipped_date]
, [at_returned_date] AS [at_returned_date]
, [at_rating] AS [at_rating]
, [title_name] AS [title_name]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM FudgeInc.DimFfAccountTitles
GO


/* Drop table FudgeInc.DimFfTitles */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.DimFfTitles') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.DimFfTitles 
;

/* Create table FudgeInc.DimFfTitles */
CREATE TABLE FudgeInc.DimFfTitles (
   [title_key]  int IDENTITY  NOT NULL
,  [title_id]  varchar(20)   NOT NULL
,  [title_name]  varchar(200)   NOT NULL
,  [title_type]  varchar(20)   NOT NULL
,  [title_synopsis]  varchar(max)   NOT NULL
,  [title_avg_rating]  decimal(18,2)   NOT NULL
,  [title_release_year]  int   NOT NULL
,  [title_runtime]  int   NOT NULL
,  [title_rating]  varchar(20)   NOT NULL
,  [title_bluray_available]  bit   NOT NULL
,  [title_dvd_available]  bit   NOT NULL
,  [title_instant_available]  bit   NOT NULL
,  [title_date_modified]  datetime   NOT NULL
,  [tg_genre_name]  varchar(200)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_FudgeInc.DimFfTitles] PRIMARY KEY CLUSTERED 
( [title_key] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT FudgeInc.DimFfTitles ON
;
INSERT INTO FudgeInc.DimFfTitles (title_key, title_id, title_name, title_type, title_synopsis, title_avg_rating, title_release_year, title_runtime, title_rating, title_bluray_available, title_dvd_available, title_instant_available, title_date_modified, tg_genre_name, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, 'None', 'None', 'None', 'None', 0, 0, 0, 'None', 0, 0, 0, '12/31/1899', 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT FudgeInc.DimFfTitles OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[FfTitles]'))
DROP VIEW [FudgeInc].[FfTitles]
GO
CREATE VIEW [FudgeInc].[FfTitles] AS 
SELECT [title_key] AS [title_key]
, [title_id] AS [title_id]
, [title_name] AS [title_name]
, [title_type] AS [title_type]
, [title_synopsis] AS [title_synopsis]
, [title_avg_rating] AS [title_avg_rating]
, [title_release_year] AS [title_release_year]
, [title_runtime] AS [title_runtime]
, [title_rating] AS [title_rating]
, [title_bluray_available] AS [title_bluray_available]
, [title_dvd_available] AS [title_dvd_available]
, [title_instant_available] AS [title_instant_available]
, [title_date_modified] AS [title_date_modified]
, [tg_genre_name] AS [tg_genre_name]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM FudgeInc.DimFfTitles
GO



/* Drop table FudgeInc.DimFmCustomers */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.DimFmCustomers') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.DimFmCustomers 
;

/* Create table FudgeInc.DimFmCustomers */
CREATE TABLE FudgeInc.DimFmCustomers (
   [customer_key]  int IDENTITY  NOT NULL
,  [customer_id]  int   NOT NULL
,  [customer_email]  varchar(100)   NOT NULL
,  [customer_firstname]  varchar(50)   NOT NULL
,  [customer_lastname]  varchar(50)   NOT NULL
,  [customer_address]  varchar(255)   NOT NULL
,  [customer_city]  varchar(50)   NOT NULL
,  [customer_state]  char(2)   NOT NULL
,  [customer_zip]  varchar(20)   NOT NULL
,  [customer_phone]  varchar(30)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_FudgeInc.DimFmCustomers] PRIMARY KEY CLUSTERED 
( [customer_key] )
) ON [PRIMARY]
;

SET IDENTITY_INSERT FudgeInc.DimFmCustomers ON
;
INSERT INTO FudgeInc.DimFmCustomers (customer_key, customer_id, customer_email, customer_firstname, customer_lastname, customer_address, customer_city, customer_state, customer_zip, customer_phone, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'None', 'None', 'None', 'None', 'None', 'NA', 'None', 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT FudgeInc.DimFmCustomers OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[FmCustomers]'))
DROP VIEW [FudgeInc].[FmCustomers]
GO
CREATE VIEW [FudgeInc].[FmCustomers] AS 
SELECT [customer_key] AS [customer_key]
, [customer_id] AS [customer_id]
, [customer_email] AS [customer_email]
, [customer_firstname] AS [customer_firstname]
, [customer_lastname] AS [customer_lastname]
, [customer_address] AS [customer_address]
, [customer_city] AS [customer_city]
, [customer_state] AS [customer_state]
, [customer_zip] AS [customer_zip]
, [customer_phone] AS [customer_phone]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM FudgeInc.DimFmCustomers
GO


/* Drop table FudgeInc.DimFmCustomerProductReviews */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.DimFmCustomerProductReviews') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.DimFmCustomerProductReviews 
;

/* Create table FudgeInc.DimFmCustomerProductReviews */
CREATE TABLE FudgeInc.DimFmCustomerProductReviews (
   [review_key]  int IDENTITY  NOT NULL
,  [customer_id]  int   NOT NULL
,  [product_id]  int   NOT NULL
,  [review_date]  datetime   NOT NULL
,  [review_stars]  int   NOT NULL
,  [product_name]  varchar(50)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_FudgeInc.DimFmCustomerProductReviews] PRIMARY KEY CLUSTERED 
( [review_key] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT FudgeInc.DimFmCustomerProductReviews ON
;
INSERT INTO FudgeInc.DimFmCustomerProductReviews (review_key, customer_id, product_id, review_date, review_stars, product_name, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, -1, '12/31/1899', 0, 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT FudgeInc.DimFmCustomerProductReviews OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[FmCustomerProductReviews]'))
DROP VIEW [FudgeInc].[FmCustomerProductReviews]
GO
CREATE VIEW [FudgeInc].[FmCustomerProductReviews] AS 
SELECT [review_key] AS [review_key]
, [customer_id] AS [customer_id]
, [product_id] AS [product_id]
, [review_date] AS [review_date]
, [review_stars] AS [review_stars]
, [product_name] AS [product_name]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM FudgeInc.DimFmCustomerProductReviews
GO


/* Drop table FudgeInc.DimFmOrders */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.DimFmOrders') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.DimFmOrders 
;

/* Create table FudgeInc.DimFmOrders */
CREATE TABLE FudgeInc.DimFmOrders (
   [order_key]  int IDENTITY  NOT NULL
,  [order_id]  int   NOT NULL
,  [customer_id]  int   NOT NULL
,  [order_date]  datetime   NOT NULL
,  [shipped_date]  datetime   NOT NULL
,  [ship_via]  varchar(20)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_FudgeInc.DimFmOrders] PRIMARY KEY CLUSTERED 
( [order_key] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT FudgeInc.DimFmOrders ON
;
INSERT INTO FudgeInc.DimFmOrders (order_key, order_id, customer_id, order_date, shipped_date, ship_via, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 0, '12/31/1899', '12/31/1899', 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT FudgeInc.DimFmOrders OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[FmOrders]'))
DROP VIEW [FudgeInc].[FmOrders]
GO
CREATE VIEW [FudgeInc].[FmOrders] AS 
SELECT [order_key] AS [order_key]
, [order_id] AS [order_id]
, [customer_id] AS [customer_id]
, [order_date] AS [order_date]
, [shipped_date] AS [shipped_date]
, [ship_via] AS [ship_via]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM FudgeInc.DimFmOrders
GO



/* Drop table FudgeInc.DimFmProducts */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.DimFmProducts') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.DimFmProducts 
;

/* Create table FudgeInc.DimFmProducts */
CREATE TABLE FudgeInc.DimFmProducts (
   [product_key]  int IDENTITY  NOT NULL
,  [product_id]  int   NOT NULL
,  [product_department]  varchar(20)   NOT NULL
,  [product_name]  varchar(50)   NOT NULL
,  [product_retail_price]  money   NOT NULL
,  [product_wholesale_price]  money   NOT NULL
,  [product_is_active]  bit   NOT NULL
,  [product_add_date]  datetime   NOT NULL
,  [vendor_name]  varchar(50)   NOT NULL
,  [vendor_phone]  varchar(20)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_FudgeInc.DimFmProducts] PRIMARY KEY CLUSTERED 
( [product_key] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT FudgeInc.DimFmProducts ON
;
INSERT INTO FudgeInc.DimFmProducts (product_key, product_id, product_department, product_name, product_retail_price, product_wholesale_price, product_is_active, product_add_date, vendor_name, vendor_phone, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'None', 'None', 0, 0, 0, '12/31/1899', 'None', 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT FudgeInc.DimFmProducts OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[FmProducts]'))
DROP VIEW [FudgeInc].[FmProducts]
GO
CREATE VIEW [FudgeInc].[FmProducts] AS 
SELECT [product_key] AS [product_key]
, [product_id] AS [product_id]
, [product_department] AS [product_department]
, [product_name] AS [product_name]
, [product_retail_price] AS [product_retail_price]
, [product_wholesale_price] AS [product_wholesale_price]
, [product_is_active] AS [product_is_active]
, [product_add_date] AS [product_add_date]
, [vendor_name] AS [vendor_name]
, [vendor_phone] AS [vendor_phone]
, [RowIsCurrent] AS [Row Is Current]
, [RowStartDate] AS [Row Start Date]
, [RowEndDate] AS [Row End Date]
, [RowChangeReason] AS [Row Change Reason]
FROM FudgeInc.DimFmProducts
GO


/* Drop table FudgeInc.DimDate */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.DimDate') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.DimDate 
;

/* Create table FudgeInc.DimDate */
CREATE TABLE FudgeInc.DimDate (
   [DateKey]  int   NOT NULL
,  [Date]  date   NULL
,  [FullDateUSA]  nchar(11)   NOT NULL
,  [DayOfWeek]  tinyint   NOT NULL
,  [DayName]  nchar(10)   NOT NULL
,  [DayOfMonth]  tinyint   NOT NULL
,  [DayOfYear]  smallint   NOT NULL
,  [WeekOfYear]  tinyint   NOT NULL
,  [MonthName]  nchar(10)   NOT NULL
,  [MonthOfYear]  tinyint   NOT NULL
,  [Quarter]  tinyint   NOT NULL
,  [QuarterName]  nchar(10)   NOT NULL
,  [Year]  smallint   NOT NULL
,  [IsWeekday]  bit  DEFAULT 0 NOT NULL
, CONSTRAINT [PK_FudgeInc.DimDate] PRIMARY KEY CLUSTERED 
( [DateKey] )
) ON [PRIMARY]
;


INSERT INTO FudgeInc.DimDate (DateKey, Date, FullDateUSA, DayOfWeek, DayName, DayOfMonth, DayOfYear, WeekOfYear, MonthName, MonthOfYear, Quarter, QuarterName, Year, IsWeekday)
VALUES (-1, '', 'Unk date', 0, 'Unk date', 0, 0, 0, 'Unk month', 0, 0, 'Unk qtr', 0, 0)
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[Date]'))
DROP VIEW [FudgeInc].[Date]
GO
CREATE VIEW [FudgeInc].[Date] AS 
SELECT [DateKey] AS [DateKey]
, [Date] AS [Date]
, [FullDateUSA] AS [FullDateUSA]
, [DayOfWeek] AS [DayOfWeek]
, [DayName] AS [DayName]
, [DayOfMonth] AS [DayOfMonth]
, [DayOfYear] AS [DayOfYear]
, [WeekOfYear] AS [WeekOfYear]
, [MonthName] AS [MonthName]
, [MonthOfYear] AS [MonthOfYear]
, [Quarter] AS [Quarter]
, [QuarterName] AS [QuarterName]
, [Year] AS [Year]
, [IsWeekday] AS [IsWeekday]
FROM FudgeInc.DimDate
GO


/* Drop table FudgeInc.FactFfPlanTypeProfits */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.FactFfPlanTypeProfits') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.FactFfPlanTypeProfits 
;

/* Create table FudgeInc.FactFfPlanTypeProfits */
CREATE TABLE FudgeInc.FactFfPlanTypeProfits (
   [plan_key]  int   NOT NULL
,  [account_key]  int   NOT NULL
,  [ab_key]  int   NOT NULL
,  [BilledDateKey]  int   NOT NULL
,  [plan_name]  varchar(50)   NOT NULL
,  [plan_price]  money   NOT NULL
,  [account_name]  varchar(100)   NOT NULL
,  [account_email]  varchar(50)   NOT NULL
,  [account_zip]  char(5)   NOT NULL
,  [OpenedDateKey]  int   NOT NULL
,  [ab_billed_amount]  money   NOT NULL
) ON [PRIMARY]
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[FudgeInc].[FfPlanTypeProfits]'))
DROP VIEW [FudgeInc].[FfPlanTypeProfits]
GO
CREATE VIEW [FudgeInc].[FfPlanTypeProfits] AS 
SELECT [plan_key] AS [plan_key]
, [account_key] AS [account_key]
, [ab_key] AS [ab_key]
, [BilledDateKey] AS [BilledDateKey]
, [plan_name] AS [plan_name]
, [plan_price] AS [plan_price]
, [account_name] AS [customer_name]
, [account_email] AS [customer_email]
, [account_zip] AS [customer_zip]
, [OpenedDateKey] AS [OpenedDateKey]
, [ab_billed_amount] AS [billed_amount]
FROM FudgeInc.FactFfPlanTypeProfits
GO


/* Drop table FudgeInc.FactFfCustomerDemand */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'FudgeInc.FactFfCustomerDemand') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE FudgeInc.FactFfCustomerDemand 
;

/* Create table FudgeInc.FactFfCustomerDemand */
CREATE TABLE FudgeInc.FactFfCustomerDemand (
   [ProductKey]  int   NOT NULL
,  [CustomerKey]  int   NOT NULL
,  [OrderDateKey]  int   NOT NULL
,  [InsertAuditKey]  int   NOT NULL
,  [UpdateAuditKey]  int   NOT NULL
,  [OrderID]  int   NOT NULL
,  [Order_qty]  smallint   NOT NULL
, CONSTRAINT [PK_FudgeInc.FactFfCustomerDemand] PRIMARY KEY NONCLUSTERED 
( [ProductKey], [OrderID] )
) ON [PRIMARY]
;




ALTER TABLE northwind.FactSales ADD CONSTRAINT
   FK_northwind_FactSales_ProductKey FOREIGN KEY
   (
   ProductKey
   ) REFERENCES DimProduct
   ( ProductKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE northwind.FactSales ADD CONSTRAINT
   FK_northwind_FactSales_CustomerKey FOREIGN KEY
   (
   CustomerKey
   ) REFERENCES DimCustomer
   ( CustomerKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE northwind.FactSales ADD CONSTRAINT
   FK_northwind_FactSales_EmployeeKey FOREIGN KEY
   (
   EmployeeKey
   ) REFERENCES DimEmployee
   ( EmployeeKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE northwind.FactSales ADD CONSTRAINT
   FK_northwind_FactSales_OrderDateKey FOREIGN KEY
   (
   OrderDateKey
   ) REFERENCES DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE northwind.FactSales ADD CONSTRAINT
   FK_northwind_FactSales_ShippedDateKey FOREIGN KEY
   (
   ShippedDateKey
   ) REFERENCES DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;