
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
	-StgFmCustomers
	-StgFmProducts
	-StgFmCustomerProductReviews
	-StgFmOrders
	-StgFactFmCustomerDemand
*/------------------------------------------------------------------------------------

/* Drop fudgeinc.StgFfPlans | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFmCustomers') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFmCustomers 

/* Drop fudgeinc.StgFfAccounts | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFmProducts') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFmProducts 

/* Drop fudgeinc.StgFfAccountBilling | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFmCustomerProductReviews') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFmCustomerProductReviews 

/* Drop fudgeinc.StgFfAccountTitles | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFmOrders') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFmOrders 

/* Drop fudgeinc.StgFfTitles | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgFactFmCustomerDemand') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgFactFmCustomerDemand 

/* Drop fudgeinc.StgFfTitles | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgCustomerProductReviewMetrics') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgCustomerProductReviewMetrics 



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



/* Drop fudgeinc.StgDates | Dependencies on:  */
USE $(stage_db);
GO
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'$(use_schema).StgDates') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE $(use_schema).StgDates
