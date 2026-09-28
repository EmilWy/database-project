# Project - data werehouse 

## Objective
Develop a data warehouse in SQL Server using sales data from CSV files.

### Data Source
- CSV files from two data sources (CRM and ERP), with three files per source and six files in total.

### Data Quality
- Data quality issues include duplicate values, inconsistent naming conventions, and incorrect values (outside the scope of this project).

### Data Integration
- Combine data into a coherent schema for further analysis.

### Scope
- Use only the latest data and ignore historical values.

### Used technology
Microsoft SQL Server menagement Studio - SQL Server Administration Tool
Microsoft SQL Server - database engine
File execution order:
1. \scripts\Create_schemas.sql
2. \scripts\bronze\Bronze_DDL.sql
3. \scripts\bronze\Bronze_DML_insert_bulk_data.sql
4. \scripts\silver\Silver_DDL.sql
5. \scripts\silver\Silver_DML_insert_cleaned_data.sql
6. \scripts\gold\Gold_DML_create_views.sql


