#!/bin/bash
#
#   pre_system_check.sh
#   Script to check host prior to database build 
#
# Rev Date    Rev#   Author   Change/Modification
# ----------- -----  -------- -------------------------------------
# 10.22.2018  1.2    RJC      Failure condition
# 09.21.2018  1.1    RJC      Conditions added for memory, swap and mounts per request GS
# 09.13.2018  1.0    RJC      Initial version
#
###################################
### Initialize global variables
###################################
#stage_dir='/app/oradba/automation/scripts'
stage_dir='/tmp/code'
###################################
### Set environment variables 
###################################
. ${stage_dir}/set_env_19.sh
#
export FILENAME=/tmp/precheck.log
export HOSTNAME=`hostname`
export DBA_MAIL=${notifylist}
###################################
###   Space calculations
###################################
megabyte=1048576
recommem=2097152
swaprammem=16777216
memtot=`grep MemTotal /proc/meminfo | awk -F ':' '{ print $2 }' | cut -d" " -f8`
memtot2=`grep MemTotal /proc/meminfo | awk -F ':' '{ print $2 }' | cut -d" " -f9`
swaptot=`grep SwapTotal /proc/meminfo | awk -F ':' '{ print $2 }' | cut -d" " -f7`
swaptot2=`grep SwapTotal /proc/meminfo | awk -F ':' '{ print $2 }' | cut -d" " -f8`
###################################
###  Condition to handle field differences - Depending on the value use the appropriate variable
###      for anything less than 10GB use alternate value
###################################
if [ -z $memtot ]
then
   memver=$memtot2
else
   memver=$memtot
fi 
if [ -z $swaptot ]
then
   swapver=$swaptot2
else
   swapver=$swaptot
fi 
###################################
### Calculate total for display
###################################
totmem=$((($memver/$megabyte)+1)) 
totswap=$((($swapver/$megabyte)+1)) 
totswapram=$(($swaprammem/$megabyte)) 
###################################
###   Begin processing
###     NFS mounts must be activitated
###################################
df -h /app/oraoem/.
df -h /app/oracle/.
df -h /data/oracle01/.
df -h /data/oracle02/.
df -h /data/oracle03/.
df -h /data/audit01/.
df -h /data/dump01/.
###################################
echo "         Platform Requirements "
echo " ===================================== "
echo "   Processor "
uname -m  
###################################
echo "   "
echo "   OS Version"
cat /etc/redhat-release 
#
echo "  "
echo "   Kernel version"
uname -r
#
echo "  "
echo "  "
echo "         RAM and Swap "
echo " ============================= "
###################################
###  Determine Memory Total	
###################################
echo "   Memory Total: minimum - 1GB / Recommended: 2GB or more"
###################################
###  Compare total memory to recommended size
###################################
if [ $memver -lt $recommem ]
then
 echo "*Meets minimum requirement of 1GB: " $totmem  " Recommenation of 2GB or more"
else
 echo "*Exceeds minium requirement of 1GB - MemTotal: " $totmem
fi
###################################
###  Determine Swap Total	
###################################
echo "   "
echo "   Swap should equal RAM when RAM: 2GB - 16GB / Swap should equal 16GB when RAM: More than 16GB"
###################################
###  Compare swap memory to total memory 
###################################
if [[ ($memver -gt $swaprammem) && ($totswap -ge $totswapram) ]]
then 
  echo "*Meets condition:  Swap space: " $totswap "  RAM size: " $totmem 
else
  if [ $swapver -ge $memver ]
  then
     echo "*Meets condition: Swap space: " $totswap "  RAM size: " $totmem
  else 
    echo "**Swap space: " $totswap "  RAM size: " $totmem
    echo "Warning: Swap and RAM are not equal - review sizes - requests more Swap if needed"
    #####
    # Failure on SWAP and RAM sizing
    #####
    exit 1
  fi
fi
###################################
echo " "
echo " "
echo "         System Packages "
echo " ============================= "
rpm -q binutils compat-libstdc++-33 gcc gcc-c++ glibc glibc-devel kernel ksh libaio libaio-devel libgcc libstdc++- libstdc++-devel libXext libXtst libX11 libXau libXi make sysstat unixODBC unixODBC-devel
###################################
echo " "
echo " "
echo "         Kernel parms "
echo " ============================= "
more /etc/sysctl.d/50-oracle.conf | grep aio-max-nr
more /etc/sysctl.d/50-oracle.conf | grep kernel.sh
more /etc/sysctl.d/50-oracle.conf | grep sem
more /etc/sysctl.d/50-oracle.conf | grep file-max
more /etc/sysctl.d/50-oracle.conf | grep ip_local_port_range
more /etc/sysctl.d/50-oracle.conf | grep rmem_default
more /etc/sysctl.d/50-oracle.conf | grep rmem_max
more /etc/sysctl.d/50-oracle.conf | grep wmem_default
more /etc/sysctl.d/50-oracle.conf | grep wmem_max
more /etc/sysctl.d/50-oracle.conf | grep panic_on
###################################
### Compare mounts allocated sizes to minimum size required
###################################
echo " "
echo " "
echo "        Mounts *Size in GB "
echo " ============================= "
scnt=0
tmpsz=`df -BG /tmp | tail -1 | tr -s ' ' | cut -d' ' -f2 | cut -d'G' -f1`
if [ $tmpsz -lt 1 ]
then
  echo "**/tmp does not meet minimum requirement of 1GB - Size: " $tmpsz
  scnt=$(echo $scnt+1)
fi
homesz=`df -BG /home/dcs2or01 | tail -1 | tr -s ' ' | cut -d' ' -f2 | cut -d'G' -f1`
if [ $homesz -lt 20 ]
then
  echo "**/home/dcs2or01 does not meet minimum requirement of 20GB - Size: " $homesz
  scnt=$(echo $scnt+1)
fi
orasz=`df -BG /app/oracle | tail -1 | tr -s ' ' | cut -d' ' -f2 | cut -d'G' -f1`
if [ $orasz -lt 20 ]
then
  echo "**/app/oracle does not meet minimum requirement of 20GB - Size: " $orasz
  scnt=$(echo $scnt+1)
fi
ora1sz=`df -BG /data/oracle01 | tail -1 | tr -s ' ' | cut -d' ' -f2 | cut -d'G' -f1`
if [ $ora1sz -lt 10 ]
then
  echo "**/data/oracle01 does not meet minimum requirement of 10GB - Size: " $ora1sz
  scnt=$(echo $scnt+1)
fi
ora2sz=`df -BG /data/oracle02 | tail -1 | tr -s ' ' | cut -d' ' -f2 | cut -d'G' -f1`
if [ $ora2sz -lt 5 ]
then
  echo "**/data/oracle02 does not meet minimum requirement of 5GB - Size: " $ora2sz
  scnt=$(echo $scnt+1)
fi
ora3sz=`df -BG /data/oracle03 | tail -1 | tr -s ' ' | cut -d' ' -f2 | cut -d'G' -f1`
if [ $ora3sz -lt 5 ]
then
  echo "**/data/oracle03 does not meet minimum requirement of 5GB - Size: " $ora3sz
  scnt=$(echo $scnt+1)
fi
aud1sz=`df -BG /data/audit01 | tail -1 | tr -s ' ' | cut -d' ' -f2 | cut -d'G' -f1`
if [ $aud1sz -lt 10 ]
then
  echo "**/data/audit01 does not meet minimum requirement of 10GB - Size: " $aud1sz
  scnt=$(echo $scnt+1)
fi
dmp1sz=`df -BG /data/dump01   | tail -1 | tr -s ' ' | cut -d' ' -f2 | cut -d'G' -f1`
if [ $dmp1sz -lt 20 ]
then
  echo "**/data/dump01 does not meet minimum requirement of 20GB - Size: " $dmp1sz
  scnt=$(echo $scnt+1)
fi
oemsz=`df -BG /app/oraoem | tail -1 | tr -s ' ' | cut -d' ' -f2 | cut -d'G' -f1`
if [ $oemsz -lt 10 ]
then
  echo "**/app/oraoem does not meet minimum requirement of 10GB - Size: " $oemsz
  scnt=$(echo $scnt+1)
fi
if [ $scnt -eq 0 ]
then
   echo "*All mounts meet minimum space requirements"
fi  
###################################
### Check size of /dev/shm directory 
###################################
echo " "
echo "   If using database memory_max_target/memory_target parms - /dev/shm must be larger than those value(s)"
echo "/dev/shm size: " `df -BG /dev/shm | tail -1 | tr -s ' ' | cut -d' ' -f2 | cut -d'G' -f1`
#
echo " "
echo " "
echo "         Resouce Limits (dcs2or01)"
echo " ===================================== "
grep dcs2or01 /etc/security/limits.d/50-oracle.conf
###################################
###  Determine if Transparent HugePages or HugePage are enabled/in use
###################################
echo " "
echo " "
echo "        Transparent Huge Pages "
echo " ==================================== "
thpvar=`grep AnonHugePages /proc/meminfo | awk -F ":" '{ print $2 }' | cut -d" " -f10`
if [ $thpvar = 0 ]
then
   echo "Transparent HugePages disabled "
else
   echo "Transparent HugePages enabled - Contact Compute to disable: " $thpvar 
fi
###################################
echo " "
echo " "
echo "        Huge Pages "
echo " ==================================== "
###################################
###  Determine if HugePages in use 
###################################
hpvar=`grep -i HugePages_Total /proc/meminfo | awk -F ':' '{ print $2 }'`
if [ $hpvar -eq 0 ]
then
   echo "HugePages not in use"
else
   echo "HugePages enabled: " $hpvar
fi
###################################
echo " "
echo " "
echo "         Directory ownership "
echo " ========================================"
appown=`ls -ld /app/oracle | awk '{ print $3 }'`
appgrp=`ls -ld /app/oracle | awk '{ print $4 }'`
echo " /app/oracle    owner|group: " $appown"|"$appgrp
dataown=`ls -ld /data/oracle01 | awk '{ print $3 }'`
datagrp=`ls -ld /data/oracle01 | awk '{ print $4 }'`
echo " /data/oracle01 owner|group: " $dataown"|"$datagrp
dataown=`ls -ld /data/oracle02 | awk '{ print $3 }'`
datagrp=`ls -ld /data/oracle02 | awk '{ print $4 }'`
echo " /data/oracle02 owner|group: " $dataown"|"$datagrp
dataown=`ls -ld /data/oracle03 | awk '{ print $3 }'`
datagrp=`ls -ld /data/oracle03 | awk '{ print $4 }'`
echo " /data/oracle03 owner|group: " $dataown"|"$datagrp
dataown=`ls -ld /data/audit01 | awk '{ print $3 }'`
datagrp=`ls -ld /data/audit01 | awk '{ print $4 }'`
echo " /data/audit01  owner|group: " $dataown"|"$datagrp
dataown=`ls -ld /data/dump01 | awk '{ print $3 }'`
datagrp=`ls -ld /data/dump01 | awk '{ print $4 }'`
echo " /data/dump01   owner|group: " $dataown"|"$datagrp
###################################
echo " "
echo " "
echo "        Additional system checks " 
echo " ====================================== "
echo "   Authorization for dcs2or01 account "
grep pam_limit /etc/pam.d/system-auth
###################################
###  List java version
###################################
capver=`ls -ld /etc/alternatives/java | awk -F "->" '{ print $2 }'`
echo "  "
echo "   Java version "
echo "System java version: " $capver
###################################
echo "  "
echo "   Check /etc/pam.d/login file "
cat /etc/pam.d/login
###################################
### script status 
###   send status notification
###################################
echo " "
echo -e "STATUS:SUCCESS\n"
#
mailx -s "Pre system check results on host:  $HOSTNAME" $DBA_MAIL < $FILENAME
###################################
### end of script
