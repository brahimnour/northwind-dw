-- ============================================================
-- Migration logic: Northwind (OLTP) -> NorthwindDW (star schema)
-- This is the reference T-SQL logic. The SSIS package implements
-- the same transformations visually as ETL data flow tasks.
-- ============================================================

USE NorthwindDW;
GO

-- ---------- dim_customer ----------
INSERT INTO dim_customer (customer_id, company_name, country, city)
SELECT CustomerID, CompanyName, Country, City
FROM Northwind.dbo.Customers;

-- ---------- dim_employee ----------
INSERT INTO dim_employee (employee_id, full_name, title)
SELECT EmployeeID, FirstName + ' ' + LastName, Title
FROM Northwind.dbo.Employees;

-- ---------- dim_product ----------
INSERT INTO dim_product (product_id, product_name, category_name, unit_price)
SELECT p.ProductID, p.ProductName, c.CategoryName, p.UnitPrice
FROM Northwind.dbo.Products p
LEFT JOIN Northwind.dbo.Categories c ON p.CategoryID = c.CategoryID;

-- ---------- dim_date (generated from order date range) ----------
DECLARE @StartDate DATE = (SELECT MIN(OrderDate) FROM Northwind.dbo.Orders);
DECLARE @EndDate   DATE = (SELECT MAX(OrderDate) FROM Northwind.dbo.Orders);

;WITH DateSeq AS (
    SELECT @StartDate AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d) FROM DateSeq WHERE d < @EndDate
)
INSERT INTO dim_date (date_key, full_date, year, quarter, month, month_name, day, weekday_name)
SELECT
    CAST(FORMAT(d, 'yyyyMMdd') AS INT),
    d,
    YEAR(d),
    'Q' + CAST(DATEPART(QUARTER, d) AS VARCHAR(1)),
    MONTH(d),
    DATENAME(MONTH, d),
    DAY(d),
    DATENAME(WEEKDAY, d)
FROM DateSeq
OPTION (MAXRECURSION 0);

-- ---------- fact_orders ----------
INSERT INTO fact_orders (order_id, customer_key, employee_key, product_key, date_key,
                          quantity, unit_price, discount)
SELECT
    o.OrderID,
    dc.customer_key,
    de.employee_key,
    dp.product_key,
    CAST(FORMAT(o.OrderDate, 'yyyyMMdd') AS INT),
    od.Quantity,
    od.UnitPrice,
    od.Discount
FROM Northwind.dbo.Orders o
JOIN Northwind.dbo.[Order Details] od ON o.OrderID = od.OrderID
JOIN dim_customer dc ON o.CustomerID = dc.customer_id
JOIN dim_employee de ON o.EmployeeID = de.employee_id
JOIN dim_product dp  ON od.ProductID = dp.product_id;

-- ---------- Verification ----------
SELECT 'dim_customer' AS tbl, COUNT(*) AS rows FROM dim_customer
UNION ALL SELECT 'dim_employee', COUNT(*) FROM dim_employee
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'fact_orders', COUNT(*) FROM fact_orders;
