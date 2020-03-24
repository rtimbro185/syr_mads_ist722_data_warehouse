
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