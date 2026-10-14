#!/bin/bash
# Quantus RC extraction to an av_extracted view, after scripts/lvs.sh has run for the cell.
# Reuses a Quantus command file written by the GUI for another cell ($QRC_REF).
# usage: scripts/qrc.sh FA_P2Q1
c=$1; W=${HRWORK:-$HOME/hr}; d=$W/lvs/$c
QRC_REF=${QRC_REF:-$HOME/work_gpdk045/LVS/svdb/qrc.NAND_1X.ccl}; REFDIR=$(dirname $(dirname $QRC_REF))
sed -e "s/NAND_1X/$c/g" -e "s#$REFDIR\"#$d\"#g" -e "s#$REFDIR/svdb#$d/svdb#g" $QRC_REF > $d/qrc.$c.ccl
cd $d && qrc -cmd $d/qrc.$c.ccl > $d/qrc.out 2>&1
echo "== QRC $c exit=$?"; grep -i 'error\|completed' $d/qrc.out | tail -3
