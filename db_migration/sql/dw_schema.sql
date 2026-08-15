-- ============================================================
-- Database Migration & Modeling — Data Warehouse Schema
-- Target: SQL Server (star schema, migrated from Northwind OLTP)
-- ============================================================

CREATE DATABASE NorthwindDW;
GO
USE NorthwindDW;
GO

-- ---------- DIMENSIONS ----------

CREATE TABLE dim_customer (
    customer_key    INT IDENTITY(1,1) PRIMARY KEY,
    customer_id     NCHAR(5)      NOT NULL UNIQUE,   -- Northwind CustomerID
    company_name    NVARCHAR(100) NOT NULL,
    country         NVARCHAR(50)  NULL,
    city            NVARCHAR(50)  NULL
);

CREATE TABLE dim_employee (
    employee_key    INT IDENTITY(1,1) PRIMARY KEY,
    employee_id     INT           NOT NULL UNIQUE,   -- Northwind EmployeeID
    full_name       NVARCHAR(100) NOT NULL,
    title           NVARCHAR(50)  NULL
);

CREATE TABLE dim_product (
    product_key     INT IDENTITY(1,1) PRIMARY KEY,
    product_id      INT           NOT NULL UNIQUE,   -- Northwind ProductID
    product_name    NVARCHAR(100) NOT NULL,
    category_name   NVARCHAR(50)  NULL,
    unit_price      DECIMAL(10,2) NULL
);

CREATE TABLE dim_date (
    date_key        INT PRIMARY KEY,      -- format YYYYMMDD
    full_date       DATE NOT NULL UNIQUE,
    year            INT NOT NULL,
    quarter         NVARCHAR(2) NOT NULL,
    month           INT NOT NULL,
    month_name      NVARCHAR(15) NOT NULL,
    day             INT NOT NULL,
    weekday_name    NVARCHAR(15) NOT NULL
);

-- ---------- FACT TABLE ----------

CREATE TABLE fact_orders (
    order_line_key  INT IDENTITY(1,1) PRIMARY KEY,
    order_id        INT NOT NULL,
    customer_key    INT NOT NULL REFERENCES dim_customer(customer_key),
    employee_key    INT NOT NULL REFERENCES dim_employee(employee_key),
    product_key     INT NOT NULL REFERENCES dim_product(product_key),
    date_key        INT NOT NULL REFERENCES dim_date(date_key),
    quantity        INT NOT NULL,
    unit_price      DECIMAL(10,2) NOT NULL,
    discount        DECIMAL(4,2)  NOT NULL DEFAULT 0,
    revenue         AS (quantity * unit_price * (1 - discount)) PERSISTED
);

CREATE INDEX idx_fact_orders_customer ON fact_orders(customer_key);
CREATE INDEX idx_fact_orders_employee ON fact_orders(employee_key);
CREATE INDEX idx_fact_orders_product  ON fact_orders(product_key);
CREATE INDEX idx_fact_orders_date     ON fact_orders(date_key);
