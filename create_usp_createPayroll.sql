--INFT3007 Amanda Crowley 29/04/17

--USE OfficeWizard
--Before passing the table variables to the stored procedure, first we need to create a user defined table types
USE OfficeWizard;
GO

  /* Create User-defined table employee hours worked */
CREATE TYPE UT_EmployeeHoursWorkedInfo AS TABLE( 
	employeeID CHAR(10) PRIMARY KEY,
	hoursWorked DECIMAL (19,2) 
);  

--/* Create User-defined table employee allowance info */ 
CREATE TYPE UT_EmployeeAllowanceInfo AS TABLE( 
	employeeID CHAR(10),
	allowanceTypeID CHAR(10) PRIMARY KEY, 
	allowanceAmount DECIMAL (19,2)
); 
GO

CREATE PROCEDURE usp_createPayroll
	@startDate Date, -- Start date for start of pay period
	@endDate Date, -- End date for the pay period
	@taxID CHAR(10), -- tax id for the tax bracket 
	@empHrsWorkedInfo UT_EmployeeHoursWorkedInfo READONLY, -- A table-valued parameter with employee id and hours worked for the pay period
	@empAllowanceInfo UT_EmployeeAllowanceInfo READONLY -- A table-valued parameter with employee id, allowance type id and allowance amount.	
AS
	BEGIN
		--ADD UP TOTAL ALLOWANCE AMOUNT ALLOCATED TO EMPLOYEE
		DECLARE @allowanceAmount DECIMAL (19,2);	--Holds allowance amount as cursor moves through TVP @empAllowanceInfo table
		DECLARE @allowanceTotal DECIMAL (19,2) = 0; --Total allowance amount - Iterative total of all allowance amounts in @empAllowanceInfo table

		DECLARE allowanceCursor CURSOR -- Declare cursor
		FOR 
		SELECT allowance.allowanceAmount -- Select the allowance amount from the TVP @empAllowanceInfo
		FROM @empAllowanceInfo allowance
		FOR READ ONLY;

		OPEN allowanceCursor
		FETCH NEXT FROM allowanceCursor INTO @allowanceAmount -- Stores next allowance amount into @allowanceAmount variable

		WHILE @@FETCH_STATUS = 0
		BEGIN
		   IF @allowanceAmount IS NOT NULL
				SET @allowanceTotal = @allowanceTotal + @allowanceAmount; --Add allowance in @allowanceAmount variable to total variable
				FETCH NEXT FROM allowanceCursor INTO @allowanceAmount	  --Stores the next allowance amount 
		END
		CLOSE allowanceCursor 
		DEALLOCATE allowanceCursor 
		--END OF ALLOWANCE CALCULATION SECTION

		-- Payslip table = payslipID, employeeID, startDate, endDate, hoursWorked, positionID, basePay, allowanceAmount, taxID, taxableIncome, taxAmount, netPay
		INSERT INTO Payslip (startDate,endDate, employeeID, hoursWorked, positionID, basePay, allowanceAmount, taxID, taxableIncome, taxAmount) --netPay is a calculated field
		SELECT 
			@startDate,
			@endDate,
			hrs.employeeID,
			hrs.hoursWorked,
			PositionHistory.positionID,
			Position.hourlyRate * hrs.hoursWorked, -- base pay = hourly rate * hours worked
			@allowanceTotal, -- Total allowance amount, allowances passed in through TVP and amounts are added up (in while loop above)
			@taxID,
			(Position.hourlyRate * hrs.hoursWorked) + @allowanceTotal, -- taxable income = base pay + allowance total amount
			((Position.hourlyRate * hrs.hoursWorked) + @allowanceTotal) * TaxBracket.taxRate /100 -- tax amount = (taxable income) * tax rate /100
			FROM @empHrsWorkedInfo hrs,
				 PositionHistory,
				 Position,
				 TaxBracket
			WHERE (PositionHistory.endDate IS NULL AND PositionHistory.employeeID = hrs.employeeId) -- join position history and employee tables
				 AND PositionHistory.positionID = Position.positionID -- Join position history and position tables
				 AND TaxBracket.taxID = @taxID -- Join tax table
	END
