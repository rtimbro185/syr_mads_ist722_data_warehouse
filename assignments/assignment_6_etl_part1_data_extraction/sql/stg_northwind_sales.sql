SELECT
	[Order Details].OrderID,
	[Order Details].ProductID,
	Orders.CustomerID,
	Orders.EmployeeID,
	Orders.OrderDate,
	Orders.ShippedDate,
	[Order Details].UnitPrice,
	[Order Details].Quantity, 
	[Order Details].Discount
FROM [Order Details]
	INNER JOIN Orders ON [Order Details].OrderID = Orders.OrderID