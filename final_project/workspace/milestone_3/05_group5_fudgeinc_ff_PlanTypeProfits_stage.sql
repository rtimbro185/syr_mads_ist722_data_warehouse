/*
Course: IST 722 Data Warehouse
Assignment: Group 5 - Final Project - Implementing Dimensional Models
Author: Ryan Timbrook
NetID: RTIMBROO
Date: 2/28/2020

Objective:
Step 2: 
	Next stage the data.  
	a. You only need to stage the data you do not already have. 
	b. You should always stage the fact table, even if some of the data was staged already. 

Perform the initial ETL load from the source system. 
The goal of this process does not replace actual ETL tooling since we have no means to automate, audit success or failure, track changes to data, or document this process. 
Instead our goals are simply to: 
1. Understand how to source the data required for our implementation,  
2. Verify that our model actually solves our business problem, 
3. Remove our dependency on the external world by staging our data, and  
4. Complete these tasks in a manner in which we can re-create our data, when required. 

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
:setvar use_database ist722_rtimbroo_stage    -- my local development STAGE database
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

/* STEP 1: DROP STAGING TABLES IF THEY EXIST -----------------------------------------
--StgFfPlans
--StgFfAccounts
--StgFfAccountBilling
--StgFfAccountTitles
--StgFfTitles
--StgFactFfPlanTypeProfits
*/------------------------------------------------------------------------------------

/* Drop fudgeinc.StgFfPlans | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFfPlans') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFfPlans 

/* Drop fudgeinc.StgFfAccounts | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFfAccounts') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFfAccounts 

/* Drop fudgeinc.StgFfAccountBilling | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFfAccountBilling') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFfAccountBilling 

/* Drop fudgeinc.StgFfAccountTitles | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFfAccountTitles') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFfAccountTitles 

/* Drop fudgeinc.StgFfTitles | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFfTitles') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFfTitles 

/* Drop fudgeinc.StgFactFfPlanTypeProfits | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFactFfPlanTypeProfits') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFactFfPlanTypeProfits


/* STEP 2: STAGE fudgeflix_v3 Dimension Tables ----------------------------

--dbo.ff_plans
--dbo.ff_accounts
--dbo.ff_account_billing
--dbo.ff_titles
--dbo.ff_account_titles

*/-------------------------------------------------------------------------

/* Stage fudgeflix_v3.dbo.ff_plans into StgFfPlans	*/
------------------------------------------------------
------------------------------------------------------
SELECT [plan_id] as [PlanID]
      ,[plan_name] as [PlanName]
      ,[plan_price] as [PlanPrice]
    ,[plan_current] as [IsPlanCurrent]
  INTO
  	$(use_schema).StgFfPlans
  FROM [fudgeflix_v3].[dbo].[ff_plans]

SELECT TOP(10) * FROM $(use_schema).StgFfPlans;


/* Stage fudgeflix_v3dbo.ff_accounts into StgFfAccounts*/
---------------------------------------------------------
---------------------------------------------------------
SELECT [account_id] as [AccountID]
      ,[account_email] as [Email]
      ,[account_firstname] as [FirstName]
      ,[account_lastname] as [LastName]
      ,[account_address] as [Address]
      ,[account_zipcode] as [AccountZipCode]
      ,p.[plan_name] as [PlanName]
      ,[account_opened_on] as [AccountOpenedDate]
      ,z.[zip_city] as [AccountCity]
      ,z.[zip_state] as [AccountState]
  INTO $(use_schema).StgFfAccounts
  FROM [fudgeflix_v3].[dbo].[ff_accounts] a
  	JOIN [fudgeflix_v3].[dbo].[ff_zipcodes] z
  		on a.account_zipcode = z.zip_code
  	JOIN [fudgeflix_v3].[dbo].[ff_plans] p
  		on a.account_plan_id = p.plan_id

-- ***WARNING*** There is a bug in fudgeflix ff_accounts account_lastname. 
-- The property, Collation, for this column conflicts with other varchar fields such 
-- as account_firstname where it will throw an error if you try and concationate them
-- This alter table statement normalizes the LastName field in our staging table with the other fields Collation configuration
ALTER TABLE $(use_schema).StgFfAccounts
ALTER COLUMN LastName VARCHAR(50)
COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

--TEST FIX
SELECT CONCAT(FirstName, ' ', LastName) as FullName
FROM $(use_schema).StgFfAccounts

SELECT TOP(10) * FROM $(use_schema).StgFfAccounts;


/* Stage fudgeflix_v3dbo.ff_account_billing into StgFfAccountBilling*/
----------------------------------------------------------------------
----------------------------------------------------------------------
SELECT [ab_id] as [AccountBillingID]
      ,[ab_date] as [AccountBillingDate]
      ,[ab_account_id] as [AccountID]
      ,p.[plan_name] as [PlanName]
      ,[ab_billed_amount] as [AccountBilledAmount]
  INTO $(use_schema).StgFfAccountBilling
  FROM [fudgeflix_v3].[dbo].[ff_account_billing] ab
  	JOIN [fudgeflix_v3].[dbo].[ff_accounts] a
  		ON ab.ab_account_id = a.account_id
  	JOIN [fudgeflix_v3].[dbo].[ff_plans] p
  		ON ab.ab_plan_id = p.plan_id


SELECT TOP(10) * FROM $(use_schema).StgFfAccountBilling;

/* Stage fudgeflix_v3.dbo.ff_titles into StgFfTitles*/
------------------------------------------------------
------------------------------------------------------
SELECT [title_id] as [TitleID]
      ,[title_name] as [TitleName]
      ,[title_type] as [TitleType]
      ,[title_synopsis] as [Synopsis]
      ,[title_avg_rating] as [AverageRatingByCustomer]
      ,[title_release_year] as [ReleaseYear]
      ,[title_runtime] as [Runtime]
      ,[title_rating] as [MPAARating]
      ,[title_bluray_available] as [IsBlurayAvailable]
      ,[title_dvd_available] as [IsDvdAvailable]
      ,[title_instant_available] as [IsInstantAvailable]
      ,[title_date_modified] as [LastUpdateDate]
      ,g.[tg_genre_name] as [TitleGenreName]
  INTO $(use_schema).StgFfTitles
  FROM [fudgeflix_v3].[dbo].[ff_titles] t
  	JOIN [fudgeflix_v3].[dbo].[ff_title_genres] g
  		ON t.title_id = g.tg_title_id


SELECT TOP(10) * FROM $(use_schema).StgFfTitles;


/* Stage fudgeflix_v3.dbo.ff_account_titles into StgFfAccountTitles*/
---------------------------------------------------------------------------
---------------------------------------------------------------------------
SELECT [at_id] as [AccountTitleID]
      ,[at_account_id] as [AccountID]
      ,[at_title_id] as [TitleID]
      ,t.[title_name] as [TitleName]
      ,[at_queue_date] as [QueuedDate]
      ,[at_shipped_date] as [ShippedDate]
      ,[at_returned_date] as [ReturnedDate]
      ,[at_rating] as [AccountTitleRating]
  INTO $(use_schema).StgFfAccountTitles
  FROM [fudgeflix_v3].[dbo].[ff_account_titles] at
  	JOIN [fudgeflix_v3].[dbo].[ff_titles] t
  		ON at.at_title_id = t.title_id


SELECT TOP(10) * FROM $(use_schema).StgFfAccountTitles;


/* Stage  StgFactFfPlanTypeProfits*/
---------------------------------------------------------------------------
---------------------------------------------------------------------------
SELECT [ab_id] as [AccountBillingID]
		,[ab_account_id] as [AccountID]
		,[ab_plan_id] as [PlanID]
		,[ab_date] as [AccountBilledDate]
		,[ab_billed_amount] as [AccountBilledAmount]
		,p.[plan_price] as [PlanPriceAmount]
	INTO $(use_schema).StgFactFfPlanTypeProfits
	FROM [fudgeflix_v3].[dbo].[ff_account_billing] ab
		JOIN [fudgeflix_v3].[dbo].[ff_plans] p
			ON ab.ab_plan_id = p.plan_id
		JOIN [fudgeflix_v3].[dbo].[ff_accounts] a
			ON ab.ab_account_id = a.account_id
			
			
SELECT TOP(10) * FROM $(use_schema).StgFactFfPlanTypeProfits;

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
;
*/

		
		