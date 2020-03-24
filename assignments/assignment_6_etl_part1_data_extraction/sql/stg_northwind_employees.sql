Select Employees.EmployeeID, 
		Employees.LastName, 
		Employees.FirstName,
		Employees.Title,
		Employees_1.HireDate,
		Employees_1.EmployeeID AS SupervisorID,
		Employees_1.LastName AS SupervisorLastName,
		Employees_1.FirstName AS SupervisorFirstName,
		Employees_1.Title AS SupervisorTitle
From dbo.Employees
	left join Employees AS Employees_1 ON Employees.ReportsTo = Employees_1.EmployeeID
	;