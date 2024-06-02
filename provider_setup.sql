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
CREATE IMAGE REPOSITORY IF NOT EXISTS spcs_app.napp.img_repo;
SHOW IMAGE REPOSITORIES IN SCHEMA spcs_app.napp;
-- Run configure.sh script
-- Build Docker image and push to repo via make
-- Upload files to Stage


DROP APPLICATION PACKAGE IF EXISTS na_spcs_python_pkg;
CREATE APPLICATION PACKAGE na_spcs_python_pkg;
CREATE SCHEMA na_spcs_python_pkg.shared_data;
CREATE TABLE na_spcs_python_pkg.shared_data.feature_flags(flags VARIANT, acct VARCHAR);
CREATE SECURE VIEW na_spcs_python_pkg.shared_data.feature_flags_vw AS SELECT * FROM na_spcs_python_pkg.shared_data.feature_flags WHERE acct = current_account();
GRANT USAGE ON SCHEMA na_spcs_python_pkg.shared_data TO SHARE IN APPLICATION PACKAGE na_spcs_python_pkg;
GRANT SELECT ON VIEW na_spcs_python_pkg.shared_data.feature_flags_vw TO SHARE IN APPLICATION PACKAGE na_spcs_python_pkg;
INSERT INTO na_spcs_python_pkg.shared_data.feature_flags SELECT parse_json('{"debug": ["GET_SERVICE_STATUS", "GET_SERVICE_LOGS", "LIST_LOGS", "TAIL_LOG"]}') AS flags, current_account() AS acct;
GRANT USAGE ON SCHEMA na_spcs_python_pkg.shared_data TO SHARE IN APPLICATION PACKAGE na_spcs_python_pkg;


-- For Provider-side Testing
USE ROLE naspcs_role;
GRANT INSTALL, DEVELOP ON APPLICATION PACKAGE na_spcs_python_pkg TO ROLE nac;
USE ROLE ACCOUNTADMIN;
GRANT CREATE APPLICATION ON ACCOUNT TO ROLE nac;
