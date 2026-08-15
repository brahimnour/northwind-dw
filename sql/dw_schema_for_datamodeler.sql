-- ============================================================
-- NorthwindDW — Generic DDL for Oracle SQL Data Modeler import
-- (SQL Server-specific syntax like IDENTITY and computed/PERSISTED
-- columns is intentionally simplified here so Data Modeler's DDL
-- importer can parse it cleanly. The real deployment schema is
-- sql/dw_schema.sql — this file is for documentation/modeling only.)
-- ============================================================

CREATE TABLE dim_customer (
    customer_key    INT PRIMARY KEY,
    customer_id     VARCHAR(5)   NOT NULL,
    company_name    VARCHAR(100) NOT NULL,
    country         VARCHAR(50),
    city            VARCHAR(50)
);

CREATE TABLE dim_employee (
    employee_key    INT PRIMARY KEY,
    employee_id     INT          NOT NULL,
    full_name       VARCHAR(100) NOT NULL,
    title           VARCHAR(50)
);

CREATE TABLE dim_product (
    product_key     INT PRIMARY KEY,
    product_id      INT          NOT NULL,
    product_name    VARCHAR(100) NOT NULL,
    category_name   VARCHAR(50),
    unit_price      DECIMAL(10,2)
);

CREATE TABLE dim_date (
    date_key        INT PRIMARY KEY,
    full_date        DATE NOT NULL,
    year            INT NOT NULL,
    quarter         VARCHAR(2) NOT NULL,
    month           INT NOT NULL,
    month_name      VARCHAR(15) NOT NULL,
    day             INT NOT NULL,
    weekday_name    VARCHAR(15) NOT NULL
);

CREATE TABLE fact_orders (
    order_line_key  INT PRIMARY KEY,
    order_id        INT NOT NULL,
    customer_key    INT NOT NULL,
    employee_key    INT NOT NULL,
    product_key     INT NOT NULL,
    date_key        INT NOT NULL,
    quantity        INT NOT NULL,
    unit_price      DECIMAL(10,2) NOT NULL,
    discount        DECIMAL(4,2) NOT NULL,
    revenue         DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (employee_key) REFERENCES dim_employee(employee_key),
    FOREIGN KEY (product_key)  REFERENCES dim_product(product_key),
    FOREIGN KEY (date_key)     REFERENCES dim_date(date_key)
);
