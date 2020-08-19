#
#   environment script called by all local scripts
#
export NLS_DATE_FORMAT='YYYY-MM-DD-HH24:MI:SS'
export NLS_LANG=American_America.WE8MSWIN1252
export ORACLE_BASE=/app/oracle
export ORACLE_HOME=/app/oracle/product/19.0.0/dbhome_1
export ORACLE_SID=<sid>
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/jdbc/lib:/usr/lib
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/dbs:$ORACLE_HOME/OPatch:$ORACLE_BASE/local:/usr/local/bin:/usr/local/sbin:/app/share/bin:/app/share/sbin:/usr/bin/X11:/bin:/usr/bin:/sbin:/usr/sbin:.
export TNS_ADMIN=/app/oracle/product/19.0.0/dbhome_1/network/admin
export EMAIL_LIST=<list>
#
