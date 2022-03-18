--*************************************************************************--
-- Title: Assignment04
-- Author: Huating Sun
-- Desc: This file demonstrates how to process data from a database
-- Change Log: When,Who,What
-- 2021-01-31,Huating Sun,Created File
--**************************************************************************--
Use Master;
Go

If Exists(Select Name from SysDatabases Where Name = 'Assignment04DB_HSun')
 Begin
  Alter Database [Assignment04DB_HSun] set Single_user With Rollback Immediate;
  Drop Database Assignment04DB_HSun;
 End
Go

Create Database Assignment04DB_HSun;
Go

Use Assignment04DB_HSun;
Go

-- Data Request: 0301
-- Request: I want a list of customer companies and their contact people

Create View vCustomerContacts AS
SELECT CompanyName, ContactName From Northwind.dbo.Customers;
Go

-- Test with this statement --

Select * from vCustomerContacts;
Go

-- Data Request: 0302
-- Request: I want a list of customer companies and their contact people, but only the ones in US and Canada

Create View vUSAandCanadaCustomerContacts As
Select Top 1000000000 
	CompanyName, 
	ContactName, 
	Country 
	From Northwind.dbo.Customers
Where Country = 'USA' OR Country = 'Canada'
Order By Country, CompanyName;
Go

-- Test with this statement --

Select * from vUSAandCanadaCustomerContacts;
Go

-- Data Request: 0303
-- Request: I want a list of products, their standard price and their categories.
-- Order the results by Category Name and then Product Name, in alphabetical order.

Create View vProductPricesByCategories As
Select Top 1000000000 
	C.CategoryName, 
	P.ProductName, 
	'$' + CAST(P.UnitPrice As nvarchar(150)) As 'StandardPrice'
From Northwind.dbo.Products AS P
Join Northwind.dbo.Categories As C 
	On P.CategoryID = C.CategoryID
Order By CategoryName, ProductName;
Go

-- Test with this statement --

Select * from vProductPricesByCategories;
Go

-- Data Request: 0304
-- Request: I want a list of products, their standard price and their categories.
-- Order the results by Category Name and then Product Name, in alphabetical order but only for the seafood category

Create Function fProductPricesByCategories(@categoryInput varchar(100))
Returns Table As Return(
  Select Top 1000000000 
	C.CategoryName, 
	P.ProductName, 
	'$' + CAST(P.UnitPrice As nvarchar(150)) As 'Standard Price'
  From Northwind.dbo.Products As P
  Join Northwind.dbo.Categories As C 
	On P.CategoryID = C.CategoryID
  Where C.CategoryName = @categoryInput
  Order By CategoryName, ProductName
);
Go

-- Test with this statement --
Select * from dbo.fProductPricesByCategories('seafood');
Go

-- Data Request: 0305
-- Request: I want a list of how many orders our customers have placed each year

Create View vCustomerOrderCounts As
Select Top 1000000000 
	CompanyName, 
	Count(*) As NumberOfOrders, 
	Year(OrderDate) As [Order Year]
From Northwind.dbo.Orders As O
Join Northwind.dbo.Customers As C 
	On C.CustomerID = O.CustomerID
Group By CompanyName, Year(OrderDate)
Order By CompanyName, [Order Year];
Go

-- Test with this statement --

Select * from vCustomerOrderCounts
Go

-- Data Request: 0306
-- Request: I want a list of total order dollars our customers have placed each year

Create View vCustomerOrderDollars As
Select Top 1000000000
CompanyName,
'$' + (Cast
	(Format
	(Convert(Decimal(18, 2), 
	Sum(D.Quantity * D.UnitPrice)), '#,###.00') As nvarchar(100))) As TotalDollars,
Year(OrderDate) As OrderYear
From Northwind.dbo.Orders As O
Join Northwind.dbo.Customers As C 
	On C.CustomerID = O.CustomerID
Join Northwind.dbo.[Order Details] As D 
	On D.OrderID = O.OrderID
Group By CompanyName, Year(OrderDate)
Order By CompanyName, OrderYear;
Go

-- Test with this statement --

Select * from vCustomerOrderDollars;
Go
