#!/bin/bash

checkcpurunning=
checkcpurunning=$(ps -ef | grep check_cpu.sh | grep -v "grep" | wc -l)

if [[ $checkcpurunning -gt 0 ]]; then
        exit
else
        /bin/bash /<CHANGE THIS>/check_cpu.sh&
fi
