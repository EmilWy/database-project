/*
=============================================================
Create procedure for silver layer
=============================================================
Script Purpose:
    Use this script for batch insert of data from bronze layer, cleaned of duplicates, nulls,
    multiplated values etc. Use if data needs to be updated (changes in bronze layer).
	
	It informs about execution time for each table, for bottleneck tracebility
	and full load time. It informs about error occurance via try-catch.
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    BEGIN TRY
        DECLARE @start_time DATETIME, @end_time DATETIME
		DECLARE @start_time_full DATETIME, @end_time_full DATETIME
		SET @start_time_full = GETDATE()
		PRINT '============================================'
		PRINT 'LODAING CRM DATA FROM BRONZE LAYER'
		PRINT '============================================'

        PRINT 'Truncating table silver.crm_customer_info'
        TRUNCATE TABLE silver.crm_customer_info;
        PRINT 'Bulk inserting data into table silver.crm_customer_info'
		SET @start_time = GETDATE();
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
        WHERE flag.earl_create_date = 1 AND cst_id IS NOT NULL;
        SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		
		PRINT '--------------------------------------------'
        PRINT 'Truncating table silver.crm_pdr_info'
        TRUNCATE TABLE silver.crm_pdr_info;
        PRINT 'Bulk inserting data into table silver.crm_pdr_info'
		SET @start_time = GETDATE();
        INSERT INTO silver.crm_pdr_info (
            prd_id,
            prd_cat_id,
            prd_key,
	        prd_nm,
            prd_cost,
	        prd_line,
	        prd_start_dt,
	        prd_end_dt
        )

        SELECT 
	        prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat_id,
            SUBSTRING(prd_key, 7, len(prd_key)) AS prd_key,
	        prd_nm,
            ISNULL(prd_cost, 0) as prd_cost,
	        CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END prd_line,
	        prd_start_dt,
	        DATEADD(DAY, -1, LEAD(prd_start_dt, 1) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC)) AS prd_end_dt_new
        FROM bronze.crm_pdr_info
        ORDER BY prd_id;
        SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		
		PRINT '--------------------------------------------'
        PRINT 'Truncating table silver.crm_sales_details'
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT 'Bulk inserting data into table silver.crm_sales_details'
		SET @start_time = GETDATE();
        INSERT INTO silver.crm_sales_details ( 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )

        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
		        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8 THEN NULL
		        ELSE CONVERT(DATE, CAST(sls_order_dt AS NVARCHAR))
	        END sls_order_dt,
	        CONVERT(DATE, CAST(sls_ship_dt AS NVARCHAR)) AS sls_ship_dt,
	        CONVERT(DATE, CAST(sls_due_dt AS NVARCHAR)) AS sls_due_dt,
            CASE
		        WHEN sls_sales <= 0 OR sls_sales IS NULL or sls_sales != ABS(sls_quantity*sls_price) THEN ABS(sls_quantity*sls_price)
		        ELSE sls_sales 
	        END sls_sales, 
	        sls_quantity, 
	        CASE
		        WHEN sls_price <=0 OR sls_price IS NULL THEN sls_sales/sls_quantity
		        ELSE sls_price
	        END sls_price
        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		
		PRINT '--------------------------------------------'
        PRINT 'Truncating table silver.erp_cust_az12'
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT 'Bulk inserting data into table silver.erp_cust_az12'
		SET @start_time = GETDATE();
        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )

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
        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		
		PRINT '--------------------------------------------'
        PRINT 'Truncating table silver.erp_loc_a101'
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT 'Bulk inserting data into table silver.erp_loc_a101'
		SET @start_time = GETDATE();
        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )

        SELECT 
	        REPLACE(cid, '-', '') cid,
	        CASE
		        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		        WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
		        WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'n/a'
		        ELSE TRIM(cntry)
	        END cntry
        FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		
		PRINT '--------------------------------------------'
        PRINT 'Truncating table silver.erp_px_cat_g1v2'
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT 'Bulk inserting data into table silver.erp_px_cat_g1v2'
		SET @start_time = GETDATE();
        INSERT INTO silver.erp_px_cat_g1v2(
            id,
	        cat,
	        cubcat,
	        maintenance
        )

        SELECT 
	        id,
	        cat,
	        cubcat,
	        maintenance
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		
		SET @end_time_full = GETDATE()
		PRINT '============================================'
		PRINT 'FINISHED'
		PRINT 'Full execution time: ' + CAST(DATEDIFF(second, @start_time_full, @end_time_full) AS NVARCHAR) + ' seconds'
		PRINT '============================================'
	END TRY
	BEGIN CATCH
		PRINT '============================================'
		PRINT 'ERROR Occured'
		PRINT '============================================'
	END CATCH
END
