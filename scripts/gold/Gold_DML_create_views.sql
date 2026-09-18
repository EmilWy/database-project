-- FINAL
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_nr,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	cl.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE 
		WHEN ci.cst_gndr IN ('FEMALE', 'MALE') THEN ci.cst_gndr
		ELSE ISNULL(cd.gen, 'n/a')
	END gender,
	cd.bdate AS birthday,
	ci.cst_create_date AS date_created
FROM silver.crm_customer_info ci
LEFT JOIN silver.erp_cust_az12 cd
	ON ci.cst_key = cd.cid
LEFT JOIN silver.erp_loc_a101 cl
	ON ci.cst_key = cl.cid;

GO

CREATE OR ALTER VIEW gold.dim_products AS
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

GO

CREATE OR ALTER VIEW gold.fact_sales AS
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
