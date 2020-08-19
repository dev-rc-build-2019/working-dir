REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
REM * NAME: baseline_Oracle12c_Linux_hardening_Check-1.sql            *
REM * DESC: This is one of several scripts designed to query          *
REM *         Oracle 12c settings and security controls.              *
REM *                                                                 *
REM * DATE       AUTHOR/Modification                                  *
REM * 11/11/2019 Renee Cutler,     System Engineer                    *
REM * 05/13/2016 Melvin Rodriguez, LM CIS-PSE                         *
REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
set pagesize 80
set head off
col profile format a30
col resource_name format a35
col limit format a10
spool $HOME/Oracle12c_Provisioning_Quality_Check.txt

REM     Provisioned Character Set	
PROMPT "Character Set Applied"
SELECT *
FROM nls_database_parameters
WHERE parameter like '%CHARACTERSET';

REM     Provisioned Memory Allocations
PROMPT "Memory Allocations "
show parameter memory_max_target;
show parameter memory_target;
show parameter sga_max_size;
show parameter sga_target;
show parameter pga_aggregate_target;
show parameter use_large_pages;

REM    Provisioned Local Listener
PROMPT 
PROMPT "Local Listener Value "
show parameter local_listener;

REM    Provisioned Recovery Area Space
---PROMPT 
---PROMPT "Flash Recovery Size (Should be size of /data/flashX1 minus 5G) "
---show parameter db_recovery_file_dest_size;

REM    Provisioned Recovery Area Space
PROMPT
PROMPT "Audit File Parameters "
show parameter audit_file_dest
show parameter audit_sys_operations
show parameter audit_trail

REM    Provisioned Recovery Area Space
PROMPT
PROMPT "APPDBA and FSDBA Roles Generated "
select role
from dba_roles
where role in ('APPDBA', 'FSDBA_ROLE');

spool off;

REM Command to label the output and result of the script query command
REM Patch_Version Query

host echo " " >> $HOME/Oracle12c_Provisioning_Quality_Check.txt
host echo "Patch Version" >> $HOME/Oracle12c_Provisioning_Quality_Check.txt
host $ORACLE_HOME/OPatch/opatch lsinventory|grep "Patch description" >> $HOME/Oracle12c_Provisioning_Quality_Check.txt
host echo " " >> $HOME/Oracle12c_Provisioning_Quality_Check.txt


