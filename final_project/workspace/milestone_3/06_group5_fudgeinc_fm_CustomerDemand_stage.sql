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


/* STEP 2: STAGE fudgemart_v3 Dimension Tables ----------------------------

Source Tables:
--dbo.fm_customers
--dbo.fm_products
--dbo.fm_customer_product_reviews
--dbo.fm_orders
--dbo.fm_order_details

*/-------------------------------------------------------------------------

/* Stage fudgemart_v3.dbo.ff_plans into StgFmCustomers	*/
------------------------------------------------------
------------------------------------------------------
SELECT [customer_id] as [CustomerID]
      ,[customer_email] as [Email]
      ,[customer_firstname] as [FirstName]
      ,[customer_lastname] as [LastName]
      ,CONCAT(customer_firstname,' ',customer_lastname) as [FullName]
      ,CONCAT(customer_firstname,' ',customer_lastname,' ','<',customer_email,'>') as [CustomerAliasName]
      ,[customer_city] as [CustomerCity]
      ,[customer_state] as [CustomerState]
      ,[customer_zip] as [CustomerZip]
      ,[customer_phone] as [Phone]
  INTO $(use_schema).StgFmCustomers
  FROM [fudgemart_v3].[dbo].[fm_customers]

SELECT TOP(10) * FROM $(use_schema).StgFmCustomers;


/* Stage fudgemart_v3dbo.ff_accounts into StgFmProducts*/
---------------------------------------------------------
---------------------------------------------------------

SELECT [product_id] as [ProductID]
      ,[product_department] as [ProductDepartment]
      ,[product_name] as [ProductName]
      ,[product_retail_price] as [RetailPrice]
      ,[product_wholesale_price] as [WholesalePrice]
      ,[product_is_active] as [IsProductActive]
      ,[product_add_date] as [ProductLiveDate]
      ,v.[vendor_name] as [VendorName]
      ,v.[vendor_phone] as [VendorPhone]
  INTO $(use_schema).StgFmProducts
  FROM [fudgemart_v3].[dbo].[fm_products] p
  	JOIN [fudgemart_v3].[dbo].[fm_vendors] v
  		on p.product_vendor_id = v.vendor_id
  

SELECT TOP(10) * FROM $(use_schema).StgFmProducts;


/* Stage fudgemart_v3dbo.ff_account_billing into StgFmCustomerProductReviews*/
----------------------------------------------------------------------
----------------------------------------------------------------------

SELECT r.[customer_id] as [CustomerID]
			,CONCAT(c.customer_firstname,' ',c.customer_lastname) as [CustomerFullName]
			,CONCAT(c.customer_firstname,' ',c.customer_lastname,' ','<',c.customer_email,'>') as [CustomerAliasName]
      ,r.[product_id] as [ProductID]
      ,p.[product_name] as [ProductName]
      ,r.[review_date] as [ReviewDate]
      ,r.[review_stars] as [ReviewStars]
  INTO $(use_schema).StgFmCustomerProductReviews
  FROM [fudgemart_v3].[dbo].[fm_customer_product_reviews] r
  	JOIN [fudgemart_v3].[dbo].[fm_customers] c 
  		ON r.customer_id = c.customer_id
  	JOIN [fudgemart_v3].[dbo].[fm_products] p
			ON r.product_id = p.product_id

SELECT TOP(10) * FROM $(use_schema).StgFmCustomerProductReviews;

/* Stage fudgemart_v3.dbo.ff_titles into StgFmOrders*/
------------------------------------------------------
------------------------------------------------------

SELECT [order_id] as [OrderID]
      ,o.[customer_id] as [CustomerID]
      ,CONCAT(c.customer_firstname,' ',c.customer_lastname) as [CustomerFullName]
      ,CONCAT(c.customer_firstname,' ',c.customer_lastname,' ','<',c.customer_email,'>') as [CustomerAliasName]
      ,[order_date] as [OrderDate]
      ,[shipped_date] as [ShippedDate]
      ,s.[ship_via] as [ShippingCompanyName]
  INTO $(use_schema).StgFmOrders
  FROM [fudgemart_v3].[dbo].[fm_orders] o
  	JOIN [fudgemart_v3].[dbo].[fm_customers] c
  		ON o.customer_id = c.customer_id
  	JOIN [fudgemart_v3].[dbo].[fm_shipvia_lookup] s
			ON o.ship_via = s.ship_via

SELECT TOP(10) * FROM $(use_schema).StgFmOrders;


/* Stage  StgFactFmCustomerDemand*/
---------------------------------------------------------------------------
---------------------------------------------------------------------------
GO
SELECT product_id
		,ROUND(cast(AVG(review_stars+0.00) as decimal(3,2)),2) as AvgReviewStars
		,MIN(review_stars) as MinReviewStars
		,MAX(review_stars) as MaxReviewStars
		,COUNT(*) as ProductCount
	INTO $(use_schema).StgCustomerProductReviewMetrics
	FROM [fudgemart_v3].[dbo].[fm_customer_product_reviews]
	WHERE review_stars != 0
	group by product_id
	order by product_id asc
;
GO
SELECT * FROM $(use_schema).StgCustomerProductReviewMetrics;


SELECT od.[order_id] as [OrderID]
		,od.[product_id] as [ProductID]
		,o.[customer_id] as [CustomerID]
		,od.[order_qty] as [OrderQuantity]
		,p.[product_retail_price] as [ProductRetailPrice]
		,p.[product_wholesale_price] as [ProductWholesalePrice]
		,o.[order_date] as [OrderDate]
		,o.[shipped_date] as [ShippedDate]
		,p.[product_add_date] as [ProductLiveDate]
		,rm.[AvgReviewStars] as [ProductReviewAvgScore]
		,rm.[ProductCount] as [ProductReviewCount]
  INTO $(use_schema).StgFactFmCustomerDemand
  FROM [fudgemart_v3].[dbo].[fm_order_details] od
  	JOIN [fudgemart_v3].[dbo].[fm_orders] o
  		ON od.order_id = o.order_id
  	JOIN [fudgemart_v3].[dbo].[fm_products] p
			ON od.product_id = p.product_id
		JOIN $(use_schema).StgCustomerProductReviewMetrics rm
			ON od.product_id = rm.product_id
;		

SELECT TOP(10) * FROM $(use_schema).StgFactFmCustomerDemand;

