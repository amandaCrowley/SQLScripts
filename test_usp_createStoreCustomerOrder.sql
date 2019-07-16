--INFT3007 Amanda Crowley 29/04/17

-- Test script for create store customer order
--Ensure you have created usp_createStoreCustomerOrder first

USE OfficeWizard;

BEGIN TRY
	-- Declare temp insert table for product barcode and quantity
	DECLARE @productInfoTable AS UT_ProductBarcodeInfo;

--UPDATE VALUES TO CHANGE CUSTOMER ORDER
	DECLARE @customerID CHAR(10) = 2;							/**** Change this value to adjust which customer places the order - can be null *****/ 	 
	DECLARE @employeeID	CHAR(10) = '5';							/**** Change this value to adjust which employee handles the sales order *****/
	DECLARE @modeOfSale VARCHAR(25) = 'Phone';					/**** Change this value to adjust the mode of sale - Online, In-store or Phone *****/
	DECLARE @customerOrderdiscount DECIMAL (19,2) = 50;			/**** Change this value to adjust the amount to discount from the entire customer order (e.g. 0 or 35.50 etc) *****/
	DECLARE @salesOrderID INT;									-- output parameter that specifies the newly created customer order id. 
	
	--INSERT PRODUCT ITEM barcodes AND qunatity INTO THE PRODUCT INFO TABLE
	/**** TO ADD ANOTHER PRODUCT TO A CUSTOMER ORDER - add another insert row here, with a barcode that matches a barcode field from ProductItem table and a quantity *****/
	INSERT INTO @productInfoTable VALUES (3182033548951, 2);
	--END INSERTING

	--ERROR CHECKING
		DECLARE @barcodeID CHAR(20); --Temporarily stores the barcode

		DECLARE ProductInfoCursor CURSOR -- Declare cursor
		FOR 
		SELECT prodInfo.barcode -- Select the barcode from the TVP @productInfoTable
		FROM @productInfoTable prodInfo
		FOR READ ONLY;

		OPEN ProductInfoCursor
		FETCH NEXT FROM ProductInfoCursor INTO @barcodeID -- Stores next barcode value into @barcodeID

		--CURSOR LOOP
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Raise an error if any barcode entered is not in the productItem table
		   IF (@barcodeID IS NOT NULL)
				IF NOT EXISTS (SELECT ProductItem.barcode
								FROM ProductItem, @productInfoTable prod
								WHERE ProductItem.barcode = @barcodeID)
					RAISERROR ('Data not inserted - Barcode no. %s not found in the Product item table.', 16, 1, @barcodeID); 
				-- Raise an error if the quantity of a product customer is trying to purchase is greater than the amount that is in stock
				DECLARE @availableQuantity INT = 0;

				--SET @availableQuantity to the quantity that is available for the product id of the current barcoded item (in the loop)  
				SET @availableQuantity = (SELECT availableQuantity
										  FROM Product
										  INNER JOIN ProductItem ON ProductItem.productID = Product.productID
										  INNER JOIN @productInfoTable p ON ProductItem.barcode = p.barcode
										  WHERE ProductItem.barcode = @barcodeID);
				
				--Check quantity level (IF availableQuantity - quantity in @productInfoTable < 0  = error)
				IF @availableQuantity - (SELECT p.quantity
										 FROM @productInfoTable p
										 INNER JOIN ProductItem ON ProductItem.barcode = p.barcode 
										 WHERE ProductItem.barcode = @barcodeID)
										 < 0 
										 RAISERROR ('Data not inserted - Not enough of product no. %s in stock to continue with customer order.', 16, 1, @barcodeID); 		
				FETCH NEXT FROM ProductInfoCursor INTO @barcodeID	  --Stores the next barcode value
		END
		CLOSE ProductInfoCursor 
		DEALLOCATE ProductInfoCursor 
		--END CURSOR LOOP

		IF NOT EXISTS(
			SELECT employeeID
			FROM Employee
			WHERE employeeID = @employeeID)
			RAISERROR ('Data not inserted - Employee not found.', 16, 1); -- Raise an error if the employee id entered is not in the database

		IF @modeOfSale NOT IN('Online','online','phone','Phone','In-store','in-store','In-Store')
			RAISERROR ('Data not inserted - Please enter a valid mode of sale for the customer order e.g. Online, Phone or In-store.', 16, 1); -- Raise an error if mode of sale is not an accpeted mode
		
		IF (@customerOrderdiscount < 0 OR @customerOrderdiscount IS NULL)
			RAISERROR ('Data not inserted - Customer order discount amount must be 0 or above.', 16, 1); -- Raise an error if the customer order discount amount is less than 0
		--END ERROR CHECKING

EXECUTE usp_createStoreCustomerOrder
	@customerID,			--customerid input
	@productInfoTable,      --TVP of barcodes
	@employeeID,			--employee id input
	@modeOfSale,			--customer order mode of sale
	@customerOrderdiscount,	-- customer order dicount amount
	@salesOrderID OUT		-- output parameter
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

--TEST CASE 1 - with 3 items
----INSERT PRODUCT ITEM barcodes AND qunatity INTO THE PRODUCT INFO TABLE
--/**** TO ADD ANOTHER PRODUCT TO A CUSTOMER ORDER - add another insert row here, with a barcode that matches a barcode field from ProductItem table and a quantity *****/
--INSERT INTO @productInfoTable VALUES (3182033548951, 1);
--INSERT INTO @productInfoTable VALUES (4466587445614, 3);
--INSERT INTO @productInfoTable VALUES (1549642587840, 6);
----END INSERTING

--TEST CASE 2 - Error check productItem not found
----INSERT PRODUCT ITEM barcodes AND qunatity INTO THE PRODUCT INFO TABLE
--/**** TO ADD ANOTHER PRODUCT TO A CUSTOMER ORDER - add another insert row here, with a barcode that matches a barcode field from ProductItem table and a quantity *****/
--INSERT INTO @productInfoTable VALUES (3456765448951, 1);

--TEST CASE 3 - Error check employee not found
--UPDATE VALUES TO CHANGE CUSTOMER ORDER
	--DECLARE @customerID CHAR(10) = '2';							/**** Change this value to adjust which customer places the order - can be null *****/ 	 
	--DECLARE @employeeID	CHAR(10) = '20';							/**** Change this value to adjust which employee handles the sales order *****/
	--DECLARE @modeOfSale VARCHAR(25) = 'Phone';					/**** Change this value to adjust the mode of sale - Online, In-store or Phone *****/
	--DECLARE @customerOrderdiscount DECIMAL (19,2) = 50;			/**** Change this value to adjust the amount to discount from the entire customer order (e.g. 0 or 35.50 etc) *****/
	--DECLARE @salesOrderID INT;									-- output parameter that specifies the newly created customer order id. 

--TEST CASE 4 - NULL customer 
--UPDATE VALUES TO CHANGE CUSTOMER ORDER
	--DECLARE @customerID CHAR(10) = NULL;							/**** Change this value to adjust which customer places the order - can be null *****/ 	 
	--DECLARE @employeeID	CHAR(10) = '5';							/**** Change this value to adjust which employee handles the sales order *****/
	--DECLARE @modeOfSale VARCHAR(25) = 'Phone';					/**** Change this value to adjust the mode of sale - Online, In-store or Phone *****/
	--DECLARE @customerOrderdiscount DECIMAL (19,2) = 50;			/**** Change this value to adjust the amount to discount from the entire customer order (e.g. 0 or 35.50 etc) *****/
	--DECLARE @salesOrderID INT;									-- output parameter that specifies the newly created customer order id. 

--TEST CASE 5 - Error check mode of sale 
--UPDATE VALUES TO CHANGE CUSTOMER ORDER
	--DECLARE @customerID CHAR(10) = 2;							/**** Change this value to adjust which customer places the order - can be null *****/ 	 
	--DECLARE @employeeID	CHAR(10) = '5';							/**** Change this value to adjust which employee handles the sales order *****/
	--DECLARE @modeOfSale VARCHAR(25) = 'blah';					/**** Change this value to adjust the mode of sale - Online, In-store or Phone *****/
	--DECLARE @customerOrderdiscount DECIMAL (19,2) = 50;			/**** Change this value to adjust the amount to discount from the entire customer order (e.g. 0 or 35.50 etc) *****/
	--DECLARE @salesOrderID INT;									-- output parameter that specifies the newly created customer order id. 

-- TEST CASE 6 - Error check stocks level insuffcient
	----INSERT PRODUCT ITEM barcodes AND qunatity INTO THE PRODUCT INFO TABLE
	--/**** TO ADD ANOTHER PRODUCT TO A CUSTOMER ORDER - add another insert row here, with a barcode that matches a barcode field from ProductItem table and a quantity *****/
	--INSERT INTO @productInfoTable VALUES (3182033548951, 100);
	----END INSERTING
