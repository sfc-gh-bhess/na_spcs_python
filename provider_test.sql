-- FOLLOW THE consumer_setup.sql TO SET UP THE TEST ON THE PROVIDER
USE ROLE nac;
USE WAREHOUSE wh_nac;

-- Create the APPLICATION
DROP APPLICATION IF EXISTS spcs_app_instance;
CREATE APPLICATION spcs_app_instance FROM APPLICATION PACKAGE spcs_app_pkg USING VERSION v1;

-- Grant permission(s) via Snowsight configuration UI or via SQL
GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO APPLICATION spcs_app_instance;
-- Grant access to the TPC-H ORDERS view in NAC_TEST.DATA via Snowsight Configuraiton UI or via SQL
CALL spcs_app_instance.v1.register_single_callback(
  'ORDERS_TABLE' , 'ADD', SYSTEM$REFERENCE('VIEW', 'NAC_TEST.DATA.ORDERS', 'PERSISTENT', 'SELECT'));
-- Grant access to the query warehouse via SQL
--   This is a temporary step. In the future this will be done via the Permissions SDK, 
--   but SERVICE QUERY_WAREHOUSE does not support References today.
GRANT USAGE ON WAREHOUSE wh_nac TO APPLICATION spcs_app_instance;
-- Create EXTERNAL ACCESS INTEGRATION for webpage to load image from external source
--   This is a temporary step. In the future this will be done via the Permissions SDK.
CREATE OR REPLACE NETWORK RULE nac_test.data.nr_wiki
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('upload.wikimedia.org');
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION eai_wiki
  ALLOWED_NETWORK_RULES = ( nac_test.data.nr_wiki )
  ENABLED = true;
GRANT USAGE ON INTEGRATION eai_wiki TO APPLICATION spcs_app_instance;

-- Create the COMPUTE POOL for the APPLICATION
DROP COMPUTE POOL IF EXISTS pool_nac;
CREATE COMPUTE POOL pool_nac FOR APPLICATION spcs_app_instance
    MIN_NODES = 1 MAX_NODES = 1
    INSTANCE_FAMILY = CPU_X64_XS
    AUTO_RESUME = TRUE;
GRANT USAGE ON COMPUTE POOL pool_nac TO APPLICATION spcs_app_instance;
DESCRIBE COMPUTE POOL pool_nac;
-- Wait until COMPUTE POOL state returns `IDLE` or `ACTIVE`

-- Start the app
CALL spcs_app_instance.app_public.start_app('POOL_NAC', 'WH_NAC', 'EAI_WIKI');
-- Grant usage of the app to others
GRANT APPLICATION ROLE spcs_app_instance.app_user TO ROLE sandbox;
-- Get the URL for the app
CALL spcs_app_instance.app_public.app_url();
