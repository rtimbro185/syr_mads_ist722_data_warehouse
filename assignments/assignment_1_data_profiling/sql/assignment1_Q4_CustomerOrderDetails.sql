Select total_order_product_sold.OrderID, o.CustomerID, o.CompanyName, total_order_product_sold.Total_Order_Product_Amt_Sold
From
(Select OrderID, SUM(TotalOrderProductPriceSold) as Total_Order_Product_Amt_Sold
	From
		(Select OrderID, ProductID, (DiscountedUnitPrice * Quantity) AS TotalOrderProductPriceSold
			From
				(Select OrderID, ProductID, UnitPrice, (UnitPrice - Discount) as DiscountedUnitPrice, Quantity, Discount
					From [Order Details]) as discounted_unit_price) as total_product_price
		Group By OrderID) as total_order_product_sold
	join (Select o.OrderID, o.CustomerID, c.CompanyName
			From Orders o
				join Customers c on o.CustomerID = c.CustomerID
			Where o.CustomerID = 'WHITC') o on total_order_product_sold.OrderID = o.OrderID
;

Select o.OrderID, o.CustomerID, c.CompanyName
From Orders o
	join Customers c on o.CustomerID = c.CustomerID
Where o.CustomerID = 'WHITC'
Order By o.OrderID;

Select *
From Customers
Where CustomerID = 'WHITC'
Order By CustomerID
;

