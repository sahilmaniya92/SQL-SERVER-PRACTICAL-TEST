PRINT 'A1 - Function direct query (TOP 10 by price):';
SELECT TOP (10)
    ProductID,
    ProductName,
    ListPrice,
    PriceCategory
FROM RetailAnalytics.ufn_GetProductPriceCategory()
ORDER BY ListPrice DESC;
GO




--TEST CASE 2
EXEC RetailAnalytics.usp_GetProductPriceCategory
    @PriceCategory = N'Standard';
GO


--TASE CASE 3
SELECT
    ProductID,
    ProductName,
    ListPrice,
    PriceCategory,
    ExpectedCategory =
        CASE
            WHEN ListPrice >= 1000 THEN N'Premium'
            WHEN ListPrice >= 100  THEN N'Standard'
            ELSE N'Budget'
        END
FROM RetailAnalytics.ufn_GetProductPriceCategory()
WHERE ProductID IN (316, 317, 318, 319, 320);
GO



-- TASE CASE FOR ALTER FUNCTION AND PROCEDURE

IF COL_LENGTH('Production.Product', 'StandardCost') IS NULL
BEGIN
    PRINT 'StandardCost column missing on Production.Product. Cannot validate ALTER tests.';
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.columns AS c
    INNER JOIN sys.objects AS o
        ON c.object_id = o.object_id
    WHERE o.name = N'ufn_GetProductPriceCategory'
      AND SCHEMA_NAME(o.schema_id) = N'RetailAnalytics'
      AND c.name = N'MarginAmount'
)
BEGIN
    PRINT 'ALTER not applied yet.';
END
ELSE
BEGIN
    -- test case 4 for alter 
    PRINT 'B1 - Function after ALTER (TOP 10):';
    SELECT TOP (10)
        ProductID,
        ProductName,
        ListPrice,
        PriceCategory,
        StandardCost,
        MarginAmount
    FROM RetailAnalytics.ufn_GetProductPriceCategory()
    ORDER BY MarginAmount DESC;

    




    PRINT 'B2 - Margin calculation validation:';
    SELECT TOP (10)
        ProductID,
        ListPrice,
        StandardCost,
        MarginAmount,
        CalculatedMargin = ListPrice - StandardCost,
        MarginMatches = CASE
            WHEN MarginAmount = ListPrice - StandardCost THEN N'OK'
            ELSE N'MISMATCH'
        END
    FROM RetailAnalytics.ufn_GetProductPriceCategory()
    ORDER BY ProductID;



END
GO


-- TEST CASE FOR DROP FUNCTION AND PROCUDEURE





