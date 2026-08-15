"""
Database Migration & Modeling — Flask web app.
Database connection layer: supports SQL Server (production) and
SQLite (local development/testing) via the same query interface.
"""
import os
import sqlite3

USE_SQLITE = os.getenv("USE_SQLITE", "false").lower() == "true"
SQLITE_PATH = os.getenv("SQLITE_PATH", "northwind_dw_dev.sqlite")

if not USE_SQLITE:
    import pyodbc  # only required when actually connecting to SQL Server

SQLSERVER_CONFIG = {
    "server": os.getenv("DB_SERVER", "localhost\\SQLEXPRESS"),
    "database": os.getenv("DB_NAME", "NorthwindDW"),
    "driver": os.getenv("DB_DRIVER", "{ODBC Driver 17 for SQL Server}"),
}


def get_connection():
    if USE_SQLITE:
        conn = sqlite3.connect(SQLITE_PATH)
        conn.row_factory = sqlite3.Row
        return conn
    conn_str = (
        f"DRIVER={SQLSERVER_CONFIG['driver']};"
        f"SERVER={SQLSERVER_CONFIG['server']};"
        f"DATABASE={SQLSERVER_CONFIG['database']};"
        f"Trusted_Connection=yes;"
    )
    return pyodbc.connect(conn_str)


def run_query(sql: str, params: tuple = ()) -> list[dict]:
    """Run a SELECT query and return rows as a list of dicts."""
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(sql, params)
    columns = [desc[0] for desc in cur.description]
    rows = [dict(zip(columns, row)) for row in cur.fetchall()]
    conn.close()
    return rows
