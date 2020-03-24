Select SUM(TotalOrderProductPriceSold) as Total_Product_Amt_Sold
	From
		(Select OrderID, ProductID, (DiscountedUnitPrice * Quantity) AS TotalOrderProductPriceSold
		From
			(Select OrderID, ProductID, UnitPrice, (UnitPrice - Discount) as DiscountedUnitPrice, Quantity, Discount
				From [Order Details]) as discounted_unit_price) as total_product_price
;





Select OrderID, ProductID, UnitPrice, (UnitPrice - Discount) as DiscountedUnitPrice, Quantity, Discount
From [Order Details];