#!/bin/bash
# chg_oratab.sh
#   Version: 12cR2 and higher 
#   change the last character in the /etc/oratab file from N to Y
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 10.28.2019    R Cutler        Code for automation
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Change last character to a Y
#  Send success notification
##########################################
sed -i 's/N$/Y/' /etc/oratab
#
echo -e "STATUS:SUCCESS\n"
#####
# end of script
