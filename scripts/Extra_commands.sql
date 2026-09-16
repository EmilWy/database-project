-- EXEC bronze.load_bronze

SELECT TOP 1000 * from bronze.crm_customer_info;

SELECT TOP 1000 * from bronze.crm_pdr_info;

SELECT TOP 1000 * from bronze.crm_sales_details;


SELECT TOP 1000 * from bronze.erp_cust_az12;

SELECT TOP 1000 * from bronze.erp_loc_a101;

SELECT TOP 1000 * from bronze.erp_px_cat_g1v2;

-- =======================================================

SELECT
	cst_id,
	count(*)
FROM bronze.crm_customer_info
GROUP BY cst_id
HAVING count(*) != 1;

SELECT *
FROM (SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS earl_create_date
FROM bronze.crm_customer_info) flag
WHERE flag.earl_create_date = 1 AND cst_id IS NOT NULL

SELECT TRIM(cst_firstname), TRIM(cst_lastname)
FROM bronze.crm_customer_info;

SELECT DISTINCT cst_marital_status
FROM bronze.crm_customer_info

SELECT DISTINCT cst_gndr
FROM bronze.crm_customer_info

SELECT * 
FROM bronze.crm_customer_info
WHERE cst_marital_status IS NULL

SELECT * 
FROM bronze.crm_customer_info
WHERE cst_gndr IS NULL

-- =======================================================

SELECT prd_id, COUNT(*)
FROM bronze.crm_pdr_info
GROUP BY prd_id
HAVING COUNT(*) != 1;

SELECT *
FROM bronze.crm_pdr_info
WHERE prd_key = 'CO-RF-FR-R92B-58'

SELECT 
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
	SUBSTRING(prd_key, 7, len(prd_key)),
	prd_key
FROM bronze.crm_pdr_info
