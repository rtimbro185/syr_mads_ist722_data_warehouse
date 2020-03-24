Select CategoryName as ProductCategoryName, COUNT(ProductID) as ProductCount
From
(Select p.ProductID, p.ProductName, p.CategoryID, c.CategoryName, c.Description as CategoryDescription
From Products p
	join Categories c on p.CategoryID = c.CategoryID) as prod_category_name
Group By CategoryName
Order By ProductCount DESC
;

Select p.ProductID, p.ProductName, p.CategoryID, c.CategoryName, c.Description as CategoryDescription
From Products p
	join Categories c on p.CategoryID = c.CategoryID
	Order By CategoryName;