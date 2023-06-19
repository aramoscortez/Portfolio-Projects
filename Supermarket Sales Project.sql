/*

Supermarket Sales Data Exploration 

Skills Used:
	- Case Statement
	- Subquery
	- Partitioning
	- Stored Procedures

*/


/*
QUESTIONS TO ASK/SCENARIOS:

Which branch has the best results in the loyalty program?

Which product category generates the highest income?

Classify the Rating field into categories.

Find the branch who produced the most sales (i.e. gross income from customers) for each month.

What proportion of customers buys Fashion accessories? Health and beauty? Electronic accessories? 
Food and beverages? Sports and travel? Home and lifestyle?

Create a Stored Procedure with a Parameter.

What are the two product lines that sell the most according to cost of goods sold (that is total - tax) for each branch?
*/

SELECT *
FROM Portfolio.dbo.supermarket_sales



--------------------------------------------------------------------------------------------------------------------------------------

-- Which branch has the best results in the loyalty program?

SELECT Branch, AVG(Total) AS [Average Sales], AVG(gross_income) AS [Average Gross Income from Customers], AVG(Rating) AS [Average Rating]
FROM Portfolio.dbo.supermarket_sales
WHERE Customer_type = 'Member'
GROUP BY Branch
ORDER BY [Average Sales] DESC




--------------------------------------------------------------------------------------------------------------------------------------

-- Which product category generates the highest income?

SELECT TOP 1 Product_line, SUM(gross_income) AS [Sum of Gross Income]
FROM Portfolio.dbo.supermarket_sales
GROUP BY Product_line
ORDER BY [Sum of Gross Income] DESC





--------------------------------------------------------------------------------------------------------------------------------------

-- Classify the Rating field into categories where
-- (1, 4) Below Average
-- [4, 6) Average
-- [6, 10] Above Average
-- AND add the field to the table 


SELECT Rating, 
CASE
WHEN Rating BETWEEN 1 AND 3.99999999999999 THEN 'Below Average'
WHEN Rating BETWEEN 4 AND 5.99999999999999 THEN 'Average'
ELSE 'Above Average'
END AS [Rating Category]
FROM Portfolio.dbo.supermarket_sales



ALTER TABLE Portfolio.dbo.supermarket_sales
ADD [Rating Category] nvarchar(255);

UPDATE Portfolio.dbo.supermarket_sales
SET [Rating Category] = CASE
WHEN Rating BETWEEN 1 AND 3.99999999999999 THEN 'Below Average'
WHEN Rating BETWEEN 4 AND 5.99999999999999 THEN 'Average'
ELSE 'Above Average'
END





--------------------------------------------------------------------------------------------------------------------------------------

-- Find the branch who produced the most sales (i.e. gross income from customers) for each month 

WITH CTE_BestSellerofMonth AS
(SELECT Branch, total, 
CASE
WHEN DATE BETWEEN '2019-01-01' AND '2019-01-31' THEN 'January'
WHEN DATE BETWEEN '2019-02-01' AND '2019-02-28' THEN 'February'
WHEN DATE BETWEEN '2019-03-01' AND '2019-03-31' THEN 'March'
END AS Month
FROM Portfolio.dbo.supermarket_sales)

SELECT Month, Branch, SUM(Total) AS [Sum of Total]
FROM CTE_BestSellerofMonth
GROUP BY Month, Branch
HAVING SUM(Total) = (
    SELECT MAX(subquery.total_sales)
    FROM (
      SELECT Month, Branch, SUM(Total) AS total_sales
      FROM CTE_BestSellerofMonth
      GROUP BY Month, Branch
    ) AS subquery
    WHERE subquery.Month = CTE_BestSellerofMonth.Month
  )
ORDER BY CASE 
	WHEN Month = 'January' THEN 1
	WHEN Month = 'February' THEN 2
	WHEN Month = 'March' THEN 3
	END;



-- An alternative way



WITH CTE_BestSellerOfMonth AS (
SELECT Branch, SUM(Total) AS [Sum of Total], DATEPART(MONTH, [Date]) AS Month,
RANK() OVER (PARTITION BY DATEPART(MONTH, [Date]) ORDER BY SUM(Total) DESC) AS Rank
FROM Portfolio.dbo.supermarket_sales
WHERE [Date] BETWEEN '2019-01-01' AND '2019-03-31'
GROUP BY Branch, DATEPART(MONTH, [Date])
)
SELECT Month, Branch, [Sum of Total]
FROM CTE_BestSellerOfMonth
WHERE Rank = 1;





--------------------------------------------------------------------------------------------------------------------------------------

-- What proportion of customers buys Fashion accessories? Health and beauty? Electronic accessories? Food and beverages? 
-- Sports and travel? Home and lifestyle ?

SELECT Product_line,
COUNT(Product_line) * 100.0 / (SELECT COUNT(*) FROM Portfolio.dbo.supermarket_sales) AS [Proportion]
FROM Portfolio.dbo.supermarket_sales
GROUP BY Product_line


--------------------------------------------------------------------------------------------------------------------------------------

-- Create a Stored Procedure with a Parameter given the following scenario: Return all fields given the Invoice_ID

-- Creating the Stored Procedure
CREATE PROCEDURE Invoide_IDLookup 
AS
SELECT *
FROM Portfolio.dbo.supermarket_sales


-- Executing the Stored Procedure with an Invoice_ID which must be introduced
EXEC Invoide_IDLookup @Invoice_ID = '750-67-8428'
EXEC Invoide_IDLookup @Invoice_ID = '252-56-2699';



-- UPON RIGHT CLICKING ON PROGRAMMABILITY -> STORED PROCEDURES -> <GIVEN PROCEDURE NAME> -> MODIFY
-- THIS IS THE SCREEN THAT SHOULD POP UP
-- We add the paremeters here:

--USE [Portfolio]
--GO
--/****** Object:  StoredProcedure [dbo].[Invoide_IDLookup]    Script Date: 6/18/2023 11:18:59 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--ALTER PROCEDURE [dbo].[Invoide_IDLookup] 
--@Invoice_ID nvarchar(255)
--AS
--SELECT *
--FROM Portfolio.dbo.supermarket_sales
--WHERE Invoice_ID = @Invoice_ID





--------------------------------------------------------------------------------------------------------------------------------------

-- What are the two product lines that sell the most according to cost of goods sold (that is total - tax) for each branch?

WITH CTE_BestSellerPerBranch AS (
SELECT Branch, Product_line, SUM(cogs) AS [Cost of Goods Sold Sum],
RANK() OVER (PARTITION BY Branch ORDER BY SUM(cogs) DESC) AS Rank
FROM Portfolio.dbo.supermarket_sales
GROUP BY Branch, Product_line
)
SELECT Branch, Product_line, [Cost of Goods Sold Sum]
FROM CTE_BestSellerPerBranch
WHERE Rank IN (1, 2);


