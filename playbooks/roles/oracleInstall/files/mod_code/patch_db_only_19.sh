#!/bin/bash
#
# patch_db_only_19.sh
#   Version: 12cR2 and higher
#   Description: Patch database only using Oracle combo patch
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 07.21.2020    R Cutler        Modify for Jul patchset
# 01.24.2020    R Cutler        Modify for new patchset
# 01.09.2020    R Cutler        Add comments on code logic
# 11.07.2019    R Cutler        Code for automation
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variables
##########################################
stage_dir="/tmp/code"
##########################################
# Set environment variables
##########################################
. ${stage_dir}/set_env_19.sh
#
export ORATAB="/etc/oratab"
export ORACLE_HOME=`grep -E "19.0" $ORATAB |head -1 |awk -F ":" '{print $2}'`
export HOSTNAME=`hostname`
export DBA_MAIL=${notifylist}
##########################################
# send an email that the patching process is beginning
##########################################
echo "patching of database $HOSTNAME began at `date`" > /tmp/start_time.txt
mailx -s "DCSPATCHING -- patching database only $HOSTNAME has begun" oracle@$HOSTNAME $DBA_MAIL < /tmp/start_time.txt
chmod 777 /tmp/start_time.txt
#
##########################################
# stop listener(s)
# append the listener_start.log to patch.log
##########################################
for LSNR in `grep ^LISTENER $ORACLE_HOME/network/admin/listener.ora | head -24 | awk '{print $1}'`
do
 $ORACLE_HOME/bin/lsnrctl stop $LSNR >> /tmp/listener_stop.log
 cat /tmp/listener_stop.log >> /tmp/patch.log
 chmod 777 /tmp/listener_stop.log
done
##########################################
# stop the database
##########################################
$ORACLE_HOME/bin/dbshut >> /tmp/patch.log
##########################################
# get sid and oracle_home from oratab file
#  remove any entries with *
#  remove the temp file - grant rwx permissions
##########################################
grep oracle $ORATAB | awk -F: '{print $1" "$2}' > /tmp/tempdbs
grep -v "*" /tmp/tempdbs > /tmp/dbs.lst
rm /tmp/tempdbs
chmod 777 /tmp/dbs.lst
##########################################
# start database(s) in upgrade mode
#  send messages to log files
#  sleep for 2 seconds
##########################################
while read sid oh
do
ORACLE_SID=$sid; export ORACLE_SID
ORACLE_HOME=$oh; export ORACLE_HOME
echo "startup upgrade database"
$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" <<EOF > /dev/null
@${stage_dir}/start_databases_19.sql
exit;
EOF
cat /tmp/output.txt >> /tmp/sqlplus.log
chmod 777 /tmp/output.txt
chmod 777 /tmp/sqlplus.log
sleep 2
##########################################
# apply post patch sql
##########################################
$ORACLE_HOME/OPatch/datapatch -verbose
##########################################
# bounce the database
# recompile invalid objects
##########################################
echo "now bouncing database"
$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" <<EOF > /dev/null
@${stage_dir}/restart_databases_19.sql
@${ORACLE_HOME}/rdbms/admin/utlrp.sql
exit
EOF
##########################################
# verify patch has been applied to data dictionary
##########################################
echo " "
$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" <<EOF > /tmp/sqlplus.log
select patch_id from dba_registry_sqlpatch where patch_id in (31281355,31219897);
exit
EOF
cat /tmp/output.txt >> /tmp/sqlplus.log
done < /tmp/dbs.lst
##########################################
# start listener(s)
# append the sqlplus.log and listener_start.log to patch.log
##########################################
for LSNR in `grep ^LISTENER $ORACLE_HOME/network/admin/listener.ora | head -24 | awk '{print $1}'`
do
 $ORACLE_HOME/bin/lsnrctl start $LSNR >> /tmp/listener_start.log
 cat /tmp/sqlplus.log >> /tmp/patch.log
 cat /tmp/listener_start.log >> /tmp/patch.log
 chmod 777 /tmp/listener_start.log
done
##########################################
# verify opatch has been applied to binaries
##########################################
echo " " >> /tmp/patch.log
echo "Database patch: " `$ORACLE_HOME/OPatch/opatch lsinv | grep 31281355` >> /tmp/patch.log
echo "OJVM patch: " `$ORACLE_HOME/OPatch/opatch lsinv | grep 31219897` >> /tmp/patch.log
##########################################
# look for errors in the log
# send log information to the designated DBA
##########################################
ERRCNT=`grep -E "ORA-|error" /tmp/patch.log |wc -l`
if [ ! "${ERRCNT}" = "0" ]
   then
        RESULT="with errors"
        echo -e "STATUS:FAILURE\n"
   else
        RESULT="without errors"
        echo -e "STATUS:SUCCESS\n"
fi
##########################################
# Cleanup/remove interim logs
#  change permissions to rwx on main log
##########################################
rm /tmp/listener_start.log
rm /tmp/listener_stop.log
rm /tmp/start_time.txt
chmod 777 /tmp/patch.log
##########################################
# Send notification
##########################################
mailx -s "DCSPATCHING -- patching database only $HOSTNAME completed $RESULT" oracle@$HOSTNAME $DBA_MAIL < /tmp/patch.log
##########################################
# end of script
