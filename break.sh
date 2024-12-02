#!/bin/bash

floor () {
  DIVIDEND=${1}
  DIVISOR=${2}
  RESULT=$(( ( ${DIVIDEND} - ( ${DIVIDEND} % ${DIVISOR}) )/${DIVISOR} ))
  echo ${RESULT}
}

timecount(){
    # modified from https://serverfault.com/a/532600

    HOUR=$( floor ${1} 60/60 )
    s=$((${1}-(60*60*${HOUR})))
    MIN=$( floor ${s} 60 )
    SEC=$((${s}-60*${MIN}))
    while [ $HOUR -ge 0 ]; do
        while [ $MIN -ge 0 ]; do
            while [ $SEC -ge 0 ]; do
                printf "next break in... %02dh %02dm %02ds \033[0K\r" $HOUR $MIN $SEC
                SEC=$((SEC-1))
                sleep 1
            done
            SEC=59
            MIN=$((MIN-1))
        done
        MIN=59
        HOUR=$((HOUR-1))
    done
}

runWithDelay () {
    # modified from https://unix.stackexchange.com/a/102959

    timeInMinutes=$1

    if [[ $timeInMinutes -eq -1 ]]; then
        echo "please provide time (in minutes) until next break"
        exit 1
    fi

    secs=$(($timeInMinutes * 60));
    timecount $secs;

    time=$(date +"%T");

    echo;
    echo "locking screen now ($time)...";
    shift;
    eval "$@";
}

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    osCmd="pmset displaysleepnow";
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    osCmd="rundll32.exe powrprof.dll, SetSuspendState Sleep";
else
    # Other OS (e.g., Linux)
    echo "This is neither macOS nor Windows";
    exit 1;
fi

runWithDelay ${1:--1} "$osCmd";
