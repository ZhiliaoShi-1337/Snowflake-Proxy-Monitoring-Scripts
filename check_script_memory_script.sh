#!/bin/bash

checkifrunning=
checkifrunning=$(ps -ef | grep check_memory.sh | grep -v "grep" | wc -l)

if [[ $checkifrunning -gt 0 ]]; then
        exit
else
        /bin/bash current_dir/check_memory.sh&
fi
