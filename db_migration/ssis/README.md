# SSIS Package — Status & Intended Architecture

**Status**: The SSIS package (`.dtsx`) itself is not yet built due to a Visual
Studio 2026 / SSIS extension compatibility issue encountered in this
environment (the SSIS Projects extension did not complete installation
despite following Microsoft's documented steps for the "2022+" release
that claims VS 2026 support). This is an environment/tooling blocker,
not a design gap.

**What replaces it for now**: `sql/migrate_reference.sql` implements and
has been tested end-to-end — it contains the exact same transformation
logic (extract from Northwind OLTP, join, reshape into the star schema,
load into NorthwindDW) that the SSIS package is designed to reproduce
visually as a Data Flow Task.

## Intended SSIS Package Design

```
Control Flow:
  [Execute SQL Task: Truncate DW tables]
        │
        ▼
  [Data Flow Task: Load Dimensions]
        │  ├─ OLE DB Source (Northwind.dbo.Customers) → OLE DB Destination (dim_customer)
        │  ├─ OLE DB Source (Northwind.dbo.Employees) → Derived Column (concat name) → OLE DB Destination (dim_employee)
        │  ├─ OLE DB Source (Northwind.dbo.Products + Categories, merge join) → OLE DB Destination (dim_product)
        │  └─ Script Component (generate date range) → OLE DB Destination (dim_date)
        ▼
  [Data Flow Task: Load Fact]
        │  OLE DB Source (Orders JOIN [Order Details])
        │  → Lookup transformations (customer_key, employee_key, product_key, date_key)
        │  → OLE DB Destination (fact_orders)
```

Each Lookup transformation replaces the `JOIN ... ON` clauses used in
the T-SQL reference script — this is the standard way SSIS resolves
dimension surrogate keys during fact table loading.
