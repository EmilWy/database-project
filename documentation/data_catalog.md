## Gold layer data

For final tables data insights

**1. gold.dim_customers**
* Information about customers

| Colun name | Data type | Note |
|----------|----------|----------|
| customer_key | bigint |Surrogate key|
| customer_id | int ||
| customer_nr | nvarchar(50) ||
| first_name | nvarchar(50) ||
| last_name | nvarchar(50) ||
| country | nvarchar(50) ||
| marital_status | nvarchar(50) ||
| gender | nvarchar(50) ||
| birthday | date ||
| date_created | date ||

**2. gold.dim_products**
* Information about products that are still manufactured and sold

| Colun name | Data type | Note |
|----------|----------|----------|
| product_key | bigint |Surrogate key|
| product_id | int ||
| product_nr | nvarchar(50) ||
| product_name | nvarchar(50) ||
| category_id | nvarchar(50) ||
| category | nvarchar(50) ||
| subcategory | nvarchar(50) ||
| maintenance | nvarchar(50) ||
| cost | int ||
| production_line | nvarchar(50) ||
| start_date | date ||

**3. gold.fact_sales**
* Information about product sales

| Colun name | Data type | Note |
|----------|----------|----------|
| order_nr | nvarchar(50) ||
| product_key | bigint |Foreign key|
| customer_key | bigint |Foreign key|
| quantity | int ||
| price | int ||
| total_sales | int ||
| order_date | date ||
| ship_date | date ||
| due_date | date ||
