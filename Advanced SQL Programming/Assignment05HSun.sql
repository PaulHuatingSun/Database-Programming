--*************************************************************************--
-- Title: Assignment05
-- Author: Huating Sun
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2021-02-07,Huating Sun,Created File
--**************************************************************************--
-- Step 1: Create the assignment database
Use Master;
Go

If Exists(Select Name From SysDatabases Where Name = 'Assignment05DB_HuatingSun')
 Begin 
  Alter Database [Assignment05DB_HuatingSun] Set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_HuatingSun;
 End
Go

Create Database Assignment05DB_HuatingSun;
Go

Use Assignment05DB_HuatingSun;
Go

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
Go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [Money] NOT NULL
);
Go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
Go

-- Add Constraints (Module 02) -- 
Alter Table Categories 
 Add Constraint pkCategories 
  Primary Key (CategoryId);
Go

Alter Table Categories 
 Add Constraint ukCategories 
  Unique (CategoryName);
Go

Alter Table Products 
 Add Constraint pkProducts 
  Primary Key (ProductId);
Go

Alter Table Products 
 Add Constraint ukProducts 
  Unique (ProductName);
Go

Alter Table Products 
 Add Constraint fkProductsToCategories 
  Foreign Key (CategoryId) References Categories(CategoryId);
Go

Alter Table Products 
 Add Constraint ckProductUnitPriceZeroOrHigher 
  Check (UnitPrice >= 0);
Go

Alter Table Inventories 
 Add Constraint pkInventories 
  Primary Key (InventoryId);
Go

Alter Table Inventories
 Add Constraint dfInventoryDate
  Default GetDate() For InventoryDate;
Go

Alter Table Inventories
 Add Constraint fkInventoriesToProducts
  Foreign Key (ProductId) References Products(ProductId);
Go

Alter Table Inventories 
 Add Constraint ckInventoryCountZeroOrHigher 
  Check ([Count] >= 0);
Go


-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
Go
Select * From Products;
Go
Select * From Inventories;
Go

-- Step 2: Add some starter data to the database
Insert Into Categories(CategoryName) Values ('Beverages');
Go

Insert Into Products(ProductName, CategoryID, UnitPrice)
Values
('Chai', (Select CategoryID From Categories Where CategoryName = 'Beverages'), 18.00),
('Chang', (Select CategoryID From Categories Where CategoryName = 'Beverages'), 19.00);
Go

Insert Into Inventories(InventoryDate, ProductID, Count)
Values
('2017-01-01', (Select ProductID From Products Where ProductName = 'Chai'), 61),
('2017-01-01', (Select ProductID From Products Where ProductName = 'Chang'), 17),
('2017-02-01', (Select ProductID From Products Where ProductName = 'Chai'), 13),
('2017-02-01', (Select ProductID From Products Where ProductName = 'Chang'), 12),
('2017-03-02', (Select ProductID From Products Where ProductName = 'Chai'), 18),
('2017-03-02', (Select ProductID From Products Where ProductName = 'Chang'), 12)
Go
-- Added the following data to the three tables.
/* Add the following data to this database using Inserts:
Category	Product	Price	Date		Count
Beverages	Chai	18.00	2017-01-01	61
Beverages	Chang	19.00	2017-01-01	17

Beverages	Chai	18.00	2017-02-01	13
Beverages	Chang	19.00	2017-02-01	12

Beverages	Chai	18.00	2017-03-02	18
Beverages	Chang	19.00	2017-03-02	12
*/

-- Step 3: Create Transactional stored Procedures for each table using the proviced template:
-- Created the insert procedure for the Category Table
Create Procedure pInsCategories
(@CategoryName nvarchar(100))
/* Author: Huating Sun
** Desc: Insert rows Into categories table
** Change Log:
** 2021-02-07, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Insert Into Categories (CategoryName) 
        Values (@CategoryName);
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Created the update procedure for the Categories Table
Create Procedure pUpdCategories
(@CategoryID int, @CategoryName nvarchar(100))
/* Author: Huating Sun
** Desc: Update rows From categories table
** Change Log:
** 2021-02-07, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Update Categories
        Set CategoryName = @CategoryName
        Where CategoryID = @CategoryID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Created the delete procedure for the Categories Table
Create Procedure pDelCategories
(@CategoryID int)
/* Author: Huating Sun
** Desc: Delete rows From categories table
** Change Log:
** 2021-02-07, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Delete From Categories Where CategoryID = @CategoryID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Created the insert procedure for the Products Table
Create Procedure pInsProducts
(@ProductName nvarchar(100), @CategoryID int, @UnitPrice Money)
/* Author: Huating Sun
** Desc: Insert rows Into Products table
** Change Log:
** 2021-02-07, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Insert Into Products (ProductName, CategoryID, UnitPrice) 
        Values (
          @ProductName,
          @CategoryID,
          @UnitPrice);
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Created the update procedure for the Products Table
Create Procedure pUpdProducts
(@ProductID int, @ProductName nvarchar(100), @CategoryID int, @UnitPrice Money)
/* Author: Huating Sun
** Desc: Update rows From products table
** Change Log:
** 2021-02-07, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Update Products
        Set ProductName = @ProductName,
            CategoryID = @CategoryID,
            UnitPrice = @UnitPrice
        Where ProductID = @ProductID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Created the delete procedure for the Products Table
Create Procedure pDelProducts
(@ProductID int)
/* Author: Huating Sun
** Desc: Delete rows From products table
** Change Log:
** 2021-02-07, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Delete From Products Where ProductID = @ProductID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Created the insert procedure for the Inventories Table
Create Procedure pInsInventories
(@InventoryDate Date, @ProductID int, @Count int)
/* Author: Huating Sun
** Desc: Insert rows Into Inventories table
** Change Log:
** 2021-02-07, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Insert Into Inventories (InventoryDate, ProductID, Count) 
        Values (
          @InventoryDate,
          @ProductID,
          @Count);
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Created the update procedure for the Inventories Table
Create Procedure pUpdInventories
(@InventoryID int, @InventoryDate Date, @ProductID int, @Count int)
/* Author: Huating Sun
** Desc: Update rows From inventories table
** Change Log:
** 2021-02-07, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Update Inventories
        Set InventoryDate = @InventoryDate,
            ProductID = @ProductID,
            Count = @Count
        Where InventoryID = @InventoryID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Created the delete procedure for the Inventories Table
Create Procedure pDelInventories
(@InventoryID int)
/* Author: Huating Sun
** Desc: Delete rows From inventories table
** Change Log:
** 2021-02-07, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Delete From Inventories Where InventoryID = @InventoryID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      If(@@Trancount > 0) Rollback Transaction
      Print Error_Message();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Step 4: Create code to test each transactional stored procedure. 

-- Test the insert procedure for the Categories Table
Declare @Status int;
Exec @Status = pInsCategories @CategoryName = 'Kitchen Supplies';
Select [pInsCategories Status] = @Status;
Select * From Categories;
Go
-- Success

-- Test the update procedure for the Categories Table

Declare @Status int;
Exec @Status = pUpdCategories @CategoryID = 2, @CategoryName = 'Medicines';
Select [pUpdCategories Status] = @Status;
Select * From Categories;
Go
-- Success

-- Test the delete procedure for Categories Table

Declare @Status int;
Exec @Status = pDelCategories @CategoryID = 2;
Select [pDelCategories Status] = @Status;
Select * From Categories;
Go
-- Success

-- Test Insert procedure for the Products Table

Declare @Status int;
Exec @Status = pInsProducts @ProductName = 'Cream Cheese', @CategoryID = 1, @UnitPrice = 5.00;
Select [pInsProducts Status] = @Status;
Select * From Products;
Go
-- Success

-- Test the update procedure for the Products Table

Declare @Status int;
Exec @Status = pUpdProducts @ProductID = 3, @ProductName = 'Sour Cream', @CategoryID = 1, @UnitPrice = 7.00;
Select [pUpdProducts Status] = @Status;
Select * From Products;
Go
-- Success

-- Test the delete procedure for the Products Table

Declare @Status int;
Exec @Status = pDelProducts @ProductID = 3;
Select [pDelProducts Status] = @Status;
Select * From Products;
Go
-- Success

-- Test the Insert Procedure for the Inventories Table

Declare @Status int;
Exec @Status = pInsInventories @InventoryDate = '2018-06-01', @ProductID = 1, @Count = 85;
Select [pInsInventories Status] = @Status;
Select * From Inventories;
Go
-- Success

-- Test the Update procedure for the Inventories Table

Declare @Status int;
Exec @Status = pUpdInventories @InventoryID = 5, @InventoryDate = '2017-03-01', @ProductID = 2, @Count = 20;
Select [pUpdInventories Status] = @Status;
Select * From Inventories;
Go
-- Success

-- Test the Delete Procedure for the Inventories Table

Declare @Status int;
Exec @Status = pDelInventories @InventoryID = 7;
Select [pDelInventories Status] = @Status;
Select * From Inventories;
Go
-- Success
-- All nine procedures work.