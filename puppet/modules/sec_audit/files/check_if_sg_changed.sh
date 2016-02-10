#!/bin/bash
PIPE_IN=`cat`
CURRENT_REPORT=./sg_report_current.txt
echo "$PIPE_IN" > $CURRENT_REPORT
PREVIOS_REPORT=./sg_report.txt
LOG_FILE=./sg_compare.log
#set -x
function logger() {
	echo "$1" | while read a; do echo "[$(date)] $a"; done
}
{
	if [ ! -f $PREVIOS_REPORT ]; then
		logger "previos report $PREVIOS_REPORT does not exist, nothing to compare, exit(1) now"
		exit 1
	fi

	if [ ! -f $CURRENT_REPORT ]; then
		logger "current report $CURRENT_REPORT does not exist, nothing to compare, exit(1) now"
		exit 1
	fi

	DIFF=`diff $PREVIOS_REPORT $CURRENT_REPORT`
	if [ $? -eq 0 ]; then
		logger "nothing changed since last run"
	else 
		logger "changes since last run:"
		logger "$DIFF"
	fi
	mv $CURRENT_REPORT $PREVIOS_REPORT
	exit 0
} | tee -a "$LOG_FILE"