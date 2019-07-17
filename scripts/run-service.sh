#!/bin/bash

SLEEP=2
PYTHON=python3

while true; do
	${PYTHON} manage.py ${@}
	echo "Exit from django management task: ${PYTHON} manage.py ${@}."
	echo "Restarting in ${SLEEP} seconds..."
	sleep ${SLEEP}
done
