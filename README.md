# Snowflake-Proxy-Monitoring-Scripts

--- WARNING ---
The provided scripts to monitor and restart the snowflake-proxy are NOT from torproject!
These scripts are created by an single person, trying to manage high CPU and RAM errors, which can result in an crash of the system.

--- DISCLAIMER ---
I do NOT take any responsibility for any errors, resulted by the provided scripts.
If you, the user, want to create any kind of Issue, please keep in mind, that I CAN'T work on this project full time.

--- How to use the provided scripts ---
1. Download the Repo to you're machine, where snowflake-proxy is installed.
2. Change the mentioned strings for folders, where logs will be created.
3. Create those log directories
4. enter crontab -e to set the entries for the scripts - don't worry, it's just the path to the scripts
5. install sysstat - it's needed to monitor the RAM usage via mpstat
6. if you don't already have opened the UDP-Portrange from 32768 to 60999, do this via ufw allow 32768:60999/udp - the snowflake log will then show "NAT type: unrestricted"
7. restart you're server and hope, that everything is running
