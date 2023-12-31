#!/bin/bash

check_sysstat=""
check_psmisc=""
recheck_sysstat=""
user_input_logdir=""
user_input_logdir_choice=""
user_input_choice_update=""
user_input_extra_logs_choice=""
user_input_choice_logrotation=""
logrotation=
check_snowflake_proxy_binary=""
choise_user_group=""
user_snowflake_proxy=""
group_snowflake_proxy=""
current_dir=$(pwd)

if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit
else
        echo "### sysstat ###"
        echo "checking for sysstat package ..."
        check_sysstat=$(dpkg -l | grep sysstat | grep -v rc)
        if [[ -z $check_sysstat ]]; then
                echo "installing sysstat ..."
                apt install sysstat -y 1>/dev/null 2>&1
                echo "recheck for sysstat package ..."
                recheck_sysstat=$(dpkg -l | grep sysstat | grep -v rc)
                if [[ -z $recheck_sysstat ]]; then
                        echo "[ERROR] could not install sysstat - please check internet connectivity"
                        exit
                else
                        echo "[OK] sysstat installed"
                fi
        else
                echo "[OK] sysstat already installed"
        fi

        echo "### psmisc ###"
        echo "checking for psmisc package ..."
        check_psmisc=$(ps -ef | grep psmisc | grep -v rc)
        if [[ -z $check_psmisc ]]; then
                echo "installing psmisc ..."
                apt install psmisc -y 1>/dev/null 2>&1
                echo "recheck for psmisc package ..."
                recheck_sysstat=$(dpkg -l | grep psmisc | grep -v rc)
                if [[ -z $recheck_sysstat ]]; then
                        echo "[ERROR] could not install psmisc - please check internet connectivity"
                        exit
                else
                        echo "[OK] psmisc installed"
                fi
        else
                echo "[OK] psmisc already installed"
        fi

        echo "### log directory ###"
        echo "(1) /var/log"
        echo "(2) Input log directory"
        read -p "Please enter the log directory for snowflake logs (1)(2): " user_input_logdir_choice
        case $user_input_logdir_choice in
                1)
                        user_input_logdir="/var/log"
                ;;
                2)
                        read -p "please enter the log directory: " user_input_logdir
                ;;
                *)
                        echo "[ERROR] Invalid Input"
                        exit
                ;;
        esac

        echo "### replace user_input_logdir in shell scripts ###"
        sed -i "s@user_input_logdir@$user_input_logdir@g" ./check_cpu.sh
        sed -i "s@user_input_logdir@$user_input_logdir@g" ./check_memory.sh
        sed -i "s@user_input_logdir@$user_input_logdir@g" ./check_snowflake.sh
        sed -i "s@user_input_logdir@$user_input_logdir@g" ./initial_snowflake.sh
        sed -i "s@current_dir@$current_dir@g" ./check_script_cpu_script.sh
        sed -i "s@current_dir@$current_dir@g" ./check_script_memory_script.sh

        echo "### ask for automated updates via crontab ###" # automated restart any day at 3am
        read -p "Do you want to have automated updates and an restart at 3pm every day? (Y|N): " user_input_choice_update
        case $user_input_choice_update in
                Y)
                        echo "# Update System - this would restart the server at any day at 3 am" >> ./crontab
                        echo "0 3 * * *       apt update -y && apt full-upgrade -y && apt dist-upgrade -y && apt autoclean -y && apt autoremove -y && /sbin/init 6" >> ./crontab
                        echo "" >> ./crontab
                        echo "automated updates enabled"
                ;;
                N)
                        echo "automated updates stay disabled"
                ;;
                *)
                        echo "[ERROR] Invalid Input"
                        exit
                ;;
        esac

        echo "### create log directories ###"
        read -p "Do you want to have CPU and RAM logs? (Y|N): " user_input_extra_logs_choice
        case $user_input_extra_logs_choice in
                Y)
                        create_cpu_log_dir=$(mkdir -p "$user_input_logdir/snowflake/cpu-logs")
                        create_memory_log_dir=$(mkdir -p "$user_input_logdir/snowflake/memory-logs")
                        create_snowflake_log_dir=$(mkdir -p "$user_input_logdir/snowflake/snowflake-logs")
                        create_snowflake_erro_log_dir=$(mkdir -p "$user_input_logdir/snowflake/snowflake-error-logs")
                        echo "[OK] log directories created"
                        echo "# snowflake initial script" >> ./crontab
                        echo "@reboot         /bin/bash $current_dir/initial_snowflake.sh&" >> ./crontab
                        echo "" >> ./crontab
                        echo "# snowflake check script" >> ./crontab
                        echo "*/5 * * * *     /bin/bash $current_dir/check_snowflake.sh&" >> ./crontab
                        echo "" >> ./crontab
                        echo "# memory check script" >> ./crontab
                        echo "*/1 * * * *     /bin/bash $current_dir/check_script_memory_script.sh" >> ./crontab
                        echo "" >> ./crontab
                        echo "# cpu check script" >> ./crontab
                        echo "*/1 * * * *     /bin/bash $current_dir/check_script_cpu_script.sh" >> ./crontab
                        echo "" >> ./crontab
                ;;
                N)
                        create_snowflake_log_dir=$(mkdir -p "$user_input_logdir/snowflake/snowflake-logs")
                        create_snowflake_erro_log_dir=$(mkdir -p "$user_input_logdir/snowflake/snowflake-error-logs")
                        echo "[OK] log directories created"
                        echo "# snowflake initial script" >> ./crontab
                        echo "@reboot         /bin/bash $current_dir/initial_snowflake.sh&" >> ./crontab
                        echo "" >> ./crontab
                        echo "# snowflake check script" >> ./crontab
                        echo "*/5 * * * *     /bin/bash $current_dir/check_snowflake.sh&" >> ./crontab
                        echo "" >> ./crontab
                ;;
                *)
                        echo "[ERROR] Invalid Input"
                        exit
                ;;
        esac

        echo "### get user input for log rotation ###"
        read -p "Do you want to use the the default log rotation with 30 days? (Y|N): " user_input_choice_logrotation
        case $user_input_choice_logrotation in
                Y)
                        logrotation=30
                        echo "log rotation stay at 30 days"
                ;;
                N)
                        read -p "Please enter an integer for the logrotation: " logrotation
                        echo "changed log rotation to: $logrotation days"
                ;;
                *)
                        echo "[ERROR] Invalid Input"
                        exit
                ;;
        esac

        echo "### check for snowflake-proxy binary ###"
        check_snowflake_proxy_binary=$(which snowflake-proxy)
        if [[ -z $check_snowflake_proxy_binary ]]; then
                echo "snowflake-proxy not found, trying to install via apt ..."
                apt install snowflake-proxy -y 1>/dev/null 2>&1
                if [[ $? -ne 0 ]]; then
                        echo "[ERROR] could not install snowflake-proxy via apt ..."
                        exit
                else
                        echo "[OK] snowflake-proxy installed"
                        systemctl disable snowflake-proxy.service
                        systemctl stop snowflake-proxy.service
                fi
        else
                snowflake_proxy_binary=$check_snowflake_proxy_binary
                echo "snowflake-proxy binary stays at $snowflake_proxy_binary"
        fi

        echo "### insert lines into crontab ###"
        if [[ $user_input_extra_logs_choice == "Y" ]]; then
                echo "# delete old cpu logs at first day of the month - default is set to $logrotation days" >> ./crontab
                echo "0 0 1 * *       find $user_input_logdir/snowflake/cpu-logs/ -type f -mtime +$logrotation -exec rm -f {} \;" >> ./crontab
                echo "" >> ./crontab
                echo "# delete old memory logs at first day of the month - default is set to $logrotation days" >> ./crontab
                echo "0 0 1 * *       find $user_input_logdir/snowflake/memory-logs/ -type f -mtime +$logrotation -exec rm -f {} \;" >> ./crontab
                echo "" >> ./crontab
                echo "# delete old snowflake error logs at first day of the month - default is set to $logrotation days" >> ./crontab
                echo "0 0 1 * *       find $user_input_logdir/snowflake/snowflake-logs/ -type f -mtime +$logrotation -exec rm -f {} \;" >> ./crontab
                echo "" >> ./crontab
                echo "# delete old snowflake logs at first day of the month - default is set to $logrotation days" >> ./crontab
                echo "0 0 1 * *       find $user_input_logdir/snowflake/snowflake-error-logs/ -type f -mtime +$logrotation -exec rm -f {} \;" >> ./crontab
                echo "" >> ./crontab
        else
                echo "# delete old snowflake error logs at first day of the month - default is set to $logrotation days" >> ./crontab
                echo "0 0 1 * *       find $user_input_logdir/snowflake/snowflake-logs/ -type f -mtime +$logrotation -exec rm -f {} \;" >> ./crontab
                echo "" >> ./crontab
                echo "# delete old snowflake logs at first day of the month - default is set to $logrotation days" >> ./crontab
                echo "0 0 1 * *       find $user_input_logdir/snowflake/snowflake-error-logs/ -type f -mtime +$logrotation -exec rm -f {} \;" >> ./crontab
                echo "" >> ./crontab
        fi

        echo "insert crontab file into crontab -e ..."
                cat ./crontab | crontab -
                if [[ $? -eq 0 ]]; then
                        echo "[OK] crontab inserted into crontab -e"
                else
                        echo "[ERROR] something went wrong, please remove entries in crontab -e, remove crontab file and re-run script"
                        exit
                fi

        echo "### user and group permissions for scripts and log directories"
        read -p "Do you want to use snowflake-proxy with dedicated user and group? (Y|N): " choise_user_group
        case $choise_user_group in
                Y)
                        read -p "please provide the user for snowflake-proxy: " user_snowflake_proxy
                        read -p "please provide the group for snowflake-proxy: " group_snowflake_proxy
                        chown $user_snowflake_proxy:$group_snowflake_proxy ./*.sh
                        chown $user_snowflake_proxy:$group_snowflake_proxy ./
                        chmod 750 ./*.sh
                        if [[ $user_input_extra_logs_choice == "Y" ]]; then
                                chmod 640 "$user_input_logdir/snowflake/cpu-logs"
                                chmod 640 "$user_input_logdir/snowflake/memory-logs"
                                chmod 640 "$user_input_logdir/snowflake/snowflake-logs"
                                chmod 640 "$user_input_logdir/snowflake/snowflake-error-logs"
                        else
                                chmod 640 "$user_input_logdir/snowflake/snowflake-logs"
                                chmod 640 "$user_input_logdir/snowflake/snowflake-error-logs"
                        fi
                ;;
                N)
                        chmod 750 ./*.sh
                        if [[ $user_input_extra_logs_choice == "Y" ]]; then
                                chmod 640 "$user_input_logdir/snowflake/cpu-logs"
                                chmod 640 "$user_input_logdir/snowflake/memory-logs"
                                chmod 640 "$user_input_logdir/snowflake/snowflake-logs"
                                chmod 640 "$user_input_logdir/snowflake/snowflake-error-logs"
                        else
                                chmod 640 "$user_input_logdir/snowflake/snowflake-logs"
                                chmod 640 "$user_input_logdir/snowflake/snowflake-error-logs"
                        fi
                ;;
                *)
                        echo "[ERROR] Invalid Input"
                        exit
                ;;
        esac

        echo "### remove crontab file ###"
        rm -f ./crontab
fi
