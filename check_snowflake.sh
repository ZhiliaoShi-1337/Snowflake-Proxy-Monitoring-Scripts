#!/bin/bash

snowflake_count=$(ps -ef | grep snowflake | grep -v 'grep' | grep -v 'check_snowflake' | grep -v 'check_cpu' | grep -v 'check_script_cpu_script' | grep -v 'check_memory' | grep -v 'check_script_memory_script.sh' | grep -v 'sleep' | wc -l)
if [[ $snowflake_count -lt 1 ]]; then
        mv user_input_logdir/snowflake/snowflake.log user_input_logdir/snowflake/snowflake-logs/$(date -u +%Y-%m-%d_%H-%M-%S)-snowflake.log
        echo "$(date -u +%Y-%m-%d_%H-%M-%S) No snowflake-proxy found, restarting snowflake-proxy" >> user_input_logdir/snowflake/snowflake-error-logs/$(date -u +%Y-%m-%d)-err.log
        killall snowflake-proxy
        /usr/bin/snowflake-proxy > user_input_logdir/snowflake/snowflake.log 2>&1 &
fi
