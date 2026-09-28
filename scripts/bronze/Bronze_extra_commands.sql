-- EXEC bronze.load_bronze

SELECT TOP 1000 * from bronze.crm_customer_info;

SELECT TOP 1000 * from bronze.crm_pdr_info;

SELECT TOP 1000 * from bronze.crm_sales_details;


SELECT TOP 1000 * from bronze.erp_cust_az12;

SELECT TOP 1000 * from bronze.erp_loc_a101;

SELECT TOP 1000 * from bronze.erp_px_cat_g1v2;

SELECT COUNT(*) from bronze.crm_customer_info;
SELECT COUNT(*) from bronze.erp_cust_az12;
SELECT COUNT(*) from bronze.erp_loc_a101;

-- =======================================================
-----------------------------------
-- check which ids have duplicates
-----------------------------------
SELECT
	cst_id,
	count(*)
FROM bronze.crm_customer_info
GROUP BY cst_id
HAVING count(*) != 1;
-----------------------------------
-- Check earlisest date of account creation (for ids duplication)
-----------------------------------
SELECT *
FROM (SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS earl_create_date
FROM bronze.crm_customer_info) flag
WHERE flag.earl_create_date = 1 AND cst_id IS NOT NULL
-----------------------------------
-- clear first and last nameds of spaces
-----------------------------------
SELECT TRIM(cst_firstname), TRIM(cst_lastname)
FROM bronze.crm_customer_info;
-----------------------------------
-- find all distict marital statuses
-----------------------------------
SELECT DISTINCT cst_marital_status
FROM bronze.crm_customer_info
-----------------------------------
-- find all distict genders
-----------------------------------
SELECT DISTINCT cst_gndr
FROM bronze.crm_customer_info
-----------------------------------
-- see why marital status may be null
-----------------------------------
SELECT * 
FROM bronze.crm_customer_info
WHERE cst_marital_status IS NULL
-----------------------------------
-- see why gender may be null
-----------------------------------
SELECT * 
FROM bronze.crm_customer_info
WHERE cst_gndr IS NULL

-- =======================================================
-----------------------------------
-- look for duplicated ids
-----------------------------------
SELECT prd_id, COUNT(*)
FROM bronze.crm_pdr_info
GROUP BY prd_id
HAVING COUNT(*) != 1;
-----------------------------------
-- see the row withs pecified product key
-----------------------------------
SELECT *
FROM bronze.crm_pdr_info
WHERE prd_key = 'CO-RF-FR-R92B-58'
-----------------------------------
-- create two seperate keys from product key to comunicate with dim tables
-----------------------------------
SELECT 
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
	SUBSTRING(prd_key, 7, len(prd_key)),
	prd_key
FROM bronze.crm_pdr_info
-----------------------------------
-- look for rows with additional spaces in product line name
-----------------------------------
SELECT prd_line
FROM bronze.crm_pdr_info
WHERE prd_line != TRIM(prd_line)
-----------------------------------
-- see if there are incorrect costs (negative or Unknown)
-----------------------------------
SELECT *
FROM bronze.crm_pdr_info
WHERE prd_cost < 0 OR prd_cost IS NULL
-----------------------------------
-- see all distinct product lines 
-----------------------------------
SELECT DISTINCT prd_line
FROM bronze.crm_pdr_info
-----------------------------------
-- how many records have unknwn production start date
-----------------------------------
SELECT count(*)
FROM bronze.crm_pdr_info
WHERE prd_start_dt IS NULL
-----------------------------------
-- how many records have unknwn production end date
-----------------------------------
SELECT count(*)
FROM bronze.crm_pdr_info
WHERE prd_end_dt IS NULL

-----------------------------------
-- Apperently end date can be earlier than start date, but there are no 
-- duplicates with better data quality
-----------------------------------
SELECT prd_id, COUNT(*)
FROM bronze.crm_pdr_info
WHERE (prd_id) IN (
	SELECT prd_id
	FROM bronze.crm_pdr_info
	WHERE prd_end_dt < prd_start_dt)
GROUP BY prd_id
HAVING COUNT(*)>1
-----------------------------------
-- neither by product key
-----------------------------------
SELECT prd_key, COUNT(*)
FROM bronze.crm_pdr_info
WHERE (prd_id) IN (
	SELECT prd_id
	FROM bronze.crm_pdr_info
	WHERE prd_end_dt < prd_start_dt)
GROUP BY prd_key
HAVING COUNT(*)>1
-----------------------------------
-- find where production start date is bigger than end date
-----------------------------------
SELECT *
FROM bronze.crm_pdr_info
WHERE prd_end_dt < prd_start_dt
-----------------------------------
-- find where production end date is bigger than start date
-----------------------------------
SELECT *
FROM bronze.crm_pdr_info
WHERE prd_end_dt > prd_start_dt
-----------------------------------
-- find where production start date is bigger than end date and keep row record
-----------------------------------
SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC)
FROM bronze.crm_pdr_info
WHERE (prd_id) IN (
SELECT prd_id
FROM bronze.crm_pdr_info
WHERE prd_end_dt < prd_start_dt)
-----------------------------------
-- add corrected end production dates
-----------------------------------
SELECT 
	*,
	DATEADD(DAY, -1, LEAD(prd_start_dt, 1) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC)) AS prd_end_dt_new
FROM bronze.crm_pdr_info
WHERE (prd_id) IN (
	SELECT prd_id
	FROM bronze.crm_pdr_info
	WHERE prd_end_dt < prd_start_dt) AND 
	prd_end_dt_new IS NULL

-- =======================================================

SELECT *
FROM bronze.crm_sales_details

/*
sls_ord_num, - No spaces
sls_prd_key, - No spaces
sls_cust_id, - All are in in customer info table (no unknown customers)
sls_order_dt, - INT to NVARCHAR to DATA
sls_ship_dt, - INT to NVARCHAR to DATA
sls_due_dt, - INT to NVARCHAR to DATA
sls_sales, - nulls and negatives happen
sls_quantity, - ok, normal values
sls_price - nulls and negatives happen

Dates are in correct order (first order, then ship and then due)
*/
-----------------------------------
-- records with additional spaces in product keys
-----------------------------------
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)
-----------------------------------
-- see if sales table have customers ids not found in customers table
-----------------------------------
SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_customer_info)
-----------------------------------
-- distinct sales values
-----------------------------------
SELECT DISTINCT sls_sales
FROM bronze.crm_sales_details
-----------------------------------
-- incorrect sales values
-----------------------------------
SELECT *
FROM bronze.crm_sales_details
WHERE sls_sales<0 OR sls_sales IS NULL
-----------------------------------
-- distinct quantites
-----------------------------------
SELECT DISTINCT sls_quantity
FROM bronze.crm_sales_details
-----------------------------------
-- incorrect prices values
-----------------------------------
SELECT *
FROM bronze.crm_sales_details
WHERE sls_price<0 OR sls_price IS NULL
-----------------------------------
-- if slaes are incorrect then calculate them from qty and prices 
-- if price is inccorect, calculate it based on sales and qty
-----------------------------------
SELECT 
	CASE
		WHEN sls_sales <= 0 OR sls_sales IS NULL or sls_sales != ABS(sls_quantity*sls_price) THEN ABS(sls_quantity*sls_price)
		ELSE sls_sales 
	END sls_sales, 
	sls_quantity, 
	CASE
		WHEN sls_price <=0 OR sls_price IS NULL THEN sls_sales/sls_quantity
		ELSE sls_price
	END sls_price
FROM bronze.crm_sales_details
WHERE 
	sls_price*sls_quantity !=  sls_sales OR
	sls_price IS NULL OR sls_sales IS NULL OR sls_quantity IS NULL OR
	sls_price <= 0 OR sls_sales <= 0 OR sls_quantity <= 0 
	--sls_price = 0 OR sls_sales = 0 OR sls_quantity = 0
ORDER BY sls_sales, sls_quantity, sls_price

-----------------------------------
-- shows orders with multiple things odered
-----------------------------------
SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY sls_ord_num ORDER BY sls_order_dt)
FROM bronze.crm_sales_details
WHERE sls_ord_num IN (
	SELECT sls_ord_num
	FROM bronze.crm_sales_details 
	GROUP BY sls_ord_num
	HAVING COUNT(*)>1)
-----------------------------------
-- modify dates to date datatype
-----------------------------------
SELECT 
	CASE 
		WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8 THEN NULL
		ELSE CONVERT(DATE, CAST(sls_order_dt AS NVARCHAR))
	END sls_order_dt,
	CONVERT(DATE, CAST(sls_ship_dt AS NVARCHAR)) AS sls_ship_dt,
	CONVERT(DATE, CAST(sls_due_dt AS NVARCHAR)) AS sls_due_dt
FROM bronze.crm_sales_details 
WHERE sls_order_dt = 0 OR LEN(sls_order_dt) !=8
-----------------------------------
-- see dates with incorrect lengths
-----------------------------------
SELECT 
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
FROM bronze.crm_sales_details 
WHERE sls_due_dt = 0 OR LEN(sls_due_dt) !=8
-----------------------------------
-- look for inccorect dates (not in order of order < ship < due - in perfect scenario)
-----------------------------------
SELECT 
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
FROM bronze.crm_sales_details 
WHERE 
	sls_order_dt > sls_ship_dt OR 
	sls_order_dt > sls_due_dt OR 
	sls_ship_dt > sls_due_dt

-- =======================================================
-----------------------------------
-- apply multiple changes from later parts
-----------------------------------
SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END cid,
	CASE 
		WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END bdate,
	CASE
		WHEN UPPER(gen) = 'F' OR UPPER(gen) = 'FEMALE' THEN 'FEMALE'
		WHEN UPPER(gen) = 'M' OR UPPER(gen) = 'MALE' THEN 'MALE'
		ELSE 'n/a'
	END gen
FROM bronze.erp_cust_az12
ORDER BY bdate DESC;
-----------------------------------
-- length of customers id
----------------------------------- 
SELECT LEN(cid)
FROM bronze.erp_cust_az12
GROUP BY LEN(cid)
-----------------------------------
-- there are 2 ids lengths
-----------------------------------
SELECT cid
FROM bronze.erp_cust_az12
WHERE LEN(cid)= 13 -- or 10
-----------------------------------
-- use only correct form (len of 10)
-----------------------------------
SELECT *
FROM bronze.erp_cust_az12
WHERE SUBSTRING(cid, 4, LEN(cid)) NOT IN (SELECT cst_key FROM silver.crm_customer_info)
-----------------------------------
-- see all distinct genders
-----------------------------------
SELECT DISTINCT UPPER(gen)
FROM bronze.erp_cust_az12;
-----------------------------------
-- ther ar records with spaces instead of gender, see the rows
-----------------------------------
SELECT *
FROM bronze.erp_cust_az12
WHERE gen = '   ';
-----------------------------------
-- see the biggest birthday date
-----------------------------------
SELECT *
FROM bronze.erp_cust_az12
ORDER BY bdate DESC;

-- =======================================================
-----------------------------------
-- have a look into the table
-----------------------------------
SELECT 
	cid,
	cntry
FROM bronze.erp_loc_a101;
-----------------------------------
-- remove '-' where ids with it do not appear in customer info
-----------------------------------
SELECT 
	REPLACE(cid, '-', '') cid,
	cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_customer_info)
-----------------------------------
-- find all distinct countries
-----------------------------------
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;
-----------------------------------
-- uniform countries names
-----------------------------------
SELECT 
	CASE
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
		WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'n/a'
		ELSE TRIM(cntry)
	END cntry
FROM bronze.erp_loc_a101
GROUP BY cntry

-- =======================================================
-----------------------------------
-- see the full table info
-----------------------------------
SELECT 
	id,
	cat,
	cubcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;
-----------------------------------
-- find all distinct ids
-----------------------------------
SELECT DISTINCT id
FROM bronze.erp_px_cat_g1v2;
-----------------------------------
-- find all distinct catgories
-----------------------------------
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;
-----------------------------------
-- find all distinct subcategories
-----------------------------------
SELECT DISTINCT cubcat
FROM bronze.erp_px_cat_g1v2;
-----------------------------------
-- find all distinct maintenance
-----------------------------------
SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;
-----------------------------------
-- see if ids dont have unnecessary spaces
-----------------------------------
SELECT id
FROM bronze.erp_px_cat_g1v2
WHERE id != TRIM(id)
