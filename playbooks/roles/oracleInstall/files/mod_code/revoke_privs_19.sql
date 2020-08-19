rem
rem
rem   grant explicit permissions
rem 
set echo on
GRANT EXECUTE on DBMS_SQL to DIP;
GRANT EXECUTE ON DBMS_JOB to DBSNMP;
GRANT EXECUTE ON DBMS_OBFUSCATION_TOOLKIT to DBSNMP;
GRANT EXECUTE on DBMS_SQL to DBSNMP;
GRANT EXECUTE ON DBMS_SQL to ORACLE_OCM;
GRANT EXECUTE ON UTL_FILE to ORACLE_OCM;
GRANT EXECUTE on DBMS_SQL to OUTLN;
GRANT EXECUTE ON DBMS_EXPORT_EXTENSION to SYSTEM;
GRANT EXECUTE ON DBMS_OBFUSCATION_TOOLKIT to SYSTEM;
GRANT EXECUTE ON DBMS_SQL to SYSTEM;
GRANT EXECUTE ON DBMS_LOB to XDB;
GRANT EXECUTE ON DBMS_SQL to XDB;
GRANT EXECUTE ON UTL_FILE to XDB;
rem
rem  additions for Oracle 19c
grant execute on dbms_lob to ctxsys;
grant execute on dbms_scheduler to ctxsys;
grant execute on dbms_sql to ctxsys;
grant execute on dbms_xmlgen to ctxsys;
grant execute on utl_http to ctxsys;
grant execute on dbms_lob to GSMADMIN_INTERNAL;
grant execute on dbms_random to GSMADMIN_INTERNAL;
grant execute on dbms_scheduler to GSMADMIN_INTERNAL;
grant execute on dbms_sql to GSMADMIN_INTERNAL;
grant execute on dbms_job to GSMADMIN_INTERNAL;
grant execute on utl_http to GSMADMIN_INTERNAL;
grant execute on utl_inaddr to GSMADMIN_INTERNAL;
grant execute on utl_tcp to GSMADMIN_INTERNAL;
grant execute on dbms_sql to LBACSYS;
grant execute on dbms_lob to mdsys;
grant execute on dbms_random to mdsys;
grant execute on dbms_sql to mdsys;
grant execute on utl_file to mdsys;
grant execute on utl_http to mdsys;
grant execute on dbms_xmlgen to mdsys;
grant execute on utl_tcp to mdsys;
grant execute on  dbms_sql to wmsys;
grant execute on  dbms_scheduler to xdb;
rem
rem   revoke permissions on  packages to comply with Vunerability Scans
rem 
REVOKE EXECUTE ON UTL_FILE FROM PUBLIC;
REVOKE EXECUTE ON DBMS_RANDOM FROM PUBLIC;
REVOKE EXECUTE ON UTL_HTTP FROM PUBLIC;
REVOKE EXECUTE ON UTL_SMTP FROM PUBLIC;
REVOKE EXECUTE ON UTL_TCP FROM PUBLIC;
REVOKE EXECUTE ON DBMS_SQL FROM PUBLIC;
REVOKE EXECUTE ON DBMS_EXPORT_EXTENSION FROM PUBLIC;
REVOKE EXECUTE ON DBMS_JOB FROM PUBLIC;
REVOKE EXECUTE ON DBMS_LOB FROM PUBLIC;
REVOKE EXECUTE ON DBMS_OBFUSCATION_TOOLKIT FROM PUBLIC;
REVOKE EXECUTE ON DBMS_JAVA FROM PUBLIC;
rem
rem   revoke permissions on packages - new 12c compliance             
rem 
REVOKE EXECUTE ON DBMS_ADVISOR FROM PUBLIC;
REVOKE EXECUTE ON DBMS_LDAP FROM PUBLIC;
REVOKE EXECUTE ON DBMS_SCHEDULER FROM PUBLIC;
REVOKE EXECUTE ON DBMS_XMLGEN FROM PUBLIC;
REVOKE EXECUTE ON HTTPURITYPE FROM PUBLIC;
REVOKE EXECUTE ON UTL_INADDR FROM PUBLIC;
