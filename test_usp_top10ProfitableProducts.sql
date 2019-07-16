-- Test script to find the top 10 most profitable products of all time
-- N.B. Make sure to have run the create_usp_top10ProfitableProducts script prior to running this script

-- Tell SQL which database to use
Use OfficeWizard
GO

-- Execute the script
EXECUTE usp_top10ProfitableProducts
GO