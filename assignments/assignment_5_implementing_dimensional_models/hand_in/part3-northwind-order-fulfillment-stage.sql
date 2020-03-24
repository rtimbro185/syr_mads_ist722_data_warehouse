/*
Course: IST 722 Data Warehouse
Assignment: #5 - Implementing Dimensional Models
Author: Ryan Timbrook
NetID: RTIMBROO
Date: 2/8/2020

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
Business Process: Order Fulfillment
Fact Table:		  FactOrderFulfillment
Fact Grain Type:  Accumulating Snapshot
Granularity:	  One row per order
Facts:            Time in Days between Order Date and Shipped Date

Source Dependencies:
	 - DimProduct		-> ProductKey
	 - Order Details	-> OrderID
	 - DimDate			-> DateKey

*/

-- STAGE Creation --
USE ist722_rtimbroo_stage
;

/*
GO
CREATE SCHEMA northwind
GO
*/

/* STEP 1: DROP STAGING TABLES IF THEY EXIST
	- **stg_date_dimension** - handled by northwind_dates
	- StgNorthwindProducts
	- StgNorthwindDates
	- **StgNorthwindOrderDetails** - handled by fact table staging
	- StgFactOrderFulfillment

*/

/* Drop northwind.StgNorthwindProducts | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'northwind.StgNorthwindProducts') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE northwind.StgNorthwindProducts 

/* Drop northwind.StgNorthwindOrderDetails | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'northwind.StgNorthwindOrderDetails') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE northwind.StgNorthwindOrderDetails

/* Drop northwind.StgFactOrderFulfillment | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'northwind.StgFactOrderFulfillment') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE northwind.StgFactOrderFulfillment

/* Drop northwind.StgNorthwindDates | Dependencies on:  */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'northwind.StgNorthwindDates') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE northwind.StgNorthwindDates

--########################################################################################################################################################

-- STAGE Northwind Products --
--- Test Select Query ---
SELECT [ProductID]
	,[ProductName]
	,[Discontinued]
	,[CompanyName]
	,[CategoryName]
FROM [Northwind].[dbo].[Products] p
	join [Northwind].[dbo].Suppliers s
		on p.[SupplierID] = s.[SupplierID]
	join [Northwind].[dbo].Categories c
		on c.[CategoryID] = p.[CategoryID]

--- Execute Select INTO clause to stage the data ---
SELECT [ProductID]
	,[ProductName]
	,[Discontinued]
	,[CompanyName]
	,[CategoryName]
INTO [northwind].[StgNorthwindProducts]
FROM [Northwind].[dbo].[Products] p
	join [Northwind].[dbo].Suppliers s
		on p.[SupplierID] = s.[SupplierID]
	join [Northwind].[dbo].Categories c
		on c.[CategoryID] = p.[CategoryID]

--- Validate Staging Worked ---
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (10) [ProductID]
      ,[ProductName]
      ,[Discontinued]
      ,[CompanyName]
      ,[CategoryName]
  FROM [ist722_rtimbroo_stage].[northwind].[StgNorthwindProducts]

--##########################################################################################################################################

--- STAGE NORTHWIND ORDER DATES ---
---- MODIFIED FOR ACIDEMIC PURPOSES - ONLY STAGING THE DATE DATA WE NEED FROM Orders table at this time ----
SELECT min(OrderDate) as MinOrderDate
		,max(OrderDate) as MaxOrderDate
		,min(ShippedDate) as MinShippedDate
		,max(ShippedDate) as MaxShippedDate
FROM [Northwind].[dbo].[Orders]

--- Test Query ---
SELECT *
FROM [ExternalSources2].[dbo].[date_dimension]
WHERE Year between 1996 and 1998

--- STAGE ORDER DATES ---
SELECT *
INTO [northwind].[StgNorthwindDates]
FROM [ExternalSources2].[dbo].[date_dimension] -- Using ExternalSources2 rather than ExternalSources which is offline
WHERE Year between 1996 and 1998

--- Validate Staging ---
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (10) [DateKey]
      ,[Date]
      ,[FullDateUK]
      ,[FullDateUSA]
      ,[DayOfMonth]
      ,[DaySuffix]
      ,[DayName]
      ,[DayOfWeekUSA]
      ,[DayOfWeekUK]
      ,[DayOfWeekInMonth]
      ,[DayOfWeekInYear]
      ,[DayOfQuarter]
      ,[DayOfYear]
      ,[WeekOfMonth]
      ,[WeekOfQuarter]
      ,[WeekOfYear]
      ,[Month]
      ,[MonthName]
      ,[MonthOfQuarter]
      ,[Quarter]
      ,[QuarterName]
      ,[Year]
      ,[YearName]
      ,[MonthYear]
      ,[MMYYYY]
      ,[FirstDayOfMonth]
      ,[LastDayOfMonth]
      ,[FirstDayOfQuarter]
      ,[LastDayOfQuarter]
      ,[FirstDayOfYear]
      ,[LastDayOfYear]
      ,[IsWeekday]
      ,[IsWeekdayYesNo]
      ,[IsHolidayUSA]
      ,[IsHolidayUSAYesNo]
      ,[HolidayNameUSA]
      ,[IsHolidayUK]
      ,[HolidayNameUK]
      ,[FiscalDayOfYear]
      ,[FiscalWeekOfYear]
      ,[FiscalMonth]
      ,[FiscalQuarter]
      ,[FiscalQuarterName]
      ,[FiscalYear]
      ,[FiscalYearName]
      ,[FiscalMonthYear]
      ,[FiscalMMYYYY]
      ,[FiscalFirstDayOfMonth]
      ,[FiscalLastDayOfMonth]
      ,[FiscalFirstDayOfQuarter]
      ,[FiscalLastDayOfQuarter]
      ,[FiscalFirstDayOfYear]
      ,[FiscalLastDayOfYear]
  FROM [ist722_rtimbroo_stage].[northwind].[StgNorthwindDates]

--############################################################################################################################################

-- STAGE FACT ORDER FULFILLMENT --
---- Test Select Query ----
SELECT [ProductID]
	,d.[OrderID]
	,[OrderDate]
	,[ShippedDate]
FROM [Northwind].[dbo].[Order Details] d
	join [Northwind].[dbo].[Orders] o
		on o.[OrderID] = d.[OrderID]

--- LOAD Stage Fact Order Fulfillment ---
SELECT [ProductID]
	,d.[OrderID]
	,[OrderDate]
	,[ShippedDate]
INTO [northwind].[StgFactOrderFulfillment]
FROM [Northwind].[dbo].[Order Details] d
	join [Northwind].[dbo].[Orders] o
		on o.[OrderID] = d.[OrderID]

--- VALIDATE Stage ---
/****** Script for SelectTopNRows command  ******/
SELECT TOP (10) [ProductID]
      ,[OrderID]
      ,[OrderDate]
      ,[ShippedDate]
  FROM [ist722_rtimbroo_stage].[northwind].[StgFactOrderFulfillment]
