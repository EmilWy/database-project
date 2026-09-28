# General
- naming conventions - snake_case
- Language - English

## Table naming
* **Bronze layer:**

  * Tables in the Bronze layer should be named based on the source system (`crm`, `erp`, etc.) followed by the source entity:

    * `<source_system>_<entity>`
    * **Example:** `bronze.crm_customer_info`

* **Silver layer:**

  * Tables in the Silver layer should follow the same naming convention as the Bronze layer, using the source system and entity name.
  * Column names should remain unchanged from the source data:

    * `<source_system>_<entity>`
    * **Example:** `silver.crm_customer_info`

* **Gold layer:**

  * Tables in the Gold layer should be named based on their intended use and business domain:

    * `<role>_<entity>`
    * `<role>` — the type of table, such as `fact` or `dim`
    * `<entity>` — the business domain represented by the table
    * **Example:** `gold.dim_customer`
   
## Column naming
* **Surrogate keys:**
    * Keys added as surrogate primary keys in dim tables
    * `<table>_key`
    * **Example:** `customer_key`
* **Technical columns:**
    * Columns added for additional information (in this project only used for information about when the last data transfer occured)
    * `dwh_<role>`
    * **Example:** `dwh_create_date`

## Procedure naming
* **Procedure name:**
    * Name conventions for data transfer procedures
    * `load_<leyer>`
    * **Example:** `load_brown` or `load_silver`
