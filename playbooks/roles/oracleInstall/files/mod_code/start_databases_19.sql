--- start_databases.sql
--- called from apply_oracle.sh
spool /tmp/output.txt
startup upgrade;
spool off;
