-- Original
SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	cd.bdate,
	cd.gen,
	cl.cntry
FROM silver.crm_customer_info ci
LEFT JOIN silver.erp_cust_az12 cd
	ON ci.cst_key = cd.cid
LEFT JOIN silver.erp_loc_a101 cl
	ON ci.cst_key = cl.cid

-- double gender columns - unify to coherent last column
SELECT DISTINCT
	ci.cst_gndr,
	cd.gen,
	CASE 
		WHEN ci.cst_gndr IN ('FEMALE', 'MALE') THEN ci.cst_gndr
		ELSE ISNULL(cd.gen, 'n/a')
	END gender
FROM silver.crm_customer_info ci
LEFT JOIN silver.erp_cust_az12 cd
	ON ci.cst_key = cd.cid
LEFT JOIN silver.erp_loc_a101 cl
	ON ci.cst_key = cl.cid

-- correct id crm (whem aviable genders do not match)
SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	cd.bdate,
	cd.gen
FROM silver.crm_customer_info ci
LEFT JOIN silver.erp_cust_az12 cd
	ON ci.cst_key = cd.cid
LEFT JOIN silver.erp_loc_a101 cl
	ON ci.cst_key = cl.cid
WHERE (ci.cst_gndr = 'FEMALE' AND cd.gen = 'MALE') OR (ci.cst_gndr = 'MALE' AND cd.gen = 'FEMALE')

SELECT 
	ci.cst_key,
	ci.cst_gndr,
	cd.gen
FROM silver.crm_customer_info ci
LEFT JOIN silver.erp_cust_az12 cd
	ON ci.cst_key = cd.cid
LEFT JOIN silver.erp_loc_a101 cl
	ON ci.cst_key = cl.cid

-- check for duplikates
SELECT  cst_id, COUNT(*)
FROM(
SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	cd.bdate,
	cd.gen,
	cl.cntry
FROM silver.crm_customer_info ci
LEFT JOIN silver.erp_cust_az12 cd
	ON ci.cst_key = cd.cid
LEFT JOIN silver.erp_loc_a101 cl
	ON ci.cst_key = cl.cid)t
GROUP BY cst_id
HAVING COUNT(*)>1

SELECT * FROM silver.erp_cust_az12
SELECT * FROM silver.erp_loc_a101

SELECT DISTINCT gender FROM gold.dim_customers

-- =======================================================
-- only currently produced products (pri.prd_end_dt IS NULL - no production end time)

SELECT
	ROW_NUMBER() OVER(ORDER BY pri.prd_id, pri.prd_start_dt) product_key,
	pri.prd_id product_id,
	pri.prd_key product_nr,
	pri.prd_nm product_name,
	pri.prd_cat_id category_id,
	prc.cat category,
	prc.cubcat subcategory,
	prc.maintenance,
	pri.prd_cost cost,
	pri.prd_line production_line,
	pri.prd_start_dt start_date
FROM silver.crm_pdr_info pri
LEFT JOIN silver.erp_px_cat_g1v2 prc
	ON pri.prd_cat_id = prc.id
WHERE pri.prd_end_dt IS NULL

SELECT * FROM silver.crm_pdr_info
SELECT * FROM silver.erp_px_cat_g1v2

-- =======================================================

SELECT
	sd.sls_ord_num AS order_nr,
	pr.product_key,
	cs.customer_key,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price,
	sd.sls_sales AS total_sales,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS ship_date,
	sd.sls_due_dt AS due_date
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customers cs
	ON sd.sls_cust_id = cs.customer_id
LEFT JOIN gold.dim_products pr
	ON sd.sls_prd_key = pr.product_nr


SELECT TOP 2 * FROM gold.dim_customers;
SELECT TOP 2 * FROM gold.dim_products;
SELECT TOP 2 * FROM silver.crm_sales_details;
