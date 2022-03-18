/*************************************************************
Title: Mod01-A01HSun
Info 330 Module 1: Database Design
Dev: HSun
Huating Sun
ChangeLog(When, Who, What)
01/08/2021. HSun, Created Script
*************************************************************/

Use Master;
Go
If Exists (Select Name From SysDatabases Where Name = 'Assignment01DB_HSun')
	Drop Database Assignment01DB_HSun;
Go

Create Database Assignment01DB_HSun;
Go

Use Assignment01DB_HSun;
Go

-- This table contains the list of projects including the name and description.
-- ProjectID is used as the Primary Key
Create TABLE Project(
	ProjectID int Primary Key,
	ProjectName varchar(100),
	ProjectDescription varchar(150)
);
Go

-- This table contains the list of employees, including the first and last name of the employees
-- EmployeeID is used as the Primary Key
CREATE TABLE Employee(
	EmployeeID int Primary Key,
	EmployeeFirstName varchar(100),
	EmployeeLastName varchar(100)
);
Go

-- This bridge table contains the date and number of hours worked on a project
-- ProjectID and EmployeeID are used as the Primary Keys
CREATE TABLE ProjectDetail(
	ProjectID int,
	EmployeeID int,
	ProjectDetailDate datetime,
	ProjectDetailHours decimal(4,2),
	Primary Key (ProjectID, EmployeeID)
);
Go

SELECT*FROM Project;
SELECT*FROM Employee;
SELECT*FROM ProjectDetail;
Go