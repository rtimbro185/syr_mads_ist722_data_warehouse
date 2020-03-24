/*
Course: IST 722 Data Warehouse
Assignment: #5 - Implementing Dimensional Models
Author: Ryan Timbrook
NetID: RTIMBROO
Date: 2/8/2020

Objective:
Step 3: 
Finally, load the data. 
	a. Use your staged data as a source to populate the dimensions and the fact table. 
	b. Hopefully your technical specifications are good enough! If you encounter issues with the import, 
		you might need to tweak your detailed dimensional model, regenerate the SQL and then retry the load. 
	c. Save your SQL as part3-northwind-order-fulfillment-load.sql  
	d. Create a view in your database joining all the tables together and then query your model with Excel to verify it makes sense.   
		e. Save your Excel pivot as part3-northwind-order-fulfillment-pivot.xlsx

Load From Stage Into the Data Warehouse
** Note: Document findings along the way. This will be used for planning out the ETL process in the next steps.
For example, if you need to combine two columns into one or replace NULL with a value, then this will need to happen in the ETL tooling.

Processes for loading data into the dimension tables:
1. Identify the requirements of the dimension
2. Write a select statement using the staged data to source the dimension
3. Create an INSERT INTO ... SELECT statement to populate the data

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

-- LOAD --
USE ist722_rtimbroo_dw
;

-- DELETE Table Data --
DELETE FROM [northwind].[FactOrderFulfillment];
GO
DELETE FROM [northwind].[DimDate];
GO
DELETE FROM [northwind].[DimProduct];
GO



--################################################################################################################################################################################
--################################################################################################################################################################################
/* LOAD DimProduct 
*/
--- Test Select Statement ---
SELECT 
	[ProductID]
	,[ProductName]
	,case when [Discontinued] = 0 then 'N' else 'Y' end as Discontinued
	,[CompanyName]
	,[CategoryName]
FROM [ist722_rtimbroo_stage].[northwind].[StgNorthwindProducts]

--- **** LOAD DimProduct **** ---
INSERT INTO [northwind].[DimProduct]
	([ProductID],[ProductName],[Discontinued],[SupplierName],[CategoryName])
	SELECT 
	[ProductID]
	,[ProductName]
	,case when [Discontinued] = 0 then 'N' else 'Y' end as Discontinued
	,[CompanyName]
	,[CategoryName]
FROM [ist722_rtimbroo_stage].[northwind].[StgNorthwindProducts]


--- Test the Load ---
SELECT * from [northwind].[DimProduct]

--################################################################################################################################################################################
--################################################################################################################################################################################
/* LOAD DimDate
	Load Date Dimension
*/
--- Test Select Statement ---
SELECT TOP (10) [DateKey]
	,[Date]
      ,[FullDateUSA]
      ,[DayOfWeekUSA]
      ,[DayName]
      ,[DayOfMonth]
      ,[DayOfYear]
      ,[WeekOfYear]
      ,[MonthName]
      ,[Month]
      ,[Quarter]
      ,[QuarterName]
      ,[Year]
      ,[IsWeekday]
FROM [ist722_rtimbroo_stage].[northwind].StgNorthwindDates

--- ****Load DimDate --- **Note: DimDate MonthOfYear maps to StgNorthwindDates Month**
--- First load unknown member 
INSERT INTO [northwind].[DimDate] (DateKey, Date, FullDateUSA, DayOfWeek, DayName, DayOfMonth, DayOfYear, WeekOfYear, MonthName, MonthOfYear, Quarter, QuarterName, Year, IsWeekday)
VALUES (-1, '', 'Unk date', 0, 'Unk date', 0, 0, 0, 'Unk month', 0, 0, 'Unk qtr', 0, 0)
;


INSERT INTO [northwind].[DimDate]
	([DateKey],[Date],[FullDateUSA],[DayOfWeek],[DayName],[DayOfMonth],[DayOfYear],[WeekOfYear],[MonthName],[MonthOfYear],[Quarter],[QuarterName],[Year],[IsWeekday])
	SELECT [DateKey]
		,[Date]
		,[FullDateUSA]
		,[DayOfWeekUSA]
		,[DayName]
		,[DayOfMonth]
		,[DayOfYear]
		,[WeekOfYear]
		,[MonthName]
		,[Month]
		,[Quarter]
		,[QuarterName]
		,[Year]
		,[IsWeekday]
	FROM [ist722_rtimbroo_stage].[northwind].StgNorthwindDates

-- Validate Data Load --
SELECT TOP (10) [DateKey]
      ,[Date]
      ,[FullDateUSA]
      ,[DayOfWeek]
      ,[DayName]
      ,[DayOfMonth]
      ,[DayOfYear]
      ,[WeekOfYear]
      ,[MonthName]
      ,[MonthOfYear]
      ,[Quarter]
      ,[QuarterName]
      ,[Year]
      ,[IsWeekday]
  FROM [ist722_rtimbroo_dw].[northwind].[DimDate]

--################################################################################################################################################################################
--################################################################################################################################################################################

/* LOAD FactOrderFulfillment
	- For each foreign key in the fact table, match the source data business key to the dimension business key
	so we can look up the dimension primary key.
	- Date keys are predictable, they can be generated using simple formatting to YYYYMMDD. There's an existing function in the ExternalSource2 DB to handle this, getDateKey()

	StgFactOrderFulfillment		FactOrderFulfillment	Lookup Key
		ProductID					ProductKey				DimProduct
		OrderDate					OrderDateKey			DimDate
		ShippedDate					ShippedDateKey			DimDate

	Fact: OrderToShippedLagInDays -> Derived, DATEDIFF(day, fo.OrderDate, fo.ShippedDate)
	* Set NULL values to -1
*/
-- Test Select Statement from Staging --
SELECT fo.*, p.ProductKey,fo.OrderID,
	[ExternalSources2].[dbo].[getDateKey](fo.OrderDate) as OrderDateKey,
	case when [ExternalSources2].[dbo].[getDateKey](fo.ShippedDate) is null then -1
	else [ExternalSources2].[dbo].[getDateKey](fo.ShippedDate) end as ShippedDateKey,
	case when DATEDIFF(day, fo.OrderDate, fo.ShippedDate) is null then -1
	else DATEDIFF(day, fo.OrderDate, fo.ShippedDate) end as OrderToShippedLagInDays
FROM [ist722_rtimbroo_stage].[northwind].[StgFactOrderFulfillment] fo
	join [ist722_rtimbroo_dw].[northwind].[DimProduct] p
		on fo.ProductID = p.ProductID --match on business key, not pk/fk

--**** Load FactOrderFulfillment ****--
INSERT INTO [ist722_rtimbroo_dw].[northwind].[FactOrderFulfillment]
	([ProductKey],[OrderID],[OrderDateKey],[ShippedDateKey],[OrderToShippedLagInDays])
SELECT p.ProductKey,fo.OrderID,
	[ExternalSources2].[dbo].[getDateKey](fo.OrderDate) as OrderDateKey,				--[getDateKey] function that formates the Staging Tables date field to YYYYMMDD
	case when [ExternalSources2].[dbo].[getDateKey](fo.ShippedDate) is null then -1		--[getDateKey] function that formates the Staging Tables date field to YYYYMMDD
	else [ExternalSources2].[dbo].[getDateKey](fo.ShippedDate) end as ShippedDateKey,
	case when DATEDIFF(day, fo.OrderDate, fo.ShippedDate) is null then -1
	else DATEDIFF(day, fo.OrderDate, fo.ShippedDate) end as OrderToShippedLagInDays
FROM [ist722_rtimbroo_stage].[northwind].[StgFactOrderFulfillment] fo
	join [ist722_rtimbroo_dw].[northwind].[DimProduct] p
		on fo.ProductID = p.ProductID --match on business key, not pk/fk


-- Validate FactOrderFulfillment Data Load --
SELECT TOP (20) [ProductKey]
      ,[OrderID]
      ,[OrderDateKey]
      ,[ShippedDateKey]
      ,[OrderToShippedLagInDays]
  FROM [ist722_rtimbroo_dw].[northwind].[FactOrderFulfillment]


--################################################################################################################################################################################
--			CREATE VIEW of ORDER FULFILLMENT
--################################################################################################################################################################################
/*
	Create a Simple SQL View that joins the dimensions and facts together. This view should include all the rows from each dimension table and just the facts and degenerate dimensions from the fact table
*/
--Drop View if exists
IF EXISTS(SELECT * FROM sys.views WHERE name = 'OrderFulfillmentMart' and schema_id = SCHEMA_ID('northwind'))
DROP VIEW [northwind].[OrderFulfillmentMart]
GO


-- Create VIEW of Order Fulfillment ROLAP --
CREATE VIEW [northwind].[OrderFulfillmentMart]
AS
SELECT o.OrderID, o.OrderToShippedLagInDays, p.ProductName, p.SupplierName as CompanyName, p.CategoryName, p.Discontinued,
	od.Date as OrderDate, od.DayOfWeek as OrderDayOfWeek, od.DayName as OrderDayName, od.DayOfMonth as OrderDayOfMonth, od.DayOfYear as OrderDayOfYear, od.WeekOfYear as OrderWeekOfYear, od.MonthName as OrderMonthName, od.MonthOfYear as OrderMonthOfYear, od.Quarter as OrderQuarter, od.QuarterName as OrderQuarterName, od.Year as OrderYear, od.IsWeekday as OrderIsWeekday,
	sd.Date as ShippedDate, sd.DayOfWeek as ShippedDayOfWeek, sd.DayName as ShippedDayName, sd.DayOfMonth as ShippedDayOfMonth, sd.DayOfYear as ShippedDayOfYear, sd.WeekOfYear as ShippedWeekOfYear, sd.MonthName as ShippedMonthName, sd.MonthOfYear as ShippedMonthOfYear, sd.Quarter as ShippedQuarter, sd.QuarterName as ShippedQuarterName, sd.Year as ShippedYear, sd.IsWeekday as ShippedIsWeekday
FROM [northwind].[FactOrderFulfillment] o
	join [ist722_rtimbroo_dw].[northwind].[DimProduct] p
		on p.ProductKey = o.ProductKey
	join [ist722_rtimbroo_dw].[northwind].[DimDate] od
		on od.DateKey = o.OrderDateKey
	join [ist722_rtimbroo_dw].[northwind].[DimDate] sd
		on sd.DateKey = o.ShippedDateKey
--Order by o.OrderToShippedLagInDays desc
GO

-- Test the VIEW --
SELECT * FROM [northwind].[OrderFulfillmentMart];