EXEC silver.load_silver

SELECT TOP 1000 * from silver.crm_customer_info;

SELECT TOP 1000 * from silver.crm_pdr_info;

SELECT TOP 1000 * from silver.crm_sales_details;


SELECT TOP 1000 * from silver.erp_cust_az12;

SELECT TOP 1000 * from silver.erp_loc_a101;

SELECT TOP 1000 * from silver.erp_px_cat_g1v2;

SELECT COUNT(*) from silver.crm_customer_info;
SELECT COUNT(*) from silver.erp_cust_az12;
SELECT COUNT(*) from silver.erp_loc_a101;

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

-- ========================================================

SELECT * 
FROM silver.crm_sales_details
WHERE sls_price*sls_quantity !=  sls_sales OR
	sls_price IS NULL OR sls_sales IS NULL OR sls_quantity IS NULL OR
	sls_price <= 0 OR sls_sales <= 0 OR sls_quantity <= 0 
	
-- ========================================================

SELECT *
FROM silver.erp_cust_az12

SELECT AVG(LEN(cid))
FROM silver.erp_cust_az12

SELECT DISTINCT gen
FROM silver.erp_cust_az12

SELECT *
FROM silver.erp_cust_az12
ORDER BY bdate DESC

-- ========================================================

SELECT *
FROM silver.erp_loc_a101;

SELECT DISTINCT cntry
FROM silver.erp_loc_a101;

-- ========================================================

SELECT *
FROM silver.crm_customer_info
WHERE TRIM(cst_key) not in (SELECT TRIM(cid) FROM silver.erp_cust_az12)

SELECT *
FROM silver.crm_customer_info
WHERE cst_key NOT IN (SELECT cid FROM silver.erp_loc_a101)

SELECT *
FROM silver.crm_customer_info
WHERE cst_key NOT IN (SELECT cst_key FROM bronze.crm_customer_info)

SELECT cst_key, COUNT(*)
FROM silver.crm_customer_info
GROUP BY cst_key
HAVING COUNT(*) > 1
