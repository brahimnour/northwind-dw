"""
Database Migration & Modeling — KPI query functions.
Written in portable SQL (works against both SQL Server and SQLite)
so the same code path can be tested locally before pointing at
the real SQL Server data warehouse.
"""
from webapp.db import run_query


def get_summary_kpis() -> dict:
    total_revenue = run_query("SELECT SUM(revenue) AS v FROM fact_orders")[0]["v"] or 0
    total_orders = run_query("SELECT COUNT(DISTINCT order_id) AS v FROM fact_orders")[0]["v"] or 0
    total_customers = run_query("SELECT COUNT(*) AS v FROM dim_customer")[0]["v"] or 0
    avg_order_value = round(total_revenue / total_orders, 2) if total_orders else 0
    return {
        "total_revenue": round(total_revenue, 2),
        "total_orders": total_orders,
        "total_customers": total_customers,
        "avg_order_value": avg_order_value,
    }


def get_revenue_by_country() -> list[dict]:
    rows = run_query("""
        SELECT c.country AS country, SUM(f.revenue) AS revenue
        FROM fact_orders f
        JOIN dim_customer c ON f.customer_key = c.customer_key
        GROUP BY c.country
        ORDER BY revenue DESC
    """)
    return rows


def get_top_products(limit: int = 10) -> list[dict]:
    rows = run_query("""
        SELECT p.product_name AS product_name, p.category_name AS category_name,
               SUM(f.quantity) AS units_sold, SUM(f.revenue) AS revenue
        FROM fact_orders f
        JOIN dim_product p ON f.product_key = p.product_key
        GROUP BY p.product_name, p.category_name
        ORDER BY revenue DESC
    """)
    return rows[:limit]


def get_monthly_trend() -> list[dict]:
    rows = run_query("""
        SELECT d.year AS year, d.month AS month, d.month_name AS month_name,
               SUM(f.revenue) AS revenue
        FROM fact_orders f
        JOIN dim_date d ON f.date_key = d.date_key
        GROUP BY d.year, d.month, d.month_name
        ORDER BY d.year, d.month
    """)
    return rows


def get_top_employees(limit: int = 10) -> list[dict]:
    rows = run_query("""
        SELECT e.full_name AS full_name, SUM(f.revenue) AS revenue,
               COUNT(DISTINCT f.order_id) AS orders_handled
        FROM fact_orders f
        JOIN dim_employee e ON f.employee_key = e.employee_key
        GROUP BY e.full_name
        ORDER BY revenue DESC
    """)
    return rows[:limit]
