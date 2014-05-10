-- Table: _webappos_auto_login

-- DROP TABLE _webappos_auto_login;

CREATE TABLE _webappos_auto_login
(
  id serial NOT NULL,
  user_id integer NOT NULL,
  login_key character varying(128) NOT NULL,
  expires_date timestamp without time zone NOT NULL,
  created_date timestamp without time zone NOT NULL DEFAULT now(),
  updated_date timestamp without time zone,
  CONSTRAINT _webappos_auto_login_pkey PRIMARY KEY (id),
  CONSTRAINT _webappos_auto_login_login_key_key UNIQUE (login_key)
)
WITH (
  OIDS=FALSE
);

-- Table: _webappos_oauth_manager

-- DROP TABLE _webappos_oauth_manager;

CREATE TABLE _webappos_oauth_manager
(
  id serial NOT NULL,
  user_id integer NOT NULL,
  uid character varying(256) NOT NULL,
  provider character varying(64) NOT NULL,
  created_date timestamp without time zone NOT NULL DEFAULT now(),
  updated_date timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT _webappos_oauth_manager_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

-- Table: _webappos_system_constant

-- DROP TABLE _webappos_system_constant;

CREATE TABLE _webappos_system_constant
(
  id serial NOT NULL,
  category text,
  key text NOT NULL,
  value text NOT NULL,
  data_type text NOT NULL,
  display_order integer DEFAULT 0,
  created_date timestamp without time zone NOT NULL DEFAULT now(),
  updated_date timestamp without time zone,
  CONSTRAINT system_constant_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);


-- View: _webappos_schema_columns

-- DROP VIEW _webappos_schema_columns;

CREATE OR REPLACE VIEW _webappos_schema_columns AS 
 SELECT columns.table_name, columns.column_name, 
        CASE
            WHEN upper(columns.is_nullable::text) = 'YES'::text THEN true
            ELSE false
        END AS is_nullable, 
    columns.data_type, comment.column_comment, 
    COALESCE(unique_constraint.is_unique, false) AS is_unique
   FROM information_schema.columns columns
   LEFT JOIN ( SELECT psat.schemaname, psat.relname AS table_name, 
            pa.attname AS column_name, pd.description AS column_comment
           FROM pg_stat_all_tables psat, pg_description pd, pg_attribute pa
          WHERE psat.relid = pd.objoid AND pd.objsubid <> 0 AND pd.objoid = pa.attrelid AND pd.objsubid = pa.attnum) comment ON comment.schemaname = columns.table_schema::name AND comment.table_name = columns.table_name::name AND comment.column_name = columns.column_name::name
   LEFT JOIN ( SELECT DISTINCT pg_class.relname, pg_attribute.attname, 
       pg_constraint.conrelid, true AS is_unique
      FROM pg_constraint
   JOIN pg_class ON pg_class.oid = pg_constraint.conrelid
   JOIN pg_attribute ON pg_constraint.conindid = pg_attribute.attrelid
  WHERE pg_constraint.contype = 'u'::"char") unique_constraint ON unique_constraint.relname = columns.table_name::name AND unique_constraint.attname = columns.column_name::name
  WHERE columns.table_catalog::name = current_database() AND columns.table_schema::name = "current_schema"();

