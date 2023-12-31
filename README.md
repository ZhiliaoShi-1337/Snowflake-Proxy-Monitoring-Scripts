# WARNING

 ! ! ! THE PROVIDED SCRIPTS ARE STILL AN ALPHA BUILD ! ! !
 ! ! ! Please use Debian 12, installed with english language ! ! !

The provided scripts to monitor and restart the snowflake-proxy are NOT from torproject!

These scripts are created by an single person, trying to manage high CPU and RAM errors, which can result in an crash of the system.

I do NOT take any responsibility for any errors, resulted by the provided scripts.

If you want to create any kind of Issue, please keep in mind, that I CAN'T work on this project full time.


# How to use the provided scripts

1. Download the Repo to you're machine, where snowflake-proxy is or will be installed.

2. if needed, create an user and group for snowflake-proxy

3. run bash deploy.sh

4. if you don't already have opened the UDP-Portrange from 32768 to 60999, do this via ufw allow 32768:60999/udp - the snowflake log will then show "NAT type: unrestricted" in the snowflake.log

5. restart you're server



# How the scripts work

Crontab: 
--------
first off, the initial_snowflake.sh will be run at reboot

by doing so, the last snowflake.log will be saved into the snowflake-logs folder

then snowflake-proxy will be started


the check_snowflake.sh will be executed any 5 minutes, to see, if snowflake-proxy is still running

check_script_memory_script.sh and check_script_cpu_script.sh will be started any minute to check, if the mentioned check_memory.sh and check_cpu.sh scripts are still running


at last, at every reboot the cpu.log and memory.log will be saved into the log directories


check_cpu.sh
------------
this script will check the CPU usage of the entire server

if the value get's over 90%, snowflake-proxy will be restarted and logs will be saved

if you want to increase or decrease this value, feel free to try it out


check_memory.sh
---------------
this script will get values provided by sysstat


check_snowflake.sh
------------------
this script will only see, if snowflake-proxy is still running

in case, that the snowflake-proxy would be terminated through an error or anything else, this script would restart snowflake-proxy and save the snowflake.log into snowflake-logs
