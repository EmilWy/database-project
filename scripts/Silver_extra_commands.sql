-- EXEC silver.load_silver

SELECT TOP 1000 * from silver.crm_customer_info;

SELECT TOP 1000 * from silver.crm_pdr_info;

SELECT TOP 1000 * from silver.crm_sales_details;


SELECT TOP 1000 * from silver.erp_cust_az12;

SELECT TOP 1000 * from silver.erp_loc_a101;

SELECT TOP 1000 * from silver.erp_px_cat_g1v2;

SELECT
	cst_id,
	count(*)
FROM silver.crm_customer_info
GROUP BY cst_id
HAVING count(*) != 1;

SELECT *
FROM (SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS earl_create_date
FROM silver.crm_customer_info) flag
WHERE flag.earl_create_date = 1 AND cst_id IS NOT NULL

SELECT TRIM(cst_firstname), TRIM(cst_lastname)
FROM silver.crm_customer_info;

SELECT DISTINCT cst_marital_status
FROM silver.crm_customer_info

SELECT DISTINCT cst_gndr
FROM silver.crm_customer_info

SELECT * 
FROM silver.crm_customer_info
WHERE cst_marital_status IS NULL

SELECT * 
FROM silver.crm_customer_info
WHERE cst_gndr IS NULL
