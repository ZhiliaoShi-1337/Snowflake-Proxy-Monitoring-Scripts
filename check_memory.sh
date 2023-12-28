#!/bin/bash

cat /<CHANGE THIS>/memory.log >> /<CHANGE THIS>/memory-logs/$(date -u +%Y-%m-%d)-memory.log
rm /<CHANGE THIS>/memory.log

        while true; do

        check_ram=$(free -h | grep Mem | awk -F " " '{print $4}')
        check_ram_Gi=$(echo $check_ram | grep Gi | sed 's/Gi//')
        check_ram_Mi=$(echo $check_ram | grep Mi | sed 's/Mi//')
        check_ram_Ki=$(echo $check_ram | grep Ki | sed 's/Ki//')

        if [ -z $check_ram_Gi ]; then
                continue
        else
                echo "$(date -u +%Y-%m-%d_%H-%M-%S) Free Ram: $check_ram_Gi GiB" >> /<CHANGE THIS>/memory.log
                sleep 1
        fi

        if [ -z $check_ram_Mi ]; then
                continue
        else
                echo "$(date -u +%Y-%m-%d_%H-%M-%S) Free Ram: $check_ram_Mi MiB" >> /<CHANGE THIS>/memory.log
                check_ram_Mi_amount=$(echo $check_ram_Mi | sed 's/Mi//')
                if [ $check_ram_Mi_amount -lt 20 ]; then
                        echo "$(date -u +%Y-%m-%d_%H-%M-%S) snowflake-proxy terminated due to less RAM ($check_ram_Mi_amount Mi)" >> /<CHANGE THIS>/snowflake-error-logs/$(date -u +%Y-%m-%d)-err.log
                        killall snowflake-proxy
                        mv /<CHANGE THIS>/snowflake.log /<CHANGE THIS>/snowflake-logs/$(date -u +%Y-%m-%d_%H-%M-%S)-snowflake.log
                         /usr/bin/snowflake-proxy > /<CHANGE THIS>/snowflake.log 2>&1 &
                fi
                sleep 1
        fi

        if [ -z $check_ram_Ki ]; then
                continue
        else
                echo "$(date -u +%Y-%m-%d_%H-%M-%S) Free Ram: $check_ram_Ki KiB" /<CHANGE THIS>/memory.log
                check_ram_Ki_amount=$(echo $check_ram_Ki | sed 's/Ki//')
                echo "$(date -u +%Y-%m-%d_%H-%M-%S) snowflake-proxy terminated due to less RAM ($check_ram_Ki_amount Ki)" >> /<CHANGE THIS>/snowflake-error-logs/$(date -u +%Y-%m-%d)-err.log
                killall snowflake-proxy
                mv /<CHANGE THIS>/snowflake.log /<CHANGE THIS>/snowflake-logs/$(date -u +%Y-%m-%d_%H-%M-%S)-snowflake.log
                /usr/bin/snowflake-proxy > /<CHANGE THIS>/snowflake.log 2>&1 &
                sleep 1
        fi

        done
