/*************************************************************
Title: Mod02-A02HSun
Info 330 Module 2: Database Options
Dev: HSun
Huating Sun
ChangeLog(When, Who, What)
01/15/2021. HSun, Created Script
*************************************************************/

Use Master;
Go
If Exists (Select Name From SysDatabases Where Name = 'Assignment02DB_HSun')
	Drop Database Assignment02DB_HSun;
Go

Create Database Assignment02DB_HSun;
Go

Use Assignment02DB_HSun;
Go

-- This table contains the list of customers including their first and last name and their emails and address
-- CustomerID is used as the Primary Key
Create Table Customers(
	CustomerID int Constraint pkCustomers Primary Key Not Null Identity (1, 1),
	CustomerFirstName nvarchar(100) Not Null,
	CustomerLastName nvarchar(100) Not Null,
	CustomerEmail nvarchar(100) Constraint checkCustomerEmail Check (CustomerEmail Like '%@%.%') Unique Not Null,
	CustomerAddress nvarchar(200) Not Null

);
Go

-- This table contains the list of orders including the date and order number
-- OrderID is used as the Primary Key and CustomerID is used as the Foreign Key
Create Table Orders(
	OrderID int Constraint pkOrders Primary Key Not Null Identity (1, 1),
	CustomerID int Constraint fkOrders Foreign Key References Customers(CustomerID) Not Null,
	OrderDate date Constraint dfDate Default GetDate() Not Null,
	OrderNumber int Constraint uqOrderNumber Unique Not Null


);
Go

-- This table contains the name of the categories
-- CategoryID is used as the Primary Key
Create Table Categories(
	CategoryID int Constraint pkCategories Primary Key Identity (1, 1) Not Null,
	CategoryName nvarchar(100) Constraint uqCategoryName Unique Not Null
);
Go

-- This table contains the name of the subcategories.
-- SubCategoryID is used as the Primary Key and CategoryID is used as the Foreign Key
Create Table SubCategories(
	SubCategoryID int Constraint pkSubCategories Primary Key Not Null Identity (1, 1),
	CategoryID int Constraint fkSubCategories Foreign Key References Categories(CategoryID) Not Null,
	SubCategoryName nvarchar(100) Constraint uqSubCategoryName Unique Not Null

);
Go

-- This table contains the information of the products including the name and description.
-- ProductID is used as the Primary Key and SubCategoryID is used as the Foreign Key
Create Table Products(
	ProductID int Constraint pkProducts Primary Key Not Null Identity (1, 1),
	SubCategoryID int Constraint fkProducts Foreign Key References SubCategories(SubCategoryID) Not Null,
	ProductName nvarchar(100) Constraint uqProductName Unique Not Null,
	ProductDescription nvarchar(100) Not Null

);
Go

-- This table contains the order details such as the order price and the order quantity
-- Both ProductID and OrderID are used as Primary Keys and Foreign Keys
Create Table OrderDetails(
	ProductID int Constraint fkOrderDetailsProduct Foreign Key References Products(ProductID) Not Null,
	OrderID int Constraint fkOrderDetailsOrder Foreign Key References Orders(OrderID) Not Null,
	OrderPrice money Constraint checkOrderPrice Check (OrderPrice > 0) Not Null,
	OrderQuantity int Constraint checkOrderQuantity Check (OrderQuantity > 0) Not Null

	Constraint pkOrderDetails Primary Key(ProductID, OrderID)
);
Go

-- Creates View for the Customer Table
Create View vCustomers
As
	Select CustomerID, CustomerFirstName, CustomerLastName, CustomerEmail, CustomerAddress From Customers;
Go

-- Creates View for the Orders Table
Create View vOrders
As
	Select OrderID, CustomerID, OrderDate, OrderNumber From Orders;
Go

-- Creates View for the Categories Table
Create View vCategories
As
	Select CategoryID, CategoryName From Categories;
Go

-- Creates View for the SubCategories Table
Create View vSubCategories
As
	Select SubCategoryID, CategoryID, SubCategoryName From SubCategories;
Go

-- Creates View for the Products Table
Create View vProducts
As
	Select ProductID, SubCategoryID, ProductName, ProductDescription From Products;
Go

-- Creates View for the OrderDetails Table
Create View vOrderDetails
As
	Select ProductID, OrderID, OrderPrice, OrderQuantity From OrderDetails;
Go