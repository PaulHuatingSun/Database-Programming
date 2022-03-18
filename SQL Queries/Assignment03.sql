--*************************************************************************--
-- Title: Assignment03
-- Author: Huating Sun
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2021-01-23,Huating Sun,Created File
--**************************************************************************--


/********************************* Questions and Answers *********************************/
-- Data Request: 0301
-- Date: 1/1/2020
-- From: Jane Encharge CEO
-- Request: I want a list of customer companies and their contact people
-- Needed By: ASAP

Select CompanyName, ContactName From Northwind.dbo.Customers;

-- Data Request: 0302
-- Date: 1/2/2020
-- From: Jane Encharge CEO
-- Request: I want a list of customer companies and their contact people, but only the ones in US and Canada
-- Needed By: ASAP

Select CompanyName, ContactName, Country From Northwind.dbo.Customers
Where Country = 'Canada' Or Country = 'USA'
Order By Country, CompanyName;
-- Data Request: 0303
-- Date: 1/2/2020
-- From: Jane Encharge CEO
-- Request: I want a list of products, their standard price and their categories. Order the results by Category Name 
-- and then Product Name, in alphabetical order
-- Needed By: ASAP

Select CategoryName, ProductName, '$' + Cast(UnitPrice as nvarchar(200)) as 'Standard Price'
From Northwind.dbo.Products as P
Join Northwind.dbo.Categories as C on P.CategoryID = C.CategoryID
Order By CategoryName, ProductName;

-- Data Request: 0304
-- Date: 1/3/2020
-- From: Jane Encharge CEO
-- Request: I want a list of how many customers we have in the US
-- Needed By: ASAP

Select Count(*) as Count, Country From Northwind.dbo.Customers
Where Country = 'USA'
Group by Country;

-- Data Request: 0305
-- Date: 1/4/2020
-- From: Jane Encharge CEO
-- Request: I want a list of how many customers we have in the US and Canada, with subtotals for each
-- Needed By: ASAP

Select Count(*) as Count, Country From Northwind.dbo.Customers
Where Country = 'Canada' or Country = 'USA'
Group by Country;
/***************************************************************************************/