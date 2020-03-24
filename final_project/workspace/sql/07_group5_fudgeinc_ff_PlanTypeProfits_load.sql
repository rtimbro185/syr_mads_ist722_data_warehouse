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


USE $(dw_db)
GO

-- STEP 1: DROP VIEWS IF THEY EXIST --
--Drop View if exists
IF EXISTS(SELECT * FROM sys.views WHERE name = 'FfPlanTypeProfits' and schema_id = SCHEMA_ID(N'$(use_schema)'))
DROP VIEW $(use_schema).[FfPlanTypeProfits]
GO


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

/*--------------- LOAD DIMENSION Tables ----------------------------------------- */
-----------------------------------------------------------------------------------

/* Load Dimension table fudgeinc.DimFfPlans */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[DimFfPlans]
	(
  	[PlanID]
  	,[PlanName]
  	,[PlanPrice]
  	,[IsPlanCurrent]
  )
	SELECT
		[PlanID]
  	,[PlanName]
  	,ROUND(CAST([PlanPrice]+0.00 as decimal(25,2)),2) as [PlanPrice]
		,case when [IsPlanCurrent] = 0 then 'N' else 'Y' end as [IsPlanCurrent]
FROM $(stage_db).$(use_schema).[StgFfPlans]

SELECT TOP(10) * FROM $(dw_db).$(use_schema).[DimFfPlans];
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

/* Load Dimension table fudgeinc.DimFfAccounts */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[DimFfAccounts]
	(
			[AccountID]
      ,[Email]
      ,[FirstName]
      ,[LastName]
      ,[FullName]
      ,[AccountAliasName]
      ,[PlanName]
      ,[AccountZipCode]
      ,[AccountCity]
      ,[AccountState]
      ,[AccountOpenedDateKey]
	)
	SELECT 
			[AccountID]
			,[Email]
      ,[FirstName]
      ,[LastName]
      ,CONCAT(FirstName, ' ', LastName) as [FullName]
      ,CONCAT(FirstName, ' ', LastName,' ','<',Email,'>') as [AccountAliasName]
      ,[PlanName]
      ,[AccountZipCode]
      ,[AccountCity]
      ,[AccountState]
      ,case when [ExternalSources2].[dbo].[getDateKey](AccountOpenedDate) is null then -1
			else [ExternalSources2].[dbo].[getDateKey](AccountOpenedDate) end as [AccountOpenedDateKey]
FROM $(stage_db).$(use_schema).[StgFfAccounts]


SELECT TOP(10) * FROM $(dw_db).$(use_schema).[DimFfAccounts];
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

/* Load Dimension table fudgeinc.DimFfAccountBilling */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[DimFfAccountBilling]
	(
			[AccountBillingID]
      ,[AccountBillingDateKey]
      ,[AccountID]
      ,[AccountHolderFullName]
      ,[AccountAliasName]
      ,[AccountBilledAmount]
      ,[PlanName]
	)
	SELECT 
			[AccountBillingID]
			,case when [ExternalSources2].[dbo].[getDateKey](AccountBillingDate) is null then -1
			else [ExternalSources2].[dbo].[getDateKey](AccountBillingDate) end as [AccountBillingDateKey]
      ,a.[AccountID]
      ,CONCAT(a.FirstName, ' ', a.LastName) as [AccountHolderFullName]
      ,CONCAT(a.FirstName, ' ', a.LastName,' ','<',a.Email,'>') as [AccountAliasName]
      ,ROUND(CAST([AccountBilledAmount]+0.00 as decimal(25,2)),2)
      ,ab.[PlanName]
FROM $(stage_db).$(use_schema).[StgFfAccountBilling] ab
	JOIN $(stage_db).$(use_schema).[StgFfAccounts] a
		ON ab.AccountID = a.AccountID


SELECT TOP(10) * FROM $(dw_db).$(use_schema).[DimFfAccountBilling];
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


/* Load Dimension table fudgeinc.DimFfTitles */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[DimFfTitles]
	(
		[TitleID]
    ,[TitleName]
    ,[TitleType]
    ,[Synopsis]
    ,[AverageRatingByCustomer]
    ,[ReleaseYear]
    ,[Runtime]
    ,[MPAARating]
    ,[IsBlurayAvailable]
    ,[IsDvdAvailable]
    ,[IsInstantAvailable]
    ,[LastUpdateDateKey]
    ,[TitleGenreName]
	)
	SELECT 
		[TitleID]
    ,[TitleName]
    ,[TitleType]
    ,[Synopsis]
    ,ROUND(CAST([AverageRatingByCustomer]+0.00 as decimal(3,2)),2) as [AverageRatingByCustomer]
    ,[ReleaseYear]
    ,[Runtime]
    ,[MPAARating]
  ,case when [IsBlurayAvailable] = 0 then 'N' else 'Y' end
  ,case when [IsDvdAvailable] = 0 then 'N' else 'Y' end
  ,case when [IsInstantAvailable] = 0 then 'N' else 'Y' end
  ,case when [ExternalSources2].[dbo].[getDateKey](LastUpdateDate) is null then -1
		else [ExternalSources2].[dbo].[getDateKey](LastUpdateDate) end as [LastUpdateDateKey]
    ,[TitleGenreName]
FROM $(stage_db).$(use_schema).[StgFfTitles]

SELECT TOP(10) * FROM $(dw_db).$(use_schema).[DimFfTitles];
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------




/* Load Dimension table fudgeinc.DimFfAccountTitles */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[DimFfAccountTitles]
	(
		[AccountTitleID]
    ,[AccountID]
    ,[AccountHolderFullName]
    ,[AccountAliasName]
    ,[TitleID]
    ,[TitleName]
    ,[QueuedDateKey]
    ,[ShippedDateKey]
    ,[ReturenedDateKey]
    ,[AccountTitleRating]
	)
	SELECT 
		[AccountTitleID]
    ,at.[AccountID]
    ,CONCAT(a.FirstName, ' ', a.LastName) as [AccountHolderFullName]
    ,CONCAT(a.FirstName, ' ', a.LastName,' ','<',a.Email,'>') as [AccountAliasName]
    ,at.[TitleID]
    ,at.[TitleName]
    ,case when [ExternalSources2].[dbo].[getDateKey](QueuedDate) is null then -1
			else [ExternalSources2].[dbo].[getDateKey](QueuedDate) end as [QueuedDateKey]
    ,case when [ExternalSources2].[dbo].[getDateKey](ShippedDate) is null then -1
			else [ExternalSources2].[dbo].[getDateKey](ShippedDate) end as [ShippedDateKey]
    ,case when [ExternalSources2].[dbo].[getDateKey](ReturnedDate) is null then -1
			else [ExternalSources2].[dbo].[getDateKey](ReturnedDate) end as [ReturenedDateKey]
    ,case when at.[AccountTitleRating] is NULL then 0 else at.[AccountTitleRating] end
FROM $(stage_db).$(use_schema).[StgFfAccountTitles] at
	JOIN $(stage_db).$(use_schema).[StgFfAccounts] a
		ON at.AccountID = a.AccountID

SELECT TOP(10) * FROM $(dw_db).$(use_schema).[DimFfAccountTitles];
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------



/* Load Dimension table fudgeinc.FactFfPlanTypeProfits */
----------------------------------------------------------------------------------

INSERT INTO $(dw_db).$(use_schema).[FactFfPlanTypeProfits]
	(
		[PlanKey]
    ,[AccountBillingKey]
    ,[AccountKey]
    ,[AccountBilledDateKey]
    ,[AccountBilledAmount]
    ,[PlanPriceAmount]
    ,[AccountTotalBilledAmount]
    ,[AccountTotalQuantityBilled]
    ,[PlanTotalBilledAmount]
    ,[PlanTotalQuantityBilled]
    ,[SnapeshotDateKey]
	)
	SELECT 
		p.[PlanKey]
		,ab.[AccountBillingKey]
    ,a.[AccountKey]
    ,case when [ExternalSources2].[dbo].[getDateKey](fp.AccountBilledDate) is null then -1
			else [ExternalSources2].[dbo].[getDateKey](fp.AccountBilledDate) end as [AccountBilledDateKey]
    ,fp.[AccountBilledAmount]
    ,fp.[PlanPriceAmount]
    ,SUM(fp.AccountBilledAmount) OVER (PARTITION BY fp.AccountID ORDER BY fp.AccountID) as [AccountTotalBilledAmount]
    ,COUNT(*) OVER (PARTITION BY fp.AccountID ORDER BY fp.AccountID) as [AccountTotalQuantityBilled]
    ,SUM(fp.AccountBilledAmount) OVER (PARTITION BY fp.PlanID ORDER BY fp.AccountID) as [PlanTotalBilledAmount]
    ,COUNT(*) OVER (PARTITION BY fp.PlanID ORDER BY fp.AccountID) as [PlanTotalQuantityBilled]
    --,GETDATE() as [SnapeshotDateKey]
    ,-1
FROM $(stage_db).$(use_schema).[StgFactFfPlanTypeProfits] fp
	JOIN $(dw_db).$(use_schema).[DimFfPlans] p
		ON fp.PlanID = p.PlanID --match on business key, not pk/fk
	JOIN $(dw_db).$(use_schema).[DimFfAccountBilling] ab
		ON fp.AccountBillingID = ab.AccountBillingID
	JOIN $(dw_db).$(use_schema).[DimFfAccounts] a
		ON fp.AccountID = a.AccountID
ORDER BY fp.AccountID
;
SELECT TOP(10) * FROM $(dw_db).$(use_schema).[FactFfPlanTypeProfits];

/*
select 
	AccountID
	,PlanID
	,AccountBilledDate
	,AccountBilledAmount
	,SUM(AccountBilledAmount) OVER (PARTITION BY AccountID ORDER BY AccountID) as AccountTotalBilledAmount
	,COUNT(*) OVER (PARTITION BY AccountID ORDER BY AccountID) as AccountTotalQuantityBilled
	,SUM(AccountBilledAmount) OVER (PARTITION BY PlanID ORDER BY AccountID) as PlanTotalBilledAmount
	,COUNT(*) OVER (PARTITION BY PlanID ORDER BY AccountID) as PlanTotalQuantityBilled
from [ist722_rtimbroo_stage].[dev_fudgeinc].[StgFactFfPlanTypeProfits]
order by AccountID
*/

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--################################################################################################################################################################################
--			CREATE VIEW of Plan Type Profit Analysis
--################################################################################################################################################################################
/*
	Create a Simple SQL View that joins the dimensions and facts together. 
	This view should include all the rows from each dimension table and just the facts and degenerate dimensions from the fact table
*/
--Drop View if exists
IF EXISTS(SELECT * FROM sys.views WHERE name = 'FfPlanTypeProfits' and schema_id = SCHEMA_ID(N'$(use_schema)'))
DROP VIEW $(use_schema).[FfPlanTypeProfits]
GO


-- Create VIEW of Plan Type Profits ROLAP --
CREATE VIEW $(use_schema).[FfPlanTypeProfits]
AS
SELECT 
	a.AccountID
	,ad.FullDateUSA as AccountBilledDate
	,ad.MonthName as AccountBilledMonth
	,ad.MonthOfYear as AccountBilledMonthOfYear
	,ad.QuarterName as AccountBilledQuarterName
	,ad.Quarter as AccountBilledQuarter
	,ad.Year as AccountBilledYear
	,a.FullName as AccountHolderFullName
	,a.AccountAliasName
	,a.AccountZipCode
	,a.AccountCity
	,a.AccountState
	,a.AccountOpenedDateKey
	,pp.AccountBilledAmount
	,pp.AccountTotalBilledAmount
	,pp.AccountTotalQuantityBilled
	,p.PlanID
	,p.PlanName
	,pp.PlanPriceAmount
	,p.IsPlanCurrent
	,pp.PlanTotalBilledAmount
	,pp.PlanTotalQuantityBilled
FROM $(use_schema).[FactFfPlanTypeProfits] pp
	JOIN $(use_schema).[DimFfPlans] p
		ON pp.PlanKey = p.PlanKey
	JOIN $(use_schema).[DimFfAccounts] a
		ON pp.AccountKey = a.AccountKey
	JOIN $(use_schema).[DimDate] ad
		ON ad.DateKey = pp.AccountBilledDateKey
ORDER BY AccountID ASC OFFSET 0 ROWS
;
GO
		
	--JOIN $(use_schema).[DimDate] ad
		--ON ad.DateKey = pp.AccountBilledDateKey
	--JOIN $(use_schema).[DimDate] sd
		--ON sd.DateKey = a.AccountOpenedDateKey
--Order by o.OrderToShippedLagInDays desc
GO

/*
od.Date as OrderDate, od.DayOfWeek as OrderDayOfWeek, od.DayName as OrderDayName, od.DayOfMonth as OrderDayOfMonth, od.DayOfYear as OrderDayOfYear, od.WeekOfYear as OrderWeekOfYear, od.MonthName as OrderMonthName, od.MonthOfYear as OrderMonthOfYear, od.Quarter as OrderQuarter, od.QuarterName as OrderQuarterName, od.Year as OrderYear, od.IsWeekday as OrderIsWeekday,
sd.Date as ShippedDate, sd.DayOfWeek as ShippedDayOfWeek, sd.DayName as ShippedDayName, sd.DayOfMonth as ShippedDayOfMonth, sd.DayOfYear as ShippedDayOfYear, sd.WeekOfYear as ShippedWeekOfYear, sd.MonthName as ShippedMonthName, sd.MonthOfYear as ShippedMonthOfYear, sd.Quarter as ShippedQuarter, sd.QuarterName as ShippedQuarterName, sd.Year as ShippedYear, sd.IsWeekday as ShippedIsWeekday
*/

-- Test the VIEW --
SELECT * FROM $(use_schema).[FfPlanTypeProfits];

