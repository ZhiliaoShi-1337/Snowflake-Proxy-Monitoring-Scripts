while true; do

        cpu_usage=$(mpstat 1 1 | awk '$12 ~ /[0-9.]+/ {print 100 - $12}' | awk -F "." '{print $1}' | sed -n "1p")

        if [ -z $cpu_usage ]; then
                echo "$(date -u +%Y-%m-%d_%H-%M-%S) CPU Usage: $cpu_usage %" >> user_input_logdir/snowflake/cpu.log
        else
                echo "$(date -u +%Y-%m-%d_%H-%M-%S) CPU Usage: $cpu_usage %" >> user_input_logdir/snowflake/cpu.log
                if [ $cpu_usage -gt 90 ]; then
                        echo "$(date -u +%Y-%m-%d_%H-%M-%S) snowflake-proxy terminated due to less CPU ($cpu_usage)" >> user_input_logdir/snowflake/snowflake-error-logs/$(date -u +%Y-%m-%d)-err.log
                        killall snowflake-proxy
                        mv user_input_logdir/snowflake/snowflake.log user_input_logdir/snowflake/snowflake-logs/$(date -u +%Y-%m-%d_%H-%M-%S)-snowflake.log
                        /usr/bin/snowflake-proxy > user_input_logdir/snowflake/snowflake.log 2>&1 &
                fi
        fi

done
