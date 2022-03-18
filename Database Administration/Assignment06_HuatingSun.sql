--**********************************************************************************************--Assignment06DB_HuatingSun
-- Title: Assigment06 
-- Author: Huating Sun
-- Desc: This file demonstrates how To design and Create; 
--       tables, constraints, views, stored procedures, and permissions
-- Change Log: When,Who,What
-- 2021-02-16,Huating Sun,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_HuatingSun')
	 Begin 
	  Alter Database [Assignment06DB_HuatingSun] Set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_HuatingSun;
	 End
	Create Database Assignment06DB_HuatingSun;
End Try
Begin Catch
	Print Error_Number();
End Catch
Go
Use Assignment06DB_HuatingSun;

-- Create Tables (Module 01)-- 
Create Table Students(
	StudentID int Constraint pkStudents Primary Key Not Null Identity (1, 1),
	StudentNumber nvarchar(100) Constraint uqStudentNumber Unique Not Null,
	StudentFirstName nvarchar(100) Not Null,
	StudentLastName nvarchar(100) Not Null,
	StudentEmail nvarchar(100) Constraint uqStudentEmail Unique Not Null,
	StudentPhone nvarchar(100) Constraint checkStudentPhone Check (
		StudentPhone Like '([0-9][0-9][0-9])-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]') Null,
	StudentAddress1 nvarchar(100) Not Null,
	StudentAddress2 nvarchar(100) Null,
	StudentCity nvarchar(100) Not Null,
	StudentStateCode nvarchar(100) Not Null,
	StudentZipCode nvarchar(100) Constraint checkStudentZipCode Check (
		StudentZipCode Like '[0-9][0-9][0-9][0-9][0-9]' Or 
		StudentZipCode Like '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]') Not Null
);
Go

Create Table Courses(
	CourseID int Constraint pkCourses Primary Key Not Null Identity (1, 1),
	CourseName nvarchar(100) Constraint uqCourseName Unique Not Null,
	CourseStartDate date Null,
	CourseEndDate date Null,
	CourseStartTime time Null,
	CourseEndTime time Null, 
	CourseWeekDays nvarchar(100) Null,
	CourseCurrentPrice money Null
);
Go

Create Table Enrollments(
	EnrollmentID int Constraint pkEnrollments Primary Key Not Null Identity (1, 1),
	StudentID int Constraint fkStudents Foreign Key References Students(StudentID) Not Null,
	CourseID int Constraint fkCourses Foreign Key References Courses(CourseID) Not Null,
	EnrollmentDateTime datetime Default GetDate() Not Null,
	EnrollmentPrice money Not Null
);
Go

-- Add Constraints (Module 02) -- 
Alter Table Courses
	Add Constraint checkEndDate Check (CourseEndDate > CourseStartDate),
		Constraint checkEndTime Check (CourseEndTime > CourseStartTime);
Go

Create Function dbo.fCStartDate
(@CourseID int)
Returns date
As
Begin
Return(
	Select CourseStartDate
	From Courses
	Where (CourseID = @CourseID)
)
End
Go

Alter Table Enrollments
	Add Constraint checkEnrollmentDate Check (EnrollmentDateTime < dbo.fCStartDate(CourseID));
Go

-- Add Views (Module 03 and 04) -- 
Create View vStudents
As
	Select 
		StudentID,
		StudentNumber,
		StudentFirstName, 
		StudentLastName,
		StudentEmail,
		StudentPhone,
		StudentAddress1,
		StudentAddress2,
		StudentCity,
		StudentStateCode,
		StudentZipCode
		From Students;
Go

Create View vCourses
As
	Select 
		CourseID,
		CourseName,
		CourseStartDate,
		CourseEndDate,
		CourseStartTime,
		CourseEndTime,
		CourseWeekDays,
		CourseCurrentPrice
		From Courses;
Go

Create View vEnrollments
As
	Select  
		EnrollmentID,
		StudentID,
		CourseID,
		EnrollmentDateTime,
		EnrollmentPrice
		From Enrollments;
Go

-- Add Stored Procedures (Module 04 and 05) --
-- Create reporting View for all three tables
Create View vStudentsEnrollemtsInCourses As
	Select C.CourseName As Course,
	 	CAST(C.CourseStartDate As nvarchar(150)) + ' To ' + CAST(C.CourseEndDate As nvarchar(150)) As Dates,
		C.CourseStartTime As StartTime,
		C.CourseEndTime As EndTime,
		C.CourseWeekDays As WeekDay,
		C.CourseCurrentPrice As Price,
		S.StudentFirstName + S.StudentLastName As Student,
		S.StudentNumber As Number,
		S.StudentEmail As Email,
		S.StudentPhone	As Phone,
		S.StudentAddress1 As Address1,
		S.StudentAddress2 As Address2,
		S.StudentCity As City,
		S.StudentStateCode	As State,
		S.StudentZipCode As ZipCode,
		E.EnrollmentDateTime As 'Signup date',
		E.EnrollmentPrice As Paid
	From Enrollments As E
	JOIN Students As S On E.StudentID = S.StudentID
	JOIN Courses As C On E.CourseID = C.CourseID;
Go
-- Add Stored Procedures (Module 04 and 05) --

-- Add Stored Procedures for Students
-- Add Inserting Procedure
Create Procedure pInsStudents (
  @Number nvarchar(100),
  @FirstName nvarchar(100),
	@LastName nvarchar(100),
	@Email nvarchar(100),
	@Phone nvarchar(100),
	@Address1 nvarchar(100),
	@Address2 nvarchar(100),
	@City nvarchar(100),
	@StateCode nvarchar(100),
	@ZipCode nvarchar(100)
)
/* Author: Huating Sun
** Desc: Insert procedure for the students
** Change Log:
** 2021-02-16, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Insert Into Students (
			StudentNumber, StudentFirstName, StudentLastName,
			StudentEmail, StudentPhone, StudentAddress1,
			StudentAddress2, StudentCity, StudentStateCode,
			StudentZipCode)
        Values (
			@Number, @FirstName, @LastName, @Email, @Phone, @Address1, @Address2, @City, @StateCode, @ZipCode);
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      IF(@@Trancount > 0) Rollback Transaction
      Print ERROR_MESSAGE();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Add Updating Procedure
Create Procedure pUpdStudents (
	@ID int,
	@Number nvarchar(100),
	@FirstName nvarchar(100),
	@LastName nvarchar(100),
	@Email nvarchar(100),
	@Phone nvarchar(100),
	@Address1 nvarchar(100),
	@Address2 nvarchar(100),
	@City nvarchar(100),
	@StateCode nvarchar(100),
	@ZipCode nvarchar(100)
)
/* Author: Huating Sun
** Desc: Update Procedure for the Students Table
** Change Log:
** 2021-02-16, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Update Students
        Set StudentNumber = @Number,
			StudentFirstName = @FirstName,
			StudentLastName = @LastName,
			StudentEmail = @Email,
			StudentPhone = @Phone,
			StudentAddress1 = @Address1,
			StudentAddress2 = @Address2,
			StudentCity = @City,
			StudentStateCode = @StateCode,
			StudentZipCode = @ZipCode
        Where StudentID = @ID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      IF(@@Trancount > 0) Rollback Transaction
      Print ERROR_MESSAGE();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Add Deleting Procedure
Create Procedure pDelStudents (
	@ID int
)
/* Author: Huating Sun
** Desc: Delete Procedure for the Students Table
** Change Log:
** 2021-02-16, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Delete From Students Where StudentID = @ID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      IF(@@Trancount > 0) Rollback Transaction
      Print ERROR_MESSAGE();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Add Stored Procedure for Courses
-- Add Inserting Procedure
Create Procedure pInsCourses (
  @Name nvarchar(100),
	@StartDate date,
	@EndDate date,
	@StartTime time,
	@EndTime time,
	@WeekDays nvarchar(100),
	@CurrentPrice money
)
/* Author: Huating Sun
** Desc: Insert Procedure for the Courses Table
** Change Log:
** 2021-02-16, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Insert Into Courses (
			CourseName, CourseStartDate, CourseEndDate,
			CourseStartTime, CourseEndTime, CourseWeekDays,
			CourseCurrentPrice)
        Values (
			@Name, @StartDate, @EndDate, @StartTime, @EndTime, @WeekDays, @CurrentPrice);
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      IF(@@Trancount > 0) Rollback Transaction
      Print ERROR_MESSAGE();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Add Updating Procedure
Create Procedure pUpdCourses (
	@ID int,
	@Name nvarchar(100),
	@StartDate date,
	@EndDate date,
	@StartTime time,
	@EndTime time,
	@WeekDays nvarchar(100),
	@CurrentPrice money
)
/* Author: Huating Sun
** Desc: Update Procedure for the Courses Table
** Change Log:
** 2021-02-16, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Update Courses
        Set CourseName = @Name,
			CourseStartDate = @StartDate,
			CourseEndDate = @EndDate,
			CourseStartTime = @StartTime,
			CourseEndTime = @EndTime,
			CourseWeekDays = @WeekDays,
			CourseCurrentPrice = @CurrentPrice
        Where CourseID = @ID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      IF(@@Trancount > 0) Rollback Transaction
      Print ERROR_MESSAGE();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Add Deleting Procedure
Create Procedure pDelCourses (
	@ID int
)
/* Author: Huating Sun
** Desc: Delete Procedure for the Courses Table
** Change Log:
** 2021-02-16, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Delete From Courses Where CourseID = @ID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      IF(@@Trancount > 0) Rollback Transaction
      Print ERROR_MESSAGE();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Add Stored Procedures for Enrollments
-- Add Inserting Procedure
Create Procedure pInsEnrollments (
	@StudentID int,
	@CourseID int,
	@datetime datetime,
	@Price money
)
/* Author: Huating Sun
** Desc: Insert Procedure for the Enrollment Table
** Change Log:
** 2021-02-16, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Insert Into Enrollments (StudentID, CourseID, EnrollmentDateTime, EnrollmentPrice)
        Values (@StudentID, @CourseID, @datetime, @Price);
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      IF(@@Trancount > 0) Rollback Transaction
      Print ERROR_MESSAGE();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Add Updating Procedure
Create Procedure pUpdEnrollments (
	@EnrollmentID int,
	@StudentID int,
	@CourseID int,
	@datetime datetime,
	@Price money
)
/* Author: Huating Sun
** Desc: Update Procedure for the Enrollment Table
** Change Log:
** 2021-02-16, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Update Enrollments
        Set StudentID = @StudentID,
						CourseID = @CourseID,
						EnrollmentDateTime = @datetime,
						EnrollmentPrice = @Price
        Where EnrollmentID = @EnrollmentID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      IF(@@Trancount > 0) Rollback Transaction
      Print ERROR_MESSAGE();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Add Deleting Procedure
Create Procedure pDelEnrollments (
	@ID int
)
/* Author: Huating Sun
** Desc: Delete Procedure for the Enrollment Table
** Change Log:
** 2021-02-16, Huating Sun, Created this Procedure.
*/
As
  Begin
    Declare @RC int = 0;
    Begin Try
      Begin Transaction
        Delete From Enrollments Where EnrollmentID = @ID;
      Commit Transaction
      Set @RC = +1
    End Try
    Begin Catch
      IF(@@Trancount > 0) Rollback Transaction
      Print ERROR_MESSAGE();
      Set @RC = -1
    End Catch
    Return @RC;
  End
Go

-- Set Permissions (Module 06) --
Deny Select, Insert, Update, Delete On Students To Public;
Deny Select, Insert, Update, Delete On Courses To Public;
Deny Select, Insert, Update, Delete On Enrollments To Public;
Grant Select On vStudents To Public;
Grant Select On vCourses To Public;
Grant Select On vEnrollments To Public;
Grant Select On vStudentsEnrollemtsInCourses To Public;
Grant Execute On pInsStudents To Public;
Grant Execute On pUpdStudents To Public;
Grant Execute On pDelStudents To Public;
Grant Execute On pInsCourses To Public;
Grant Execute On pUpdCourses To Public;
Grant Execute On pDelCourses To Public;
Grant Execute On pInsEnrollments To Public;
Grant Execute On pUpdEnrollments To Public;
Grant Execute On pDelEnrollments To Public;

--< Test Views and Sprocs >-- 

-- Add testing code to the table
Exec pInsStudents 
  @Number = 'B1-Smith-071', 
  @FirstName = 'Bob1', 
  @LastName = 'Smith1', 
  @Email = 'B1smith@HipMail.com', 
  @Phone = '(201)-111-2222',
  @Address1 = '1234 Main St.', 
  @Address2 = NULL, 
  @City = 'Seattle', 
  @StateCode = 'WA', 
  @ZipCode = '98002';
Go

Exec pInsStudents
  @Number = 'S-Jones-003', 
  @FirstName = 'Sue1', 
  @LastName = 'Jones1', 
  @Email = 'Sue1Jones@YaYou.com', 
  @Phone = '(201)-231-4321',
  @Address1 = '3214 Main St.', 
  @Address2 = NULL, 
  @City = 'Seattle', 
  @StateCode = 'WA', 
  @ZipCode = '98005';
Go

Exec pInsCourses
  @Name = 'SQL4 - Winter 2017', 
  @StartDate = '1/10/2017', 
  @EndDate = '1/24/2017', 
  @StartTime = '6PM', 
  @EndTime = '8:50PM',
  @WeekDays = 'T', 
  @CurrentPrice = 399;
Go

Exec pInsCourses
  @Name = 'SQL5 - Winter 2017', 
  @StartDate = '1/31/2017', 
  @EndDate = '2/14/2017', 
  @StartTime = '6PM', 
  @EndTime = '8:50PM',
  @WeekDays = 'T', 
  @CurrentPrice = 399;
Go

Exec pInsEnrollments
  @StudentID = 1, 
  @CourseID = 1, 
  @DateTime = '1/3/17', 
  @Price = 399;
Go

Exec pInsEnrollments
  @StudentID = 2, 
  @CourseID = 1,
  @DateTime = '12/14/16', 
  @Price = 349;
Go

Exec pInsEnrollments
  @StudentID = 2, 
  @CourseID = 2, 
  @DateTime = '12/14/16', 
  @Price = 349;
Go

Exec pInsEnrollments
  @StudentID = 1, 
  @CourseID = 2, 
  @DateTime = '1/12/17', 
  @Price = 399;
Go

-- Test the base view
Select * From vStudents;
Select * From vCourses;
Select * From vEnrollments;
Select * From vStudentsEnrollemtsInCourses;

-- Test Stored Procedures
-- Testing Insert Procedures
Declare @Status int;
Exec @Status = pInsStudents
  @Number = 'A-B-001', 
  @FirstName = 'A', 
  @LastName = 'B', 
  @Email = '123@HipMail.com', 
  @Phone = '(204)-222-2222',
  @Address1 = '1234 Main St.', 
  @Address2 = NULL, 
  @City = 'Seattle', 
  @StateCode = 'WA', 
  @ZipCode = '98001';
Select [pInsStudents Status] = @Status;
Select * From Students;
Go

Declare @Status int;
Exec @Status = pInsCourses
  @Name = 'SQL3 - Winter 2018', 
  @StartDate = '1/31/2017', 
  @EndDate = '2/14/2017', 
  @StartTime = '6PM', 
  @EndTime = '8:50PM',
  @WeekDays = 'Th', 
  @CurrentPrice = 499;
Select [pInsCourses Status] = @Status;
Select * From Courses;
Go

Declare @Status int;
Exec @Status = pInsEnrollments
  @StudentID = 3, 
  @CourseID = 3, 
  @DateTime = '1/3/16', 
  @Price = 499;
Select [pInsEnrollments Status] = @Status;
Select * From Enrollments;
Go

-- Test all update procedures
Declare @Status int;
Exec @Status = pUpdStudents
  @ID = 3, 
  @Number = 'B-A-002', 
  @FirstName = 'B', 
  @LastName = 'A', 
  @Email = '123@HipMail.com', 
  @Phone = '(204)-222-2222',
  @Address1 = '1234 Main St.', 
  @Address2 = NULL, 
  @City = 'Seattle', 
  @StateCode = 'WA', 
  @ZipCode = '98001';
Select [pUpdStudents Status] = @Status;
Select * From Students;
Go

Declare @Status int;
Exec @Status = pUpdCourses
  @ID = 3, 
  @Name = 'SQL3 - Winter 2018', 
  @StartDate = '2/18/2017', 
  @EndDate = '3/14/2017', 
  @StartTime = '6PM', 
  @EndTime = '8:50PM',
  @WeekDays = 'Th', 
  @CurrentPrice = 599;
Select [pUpdCourses Status] = @Status;
Select * From Courses;
Go

Declare @Status int;
Exec @Status = pUpdEnrollments
  @EnrollmentID = 5, 
  @StudentID = 3, 
  @CourseID = 3, 
  @DateTime = '1/5/16', 
  @Price = 599;
Select [pUpdEnrollments Status] = @Status;
Select * From Enrollments;
Go

-- Test all delete procedures
Declare @Status int;
Exec @Status = pDelEnrollments
  @ID = 5;
Select [pDelEnrollments Status] = @Status;
Select * From Enrollments;
Go

Declare @Status int;
Exec @Status = pDelStudents
  @ID = 3;
Select [pDelStudents Status] = @Status;
Select * From Students;
Go

Declare @Status int;
Exec @Status = pDelCourses
  @ID = 3
Select [pDelCourses Status] = @Status;
Select * From Courses;
Go

-- Remove all the testing data
Exec pDelEnrollments @ID = 1;
Exec pDelEnrollments @ID = 2;
Exec pDelEnrollments @ID = 3;
Exec pDelEnrollments @ID = 4;
Exec pDelStudents @ID = 1;
Exec pDelStudents @ID = 2;
Exec pDelCourses @ID = 1;
Exec pDelCourses @ID = 2;

-- Insert Stored Procedures to add the data from the spreadsheet into the tables.
Exec pInsStudents 
  @Number = 'B-Smith-071', 
  @FirstName = 'Bob', 
  @LastName = 'Smith', 
  @Email = 'Bsmith@HipMail.com', 
  @Phone = '(206)-111-2222',
  @Address1 = '123 Main St.', 
  @Address2 = NULL, 
  @City = 'Seattle', 
  @StateCode = 'WA', 
  @ZipCode = '98001';
Go

Exec pInsStudents
  @Number = 'S-Jones-003', 
  @FirstName = 'Sue', 
  @LastName = 'Jones', 
  @Email = 'SueJones@YaYou.com', 
  @Phone = '(206)-231-4321',
  @Address1 = '321 Main St.', 
  @Address2 = NULL, 
  @City = 'Seattle', 
  @StateCode = 'WA', 
  @ZipCode = '98001';
Go

Exec pInsCourses
  @Name = 'SQL1 - Winter 2017', 
  @StartDate = '1/10/2017', 
  @EndDate = '1/24/2017', 
  @StartTime = '6PM', 
  @EndTime = '8:50PM',
  @WeekDays = 'T', 
  @CurrentPrice = 399;
Go

Exec pInsCourses
  @Name = 'SQL2 - Winter 2017', 
  @StartDate = '1/31/2017', 
  @EndDate = '2/14/2017', 
  @StartTime = '6PM', 
  @EndTime = '8:50PM',
  @WeekDays = 'T', 
  @CurrentPrice = 399;
Go

Exec pInsEnrollments
  @StudentID = 4, 
  @CourseID = 4, 
  @DateTime = '1/3/17', 
  @Price = 399;
Go

Exec pInsEnrollments
  @StudentID = 5, 
  @CourseID = 4, 
  @DateTime = '12/14/16', 
  @Price = 349;
Go

Exec pInsEnrollments
  @StudentID = 5, 
  @CourseID = 5, 
  @DateTime = '12/14/16', 
  @Price = 349;
Go

Exec pInsEnrollments
  @StudentID = 4, 
  @CourseID = 5, 
  @DateTime = '1/12/17', 
  @Price = 399;
Go

Select * From vStudentsEnrollemtsInCourses;

--{ IMPORTANT }--
-- To get full credit, your script must run without having To highlight individual statements!!!  
/**************************************************************************************************/