INSERT INTO silver.crm_customer_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)

SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'SINGLE'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'MARRIED'
        ELSE 'n/a'
    END cst_marital_status,
    CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
        ELSE 'n/a'
    END cst_gndr,
    cst_create_date
FROM (SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS earl_create_date
FROM bronze.crm_customer_info) flag
WHERE flag.earl_create_date = 1 AND cst_id IS NOT NULL


SELECT 
	prd_id,
	prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat_id,
    SUBSTRING(prd_key, 7, len(prd_key)) AS prd_cat_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_pdr_info

