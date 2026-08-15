# NorthwindDW — Database Migration, Modeling & Web App

An end-to-end data engineering project: migrate the classic Northwind
OLTP database into a SQL Server star-schema data warehouse, document
the model in Oracle Data Modeler, explore it in Tableau, and serve it
through a custom Flask web application (not a BI tool — hand-built
HTML/CSS/JS).

## Architecture

```
Northwind (OLTP, SQL Server)
        │
        ▼  T-SQL migration logic (tested, see sql/migrate_reference.sql)
        │  — SSIS package designed to reproduce the same logic visually,
        │    see ssis/README.md for status and intended design
NorthwindDW (star schema, SQL Server)
        │
        ├──▶ Tableau (dashboard, connected via flat CSV export)
        └──▶ Flask web app (custom UI, this repo)
```

**Note on SSIS**: the visual SSIS package (`.dtsx`) could not be built
in this environment due to a Visual Studio 2026 / SSIS extension
compatibility issue (documented in `ssis/README.md`, including the
intended package design). The migration logic itself is implemented
and tested end-to-end in `sql/migrate_reference.sql`.

## Data Model (Star Schema)
- **fact_orders** — one row per order line (quantity, price, discount, computed revenue)
- **dim_customer**, **dim_employee**, **dim_product**, **dim_date** — standard dimensions

Modeled and documented as an ER diagram in Oracle SQL Data Modeler
(see `docs/er_diagram.png`).

## Project Structure
```
├── sql/
│   ├── dw_schema.sql          # Target star-schema DDL (T-SQL)
│   └── migrate_reference.sql  # Reference migration logic (mirrors the SSIS package)
├── ssis/                      # SSIS package (.dtsx) + documentation
├── docs/
│   └── er_diagram.png         # Oracle Data Modeler export
├── webapp/
│   ├── db.py                  # DB connection layer (SQL Server / SQLite)
│   ├── queries.py              # KPI query functions
│   ├── templates/              # Jinja2 HTML templates
│   └── static/css/style.css    # Hand-written design system
├── app.py                      # Flask entry point
└── requirements.txt
```

## Setup & Run

### 1. Set up the database (SQL Server)
```sql
-- Run in SSMS:
-- 1. Restore/create the Northwind source database (sql/instnwnd.sql)
-- 2. Run sql/dw_schema.sql to create NorthwindDW
-- 3. Run the SSIS package (ssis/) to migrate Northwind -> NorthwindDW
--    (or run sql/migrate_reference.sql directly as a T-SQL fallback)
```

### 2. Run the Flask app
```bash
pip install -r requirements.txt

# Against the real SQL Server warehouse:
python app.py

# Or, to develop/test the web app without SQL Server installed:
# (uses a small local SQLite database with sample data)
USE_SQLITE=true python app.py
```

Visit `http://localhost:5000`.

## Tech Stack
- **ETL**: SQL Server T-SQL (tested migration logic); SSIS (package design documented, see `ssis/README.md`)
- **Data Warehouse**: SQL Server, star-schema modeling
- **Data Modeling**: Oracle SQL Data Modeler (ER diagram)
- **Dashboarding**: Tableau
- **Web Development**: Flask, HTML, CSS, JavaScript (Chart.js)
- **Version Control**: Git, GitHub

## Design Notes
The web app's visual identity ("trade ledger / shipping manifest") is a
deliberate choice reflecting Northwind's business (import/export of
specialty foods): navy ink + brass accents, slab-serif headers, and
monospace figures for tabular data — evoking a 19th-century trading
