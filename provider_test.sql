-- FOLLOW THE consumer_setup.sql TO SET UP THE TEST ON THE PROVIDER
USE ROLE nac;
USE WAREHOUSE wh_nac;

-- Create the APPLICATION
DROP APPLICATION IF EXISTS na_spcs_python_app CASCADE;
CREATE APPLICATION na_spcs_python_app FROM APPLICATION PACKAGE na_spcs_python_pkg USING VERSION v2;

GRANT APPLICATION ROLE na_spcs_python_app.app_user TO ROLE sandbox;
-- Get the URL for the app
CALL na_spcs_python_app.app_public.app_url();



-- Use this for development purposes (after GRANTing NAC access to the STAGE and IMAGE REPOSITORY)
-- This is currently broken (SNOW-1435359)
USE ROLE nac;
DROP APPLICATION na_spcs_python_app CASCADE;
CREATE APPLICATION na_spcs_python_app FROM APPLICATION PACKAGE na_spcs_python_pkg USING '@spcs_app.napp.app_stage/na_spcs_python/v2';

