USE AdventureWorks2022;
GO


IF NOT EXISTS (
      SELECT 1
      FROM sys.schemas
      WHERE NAME=N'RETAILANALYTICS'
)
BEGIN
    EXEC(N'CREATE SCHEMA RetailAnalytics AUTHORIZATION dbo;');
    PRINT 'Schema RetailAnalytics created.';
END
ELSE
BEGIN
    PRINT 'Schema RetailAnalytics already exists.'
END 
GO

-- DROP 
IF OBJECT_ID(N'RetailAnalytics.usp_GetProductPriceCategory', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE RetailAnalytics.usp_GetProductPriceCategory;
    PRINT 'Existing procedure dropped before CREATE.';
END
GO




IF OBJECT_ID(N'RetailAnalytics.ufn_GetProductPriceCategory', N'IF') IS NOT NULL
BEGIN
    DROP FUNCTION RetailAnalytics.ufn_GetProductPriceCategory;
    PRINT 'Existing function dropped before CREATE.';
END
GO 




--CREATE FUNCTION
CREATE FUNCTION RetailAnalytics.ufn_GetProductPriceCategory
(
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.ProductID,
        p.Name AS ProductName,
        p.ListPrice,
        CASE
            WHEN p.ListPrice >= 1000 THEN N'Premium'
            WHEN p.ListPrice >= 100  THEN N'Standard'
            ELSE N'Budget'
        END AS PriceCategory
    FROM Production.Product AS p
);
GO

-- CREATE PROCEDURE

CREATE PROCEDURE RetailAnalytics.usp_GetProductPriceCategory
    @PriceCategory NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @PriceCategory IS NOT NULL
       AND @PriceCategory NOT IN (N'Premium', N'Standard', N'Budget')
    BEGIN
        RAISERROR(
            N'Invalid price category. Allowed values: Premium, Standard, Budget.',
            16,
            1
        );
        RETURN;
    END;

    SELECT
        f.ProductID,
        f.ProductName,
        f.ListPrice,
        f.PriceCategory
    FROM RetailAnalytics.ufn_GetProductPriceCategory() AS f
    WHERE @PriceCategory IS NULL
       OR f.PriceCategory = @PriceCategory
    ORDER BY f.ListPrice DESC, f.ProductID;
END;
GO


-- ALTER FUNCTION

ALTER FUNCTION RetailAnalytics.ufn_GetProductPriceCategory
(
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.ProductID,
        p.Name AS ProductName,
        p.ListPrice,
        CASE
            WHEN p.ListPrice >= 1000 THEN N'Premium'
            WHEN p.ListPrice >= 100  THEN N'Standard'
            ELSE N'Budget'
        END AS PriceCategory,
        p.StandardCost,
        p.ListPrice - p.StandardCost AS MarginAmount
    FROM Production.Product AS p
);
GO




-- ALTER PROCUDURE


ALTER PROCEDURE RetailAnalytics.usp_GetProductPriceCategory
    @PriceCategory  NVARCHAR(20) = NULL,
    @MinimumMargin  MONEY        = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @PriceCategory IS NOT NULL
       AND @PriceCategory NOT IN (N'Premium', N'Standard', N'Budget')
    BEGIN
        RAISERROR(
            N'Invalid price category. Allowed values: Premium, Standard, Budget.',
            16,
            1
        );
        RETURN;
    END;

    IF @MinimumMargin IS NOT NULL AND @MinimumMargin < 0
    BEGIN
        RAISERROR(N'Minimum margin cannot be negative.', 16, 1);
        RETURN;
    END;

    SELECT
        f.ProductID,
        f.ProductName,
        f.ListPrice,
        f.PriceCategory,
        f.StandardCost,
        f.MarginAmount
    FROM RetailAnalytics.ufn_GetProductPriceCategory() AS f
    WHERE (@PriceCategory IS NULL OR f.PriceCategory = @PriceCategory)
      AND (@MinimumMargin IS NULL OR f.MarginAmount >= @MinimumMargin)
    ORDER BY f.ListPrice DESC, f.ProductID;
END;
GO


-- DROP FUNCTION AND DROP PROCEDURE 

-- DROP PROCUDERE
IF OBJECT_ID(N'RetailAnalytics.usp_GetProductPriceCategory', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE RetailAnalytics.usp_GetProductPriceCategory;
    PRINT 'Procedure RetailAnalytics.usp_GetProductPriceCategory dropped.';
END
ELSE
BEGIN
    PRINT 'Procedure RetailAnalytics.usp_GetProductPriceCategory does not exist. Skipping DROP.';
END
GO

--DROP FUNCTION 


IF OBJECT_ID(N'RetailAnalytics.ufn_GetProductPriceCategory', N'IF') IS NOT NULL
BEGIN
    DROP FUNCTION RetailAnalytics.ufn_GetProductPriceCategory;
    PRINT 'Function RetailAnalytics.ufn_GetProductPriceCategory dropped.';
END
ELSE
BEGIN
    PRINT 'Function RetailAnalytics.ufn_GetProductPriceCategory does not exist. Skipping DROP.';
END
GO











