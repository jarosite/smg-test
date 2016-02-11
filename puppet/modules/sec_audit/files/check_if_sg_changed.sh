#!/bin/bash
PIPE_IN=`cat`
BASE_DIR=$(dirname "$0")/..
CURRENT_REPORT=$BASE_DIR/data/sg_report_current.txt
echo "$PIPE_IN" > $CURRENT_REPORT
PREVIOS_REPORT=$BASE_DIR/data/sg_report.txt
LOG_FILE=$BASE_DIR/log/sg_compare.log
#set -x
function logger() {
	echo "$1" | while read a; do echo "[$(date)] $a"; done
}
{
	if [ ! -f $PREVIOS_REPORT ]; then
		logger "previos report $PREVIOS_REPORT does not exist, nothing to compare, exit(1) now"
		mv $CURRENT_REPORT $PREVIOS_REPORT
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