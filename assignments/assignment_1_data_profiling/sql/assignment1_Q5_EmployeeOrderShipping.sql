Select o.OrderID,e.EmployeeName,DATEDIFF(day, o.OrderDate,o.ShippedDate) as DaysToShip, s.CompanyName as ShippingCompany, o.ShipName as CompanyOrderedShippment
From Orders o
	join Shippers s on o.ShipVia = s.ShipperID
	join (Select EmployeeID, concat(FirstName,' ',LastName) as EmployeeName
From Employees
Where EmployeeID = 3) e on o.EmployeeID = e.EmployeeID
Where o.EmployeeID = 3
Order By DaysToShip DESC
;

