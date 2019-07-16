--Create a store customer order
USE OfficeWizard;

-- Create User-defined table for product barcode
CREATE TYPE UT_ProductBarcodeInfo AS TABLE( 
	barcode CHAR(20) primary key,
	quantity INTEGER NOT NULL
);  
GO

CREATE PROCEDURE usp_createStoreCustomerOrder
	@customerID CHAR(10),							-- Input parameter for customer who places the order
	@productInfo UT_ProductBarcodeInfo READONLY,	-- A table-valued parameter with barcode list of products
	@employeeID	CHAR(10),							-- Input parameter for the employee handling the sales order
	@modeOfSale VARCHAR(25),						-- Input parameter - input directly into customerOrder table
	@customerOrderdiscount DECIMAL (19,2),			-- Input parameter that specifies dicount amount for whole customer order
	@salesOrderID INT OUTPUT						-- output parameter that specifies the newly created customer order id.
	
AS
BEGIN		
		----------------------------------------------------------------------------------------------------------------
		--CUSTOMER ID CHECK
		----------------------------------------------------------------------------------------------------------------
		--Check customer id passed in, if not null and if the customer id doesn't exist in the customer table add it. 
		--Otherwise insert into customerOrder table as is null or not(Already in customer table if not null)
		IF @customerID IS NOT NULL	--Check if customer ID is null
		BEGIN
			IF NOT EXISTS (SELECT customerID
							FROM Customer
							WHERE customerID = @customerID)	--Check if customer ID passed in is already in customer table
			--Insert into customer table, if not already in the table
			INSERT INTO Customer VALUES (@customerID, 12,'Cherry Cl', 'Wyong', 43658798, 0439701829, NULL, 'slayer@hotmail.com'); -- Customer table = customerID, houseNumber, streetName, suburb, homePhone, mobilePhone, faxNumber, email
		END

		----------------------------------------------------------------------------------------------------------------
		--LOOP TO ADD UP THE TOTAL PRICE FOR THE CUSTOMER ORDER
		----------------------------------------------------------------------------------------------------------------
		DECLARE @barcodeID CHAR(20); -- Stores barcode value as the cursor moves through the @productInfo table
		DECLARE @totalSalePrice DECIMAL(19,2) =0; --Stores the total for the customer order
		DECLARE ProductInfoCursor CURSOR -- Declare cursor
		FOR 
		SELECT prodInfo.barcode -- Select the barcode from the TVP @@productInfo
		FROM @productInfo prodInfo
		FOR READ ONLY;

		OPEN ProductInfoCursor
		FETCH NEXT FROM ProductInfoCursor INTO @barcodeID -- Stores next barcode value into @barcodeID

		WHILE @@FETCH_STATUS = 0
		BEGIN
				--ADD UP THE TOTAL PRICE FOR THE CUSTOMER ORDER (For each barcoded item in the TVP passed in, add the product's unitPrice * quantity to the total)
				SET @totalSalePrice = @totalSalePrice + (SELECT (unitPrice * p.quantity)
														 FROM ProductItem
														 INNER JOIN @productInfo p ON ProductItem.barcode = p.barcode
														 INNER JOIN Product ON Product.productID = ProductItem.productID
														 WHERE ProductItem.barcode = @barcodeID);
				FETCH NEXT FROM ProductInfoCursor INTO @barcodeID	  --Stores the next barcode value
		END
		CLOSE ProductInfoCursor 

		----------------------------------------------------------------------------
		--INSERT STATEMENT AND CALCULATE totalAmountPaid (to be inserted)
		----------------------------------------------------------------------------
		DECLARE @totalAmountPaid DECIMAL (19,2) = @totalSalePrice - @customerOrderdiscount;
		--Check discount amount does not bring the total of the order under 0, if it does set the order total and total amount paid to 0
		IF(@totalSalePrice - @customerOrderdiscount < 0)
		BEGIN
			SET @totalAmountPaid = 0;
			SET @totalSalePrice = 0;
		END
		INSERT INTO CustomerOrder (orderDate, totalAmountDue, totalAmountPaid, custOrderStatus, employeeID, customerID, modeOfSale, discount)-- Customer Order table = orderDate, totalAmountDue, totalAmountPaid (Derived field. totalAmountDue - discount), custOrderStatus, employeeID, customerID, modeOfSale, discount
					VALUES((
						SELECT CONVERT(date, getDate())),
						@totalSalePrice,
						@totalAmountPaid, 
						'Completed',
						@employeeID,
						@customerID,
						@modeOfSale,
						@customerOrderdiscount);
		----------------------------------------------------------------------------------------------------------------
		--LOOP TO CHANGE ProductItem itemStatus and sellingPrice and Product quantity FOR ALL ITEMS SOLD IN THE CUSTOMER ORDER
		----------------------------------------------------------------------------------------------------------------
		SET @barcodeID = NULL; -- re-use barcode id variable from above loop
		--loop for each item in productItem TVP
		OPEN ProductInfoCursor
		FETCH NEXT FROM ProductInfoCursor INTO @barcodeID -- Stores next barcode value into @barcodeID

		WHILE @@FETCH_STATUS = 0
		BEGIN
		   IF @barcodeID IS NOT NULL
				-- Set the itemStatus to sold and set the selling price as whatever it was sold for
				UPDATE ProductItem 
				SET itemStatus = 'Sold', sellingPrice = (SELECT unitprice 
														 FROM Product
														 INNER JOIN ProductItem ON ProductItem.productID = Product.productID
														 INNER JOIN @productInfo p ON ProductItem.barcode = p.barcode
														 WHERE ProductItem.barcode = @barcodeID) -- Set the selling price as the unit price for the product
				WHERE ProductItem.barcode = @barcodeID;	
				
				-- Adjust the product's available quantity to account for the stock just sold 
				UPDATE Product
				SET availableQuantity = availableQuantity - (SELECT p.quantity
															FROM @productInfo p
															INNER JOIN ProductItem ON ProductItem.barcode = p.barcode
															INNER JOIN Product ON ProductItem.productID = Product.productID
															WHERE ProductItem.barcode = @barcodeID) 
				WHERE Product.productID = (SELECT Product.productID 
										   FROM Product
										   INNER JOIN ProductItem ON ProductItem.productID = Product.productID
										   INNER JOIN @productInfo p ON ProductItem.barcode = p.barcode
										   WHERE ProductItem.barcode = @barcodeID)
				FETCH NEXT FROM ProductInfoCursor INTO @barcodeID	 --Stores the next barcode value
		END
		CLOSE ProductInfoCursor 
		DEALLOCATE ProductInfoCursor 

		SET @salesOrderID = @@IDENTITY; -- Set the @salesOrderID Output parameter - specifies the newly created Customer Order id (identity column).
END
