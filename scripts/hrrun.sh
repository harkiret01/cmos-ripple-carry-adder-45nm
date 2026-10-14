#!/bin/bash
# Send SKILL from stdin to a Virtuoso session running skill/util/command_poller.il and print its output.
# usage:  echo 'printf("hi\n")' | scripts/hrrun.sh
W=${HRWORK:-$HOME/hr}
rm -f $W/done; cat > $W/cmd.tmp; mv $W/cmd.tmp $W/cmd.il
while [ -f $W/cmd.il ] || [ ! -f $W/done ]; do sleep 0.3; done
cat $W/out.txt
