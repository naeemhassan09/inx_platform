#!/bin/bash
#
#Create  database base user and database
#
#Licence 
#Author Naeem ul Hassan <nhassan@innexiv.com>
#

#set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER innexiv WITH PASSWORD 'password';
    CREATE DATABASE bts owner innexiv;
	
    CREATE USER airflow WITH PASSWORD 'airflow';
    CREATE DATABASE airflow owner airflow;
	ALTER ROLE airflow SET search_path = 'public';
	-- CREATE EXTENSION tablefunc;
EOSQL

# Create functions in innexiv schema
psql -v ON_ERROR_STOP=1 --username "innexiv" --password "password" --dbname "bts"  <<-'EOSQL'
   -- Hex to integer
    CREATE OR REPLACE FUNCTION hex_to_int(hexval varchar) RETURNS integer AS $$
    DECLARE
       result  int;
    BEGIN
     EXECUTE 'SELECT x''' || hexval || '''::int' INTO result;
     RETURN result;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE STRICT;
	-- HEX to character/string
    CREATE OR REPLACE FUNCTION hex_to_char(hexval varchar) RETURNS integer AS $$
    DECLARE
       result  varchar;
    BEGIN
     EXECUTE 'SELECT x''' || hexval || '''::int' INTO result;
     RETURN result;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE STRICT;
EOSQL
© 2020 GitHub, Inc.