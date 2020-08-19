#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        deinstall_orasys.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to remove directories and files create under root access
#              *** Must be ran with root access
# VARIABLES:
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 01.09.2020    R Cutler        Add comments on code logic
# 11.26.2019    R Cutler        Modified to manage sticky bit directories
# 11.20.2019    R Cutler        Initial code
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Remove all files and directories
#   that have root ownership or permissions
##########################################
rm -rf /etc/oratab
rm -rf /etc/oraInst.loc
rm -rf /opt/ORCLfmap
rm -rf /app/oracle/*
rm -rf /data/audit01/*
rm -rf /data/oracle01/*
rm -rf /data/oracle02/*
rm -rf /data/oracle03/*
##########################################
echo -e "STATUS:SUCCESS\n"
##########################################
#  end of script
