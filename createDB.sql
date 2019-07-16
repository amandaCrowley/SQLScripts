--INFT3007 The Information Resource
--Assignment 2 - Database Design & Implementation
--Samantha Tegart, Amanda Crowley, Erin Craft

--Create the database for Office Wizard
CREATE DATABASE OfficeWizard;
GO

USE OfficeWizard;
GO

--DROP DATABASE OfficeWizard

--Create Product Table
CREATE TABLE Product (
	productID				CHAR(5) PRIMARY KEY,					-- product identification
	productName				VARCHAR(100) NOT NULL UNIQUE,			-- the name of the product
	manufacturer			VARCHAR(100) NOT NULL,					-- manufacturer of the product
	categoryName			VARCHAR(100) NOT NULL,					-- category which the product belongs
	prodDescription			VARCHAR(100) NOT NULL,					-- description of the product
	quantityDescription		VARCHAR(100) NOT NULL,					-- description of the quantity of the product
	unitPrice				DECIMAL(19,2) NOT NULL,					-- unit price of the product. Stored with 2 decimal places
	productStatus			VARCHAR(100) NOT NULL,					-- status of the product. e.g. in stock
	availableQuantity		INTEGER NOT NULL,						-- number of available stock of product
	reOrderLevel			VARCHAR(10) NOT NULL,					-- level at which to reorder product
	maxDiscount				DECIMAL(5,2) DEFAULT 000.00 CHECK (maxDiscount BETWEEN 000.00 AND 100.00),	-- maximum discount that can be applied to the product
)

-- Create the Postcode Table
CREATE TABLE Postcode(
	streetName				VARCHAR(50),																		-- Street name located within the suburb
	suburb					VARCHAR(20) NOT NULL,																-- Suburb associated with a postcode
	postcode				SMALLINT,																			-- A unique number associated with a street or mailing address
	
	CONSTRAINT pkPostcode PRIMARY KEY (streetName, suburb)
);	


CREATE TABLE Employee(
	employeeID				CHAR(10) PRIMARY KEY,																			-- unique identifier for an employee 
	firstName				VARCHAR(50) NOT NULL,																			-- the first name of the employee
	lastName				VARCHAR(50) NOT NULL,																			-- the first name of the employee
	gender					CHAR(3) NOT NULL CHECK (gender IN ('M', 'F', 'N/A')),											-- gender of the employee
	userName				CHAR(15) NOT NULL,																				-- employee's user name used for the database login
	password				VARCHAR(20) NOT NULL,																			-- employee's password used for the database login
	houseNumber				CHAR(10) NOT NULL,																				-- the house number for the address of the employee
	streetName				VARCHAR(50) NOT NULL,																			-- the street name for the address of the employee
	suburb					VARCHAR(20) NOT NULL,																			-- the suburb name for the address of the employee
	homePhone				VARCHAR(20),																							-- the phone number of the employee, not always applicable
	mobilePhone				VARCHAR(20) NOT NULL,																					-- the mobile phone contact number of the employee, always applicable
	dOB						DATE NOT NULL,																					-- employee's date of birth

	FOREIGN KEY(streetName,suburb) REFERENCES Postcode(streetName,suburb) ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE Position(
	positionID 				CHAR(10) PRIMARY KEY,							-- unique identifier for a position 
	title					VARCHAR(30) NOT NULL,							-- title of the position (e.g. sales assistant, manager)
	hourlyRate				DECIMAL (19,2) NOT NULL CHECK (hourlyRate > 0), -- hourly rate of the position (in dollars/cents)
);

--Create the Customer Table
CREATE TABLE Customer(
	customerID				CHAR(10) PRIMARY KEY,					-- unique identifier for the customer
	houseNumber				CHAR(10) NOT NULL,						-- the house number for the address of the customer
	streetName				VARCHAR(50) NOT NULL,					-- the street name for the address of the customer
	suburb					VARCHAR(20) NOT NULL,					-- the suburb name for the address of the customer
	homePhone				VARCHAR(20),							-- the phone number of the customer, not always applicable
	mobilePhone				VARCHAR(20) NOT NULL,					-- the mobile phone contact number of the customer, always applicable
	faxNumber				VARCHAR(20),							-- the customer fax contact number, not always applicable
	email					VARCHAR(320) NOT NULL UNIQUE,			-- email address of the customer, always applicable

	FOREIGN KEY(streetName,suburb) REFERENCES Postcode(streetName,suburb) ON UPDATE CASCADE ON DELETE NO ACTION
)

--Create the Individual (customer) Table
CREATE TABLE Individual(
	customerID				CHAR(10) PRIMARY KEY,					-- unique identifier for the customer (FK from customer parent table)
	firstName				VARCHAR(50) NOT NULL,					-- the first name of the individual customer
	lastName				VARCHAR(50) NOT NULL,					-- the last name of the individual customer
	gender					VARCHAR(3) NOT NULL CHECK (gender IN ('M', 'F', 'N/A')),	--gender of the individual customer

	CONSTRAINT fk_individual_customer FOREIGN KEY (customerID) REFERENCES Customer (customerID) ON UPDATE CASCADE ON DELETE NO ACTION
);

--Create the Corporate (customer) Table
CREATE TABLE Corporate(
	customerID				CHAR(10) PRIMARY KEY,					-- unique identifier for the customer (FK from customer parent table)
	contactName				VARCHAR(50) NOT NULL,					-- the contact person name for the corporate customer
	compName				VARCHAR(100) NOT NULL UNIQUE,			-- the company name of the corporate customer

	CONSTRAINT fk_corporate_customer FOREIGN KEY (customerID) REFERENCES Customer (customerID) ON UPDATE CASCADE ON DELETE NO ACTION
) ;

CREATE TABLE Allowance(
	allowanceID 			CHAR(10) PRIMARY KEY,							-- unique identifier for an allowance type 
	amount					DECIMAL (19,2) NOT NULL CHECK (amount >= 0),	-- allowance amount in dollars/cents (e.g. 543.54)
	allowanceType			CHAR(25) NOT NULL, 								-- allowance type e.g. sales bonus, first-aid, meal
	aDescription			VARCHAR(100),									-- description of the allowance type
	frequency				CHAR(12) NOT NULL,								-- frequency of the allowance type (e.g. monthly, weekly, bi-annually)
);

CREATE TABLE TaxBracket(
	taxID					CHAR(10) PRIMARY KEY,												-- unique identifier for a tax bracket 
	taxBracketStart			DECIMAL (19,2) NOT NULL CHECK (taxBracketStart >= 0),				-- start amount for tax bracket (in dollars/cents)
	taxBracketEnd			DECIMAL (19,2) NOT NULL CHECK (taxBracketEnd > 0),					-- end amount for tax bracket (in dollars/cents)
	taxRate					DECIMAL (19,2) NOT NULL CHECK (taxRate BETWEEN 0.00 AND 100.00),	-- rate that tax is to be calculated at - percentage - e.g. 6.88
	effectiveYear			SMALLINT CHECK (effectiveYear BETWEEN 1900 AND 2050)				-- year in which the tax bracket is effective (e.g. 2016, 2012)  
);

--Create the Customer Order Table
CREATE TABLE CustomerOrder(
	custOrderID				INT IDENTITY(1,1) PRIMARY KEY,			--identifies the customer order.
	orderDate				DATE NOT NULL,							-- date the customer order was lodged
	totalAmountDue			DECIMAL(19,2) NOT NULL,					-- the total cost due for the customer order
	totalAmountPaid			DECIMAL(19,2),							-- total amount paid by the customer
	custOrderStatus			VARCHAR(20) NOT NULL,					-- the status of the customer order
	employeeID				CHAR(10) FOREIGN KEY REFERENCES Employee (employeeID) ON UPDATE NO ACTION ON DELETE NO ACTION,	--identifies the employee involved in the customer order
	customerID				CHAR(10) FOREIGN KEY REFERENCES Customer (customerID) ON UPDATE NO ACTION ON DELETE NO ACTION,	--identified the customer who the order belongs to
	modeOfSale				VARCHAR(25) NOT NULL,					-- the method in which the order was processed
	discount				DECIMAL(5,2) DEFAULT 000.00 CHECK (discount BETWEEN 000.00 AND 100.00),		--discount (if any) applied to the customer order
)

-- Create the Supplier Table
CREATE TABLE Supplier(
	supplierID			CHAR(10) PRIMARY KEY,																					-- Unique identifier for a supplier
	name				VARCHAR(100) NOT NULL,																					-- The company name of the supplier
	streetNumber		VARCHAR(10) NOT NULL,																					-- Street number of the supplier’s address
	streetName			VARCHAR(50) NOT NULL,																					-- Street name of the supplier’s address
	suburb				VARCHAR(20) NOT NULL,																					-- The Suburb the supplier is located in
	phoneNumber			VARCHAR(20) NOT NULL,																					-- The phone number of the supplier	
	faxNumber			VARCHAR(20),																							-- The fax number of the supplier (not always applicable)
	contactPerson		VARCHAR(50) NOT NULL,																					-- The name of the contact at the supplier’s company
	
	FOREIGN KEY(streetName,suburb) REFERENCES Postcode(streetName,suburb) ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE Quote(
	quoteID					CHAR(10) PRIMARY KEY,																				-- unique identifier for a quote 
	dateOfQuote				DATE NOT NULL,																						-- date the quote was generated
	validityPeriod			SMALLINT CHECK (validityPeriod BETWEEN 1 AND 12),													-- number of months the quote is valid for 
	quoteDescription		VARCHAR(100),   																					-- description of the quote
	supplierID				CHAR(10) FOREIGN KEY REFERENCES Supplier (supplierID) ON UPDATE NO ACTION ON DELETE NO ACTION,		-- id of the supplier providing the quote
	employeeID				CHAR(10) FOREIGN KEY REFERENCES Employee (employeeID) ON UPDATE NO ACTION ON DELETE NO ACTION,		-- id of the employee who requested the quote
);

-- Create the Supplier Order Table
CREATE TABLE SupplierOrder(	
	supplierOrderID		CHAR(10) PRIMARY KEY,																					-- Unique identifier for the supplier order
	orderDate			DATE NOT NULL,																							-- The date the order was made
	orderDescription	VARCHAR(50) NOT NULL,																					-- Description about the supplier order  
	quoteID				CHAR(10) FOREIGN KEY REFERENCES Quote(quoteID) ON UPDATE CASCADE ON DELETE NO ACTION,					-- Unique identifier given to each quote (FK from the Quote parent table)
	totalAmountDue		DECIMAL(19,2) NOT NULL CHECK (totalAmountDue >= 0),														-- The total amount of the order that is due. Stored with 2 decimal places
	orderStatus			VARCHAR(20) NOT NULL,																					-- The status of the order (e.g. received, completed, delayed, etc.)
	orderReceivedDate	DATE NOT NULL,																							-- The date the order is received
	paymentDate			DATE NOT NULL,																							-- The date the payment for the order is made
	paymentRefNo		CHAR(10) NOT NULL																						-- Payment reference number linking to a separate accounting system
);

--Create ProductItem Table
CREATE TABLE ProductItem (
	barcode					CHAR(15) PRIMARY KEY,					-- barcode number for each product item
	costPrice				DECIMAL(19,2) NOT NULL,					-- cost price amount for each product item
	supplierOrderID			CHAR(10) FOREIGN KEY REFERENCES SupplierOrder (supplierOrderID) ON UPDATE CASCADE ON DELETE NO ACTION,	--Identifies the supplier order and is foreign key from SupplierOrder table
	sellingPrice			DECIMAL(19,2) NOT NULL,					-- selling price of product item
	productID				CHAR(5) FOREIGN KEY REFERENCES Product (productID) ON UPDATE CASCADE ON DELETE NO ACTION,	--product id of the item from product table
	custOrderID				INT FOREIGN KEY REFERENCES CustomerOrder (custOrderID) ON UPDATE CASCADE ON DELETE NO ACTION,	-- identifies the customer order and is foreign key from customer order table
	itemStatus				VARCHAR(20) NOT NULL,					-- indicates the status of the product item
);

--Create the Customer Order Item Table 
CREATE TABLE CustomerOrderItem(
	custOrderID				INT FOREIGN KEY REFERENCES CustomerOrder (custOrderID) ON UPDATE NO ACTION ON DELETE NO ACTION,	--the customer order the item is associated with
	barcode					CHAR(15) FOREIGN KEY REFERENCES ProductItem (barcode) ON UPDATE CASCADE ON DELETE NO ACTION,		--the barcode of the product item in the customer order
	unitSellPrice			DECIMAL(19,2),	--the unit selling price of the item on the customer order
	quantity				INTEGER NOT NULL,						-- the number(quantity) of the specific item in the customer order
	subtotal				DECIMAL (19,2) NOT NULL,				-- the subtotal cost of the customer order
	totalItemDiscount		DECIMAL(19,2) NOT NULL,					-- the total item discount cost (in dollars/cents)

	CONSTRAINT pkCustomerOrderItem PRIMARY KEY (custOrderID, barcode),
);

CREATE TABLE Payslip(
	payslipID 				INT IDENTITY(1,1) PRIMARY KEY,																	-- unique identifier for a payslip
	employeeID				CHAR(10) FOREIGN KEY REFERENCES Employee (employeeID) ON UPDATE CASCADE ON DELETE NO ACTION,	-- identifies the employee to whom the payslip belongs (FK from employee table)
	startDate				DATE NOT NULL,																					-- date the pay period commenced
	endDate					DATE NOT NULL,																					-- date the pay period finished
	hoursWorked				DECIMAL (19,2) DEFAULT 0.00,  																	-- the number of hours worked by the employee recieving the payslip (e.g. 19.5, 20, 11 etc)
	positionID				CHAR(10) FOREIGN KEY REFERENCES Position (positionID) ON UPDATE CASCADE ON DELETE NO ACTION,	-- position id of the employee receiving the payslip (FK from position table)
	basePay					DECIMAL (19,2) NOT NULL,																		-- base pay of the employee in dollars/cents (e.g. 23.12, 12.50) 
	allowanceAmount			DECIMAL (19,2) DEFAULT 0.00,																	-- total allowances allocated to the employee (in dollars/cents)
	taxID					CHAR(10) FOREIGN KEY REFERENCES TaxBracket (taxID) ON UPDATE CASCADE ON DELETE NO ACTION,		-- identifies the tax bracket in which the payslip belongs (FK from taxBracket table)
	taxableIncome			DECIMAL (19,2) NOT NULL,																		-- amount of pay that the tax needs to be calculated on in dollars/cents (i.e. gross pay)
	taxAmount				DECIMAL (19,2) NOT NULL,																		-- total amount of tax the employee needs to pay for this pay period (in dollars/cents) 
	netPay					AS taxableIncome - taxAmount,																	-- total amount the employee is to be paid (in dollars/cents) for this pay period
);

CREATE TABLE PayslipAllowance(
	allowanceID				CHAR(10) FOREIGN KEY REFERENCES Allowance (allowanceID) ON UPDATE CASCADE ON DELETE NO ACTION,	-- identifies the allowance id of the allowance item 	(FK from allowance table)
	payslipID				INT FOREIGN KEY REFERENCES Payslip (payslipID) ON UPDATE CASCADE ON DELETE NO ACTION,			-- identifies the payslip id to which the allowance item belongs (FK from payslip table)
	totalAmount				DECIMAL (19,2),																					-- total allowance amount for a particular payslip in dollars/cents (e.g. 543.54)

	CONSTRAINT pk_payslip_allowance PRIMARY KEY (allowanceID, payslipID)
);

CREATE TABLE PositionHistory(
	employeeID				CHAR(10) FOREIGN KEY REFERENCES Employee (employeeID) ON UPDATE CASCADE ON DELETE NO ACTION,		-- employee id who worked/works in the position (FK from the Employee parent table)
	positionID				CHAR(10) FOREIGN KEY REFERENCES Position (positionID) ON UPDATE CASCADE ON DELETE NO ACTION,		-- id of the position the employee worked in (FK from the Position parent table)
	startDate				DATE,			-- date the employee started working in the position
	endDate					DATE,			-- date the employee stopped working in the position (may be empty for current employees)

	CONSTRAINT pk_position_history PRIMARY KEY (employeeID, positionID, startDate)
);

-- Create the Delivery (CustomerOrder) Table
CREATE TABLE Delivery(
	custOrderID			INT PRIMARY KEY,																				-- Unique identifier for the customer order. (FK from the CustomerOrder parent table)
	deliveryCharge		DECIMAL(19,2),																							-- The amount charged for delivery. Stored with 2 decimal places
	houseNumber			VARCHAR(10) NOT NULL,																					-- Street number of the customer’s delivery address
	streetName			VARCHAR(50) NOT NULL,																					-- Street name of the customer’s delivery address
	suburb				VARCHAR(20) NOT NULL,																					-- Suburb name of the customer's delivery address

	CONSTRAINT fk_delivery_customerOrder FOREIGN KEY (custOrderID) REFERENCES CustomerOrder (custOrderID) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY(streetName,suburb) REFERENCES Postcode(streetName,suburb) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Create the Pickup (CustomerOrder) Table
CREATE TABLE Pickup(
	custOrderID			INT PRIMARY KEY,																				-- Unique identifier for the customer order. (FK from the CustomerOrder parent table)
	dateOfRetrieval		DATE NOT NULL,																							-- The date the customer order is picked up from the store

	CONSTRAINT fk_pickup_customerOrder FOREIGN KEY (custOrderID) REFERENCES CustomerOrder (custOrderID) ON UPDATE CASCADE ON DELETE NO ACTION
);


-- Create the Supplier Inventory Table
CREATE TABLE SupplierInventory(
	supplierID			CHAR(10) FOREIGN KEY REFERENCES Supplier(supplierID) ON UPDATE CASCADE ON DELETE NO ACTION,				-- Unique identifier for a supplier (FK from the Supplier parent table)
	productID			CHAR(5) FOREIGN KEY REFERENCES Product(productID) ON UPDATE CASCADE ON DELETE NO ACTION					-- Unique identifier for product identification (FK from the Product parent table)

	CONSTRAINT pkSupplierInventory PRIMARY KEY (supplierID, productID)
);

-- Create the Supplier Order Item Table
CREATE TABLE SupplierOrderItem(
	supplierOrderID		CHAR(10) FOREIGN KEY REFERENCES SupplierOrder(supplierOrderID) ON UPDATE NO ACTION ON DELETE NO ACTION,	-- Unique identifier for the supplier order (FK from the SupplierOrder parent table)
	barcode				CHAR(15) FOREIGN KEY REFERENCES	ProductItem(barcode) ON UPDATE CASCADE ON DELETE NO ACTION,				-- The unique barcode number for each product item (FK from the ProductItem parent table)
	unitPrice			DECIMAL (19,2) NOT NULL CHECK (unitPrice >= 0),															-- Unit price for each product in the supplier order. Stored with 2 decimal places
	quantity			INTEGER NOT NULL																						-- Quantity of each product in the supplier order

	CONSTRAINT pkSupplierOrderItem PRIMARY KEY (supplierOrderID, barcode)
);

-- Create the Quote Item Table
CREATE TABLE QuoteItem(
	productID			CHAR(5) FOREIGN KEY REFERENCES Product(productID) ON UPDATE CASCADE ON DELETE NO ACTION,				-- Unique identifier for product identification (FK from the Product parent table)
	quoteID				CHAR(10) FOREIGN KEY REFERENCES Quote(quoteID) ON UPDATE CASCADE ON DELETE NO ACTION,					-- Unique identifier given to each quote (FK from the Quote parent table)
	unitPrice			DECIMAL (19,2) NOT NULL CHECK (unitPrice >= 0),															-- Unit price for each product in the quote. Stored with 2 decimal places
	quantity			INTEGER NOT NULL																						-- Quantity of each product in the quote

	CONSTRAINT pkQuoteItem PRIMARY KEY (productID, quoteID)
);

----------------------------------------------------------------------------
--INSERTING DATA
----------------------------------------------------------------------------

--Postcode table = StreetName, Suburb, Postcode
INSERT INTO Postcode VALUES ('Peter St', 'Gosford', 2250);
INSERT INTO Postcode VALUES ('Wattle Rd', 'Woy Woy', 2256);
INSERT INTO Postcode VALUES ('Pothole Ln', 'Springfield', 2250);
INSERT INTO Postcode VALUES ('Sydney St', 'Umina Beach', 2257);
INSERT INTO Postcode VALUES ('Rose St', 'Bensville', 2251);
INSERT INTO Postcode VALUES ('Melbourne Rd', 'Wyong', 2259);
INSERT INTO Postcode VALUES ('Cherry Cl', 'Wyong', 2259);

--Employee table = employeeID, firstName, lastName, gender, userName, password, houseNumber, streetName, suburb, homePhone, mobilePhone, dOB
INSERT INTO Employee VALUES ('1','Tim','Borg','M','tBorg', 'march121','12','Peter St', 'Gosford', 43658765, '0465455899', '1976-05-01');
INSERT INTO Employee VALUES ('2','Paul', 'Stanton', 'M', 'pStanton', 'lionsAndTigers_555#', 654, 'Wattle Rd', 'Woy Woy', 43321144, '0497999665', '1990-12-27');
INSERT INTO Employee VALUES ('3','Jenny', 'Summmers', 'F', 'jSummers', 'yolo12*', '99B', 'Rose St', 'Bensville', 45767611, '0499988776','1985-11-06');
INSERT INTO Employee VALUES ('4','Tiffany', 'South', 'F', 'tSouth', 'password123*', '32','Sydney St', 'Umina Beach', NULL,'0412276536','1978-10-30');
INSERT INTO Employee VALUES ('5','George', 'Grundy', 'M', 'gGrundy' , 'pinkrose543', '22', 'Pothole ln', 'Springfield', NULL, '0456666777', '1966-05-22');
INSERT INTO Employee VALUES ('6','Bob', 'Duncan', 'N/A', 'bDuncan' , 'chirpy^^#', '11A', 'Pothole ln', 'Springfield', NULL, '0456666777', '1995-04-21');
INSERT INTO Employee VALUES ('7','Terry', 'Hatcher', 'M', 'tHatcher' , 'PassWORD#123', '435a', 'Cherry Cl', 'Wyong', 43765098, '0433334567', '1992-08-18');

--Position table = positionID, title, hourlyRate
INSERT INTO Position VALUES ('1','Sales Assistant',25.60);
INSERT INTO Position VALUES ('2','Store Manager',55.10);
INSERT INTO Position VALUES ('3','Store Replenishment',18.35);
INSERT INTO Position VALUES ('4','Assistant Store Manager',45.00);
INSERT INTO Position VALUES ('5','Junior Sales Assiststant',15.70);

--PositionHistory Table = employeeID, positionID, startDate, endDate
INSERT INTO PositionHistory VALUES ('1','4','2011-01-25','2015-10-31');
INSERT INTO PositionHistory VALUES ('1','2','2015-11-01',NULL);
INSERT INTO PositionHistory VALUES ('2','1','2003-06-09','2005-04-07');
INSERT INTO PositionHistory VALUES ('3','2','2007-10-30','2010-09-02');
INSERT INTO PositionHistory VALUES ('4','3','2003-03-18','2005-02-09');
INSERT INTO PositionHistory VALUES ('5','4','2015-11-01',NULL);

--Supplier Table = supplierID, name, streetNumber, streetName, suburb, phoneNumber, faxNumber, contactPerson
INSERT INTO Supplier VALUES ('1', 'Nails R us', 901, 'Peter St', 'Gosford', 43876987, 43876988, 'Billy Bob');
INSERT INTO Supplier VALUES ('2', 'Taylor Tools', 89, 'Rose St', 'Bensville', 43111766, NULL, 'Tim Taylor');
INSERT INTO Supplier VALUES ('3', 'Hart industries', 11, 'Sydney St', 'Umina Beach', 43889093, NULL, 'Mary Hart');
INSERT INTO Supplier VALUES ('4', 'Wyong hammers', 1, 'Cherry Cl', 'Wyong', 43765778, 43765777, 'Ming tsu');
INSERT INTO Supplier VALUES ('5', 'Steel supplies', '12B', 'Pothole ln', 'Springfield', 43554677, NULL, 'Steve Turner');

--Quote Table = quoteID, dateOfQuote, validityPeriod, quoteDescription, supplierID, employeeID
INSERT INTO Quote VALUES ('1', '2016-03-22', 2, '15 Verge Pro Tablets from Computers R Us','1','2');
INSERT INTO Quote VALUES ('2', '2016-02-21', 11, 'Special on portable hard drives from Taylors Tech Tools','2','1');
INSERT INTO Quote VALUES ('3', '2016-01-14', 2, 'Blue Ballpoint Pens - Feb catalogue special','5','5');
INSERT INTO Quote VALUES ('4', '2016-03-09', 3, '25 Techsmart Wireless Mouses','2','3');
INSERT INTO Quote VALUES ('5', '2016-02-01', 6, '5 JA Laser Printers','4','3');
INSERT INTO Quote VALUES ('6', '2016-04-06', 4, 'Stocktake Sale on Calculators', '3', '3');
INSERT INTO Quote VALUES ('7', '2016-04-14', 3, '20 Peach eNotepads from Computers R Us', '1', '7');
INSERT INTO Quote VALUES ('8', '2016-05-26', 6, '25 Verge 64GB Tablets from Computer R Us', '1', '5');
INSERT INTO Quote VALUES ('9', '2016-06-01', 5, 'Special on Stretch paper 500 sheets', '5', '4');
INSERT INTO Quote VALUES ('10', '2016-06-01', 1, '200 HB pencil bulk buy - Jan catalogue special', '5','2');
INSERT INTO Quote VALUES ('11', '2016-07-10', 9, '10 laser printer toners from Wyong Printers', '4','6');

-- Allowance table = allowanceID, amount, allowanceType, aDescription, frequency
INSERT INTO Allowance VALUES ('1', 100,'Sales Bonus', 'Awarded to sales employees when make more than 1000 sales in a week', 'Weekly');
INSERT INTO Allowance VALUES ('2', 52.50, 'First Aid', 'Paid to employees with first aid certificate', 'Monthly');
INSERT INTO Allowance VALUES ('3', 25, 'Meal allowance', 'Paid to employees traveling on business', 'One-off');
INSERT INTO Allowance VALUES ('4', 590.9, 'Assistant manager Bonus', 'Paid to Assistant manager if store makes > $20000 weekly profits', 'Weekly');
INSERT INTO Allowance VALUES ('5', 250, 'Employee of the month', 'Awarded to any employee', 'Monthly');

-- TaxBracket table = taxID, taxBracketStart, taxBracketEnd, taxRate, effectiveYear
INSERT INTO TaxBracket VALUES ('1', 0, 999.99, 0.2, 2016);
INSERT INTO TaxBracket VALUES ('2', 1000, 4999.99, 3.23, 2016);
INSERT INTO TaxBracket VALUES ('3', 5000, 9999.99, 4.28, 2016);
INSERT INTO TaxBracket VALUES ('4', 10000, 19999.99, 6.3, 2015);
INSERT INTO TaxBracket VALUES ('5', 20000, 49999.99, 9.36, 2015);

-- Payslip table = payslipID, employeeID, startDate, endDate, hoursWorked, positionID, basePay, allowanceAmount, taxID, taxableIncome, taxAmount, netPay
INSERT INTO Payslip VALUES (1,'2017-01-01','2017-01-31', 98.6, 2, 5432.86, 100, 4, 5532.86, 236.81);
INSERT INTO Payslip VALUES (2,'2005-03-01','2005-03-31', 25.5, 1, 652.80, 25.00, 1, 677.8, 1.35);
INSERT INTO Payslip VALUES (5,'2016-11-01','2016-11-30', 39.5, 4, 2176.45, 52.50, 1, 2228.95, 4.46);
INSERT INTO Payslip VALUES (4,'2004-05-01','2004-05-31', 150, 3, 18.35, 0, 3, 2752.50, 117.81);

-- PayslipAllowance Table = allowanceID (allowance table), payslipID (payslip table), totalAmount		
INSERT INTO PayslipAllowance VALUES (1, 1, 100);
INSERT INTO PayslipAllowance VALUES (1, 2, 100);
INSERT INTO PayslipAllowance VALUES (2, 1, 52.50);
INSERT INTO PayslipAllowance VALUES (3, 2, 25);
INSERT INTO PayslipAllowance VALUES (3, 4, 25);
INSERT INTO PayslipAllowance VALUES (4, 4, 590.90);

-- Product table = productID, productName, manufacturer, catergoryName, prodDescription, quantityDescription, unitPrice, productStatus, availableQuantity, reOrderLevel, maxDiscount
INSERT INTO Product VALUES ('1', 'Stretch Paper', 'Gaia', 'Paper', 'High quality 160gsm paper','5 boxes of paper',10.00, 'In Stock', 50, '15', 020.00);
INSERT INTO Product VALUES ('2', 'Flexable Office Stool', 'B.Digger', 'Furniture', 'Adjustable Kneeling Stool Black', '0 boxes of chairs', 150.00, 'Back Order', 0, '10', 010.00);
INSERT INTO Product VALUES ('3', 'Macrofirm Verge Pro', 'Macrofirm', 'Tablet', 'White Verge Pro WiFi, 128GB', '3 boxes of tablets', 850.00, 'In Stock', 30, '15', 005.00);
INSERT INTO Product VALUES ('4', 'Blue Ballpoint Pens', 'B.Digger', 'Pen', 'Blue Ballpoint Pens with a 1.0 nib', '1 box of 30 pen packets', 5.00, 'In Stock', 50, '20', 005.00);
INSERT INTO Product VALUES ('5', 'eNotepad', 'Peach', 'Laptop', 'Black eNotepad WiFi', '3 boxes of laptops', 1200.00, 'In Stock', 2, '10', 000.00);
INSERT INTO Product VALUES ('6', 'Macrofirm Verge', 'Macrofirm', 'Tablet', 'Black Verge WiFi, 64GB', '2 boxes of tablets', 650.00, 'In Stock', 17, '15', 005.00);
INSERT INTO Product VALUES ('7', 'Black Ballpoint Pens', 'B.Digger', 'Pen', 'Black Ballpoint Pens with a 1.0 nib', '1 box of 30 pen packets', 5.00, 'In Stock', 15, '20', 005.00);
INSERT INTO Product VALUES ('8', 'Stretch Paper Box', 'Gaia', 'Paper','Stretch Ultra A4 White 500 Sheet 5 Pack', 'A pallot of 20 boxes of paper', 25.00, 'In Stock', 30, '15', 030.00);
INSERT INTO Product VALUES ('9', 'JA Printer', 'JA', 'Printer', 'Laser Printer', '1 box of laser printers', 300.00, 'In Stock', 2, '5', 000.00);
INSERT INTO Product VALUES ('10', 'Studybuddy Exercise Book', 'Studybuddy', 'Exercise Book', 'Studybuddy Premium A4 Exercise Book 128 Page', '3 boxes of books', 2.50, 'In Stock', 50, '25', 050.00);
INSERT INTO Product VALUES ('11', 'JA Toner Cartridge', 'JA', 'Toner Cartridge', '15N LaserJet Toner', '2 boxes of printer cartridges', 375.00, 'In Stock', 5, '10', 005.00);
INSERT INTO Product VALUES ('12', 'Techsmart Wireless Mouse', 'Techsmart', 'Wireless Mouse', 'Techsmart Ergonomic Wireless Mouse Black', '2 boxes of mouses', 35.00, 'In Stock', 40, '20', 000.00);
INSERT INTO Product VALUES ('13', 'Scientific Calculator', 'Galaxy', 'Scientific Calculator', 'Grey Scientific calculator', '1 box of calculators', 45.00, 'In Stock', 30, '10', 030.00);
INSERT INTO Product VALUES ('14', 'HB Graphite Pencils', 'B.Digger', 'Pencils', 'Easy to sharpen and erase HB pencils', '1 box of 5 pack pencils', 3.50, 'In Stock', 50, '20', 020.00);
INSERT INTO Product VALUES ('15', 'Portable Hard Drive', 'Shiba', 'Portable Hard Drives', '2TB HD', '1 box of Hard Disk Drives', 100.00, 'In Stock', 10, '20', 015.00);

-- Customer table = customerID, houseNumber, streetName, suburb, homePhone, mobilePhone, faxNumber, email
INSERT INTO Customer VALUES('1','23', 'Peter St', 'Gosford', NULL, '0456234812', '43851655', 'iheartstationary@gmail.com');
INSERT INTO Customer VALUES('2', '14', 'Pothole Ln', 'Springfield', '43753548', '0478925479', NULL, 'JRRTolkien@live.com');
INSERT INTO Customer VALUES('3','7', 'Rose St', 'Bensville', NULL, '0471652459', NULL, 'sk8t0rBoi@yahoo.com.au');
INSERT INTO Customer VALUES('4','49', 'Pothole Ln', 'Springfield', '43579125', '0465987512', '43642258', 'Rowling.JK@gmail.com' );
INSERT INTO Customer VALUES('5', '3', 'Melbourne Rd', 'Wyong', '43363325', '0452136579', '43896685', 'P.Simon@leningrad.com.au');
INSERT INTO Customer VALUES('6', '36', 'Cherry Cl', 'Wyong', NULL, '0466777846', NULL,'redTwine@thecottage.com.au');
INSERT INTO Customer VALUES('7', '10', 'Sydney St', 'Umina Beach','43721568', '0422268978', '43568971', 'MbirdPublishing@gmail.com');
INSERT INTO Customer VALUES('8', '1', 'Wattle Rd', 'Woy Woy', '43589745', '0499653120', NULL, 'timmyPrintSupplies@gmail.com');

-- CustomerOrder table = custOrderID(Identity column - auto increments), orderDate, totalAmountDue, totalAmountPaid, custOrderStatus, employeeID, customerID, modeOfSale, discount
INSERT INTO CustomerOrder VALUES ('2016-07-31', 1200, 1182, 'Dispatched','7', '3', 'Phone', 18);
INSERT INTO CustomerOrder VALUES ('2017-02-15', 70, 57.8,'Received', '3', '7', 'Phone', 12.20);
INSERT INTO CustomerOrder VALUES ('2017-04-22', 1657.50, 1652.5, 'Delivered','5', NULL, 'Store', 5);
INSERT INTO CustomerOrder VALUES ('2016-10-01', 28, 25.5, 'Received','7', '5','Store', 2.50);
INSERT INTO CustomerOrder VALUES ('2016-05-13', 63, 48, 'Received', '4', '1','Online', 15);
INSERT INTO CustomerOrder VALUES ('2016-09-05', 1425, 1419.1, 'Delivered','2', '4', 'Store', 5.90);
INSERT INTO CustomerOrder VALUES ('2016-11-12', 160, 140, 'Ready to Collect','6', '6', 'Store', 20);
INSERT INTO CustomerOrder VALUES ('2016-06-20', 617.50, 612.5, 'Dispatched', '4', '2', 'Store', 5);
INSERT INTO CustomerOrder VALUES ('2017-01-18', 47.50, 42, 'Delivered', '3', '5', 'Online', 5.50);	
INSERT INTO CustomerOrder VALUES ('2017-03-01', 3000, 3000, 'Delivered', '5', '8', 'Store', 0);	
INSERT INTO CustomerOrder VALUES ('2016-08-24', 170, 154.30, 'Delivered', '7', '3', 'Online', 15.70);	

-- SupplierOrder table = supplierOrderID, orderDate, orderDescription, quoteID, totalAmountDue, orderStatus, orderReceivedDate, paymentDate, paymentRefNo
INSERT INTO SupplierOrder VALUES ('1', '2016-01-14', '1 box of Blue Ballpoint Pens', '3', 50, 'Received', '2016-01-21', '2016-01-14', '1');		
INSERT INTO SupplierOrder VALUES ('2', '2016-02-01', '5 boxes of JA Laser Printers', '5', 2000, 'Received', '2016-02-15', '2016-02-01', '2');
INSERT INTO SupplierOrder VALUES ('3', '2016-02-22', '2 boxes of Shiba portable 2TB hard drives', '2', 1400, 'Received', '2016-03-07', '2016-02-22', '3');		
INSERT INTO SupplierOrder VALUES ('4', '2016-03-09', '3 boxes of Techsmart Wireless Mouses', '4', 300, 'Received', '2016-03-30', '2016-03-09', '3');	
INSERT INTO SupplierOrder VALUES ('5', '2016-03-22', '2 boxes of Verge Pro Tablets', '1', 5000, 'Received', '2016-04-12', '2016-03-22','4');		
INSERT INTO SupplierOrder VALUES ('6', '2016-04-06', '1 box of Galaxy Scientific Calculators', '6', 200, 'Received', '2016-04-13', '2016-04-06', '5');
INSERT INTO SupplierOrder VALUES ('7', '2016-04-14', '4 boxes of eNotepads', '7', 8000, 'Received', '2016-04-21', '2016-04-14', '4');
INSERT INTO SupplierOrder VALUES ('8', '2016-05-26', '3 boxes of Verge Tablets', '8', 10000, 'Received', '2016-06-09','2016-05-26', '4');
INSERT INTO SupplierOrder VALUES ('9', '2016-06-01', '5 boxes of 500 sheet Stretch paper', '9', 100, 'Received', '2016-06-03', '2016-06-01', '1');
INSERT INTO SupplierOrder VALUES ('10', '2016-06-01', '1 box of HB Pencils', '10', 200, 'Received', '2016-06-22', '2016-06-01', '1');
INSERT INTO SupplierOrder VALUES ('11', '2016-07-06', '2 boxes of Printer toners', '11', 2000, 'Received', '2016-07-28', '2016-07-06', '2');

-- ProductItem table = barcode, costPrice, supplierOrderID, sellingPrice, productID, custOrderID, itemStatus
INSERT INTO ProductItem VALUES ('7456985425414', 800.00, '7', 1200.00, '5', '1','In Stock');
INSERT INTO ProductItem VALUES ('9780201379624', 500.00, '5', 850.00, '3','3', 'In Stock');
INSERT INTO ProductItem VALUES ('2548956231140', 5.00,'9', 10.00, '1', '7', 'In Stock');
INSERT INTO ProductItem VALUES ('4669612357450', 200.00, '11', 375.00, '11', '6', 'In Stock');
INSERT INTO ProductItem VALUES ('6421357956682', 1.00, '10', 3.50, '14', '4', 'In Stock');
INSERT INTO ProductItem VALUES ('3182033548951', 400.00, '8', 650.00, '6', '8', 'In Stock');
INSERT INTO ProductItem VALUES ('4466587445614', 20.00, '6', 45.00, '13', '5', 'In Stock');
INSERT INTO ProductItem VALUES ('8463216554651', 15.00, '4', 35.00, '12', '2', 'In Stock');
INSERT INTO ProductItem VALUES ('1549642587840', 3.00, '1', 5.00, '4', '9', 'In Stock');
INSERT INTO ProductItem VALUES ('5468413648970', 200.00, '2', 300.00, '9', '10', 'In Stock');
INSERT INTO ProductItem VALUES ('9766452157841', 70.00, '3', 100.00, '15', '11', 'In Stock');
INSERT INTO ProductItem VALUES ('3366587145612', 3.00, '10', 6.00, '7', '5', 'In Stock');
INSERT INTO ProductItem VALUES ('8488216554651', 290.00, '4', 350.00, '8', '2', 'In Stock');
INSERT INTO ProductItem VALUES ('1166587775612', 2.50, '10', 4.50, '10', '5', 'In Stock');
INSERT INTO ProductItem VALUES ('2288216554651', 5.00, '4', 8.00, '2', '2', 'In Stock');

-- CustomerOrderItem table = custOrderID, barcode, unitSellPrice, quantity, subtotal, totalItemDiscount
INSERT INTO CustomerOrderItem VALUES (1, '7456985425414', 1200.00, 1, 1200.00, 000.00);
INSERT INTO CustomerOrderItem VALUES (1, '8463216554651', 35.00, 2, 70.00, 000.00);
INSERT INTO CustomerOrderItem VALUES (1, '9780201379624', 850.00, 2, 1700.00, 42.50);
INSERT INTO CustomerOrderItem VALUES (2, '6421357956682', 3.50, 10, 35.00, 7.00);
INSERT INTO CustomerOrderItem VALUES (3, '4466587445614', 45.00, 2, 90.00, 27.00);
INSERT INTO CustomerOrderItem VALUES (11, '2548956231140', 10.00, 20, 200.00, 40.00);
INSERT INTO CustomerOrderItem VALUES (6, '3182033548951', 650.00, 1, 650.00, 32.50);
INSERT INTO CustomerOrderItem VALUES (7, '1549642587840', 5.00, 10, 50.00, 2.50);
INSERT INTO CustomerOrderItem VALUES (9, '5468413648970', 300.00, 10, 3000.00, 000.00);
INSERT INTO CustomerOrderItem VALUES (5, '9766452157841', 100.00, 2, 200.00, 30.00);

-- QuoteItem Table = productID (product table), quoteID (quote table), unitPrice, quantity
INSERT INTO QuoteItem VALUES (1, 9, 10.00, 10);
INSERT INTO QuoteItem VALUES (3, 1, 850.00, 10);
INSERT INTO QuoteItem VALUES (4, 3, 5.00, 20);
INSERT INTO QuoteItem VALUES (5, 7, 1200.00, 1);
INSERT INTO QuoteItem VALUES (6, 8, 650.00, 5);
INSERT INTO QuoteItem VALUES (9, 5, 300.00, 1);
INSERT INTO QuoteItem VALUES (11, 11, 375.00, 2);
INSERT INTO QuoteItem VALUES (12, 4, 35.00, 10);
INSERT INTO QuoteItem VALUES (13, 6, 45.00, 15);
INSERT INTO QuoteItem VALUES (14, 10, 3.50, 25);
INSERT INTO QuoteItem VALUES (15, 2, 100.00, 2);

-- Individual (customer) Table = customerID, firstName, lastName, gender
INSERT INTO Individual VALUES (2, 'John Ronald Reuel', 'Tolkein', 'M');
INSERT INTO Individual VALUES (4, 'Joanne', 'Rowling', 'F');
INSERT INTO Individual VALUES (5, 'P', 'Simon', 'N/A');
INSERT INTO Individual VALUES (6, 'Rachel', 'Twine', 'F');

-- Coporate (Customer) Table = customerID, contactName, compName
INSERT INTO Corporate VALUES (1, 'John Smith', 'I Heart Stationery');
INSERT INTO Corporate VALUES (3, 'Tony Hawk', 'Birdhouse');
INSERT INTO Corporate VALUES (7, 'Harper Lee', 'Mockingbird Publishing');
INSERT INTO Corporate VALUES (8, 'Timothy Print', 'Timmys Printing Supplies');

-- SupplierOrderItem Table = supplierOrderID (SupplierOrder table), barcode (productItem table), unitPrice, quantity
INSERT INTO SupplierOrderItem VALUES (1, 6421357956682, 3, 100);
INSERT INTO SupplierOrderItem VALUES (2, 5468413648970, 200, 10);
INSERT INTO SupplierOrderItem VALUES (3, 9766452157841, 70, 20);
INSERT INTO SupplierOrderItem VALUES (4, 8463216554651, 15, 20);
INSERT INTO SupplierOrderItem VALUES (5, 9780201379624, 500, 10);
INSERT INTO SupplierOrderItem VALUES (6, 4466587445614, 20, 30);
INSERT INTO SupplierOrderItem VALUES (7, 7456985425414, 800, 10);
INSERT INTO SupplierOrderItem VALUES (8, 3182033548951, 400, 25);
INSERT INTO SupplierOrderItem VALUES (9, 2548956231140, 5, 20);
INSERT INTO SupplierOrderItem VALUES (10, 6421357956682, 1, 200);
INSERT INTO SupplierOrderItem VALUES (11, 4669612357450, 200, 10);

-- SupplierInventory Table = supplierID (supplier table), productID (product table)
INSERT INTO SupplierInventory VALUES (1, 3);
INSERT INTO SupplierInventory VALUES (1, 5);
INSERT INTO SupplierInventory VALUES (1, 6);
INSERT INTO SupplierInventory VALUES (2, 1);
INSERT INTO SupplierInventory VALUES (2, 12);
INSERT INTO SupplierInventory VALUES (3, 15);
INSERT INTO SupplierInventory VALUES (4, 9);
INSERT INTO SupplierInventory VALUES (4, 11);
INSERT INTO SupplierInventory VALUES (5, 4);
INSERT INTO SupplierInventory VALUES (5, 7);
INSERT INTO SupplierInventory VALUES (5, 14);
