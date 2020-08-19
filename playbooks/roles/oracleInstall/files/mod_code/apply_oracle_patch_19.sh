#!/bin/bash
# apply_oracle_patch_19.sh
#   Version: 12cR2 and higher
#   Description: Code to patch binaries and database using Oracle combo patchsets
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 07.21.2020    R Cutler        Modify for Jul patchset
# 04.17.2020    R Cutler        Modify for Apr patchset
# 01.24.2020    R Cutler        Modify for new patchset
# 01.09.2020    R Cutler        Add comments on code logic
# 10.22.2019    R Cutler        Code for automation
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variables
##########################################
stage_dir="/tmp/code"
##########################################
# Set environment variables
##########################################
export ORACLE_BASE=${orabase}
export PATCH_DIR="/app/vendor/oracle/DB/PatchDir/19000"
export OPATCH_DIR="/app/vendor/oracle/DB/PatchDir/OPatch/19000/OPatch"
export ORATAB="/etc/oratab"
export ORACLE_HOME=`grep -E "19.0" $ORATAB |head -1 |awk -F ":" '{print $2}'`
export LSNR=`grep ^LISTENER $ORACLE_HOME/network/admin/listener.ora 2>/dev/null | head -24 | awk '{print $1}'`
export HOSTNAME=`hostname`
export DBA_MAIL=${notifylist}
##########################################
# send an email that the patching process is beginning
##########################################
echo "patching of server $HOSTNAME began at `date`" > /tmp/start_time.txt
mailx -s "DCIPATCHING -- patching server $HOSTNAME has begun" oracle@$HOSTNAME $DBA_MAIL < /tmp/start_time.txt
chmod 777 /tmp/start_time.txt
##########################################
# switch to patch directory
##########################################
cd $PATCH_DIR
##########################################
# Clean out log file then delete
##########################################
touch /tmp/sqlplus.log
rm /tmp/sqlplus.log
##########################################
# Checking combo patch levels
#   move into position to apply the first of 2 patches 
# Uncomment the unzip when accounts have write to /data/vendor 
##########################################
### unzip -u `ls -1rt *.zip|tail -1`
cd `ls -1rdt */ | tail -1`
cd `ls -1rdt */ | tail -1`
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
# apply the first of 2 patches 
##########################################
$ORACLE_HOME/OPatch/opatch apply -silent
#$OPATCH_DIR/opatch apply -silent
##########################################
# move to the base directory of the second patch
##########################################
cd ..
##########################################
# move into position to apply the second of 2 patches
# apply the second of 2 patches 
##########################################
cd `ls -1rdt */ | head -2`
$ORACLE_HOME/OPatch/opatch apply -silent
#$OPATCH_DIR/opatch apply -silent
##########################################
# back to the combo patch top directory 
##########################################
cd ../../
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
##########################################
while read sid oh
do
ORACLE_SID=$sid; export ORACLE_SID
ORACLE_HOME=$oh; export ORACLE_HOME
$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" <<EOF > /dev/null
@$stage_dir/start_databases_19.sql
exit
EOF
cat /tmp/output.txt >> /tmp/sqlplus.log
chmod 777 /tmp/output.txt
chmod 777 /tmp/sqlplus.log
##########################################
# apply post patch sql
##########################################
$ORACLE_HOME/OPatch/datapatch -verbose
##########################################
# bounce the database
#  recompile invalid objects
##########################################
echo "now bouncing database"
$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" <<EOF > /dev/null
@$stage_dir/restart_databases_19.sql
@$ORACLE_HOME/rdbms/admin/utlrp.sql
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
# verify patches have been applied to binaries
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
mailx -s "DCIPATCHING -- patching server $HOSTNAME completed $RESULT" oracle@$HOSTNAME $DBA_MAIL < /tmp/patch.log
##########################################
# end of script
