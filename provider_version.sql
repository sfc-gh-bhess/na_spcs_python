USE ROLE naspcs_role;

-- Build Docker image and push to repo via make 
-- Upload files to Stage
ALTER APPLICATION PACKAGE spcs_app_pkg ADD VERSION v1 USING @spcs_app.napp.app_stage/na_spcs_python/v1;

-- for subsequent updates to version
ALTER APPLICATION PACKAGE spcs_app_pkg ADD PATCH FOR VERSION v1 USING @spcs_app.napp.app_stage/na_spcs_python/v1;
