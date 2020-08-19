command="cron_oracle_pwexp_ldap_eit.sh -d $ORACLE_SID -l /open 1>/dev/null 2>&1"
job="00 05 * * 1-5 $command"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
