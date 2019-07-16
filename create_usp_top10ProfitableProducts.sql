-- N.B. Use this script prior running the test_usp_top10ProfitableProducts script
USE OfficeWizard
GO

-- Create a procedure to generate a top 10 list of the most profitable products that Office Wizard sells
CREATE PROCEDURE usp_top10ProfitableProducts
	AS
		BEGIN
			SELECT Top 10 
				(p.productID) AS ProductID,
				p.productName,
				SUM(CustomerOrderItem.quantity) AS 'Quantity Sold', --Find the total quantity sold for that particular productItem
				SUM(sellingPrice - costPrice) AS 'Unit Profit', -- subtract the selling price and the cost price of items to get the unit profit
				(SUM(sellingPrice - costPrice) * SUM(CustomerOrderItem.quantity)) AS 'Total Profit' -- subtract the selling price by the cost price and then multiply by total quantity sold to get the total profit 
			
			FROM 
			Product p,
			CustomerOrderItem,
			ProductItem
			WHERE CustomerOrderItem.quantity > 0 AND p.productID = ProductItem.productID -- join the product and product item tables
			AND ProductItem.custOrderID = CustomerOrderItem.custOrderID -- join the customer order item and product item tables	
			GROUP BY p.productID, p.productName
			ORDER BY 'Total Profit' DESC -- Order the results so that the most profitable product is at the top of the list
		END
GO