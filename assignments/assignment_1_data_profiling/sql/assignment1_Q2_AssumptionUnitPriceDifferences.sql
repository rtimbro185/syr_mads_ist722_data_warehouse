Select * From
(Select od.ProductID as OD_ProductID, od.UnitPrice as OD_UnitPrice, p.ProductID as P_ProductID, p.UnitPrice as P_UnitPrice
From Products p
	join [Order Details] od on p.ProductID = od.ProductID) AS inner_query
Where OD_UnitPrice != P_UnitPrice
Order By OD_ProductID
;