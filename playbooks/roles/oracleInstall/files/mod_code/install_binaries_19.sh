#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        install_binaries.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to install Oracle binaries
# VARIABLES: 
#        stage_dir = script staging path
#        sw_basedir = software files staging path
#        sversion = software version
#        orabase = oracle base path
#        orahome = oracle home path
#        oraloc  = oracle oraInventory path
#        orabin_file = oracle binary zip file 
#        db_sftw_file = oracle binary response file 
#        hostname  = name of database host
#        dba_mail = distribution list for messaging
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 01.09.2020    R Cutler        Add comments on code logic
# 10.09.2019    R Cutler        Code rewrite for automation                  
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variables
##########################################
#stage_loc="/app/oradba/automation/scripts"
sw_basedir="/app/vendor/oracle/DB"
stage_dir="/tmp/code"
sversion="19.0.0.0"
##########################################
# Set environment variables
##########################################
. ${stage_dir}/set_env_19.sh
#
orabase=${orabase}
orahome=${orahome}
oraloc=${orabase}/oraInventory
orabin_file="db_home.zip"
db_sftw_file="db_software.rsp"
ldate=`date +%F`
export HOSTNAME=`hostname`
export DBA_MAIL=${notifylist}
##########################################
# Module to create directories
##########################################
make_dir()
{
mkdir -p ${orabase}/oraInventory
mkdir -p ${orahome}
mkdir -p ${stage_dir}
}
##########################################
# Module to call runInstaller 
##########################################
install_software()
{
##########################################
#  Change to oracle home and unzip binary file 
#    run the installer with the response file
#    backup the root.sh file
##########################################
cd ${orahome}
unzip -q ${sw_basedir}/${sversion}/${orabin_file}
./runInstaller -silent -responseFile ${stage_dir}/${db_sftw_file} -noconfig -waitforcompletion > /tmp/track_prog.oracle
cp root.sh root.sh.bkup
}
##########################################
#  1. Build file systems 
##########################################
make_dir
##########################################
#  2. Call to install software
##########################################
install_software
##########################################
#   end of script
