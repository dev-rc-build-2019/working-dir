I. Pre-requiste
/<path>/pre_system_check_19.sh > /tmp/precheck.log

II.  Install and Configure
1. Run under the <oracle_owner> account
/<path>/man1_prov_all.sh <instance_name> <char_set> <dba ntid> <ntid email>

2. Run under an account with root access:
sudo /<path>/run_rooth.sudo

3. Run under <oracle_owner> account:
/<path>/man2_prov_all.sh <instance_name> <char_set> <dba ntid> <ntid email>

4. Run under account with root access:
sudo /<path>/chg_oratab.sh

***** Install and Build Complete

5. (Optional)  Add second dba permissions
/<path>/add_second_dba.sh <char set> <app dba ntid> <email addr>