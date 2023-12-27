#!/bin/bash

sleep 30

snowflake_count=$(ps -ef | grep snowflake | grep -v 'grep' | grep -v 'initial_snowflake' | grep -v 'check_memory' | grep -v 'sleep' | wc -l)

if [[ $snowflake_count -lt 1 ]]; then
        mv /<CHANGE THIS>/snowflake.log /<CHANGE THIS>/snowflake-logs/$(date -u +%Y-%m-%d_%H-%M-%S)-snowflake.log
        /usr/bin/snowflake-proxy > /<CHANGE THIS>/snowflake.log 2>&1 &
fi
