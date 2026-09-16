/*
=============================================================
Create procedure for tables batch insert 
=============================================================
Script Purpose:
    Use this script for batch insert of data from files within the device 
	(with specified filepaths). Use if actual data needs to be updated.
	
	It informs about execution time for each table, for bottleneck tracebility
	and full load time. It informs about error occurance via try-catch.
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME
		DECLARE @start_time_full DATETIME, @end_time_full DATETIME
		SET @start_time_full = GETDATE()
		PRINT '============================================'
		PRINT 'LODAING CRM DATA FROM FILES'
		PRINT '============================================'

		PRINT 'Truncating table bronze.crm_customer_info'
		TRUNCATE TABLE bronze.crm_customer_info;
		PRINT 'Bulk inserting data into table bronze.crm_customer_info'
		SET @start_time = GETDATE();
		BULK INSERT bronze.crm_customer_info 
			FROM 'C:\Users\emili\source\repos\NewRepo\data\source_crm\cust_info.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		
		PRINT '--------------------------------------------'
		PRINT 'Truncating table bronze.crm_pdr_info'
		TRUNCATE TABLE bronze.crm_pdr_info;
		PRINT 'Bulk inserting data into table bronze.crm_pdr_info'
		SET @start_time = GETDATE();
		BULK INSERT bronze.crm_pdr_info 
			FROM 'C:\Users\emili\source\repos\NewRepo\data\source_crm\prd_info.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		
		PRINT '--------------------------------------------'
		PRINT 'Truncating table bronze.crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT 'Bulk inserting data into table bronze.crm_sales_details'
		SET @start_time = GETDATE();
		BULK INSERT bronze.crm_sales_details 
			FROM 'C:\Users\emili\source\repos\NewRepo\data\source_crm\sales_details.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
	
		PRINT '============================================'
		PRINT 'LODAING ERP DATA FROM FILES'
		PRINT '============================================'

		PRINT 'Truncating table bronze.erp_cust_az12'
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT 'Bulk inserting data into table bronze.erp_cust_az12'
		SET @start_time = GETDATE();
		BULK INSERT bronze.erp_cust_az12 
			FROM 'C:\Users\emili\source\repos\NewRepo\data\source_erp\cust_az12.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		
		PRINT '--------------------------------------------'
		PRINT 'Truncating table bronze.erp_loc_a101'
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT 'Bulk inserting data into table bronze.erp_loc_a101'
		SET @start_time = GETDATE();
		BULK INSERT bronze.erp_loc_a101 
			FROM 'C:\Users\emili\source\repos\NewRepo\data\source_erp\loc_a101.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT 'Insert time duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		
		PRINT '--------------------------------------------'
		PRINT 'Truncating table bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT 'Bulk inserting data into table bronze.erp_px_cat_g1v2'
		SET @start_time = GETDATE();
		BULK INSERT bronze.erp_px_cat_g1v2 
			FROM 'C:\Users\emili\source\repos\NewRepo\data\source_erp\px_cat_g1v2.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
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