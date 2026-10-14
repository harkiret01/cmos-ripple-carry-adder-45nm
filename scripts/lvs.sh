#!/bin/bash
# Batch Pegasus LVS (with -qrc_data so Quantus can run afterwards) for one cell.
# usage: scripts/lvs.sh FA_P2Q1
c=$1; W=${HRWORK:-$HOME/hr}; REF=${LVS_REF:-$HOME/work_gpdk045/LVS_xor}; WORK=$(dirname $REF)
d=$W/lvs/$c; rm -rf $d; mkdir -p $d
for f in pipo1.setup si.env pegasuslvsctl .technology.rul; do
  sed -e "s#$REF#$d#g" -e "s/\"xor\"/\"$c\"/g" -e "s#/xor\.#/$c.#g" -e "s/\"xor\./\"$c./g" $REF/$f > $d/$f
done
echo "INCLUDE $WORK/cds.lib" > $d/cds.lib
(cd $d && si $d -batch -command netlist > si.log 2>&1; mv -f $d/netlist $d/$c.cdl)
(cd $WORK && strmout -templateFile $d/pipo1.setup > $d/strm.log 2>&1)
cd $d && pegasus -lvs -top_cell $c -log_dir LOGS -source_top_cell $c -spice $d/$c.spi \
  -qrc_data -ui_data -gdb_data -control $d/pegasuslvsctl $d/.technology.rul > peg.log 2>&1
echo "== LVS $c:"; grep -h 'Run Result\|ERC Results\|Extraction' peg.log | head -4
