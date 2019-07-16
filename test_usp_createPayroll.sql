--INFT3007 Amanda Crowley 29/04/17

--TEST SCRIPT TO CREATE PAYROLL
--Make sure you have created the stored procedure - usp_createPayroll - first

USE OfficeWizard;
GO

BEGIN TRY
	-- Declare insert tables and employee info variables 
	DECLARE @empHrsDataTable AS UT_EmployeeHoursWorkedInfo;
	DECLARE @empAllowanceDataTable AS UT_EmployeeAllowanceInfo

	--CHANGE THESE VALUES TO ADJUST PAYSLIP
	DECLARE @empID CHAR(10) = 1;				/**** Change this value to adjust who the payslip is to be made for *****/
	DECLARE @hoursWorked DECIMAL (19,2) = 20.5;	/**** Change this value to adjust how many hours worked for the pay period *****/
	DECLARE @taxID INT = 2;						/**** Change this value to adjust which tax bracket is to be applied to the employee's pay *****/
	DECLARE @startDate  DATE = '2017-03-01';	/**** Change this value to adjust the start date of the pay period -- FORMAT = YYYY-MM-DD*****/	
	DECLARE	@endDate DATE = '2017-03-30';		/**** Change this value to adjust the end date of the pay period -- FORMAT = YYYY-MM-DD *****/
	DECLARE @allowanceID CHAR(10) = 0;			-- Set the allowance ID
	/*You may add allowances (zero or more) to a payslip, just scroll down to the INSERT DATA INTO THE EMPLOYEE ALLOWANCE DATA TABLE section and add them where shown*/		

	/*****ADD ALLOWANCES HERE *****
	For each new allowance you want to add to the payslip, copy the next 2 lines and change the @allowanceID to = the relevant allowanceID
	If you do not wish to add any, comment out the next two lines*/
	SET @allowanceID = 1;
	INSERT INTO @empAllowanceDataTable VALUES (@empID, @allowanceID,(SELECT amount FROM Allowance WHERE allowanceID = @allowanceID));

	--INSERT DATA INTO THE EMPLOYEE HOURS TABLE
	INSERT INTO @empHrsDataTable VALUES (@empID, @hoursWorked);
	--END EMPLOYEE HOURS INSERTING

	--ERORR CHECKING
	IF NOT EXISTS(
			SELECT allowanceID
			FROM Allowance
			WHERE allowanceID = @allowanceID)
			AND @allowanceID != 0 -- Possible to allocate no allowance ID to this particular payslip
	       
			RAISERROR ('Data not inserted - Please choose an existing allowance ID.', 16, 1); -- Raise an error if the allowance id entered is not in the database
	
	IF @hoursWorked <=0
		RAISERROR ('Data not inserted - Employee has not worked any hours this pay period.', 16, 1); -- Raise an error if the employee does not work any hours within the pay period

	IF NOT EXISTS(
			SELECT employeeID
			FROM Employee
			WHERE employeeID = @empID)
        
			RAISERROR ('Data not inserted - Employee not found.', 16, 1); -- Raise an error if the employee id entered is not in the database

	IF NOT EXISTS(
			SELECT employeeID
			FROM PositionHistory
			WHERE endDate IS NULL AND employeeID = @empID)
        
			RAISERROR ('Data not inserted - Employee does not work in a current position.', 16, 1); -- Raise an error if the employee does not work in a current position (Employees only work in 1 position at a time)

	IF NOT EXISTS(
			SELECT taxID
			FROM TaxBracket
			WHERE taxID = @taxID)
        
			RAISERROR ('Data not inserted - Please choose an existing tax bracket.', 16, 1); -- Raise an error if the tax id entered is not in the database

	IF @startDate = '' OR @endDate = ''
		RAISERROR ('Data not inserted - Date is in an invalid format - Please use YYYY-MM-DD ', 16, 1); -- Raise an error if the either of the date variables are left empty
	
	IF @startDate NOT BETWEEN '2000-01-01' AND '2040-01-01'
		RAISERROR ('Data not inserted - The Payslip start and end dates must fall between the year 2000 and the year 2040', 16, 1); -- Raise an error if the start or end date entered is not within the range specified
	--END ERROR CHECKING
	EXECUTE usp_createPayroll 
		@startDate,
		@endDate,
		@taxID, 
		@empHrsWorkedInfo = @empHrsDataTable , 
		@empAllowanceInfo = @empAllowanceDataTable
END TRY
BEGIN CATCH
	--Store built in error function values
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	--Built in error functions - return error values
    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();

    -- Use RAISERROR inside the CATCH block to return error information about the original error that caused execution to jump to the CATCH block.
	RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH

--SELECT * FROM Payslip

--TEST CASE 1 - with 1 allowance
----CHANGE THESE VALUES TO ADJUST PAYSLIP
--	DECLARE @empID CHAR(10) = 1;				/**** Change this value to adjust who the payslip is to be made for *****/
--	DECLARE @hoursWorked DECIMAL (19,2) = 15.6;	/**** Change this value to adjust how many hours worked for the pay period *****/
--	DECLARE @taxID INT = 3;						/**** Change this value to adjust which tax bracket is to be applied to the employee's pay *****/
--	DECLARE @startDate  DATE = '2017-03-01';	/**** FORMAT = YYYY-MM-DD  - Change this value to adjust the start date of the pay period *****/	
--	DECLARE	@endDate DATE = '2017-03-30';		/**** FORMAT = YYYY-MM-DD  - Change this value to adjust the end date of the pay period *****/
--	/*You may add allowances (zero or more) to a payslip, just scroll down to the INSERT DATA INTO THE EMPLOYEE ALLOWANCE DATA TABLE section and add them where shown*/		

-- TEST CASE 2 - with multiple allowances
----CHANGE THESE VALUES TO ADJUST PAYSLIP
--	DECLARE @empID CHAR(10) = 1;				/**** Change this value to adjust who the payslip is to be made for *****/
--	DECLARE @hoursWorked DECIMAL (19,2) = 15.6;	/**** Change this value to adjust how many hours worked for the pay period *****/
--	DECLARE @taxID INT = 3;						/**** Change this value to adjust which tax bracket is to be applied to the employee's pay *****/
--	DECLARE @startDate  DATE = '2017-03-01';	/**** Change this value to adjust the start date of the pay period -- FORMAT = YYYY-MM-DD*****/	
--	DECLARE	@endDate DATE = '2017-03-30';		/**** Change this value to adjust the end date of the pay period -- FORMAT = YYYY-MM-DD *****/
--	DECLARE @allowanceID CHAR(10) = 0;			-- Set the allowance ID
--	/*You may add allowances (zero or more) to a payslip, just scroll down to the INSERT DATA INTO THE EMPLOYEE ALLOWANCE DATA TABLE section and add them where shown*/		
--	/*****ADD ALLOWANCES HERE *****
--	For each new allowance you want to add to the payslip, copy the next 2 lines and change the @allowanceID to = the relevant allowanceID
--	If you do not wish to add any, comment out the next two lines*/
--	SET @allowanceID = 1;
--	INSERT INTO @empAllowanceDataTable VALUES (@empID, @allowanceID,(SELECT amount FROM Allowance WHERE allowanceID = @allowanceID));
--	SET @allowanceID = 2;
--	INSERT INTO @empAllowanceDataTable VALUES (@empID, @allowanceID,(SELECT amount FROM Allowance WHERE allowanceID = @allowanceID));
--	SET @allowanceID = 5;
--	INSERT INTO @empAllowanceDataTable VALUES (@empID, @allowanceID,(SELECT amount FROM Allowance WHERE allowanceID = @allowanceID));

--TEST CASE 3 - with zero hours error
----CHANGE THESE VALUES TO ADJUST PAYSLIP
--	DECLARE @empID CHAR(10) = 5;				/**** Change this value to adjust who the payslip is to be made for *****/
--	DECLARE @hoursWorked DECIMAL (19,2) = 0;	/**** Change this value to adjust how many hours worked for the pay period *****/
--	DECLARE @taxID INT = 3;						/**** Change this value to adjust which tax bracket is to be applied to the employee's pay *****/
--	DECLARE @startDate  DATE = '2017-03-01';	/**** FORMAT = YYYY-MM-DD  - Change this value to adjust the start date of the pay period *****/	
--	DECLARE	@endDate DATE = '2017-03-30';		/**** FORMAT = YYYY-MM-DD  - Change this value to adjust the end date of the pay period *****/
--	/*You may add allowances (zero or more) to a payslip, just scroll down to the INSERT DATA INTO THE EMPLOYEE ALLOWANCE DATA TABLE section and add them where shown*/	

--TEST CASE 4 - with employee position error - i.e. doesn't work here anymore
----CHANGE THESE VALUES TO ADJUST PAYSLIP
--	DECLARE @empID CHAR(10) = 5;				/**** Change this value to adjust who the payslip is to be made for *****/
--	DECLARE @hoursWorked DECIMAL (19,2) = 0;	/**** Change this value to adjust how many hours worked for the pay period *****/
--	DECLARE @taxID INT = 3;						/**** Change this value to adjust which tax bracket is to be applied to the employee's pay *****/
--	DECLARE @startDate  DATE = '2017-03-01';	/**** FORMAT = YYYY-MM-DD  - Change this value to adjust the start date of the pay period *****/	
--	DECLARE	@endDate DATE = '2017-03-30';		/**** FORMAT = YYYY-MM-DD  - Change this value to adjust the end date of the pay period *****/
--	/*You may add allowances (zero or more) to a payslip, just scroll down to the INSERT DATA INTO THE EMPLOYEE ALLOWANCE DATA TABLE section and add them where shown*/	

--TEST CASE 4 - with employee id error - i.e. employee doesn't exist
----CHANGE THESE VALUES TO ADJUST PAYSLIP
--	DECLARE @empID CHAR(10) = 20;				/**** Change this value to adjust who the payslip is to be made for *****/
--	DECLARE @hoursWorked DECIMAL (19,2) = 0;	/**** Change this value to adjust how many hours worked for the pay period *****/
--	DECLARE @taxID INT = 3;						/**** Change this value to adjust which tax bracket is to be applied to the employee's pay *****/
--	DECLARE @startDate  DATE = '2017-03-01';	/**** FORMAT = YYYY-MM-DD  - Change this value to adjust the start date of the pay period *****/	
--	DECLARE	@endDate DATE = '2017-03-30';		/**** FORMAT = YYYY-MM-DD  - Change this value to adjust the end date of the pay period *****/
--	/*You may add allowances (zero or more) to a payslip, just scroll down to the INSERT DATA INTO THE EMPLOYEE ALLOWANCE DATA TABLE section and add them where shown*/	

--TEST CASE 5 - with tax id error - i.e. employee doesn't exist
----CHANGE THESE VALUES TO ADJUST PAYSLIP
--	DECLARE @empID CHAR(10) = 5;				/**** Change this value to adjust who the payslip is to be made for *****/
--	DECLARE @hoursWorked DECIMAL (19,2) = 0;	/**** Change this value to adjust how many hours worked for the pay period *****/
--	DECLARE @taxID INT = 10;						/**** Change this value to adjust which tax bracket is to be applied to the employee's pay *****/
--	DECLARE @startDate  DATE = '2017-03-01';	/**** FORMAT = YYYY-MM-DD  - Change this value to adjust the start date of the pay period *****/	
--	DECLARE	@endDate DATE = '2017-03-30';		/**** FORMAT = YYYY-MM-DD  - Change this value to adjust the end date of the pay period *****/
--	/*You may add allowances (zero or more) to a payslip, just scroll down to the INSERT DATA INTO THE EMPLOYEE ALLOWANCE DATA TABLE section and add them where shown*/	
