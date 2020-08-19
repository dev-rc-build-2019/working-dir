--- restart_databases.sql
--- called from apply_oracle_patch.sh
spool /tmp/output.txt
shutdown immediate;
startup;
spool off;
