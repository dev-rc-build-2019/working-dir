#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        dbca_build.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to build the Oracle 19c database
# VARIABLES: 
#        oracleid   = oracle unix id
#        orabase    = oracle base path
#        orahome    = oracle home path
#        orasidp    = oracle sid
#        charset    = character set for database
#        ntid       = application dba id
#        dbanotify  = application dba id email
#        dbca_copy_rsp  = dbca response file
#        dbca_temp_rsp  = modified dbca response file with environment changes
#        dbca_copy_file = dbca database template file 
#        dbca_temp_file =  modified dbca database template file with environment changes
#        genpasscode    = generate a random password for sys/system
#        genpassw   = generate a random password for master account
#        filename   = error/message log file
#        hostname   = name of database host
#        dba_mail   = distribution list for messaging
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 12.12.2019    R Cutler        Modify code accept derived fields from SC
# 10.21.2019    R Cutler        Modify code to address errors        
# 10.09.2019    R Cutler        Code for automation                  
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variables
##########################################
stage_loc="/app/oradba/automation/scripts"
stage_dir="/tmp/code"
tarfile=code.tar
##########################################
# Set environment variables
##########################################
. ${stage_dir}/set_env_19.sh
#########
oracleid=${oraid}
orabase=${orabase}
orahome=${orahome}
ldate=`date +%F`
#########
orasidp=`echo $1 | tr [:upper:] [:lower:]`
charset=`echo $2 | tr [:lower:] [:upper:]`
ntid=`echo $3 | tr [:upper:] [:lower:]`
dbanotify=`echo $4 | tr [:upper:] [:lower:]`
dbca_copy_rsp="${stage_dir}/dbca_db_copy.rsp"
dbca_temp_rsp="${stage_dir}/dbca_db.rsp"
dbca_copy_file="${stage_dir}/dbca_oracle19_copy.dbc"
dbca_temp_file="${stage_dir}/dbca_oracle19.dbc"
genpasscode=`< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c12`
genpassw=`< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c12`
export FILENAME="/tmp/dbca_build.log"
export HOSTNAME=`hostname`
export DBA_MAIL=${notifylist}
##########################################
#    Module to build environment
##########################################
build_db()
{
###########################################
# Modify template file(s)
###########################################
cp ${dbca_copy_file} ${dbca_temp_file}
/bin/sed -i "s/<orasid>/${sidl}/g" ${dbca_temp_file}
/bin/sed -i "s/<sgasize>/${sgamgb}/g" ${dbca_temp_file}
/bin/sed -i "s/<charset>/${charset}/g" ${dbca_temp_file}
#
cp ${dbca_copy_rsp} ${dbca_temp_rsp}
/bin/sed -i "s/<orasid>/${sidl}/g" ${dbca_temp_rsp}
/bin/sed -i "s/<passcode>/${genpasscode}/g" ${dbca_temp_rsp}
/bin/sed -i 's|<dbcafile>|'${dbca_temp_file}'|g' ${dbca_temp_rsp}
#
${orahome}/bin/dbca -silent -createDatabase -responseFile ${dbca_temp_rsp} > ${FILENAME}
${stage_dir}/postDBprov_19.sh $sidl $mtype $ntid $genpassw
${stage_dir}/create_cron.sh
#
mv ${orahome}/bin/dbshut ${orahome}/bin/dbshut.${ldate}
mv ${orahome}/bin/dbstart ${orahome}/bin/dbstart.${ldate}
cp ${stage_dir}/dbshut_auto_19 ${orahome}/bin/dbshut
cp ${stage_dir}/dbstart_auto_19 ${orahome}/bin/dbstart
}
##########################################
#    Module to calculate the sga size
##########################################
calc_sga()
{
##########################################
# SGA calculations
# Handle different versions of RHEL
##########################################
sysmem=`grep MemTotal /proc/meminfo | awk -F ':' '{ print $2 }' | cut -d" " -f8`
sysmem2=`grep MemTotal /proc/meminfo | awk -F ':' '{ print $2 }' | cut -d" " -f9`
mgb=1048576
gbyte=1073741824
##########################################
#  Condition to handle field differences -
#     If RAM is zero set sysmem to sysmem2 
##########################################
if [ -z $sysmem ]
then
   sysmem=$sysmem2
fi
##########################################
# Calculate SGA size from RAM
#  RAM minus (RAM*20%-for other) then use 65% of what is left
#      to account for SGA and PGA
##########################################
sga=$(( ($sysmem-($sysmem*20/100))*65/100 ))
newsga=`expr $sga \* 1024`
}
##########################################
# Module to obtain the following:      
#   Data Center, and environment
##########################################
gather_data() 
{
##########################################
#   Build Oracle SID from variables
##########################################
sid="${orasidp}"
##########################################
#   Use the input from gather_data    
#      module to build the SID 
##########################################
sidl=`echo ${sid} | tr [:upper:] [:lower:]`
sidu=`echo ${sid} | tr [:lower:] [:upper:]`
export orasid=${sidl}
export ORACLE_SID=${sidl}
export glorasid="${sidl}.us.lmco.com"
##########################################
# Set the file to add Oracle env parms
##########################################
cp ${HOME}/.cshrc ${HOME}/.cshrc.${ldate}
cat ${stage_dir}/cshrc_19 >> $HOME/.cshrc
echo "setenv ORACLE_SID $orasid" >> $HOME/.cshrc
}
##########################################
# Module to create local directories   
##########################################
make_dir()
{
mkdir -p /home/${oracleid}/${sidu}
mkdir -p /home/${oracleid}/${sidu}/sysout
mkdir -p /home/${oracleid}/${sidu}/scripts
mkdir -p /data/dump01/$sidl
mkdir -p /data/oracle01/$sidl/app
}
##########################################
# EXECUTE MODULES
#    Call the modules for execution
##########################################
#  1. Call to get input 
##########################################
gather_data
##########################################
#  2. Call to calculate SGA
##########################################
calc_sga
sgamgb=$(( $sga/1024 ))
##########################################
#  Determine if memory target will be used
##########################################
if [ $(($sysmem/$mgb)) -le 16 ] && [ $(($sga/$mgb)) -le 8 ]
then
   mtype='m'
fi
##########################################
#  3. Call to create directories
##########################################
make_dir
##########################################
#  If the net_build.sh does not return successfully
#  then send message otherwise
#   run the build module
##########################################
${stage_dir}/net_build_19.sh ${sidl} 
if [ "$?" = "0" ]; then
  build_db
  ${stage_dir}/serviceupdate.sh $charset $dbanotify $ntid $genpassw
else
  echo -e "STATUS:FAILURE\n"
  echo -e "ERRORMESSAGE:Failed database build at net_build_19.sh - check logs\n"
fi
##########################################
#  end of script
