CREATE APPLICATION ROLE app_admin;
CREATE APPLICATION ROLE app_user;
CREATE SCHEMA IF NOT EXISTS app_public;
GRANT USAGE ON SCHEMA app_public TO APPLICATION ROLE app_admin;
GRANT USAGE ON SCHEMA app_public TO APPLICATION ROLE app_user;
CREATE OR ALTER VERSIONED SCHEMA v1;
GRANT USAGE ON SCHEMA v1 TO APPLICATION ROLE app_admin;


CREATE PROCEDURE v1.register_single_callback(ref_name STRING, operation STRING, ref_or_alias STRING)
 RETURNS STRING
 LANGUAGE SQL
 AS $$
      BEGIN
      CASE (operation)
         WHEN 'ADD' THEN
            SELECT system$set_reference(:ref_name, :ref_or_alias);
         WHEN 'REMOVE' THEN
            SELECT system$remove_reference(:ref_name);
         WHEN 'CLEAR' THEN
            SELECT system$remove_reference(:ref_name);
         ELSE
            RETURN 'Unknown operation: ' || operation;
      END CASE;
      RETURN 'Operation ' || operation || ' succeeds.';
      END;
   $$;
GRANT USAGE ON PROCEDURE v1.register_single_callback( STRING,  STRING,  STRING) TO APPLICATION ROLE app_admin;

CREATE OR REPLACE PROCEDURE app_public.start_app(pool_name VARCHAR)
    RETURNS string
    LANGUAGE sql
    AS $$
BEGIN
    CREATE SERVICE IF NOT EXISTS app_public.st_spcs
        IN COMPUTE POOL Identifier(:pool_name)
        SPECIFICATION_FILE='fullstack.yaml'
        QUERY_WAREHOUSE=Reference('STREAMLIT_WAREHOUSE')
    ;
    GRANT USAGE ON SERVICE app_public.st_spcs TO APPLICATION ROLE app_user;

    RETURN 'Service started. Check status, and when ready, get URL';
END
$$;
GRANT USAGE ON PROCEDURE app_public.start_app(VARCHAR) TO APPLICATION ROLE app_admin;

CREATE OR REPLACE PROCEDURE app_public.start_app(pool_name VARCHAR, wh_name VARCHAR, eai_name VARCHAR)
    RETURNS string
    LANGUAGE sql
    AS $$
BEGIN
    EXECUTE IMMEDIATE 'CREATE SERVICE IF NOT EXISTS app_public.st_spcs
        IN COMPUTE POOL Identifier(''' || pool_name || ''')
        SPECIFICATION_FILE=fullstack.yaml
        QUERY_WAREHOUSE=''' || wh_name || '''
        EXTERNAL_ACCESS_INTEGRATIONS=( ''' || Upper(eai_name) || ''' )'
        ;
    ;
    GRANT USAGE ON SERVICE app_public.st_spcs TO APPLICATION ROLE app_user;

    RETURN 'Service started. Check status, and when ready, get URL';
END
$$;
GRANT USAGE ON PROCEDURE app_public.start_app(VARCHAR, VARCHAR, VARCHAR) TO APPLICATION ROLE app_admin;

CREATE OR REPLACE PROCEDURE app_public.stop_app()
    RETURNS string
    LANGUAGE sql
    AS
$$
BEGIN
    DROP SERVICE IF EXISTS app_public.st_spcs;
END
$$;
GRANT USAGE ON PROCEDURE app_public.stop_app() TO APPLICATION ROLE app_admin;

CREATE OR REPLACE PROCEDURE app_public.app_url()
    RETURNS string
    LANGUAGE sql
    AS
$$
DECLARE
    ingress_url VARCHAR;
BEGIN
    SHOW ENDPOINTS IN SERVICE app_public.st_spcs;
    SELECT "ingress_url" INTO :ingress_url FROM TABLE (RESULT_SCAN (LAST_QUERY_ID())) LIMIT 1;
    RETURN ingress_url;
END
$$;
GRANT USAGE ON PROCEDURE app_public.app_url() TO APPLICATION ROLE app_admin;
GRANT USAGE ON PROCEDURE app_public.app_url() TO APPLICATION ROLE app_user;

-- Support functions
EXECUTE IMMEDIATE FROM 'support.sql';
