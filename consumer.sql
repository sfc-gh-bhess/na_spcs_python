-- Install Native App from Private Listing
-- ** USE THE NAME spcs_app_instance FOR THE APPLICATION **
USE ROLE ACCOUNTADMIN;
GRANT APPLICATION ROLE spcs_app_instance.app_admin TO ROLE nac;
GRANT APPLICATION ROLE spcs_app_instance.app_user TO ROLE nac;

USE ROLE nac;
USE WAREHOUSE wh_nac;
GRANT USAGE ON WAREHOUSE wh_nac TO APPLICATION spcs_app_instance;

-- Grant permission(s) via Snowsight configuration UI or via SQL
GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO APPLICATION spcs_app_instance;
-- Grant access to the TPC-H ORDERS view in NAC_TEST.DATA via Snowsight Configuraiton UI or via SQL
CALL spcs_app_instance.v1.register_single_callback(
  'ORDERS_TABLE' , 'ADD', SYSTEM$REFERENCE('VIEW', 'NAC_TEST.DATA.ORDERS', 'PERSISTENT', 'SELECT'));
-- Grant access to the query warehouse via SQL
GRANT USAGE ON WAREHOUSE wh_nac TO APPLICATION spcs_app_instance;

DROP COMPUTE POOL IF EXISTS pool_nac;
CREATE COMPUTE POOL pool_nac FOR APPLICATION spcs_app_instance
    MIN_NODES = 1 MAX_NODES = 1
    INSTANCE_FAMILY = CPU_X64_XS
    AUTO_RESUME = TRUE;
DESCRIBE COMPUTE POOL pool_nac;
GRANT USAGE ON COMPUTE POOL pool_nac TO APPLICATION spcs_app_instance;

-- Start the app
CALL spcs_app_instance.app_public.start_app('POOL_NAC','WH_NAC');
-- Grant app_user to roles that you want to be able to visit the service endpoint
GRANT APPLICATION ROLE spcs_app_instance.app_user TO ROLE sandbox;
CALL spcs_app_instance.app_public.app_url();
