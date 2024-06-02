USE ROLE naspcs_role;

-- Build Docker image and push to repo via make 
-- Upload files to Stage
ALTER APPLICATION PACKAGE na_spcs_python_pkg ADD VERSION v2 USING @spcs_app.napp.app_stage/na_spcs_python/v2;

-- for subsequent updates to version
ALTER APPLICATION PACKAGE na_spcs_python_pkg ADD PATCH FOR VERSION v2 USING @spcs_app.napp.app_stage/na_spcs_python/v2;
