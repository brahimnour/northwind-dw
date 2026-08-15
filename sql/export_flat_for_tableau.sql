-- ============================================================
-- Flat export query for Tableau Public (CSV/Excel import)
-- Joins fact_orders with all dimensions into one wide table.
-- ============================================================

USE NorthwindDW;
GO

SELECT
    f.order_id,
    c.company_name,
    c.country,
    c.city,
    e.full_name       AS employee_name,
    e.title           AS employee_title,
    p.product_name,
    p.category_name,
    d.full_date        AS order_date,
    d.year,
    d.quarter,
    d.month_name,
    f.quantity,
    f.unit_price,
    f.discount,
    f.revenue
FROM fact_orders f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_employee e ON f.employee_key = e.employee_key
JOIN dim_product p  ON f.product_key  = p.product_key
JOIN dim_date d      ON f.date_key     = d.date_key
ORDER BY d.full_date;
