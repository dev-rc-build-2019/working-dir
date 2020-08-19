CREATE ROLE fsdba_role;
GRANT ALL PRIVILEGES, SELECT ANY DICTIONARY  TO fsdba_role;
GRANT SELECT_CATALOG_ROLE, SCHEDULER_ADMIN TO fsdba_role;
GRANT DATAPUMP_EXP_FULL_DATABASE, DATAPUMP_IMP_FULL_DATABASE TO fsdba_role;
GRANT EXP_FULL_DATABASE, IMP_FULL_DATABASE TO fsdba_role;
GRANT XDBADMIN, XDB_SET_INVOKER TO fsdba_role;
GRANT GRANT ANY PRIVILEGE to fsdba_role;
GRANT GRANT ANY OBJECT PRIVILEGE to fsdba_role;

-----2014/09/17 adding for awr reportins - RAB
GRANT SELECT ON SYS.V_$DATABASE TO FSDBA_ROLE;
GRANT SELECT ON SYS.V_$INSTANCE TO FSDBA_ROLE;
GRANT EXECUTE ON SYS.DBMS_WORKLOAD_REPOSITORY TO FSDBA_ROLE;
GRANT SELECT ON SYS.DBA_HIST_DATABASE_INSTANCE TO FSDBA_ROLE;
GRANT SELECT ON SYS.DBA_HIST_SNAPSHOT TO FSDBA_ROLE;
GRANT OEM_ADVISOR to FSDBA_ROLE;
GRANT ADVISOR to FSDBA_ROLE;
REVOKE CREATE LIBRARY FROM FSDBA_ROLE;
