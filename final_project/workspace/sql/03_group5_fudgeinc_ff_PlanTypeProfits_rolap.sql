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
Business Process: Plan Profitability Analysis
Fact Table:		  	FactFfPlanTypeProfits
Fact Grain Type:  Accumulating Snapshot
Granularity:	  	One row per order
Facts:            Time in Days between Order Date and Shipped Date

Source Dependencies:
	 - DimFfPlans						-> PlanKey
	 - DimFfAccountBilling	-> AccountBillingKey
	 - DimFfAccounts				-> AccountKey
	 - DimDate							-> DateKey
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
USE $(use_database);
GO

-- STEP 1: DROP VIEWS IF THEY EXIST --




-- STEP 2: DROP TABLES IF THEY EXIST --
---------------------------------------

/* Drop table fudgeinc.FactFfPlanTypeProfits */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).FactFfPlanTypeProfits') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).FactFfPlanTypeProfits 
;

/* Drop table fudgeinc.DimFfPlans */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).DimFfPlans') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).DimFfPlans 
;

/* Drop table fudgeinc.DimFfAccounts */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).DimFfAccounts') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).DimFfAccounts 
;

/* Drop table fudgeinc.DimFfAccountBilling */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).DimFfAccountBilling') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE  $(use_schema).DimFfAccountBilling 
;


/* Drop table fudgeinc.DimFfAccountTitles */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).DimFfAccountTitles') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).DimFfAccountTitles 
;

/* Drop table fudgeinc.DimFfTitles */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).DimFfTitles') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).DimFfTitles 
;


-- STEP 4: CREAT SCHEMAS  --
----------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'$(use_schema)')
	EXEC('CREATE SCHEMA $(use_schema)');
GO


-- STEP 5: CREAT TABLES  --
---------------------------

/* Create table fudgeinc.DimFfPlans */
CREATE TABLE $(use_schema).DimFfPlans (
   [PlanKey]  int IDENTITY  NOT NULL
,  [PlanID]  int   NOT NULL
,  [PlanName]  varchar(50)   NOT NULL
,  [PlanPrice]  decimal(25,2)   NOT NULL
,  [IsPlanCurrent]  nchar(1)  DEFAULT 'Y' NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_$(use_schema).DimFfPlans] PRIMARY KEY CLUSTERED 
( [PlanKey] )
) ON [PRIMARY]
;

SET IDENTITY_INSERT $(use_schema).DimFfPlans ON
;
INSERT INTO $(use_schema).DimFfPlans (PlanKey, PlanID, PlanName, PlanPrice, IsPlanCurrent, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'None', 0.00, 'N', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT $(use_schema).DimFfPlans OFF
;


/* Create table fudgeinc.DimFfAccounts */
CREATE TABLE $(use_schema).DimFfAccounts (
   [AccountKey]  int IDENTITY  NOT NULL
,  [AccountID]  int   NOT NULL
,  [Email]  varchar(200)   NOT NULL
,  [FirstName]  varchar(50)   NOT NULL
,  [LastName]  varchar(50)   NOT NULL
,  [FullName]  varchar(100)   NOT NULL
,  [AccountAliasName]  varchar(100)   NOT NULL
,  [PlanName]  varchar(50)   NOT NULL
,  [AccountZipCode]  char(5)   NOT NULL
,  [AccountCity]  varchar(50)  DEFAULT 'N/A' NOT NULL
,  [AccountState]  varchar(25)  DEFAULT 'N/A' NOT NULL
,  [AccountOpenedDateKey]  int   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_$(use_schema).DimFfAccounts] PRIMARY KEY CLUSTERED 
( [AccountKey] )
) ON [PRIMARY]
;

SET IDENTITY_INSERT $(use_schema).DimFfAccounts ON
;
INSERT INTO $(use_schema).DimFfAccounts (AccountKey, AccountID, Email, FirstName, LastName, FullName, AccountAliasName, PlanName, AccountZipCode, AccountCity, AccountState, AccountOpenedDateKey, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'None', 'None', 'None', 'None', 'None', 'None', 'None', 'None', 'None', -1, 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT $(use_schema).DimFfAccounts OFF
;

/* Create table fudgeinc.DimFfAccountBilling */
CREATE TABLE $(use_schema).DimFfAccountBilling (
   [AccountBillingKey]  int IDENTITY  NOT NULL
,  [AccountBillingID]  int   NOT NULL
,  [AccountBillingDateKey]  int   NOT NULL
,  [AccountID]  int   NOT NULL
,	 [AccountHolderFullName] varchar(100) NOT NULL
,  [AccountAliasName]  varchar(100)   NOT NULL
,  [AccountBilledAmount]  decimal(25,2)   NOT NULL
,  [PlanName]  varchar(50)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_$(use_schema).DimFfAccountBilling] PRIMARY KEY CLUSTERED 
( [AccountBillingKey] )
) ON [PRIMARY]
;

SET IDENTITY_INSERT $(use_schema).DimFfAccountBilling ON
;
INSERT INTO $(use_schema).DimFfAccountBilling (AccountBillingKey, AccountBillingID, AccountBillingDateKey, AccountID, AccountHolderFullName, AccountAliasName, AccountBilledAmount, PlanName, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, -1, -1,'None', 'None', 0.00, 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT $(use_schema).DimFfAccountBilling OFF
;


/* Create table fudgeinc.DimFfAccountTitles */
CREATE TABLE $(use_schema).DimFfAccountTitles (
   [AccountTitleKey]  int IDENTITY  NOT NULL
,  [AccountTitleID]  int   NOT NULL
,  [AccountID]  int   NOT NULL
,	 [AccountHolderFullName] varchar(100) NOT NULL
,  [AccountAliasName]  varchar(100)   NOT NULL
,	 [TitleID]  varchar(20)   NOT NULL
,  [TitleName]  varchar(200)   NOT NULL
,  [QueuedDateKey]  int   NOT NULL
,  [ShippedDateKey]  int   NOT NULL
,  [ReturenedDateKey]  int   NOT NULL
,  [AccountTitleRating]  int   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_$(use_schema).DimFfAccountTitles] PRIMARY KEY CLUSTERED 
( [AccountTitleKey] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT $(use_schema).DimFfAccountTitles ON
;
INSERT INTO $(use_schema).DimFfAccountTitles (AccountTitleKey, AccountTitleID, AccountID, AccountHolderFullName, AccountAliasName, TitleID, TitleName, QueuedDateKey, ShippedDateKey, ReturenedDateKey, AccountTitleRating, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, -1, 'None','None', 'Unk', 'None', -1, -1, -1, 0, 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT $(use_schema).DimFfAccountTitles OFF
;


/* Create table fudgeinc.DimFfTitles */
CREATE TABLE $(use_schema).DimFfTitles (
   [TitleKey]  int IDENTITY  NOT NULL
,  [TitleID]  varchar(20)   NOT NULL
,  [TitleName]  varchar(200)   NOT NULL
,  [TitleType]  varchar(20)   NOT NULL
,  [Synopsis]  varchar(max)   NOT NULL
,  [AverageRatingByCustomer]  decimal(3,2)   NOT NULL
,  [ReleaseYear]  int   NOT NULL
,  [Runtime]  int   NOT NULL
,  [MPAARating]  varchar(5)   NOT NULL
,  [IsBlurayAvailable]  nchar(1)   NOT NULL
,  [IsDvdAvailable]  nchar(1)   NOT NULL
,  [IsInstantAvailable]  nchar(1)   NOT NULL
,  [LastUpdateDateKey]  int   NOT NULL
,  [TitleGenreName]  varchar(200)   NOT NULL
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [PK_$(use_schema).DimFfTitles] PRIMARY KEY CLUSTERED 
( [TitleKey] )
) ON [PRIMARY]
;

SET IDENTITY_INSERT $(use_schema).DimFfTitles ON
;
INSERT INTO $(use_schema).DimFfTitles (TitleKey, TitleID, TitleName, TitleType, Synopsis, AverageRatingByCustomer, ReleaseYear, Runtime, MPAARating, IsBlurayAvailable, IsDvdAvailable, IsInstantAvailable, LastUpdateDateKey, TitleGenreName, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, 'Unk', 'None', 'None', 'None', 0.00, 0, 0, 'None', 'N', 'N', 'N', -1, 'None', 1, '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT $(use_schema).DimFfTitles OFF
;


/* Create table fudgeinc.FactFfPlanTypeProfits */
CREATE TABLE $(use_schema).FactFfPlanTypeProfits (
   [PlanKey]  int   NOT NULL
,  [AccountBillingKey]  int   NOT NULL
,  [AccountKey]  int   NOT NULL
,  [AccountBilledDateKey]  int   NOT NULL
,	 [AccountBilledAmount]  decimal(25,2)   NOT NULL
,  [PlanPriceAmount]  decimal(25,2)   NOT NULL
,  [AccountTotalBilledAmount] decimal(25,2)   NOT NULL
,  [AccountTotalQuantityBilled] int NOT NULL
,  [PlanTotalBilledAmount]  decimal(25,2)   NOT NULL
,  [PlanTotalQuantityBilled]  int   NOT NULL
,  [SnapeshotDateKey]  int   NOT NULL
, CONSTRAINT [PK_$(use_schema).FactFfPlanTypeProfits] PRIMARY KEY NONCLUSTERED 
( [PlanKey], [AccountKey], [AccountBillingKey] )
) ON [PRIMARY]
;

-- STEP 6: ADD TABLE CONSTRAINTS  --
------------------------------------
---
ALTER TABLE $(use_schema).DimFfAccounts ADD CONSTRAINT
   FK_$(use_schema)_DimFfAccounts_AccountOpenedDateKey FOREIGN KEY
   (
   AccountOpenedDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).DimFfAccountBilling ADD CONSTRAINT
   FK_$(use_schema)_DimFfAccountBilling_AccountBillingDateKey FOREIGN KEY
   (
   AccountBillingDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;


ALTER TABLE $(use_schema).DimFfAccountTitles ADD CONSTRAINT
   FK_$(use_schema)_DimFfAccountTitles_QueuedDateKey FOREIGN KEY
   (
   QueuedDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).DimFfAccountTitles ADD CONSTRAINT
   FK_$(use_schema)_DimFfAccountTitles_ShippedDateKey FOREIGN KEY
   (
   ShippedDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
ALTER TABLE $(use_schema).DimFfAccountTitles ADD CONSTRAINT
   FK_$(use_schema)_DimFfAccountTitles_ReturenedDateKey FOREIGN KEY
   (
   ReturenedDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
-----

ALTER TABLE $(use_schema).FactFfPlanTypeProfits ADD CONSTRAINT
   FK_$(use_schema)_FactFfPlanTypeProfits_PlanKey FOREIGN KEY
   (
   PlanKey
   ) REFERENCES $(use_schema).DimFfPlans
   ( PlanKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).FactFfPlanTypeProfits ADD CONSTRAINT
   FK_$(use_schema)_FactFfPlanTypeProfits_AccountKey FOREIGN KEY
   (
   AccountKey
   ) REFERENCES $(use_schema).DimFfAccounts
   ( AccountKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).FactFfPlanTypeProfits ADD CONSTRAINT
   FK_$(use_schema)_FactFfPlanTypeProfits_AccountBilledDateKey FOREIGN KEY
   (
   AccountBilledDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE $(use_schema).FactFfPlanTypeProfits ADD CONSTRAINT
   FK_$(use_schema)_FactFfPlanTypeProfits_SnapeshotDateKey FOREIGN KEY
   (
   SnapeshotDateKey
   ) REFERENCES $(use_schema).DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;


-- STEP 7: CREATE VIEWS  --