USE ROLE ACCOUNTADMIN;
CREATE ROLE IF NOT EXISTS naspcs_role;
GRANT ROLE naspcs_role TO ROLE accountadmin;
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE naspcs_role;
GRANT CREATE COMPUTE POOL ON ACCOUNT TO ROLE naspcs_role;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE naspcs_role;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE naspcs_role;
GRANT CREATE APPLICATION PACKAGE ON ACCOUNT TO ROLE naspcs_role;
GRANT CREATE APPLICATION ON ACCOUNT TO ROLE naspcs_role;
GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE naspcs_role;
CREATE WAREHOUSE IF NOT EXISTS wh_nap WITH WAREHOUSE_SIZE='XSMALL';
GRANT ALL ON WAREHOUSE wh_nap TO ROLE naspcs_role;

USE ROLE naspcs_role;
CREATE DATABASE IF NOT EXISTS spcs_app;
CREATE SCHEMA IF NOT EXISTS spcs_app.napp;
CREATE STAGE IF NOT EXISTS spcs_app.napp.app_stage;

DROP APPLICATION PACKAGE IF EXISTS spcs_app_pkg;
CREATE APPLICATION PACKAGE spcs_app_pkg;
-- For Support functions
CREATE SCHEMA spcs_app_pkg.shared_data;
CREATE TABLE spcs_app_pkg.shared_data.feature_flags(flags VARIANT, acct VARCHAR);
CREATE SECURE VIEW spcs_app_pkg.shared_data.feature_flags_vw AS SELECT * FROM spcs_app_pkg.shared_data.feature_flags WHERE acct = current_account();
GRANT USAGE ON SCHEMA spcs_app_pkg.shared_data TO SHARE IN APPLICATION PACKAGE spcs_app_pkg;
GRANT SELECT ON VIEW spcs_app_pkg.shared_data.feature_flags_vw TO SHARE IN APPLICATION PACKAGE spcs_app_pkg;
INSERT INTO spcs_app_pkg.shared_data.feature_flags SELECT parse_json('{"debug": ["GET_SERVICE_STATUS", "GET_SERVICE_LOGS", "LIST_LOGS", "TAIL_LOG"]}') AS flags, current_account() AS acct;
GRANT USAGE ON SCHEMA spcs_app_pkg.shared_data TO SHARE IN APPLICATION PACKAGE spcs_app_pkg;


-- For Provider-side Testing
USE ROLE naspcs_role;
GRANT INSTALL, DEVELOP ON APPLICATION PACKAGE spcs_app_pkg TO ROLE nac;
USE ROLE ACCOUNTADMIN;
GRANT CREATE APPLICATION ON ACCOUNT TO ROLE nac;

-- Create the Image Repository
USE ROLE naspcs_role;
CREATE IMAGE REPOSITORY IF NOT EXISTS spcs_app.napp.img_repo;
SHOW IMAGE REPOSITORIES IN SCHEMA spcs_app.napp;
-- Run configure.sh script
-- Build Docker image and push to repo via make
-- Upload files to Stage


