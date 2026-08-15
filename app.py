"""
Database Migration & Modeling — Flask web application.
Custom web app (not a BI tool) exposing the NorthwindDW data warehouse.

Run locally against SQLite test data:
    USE_SQLITE=true python app.py

Run against the real SQL Server warehouse:
    python app.py   (reads DB_SERVER / DB_NAME from environment, see .env.example)
"""
from flask import Flask, render_template
from webapp.queries import (
    get_summary_kpis, get_revenue_by_country,
    get_top_products, get_monthly_trend, get_top_employees,
)

app = Flask(__name__, template_folder="webapp/templates", static_folder="webapp/static")


@app.route("/")
def dashboard():
    kpis = get_summary_kpis()
    revenue_by_country = get_revenue_by_country()
    monthly_trend = get_monthly_trend()
    return render_template(
        "dashboard.html",
        kpis=kpis,
        revenue_by_country=revenue_by_country,
        monthly_trend=monthly_trend,
    )


@app.route("/products")
def products():
    top_products = get_top_products(limit=15)
    return render_template("products.html", products=top_products)


@app.route("/employees")
def employees():
    top_employees = get_top_employees(limit=10)
    return render_template("employees.html", employees=top_employees)


if __name__ == "__main__":
    app.run(debug=True, port=5000)
