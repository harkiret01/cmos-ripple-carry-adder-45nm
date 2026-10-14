#!/bin/bash
# Batch Pegasus DRC for one cell. Reuses the stream-out template and control file that the
# Pegasus GUI wrote into a reference run directory ($REF), retargeted to cell $1.
# usage: scripts/drc.sh FA_P2Q1
c=$1; W=${HRWORK:-$HOME/hr}; REF=${DRC_REF:-$HOME/work_gpdk045/DRC}
d=$W/drc/$c; rm -rf $d; mkdir -p $d
sed -e "s/\"xor\"/\"$c\"/" -e "s#$REF/xor#$d/$c#g" -e "s#$REF#$d#g" $REF/pipo1.setup > $d/pipo.setup
(cd $(dirname $REF) && strmout -templateFile $d/pipo.setup > $d/strm.log 2>&1)
sed -e "s#$REF/xor#$d/$c#g" -e "s/\"xor.sum\"/\"$c.sum\"/" $REF/pegasusdrcctl > $d/ctl
cp $REF/.technology.rul $d/tech.rul
cd $d && pegasus --log_dir LOGS -top_cell $c --control $d/ctl $d/tech.rul > peg.log 2>&1
echo "== DRC $c: $(grep -h 'Total DRC Results' peg.log)"
