#!/bin/bash
# Print each violated rule with the first few error edges converted from DBU (2000/um) to um.
f=${HRWORK:-$HOME/hr}/drc/$1/$1.drc_errors.ascii
awk '/^[A-Z][A-Za-z0-9_.]+$/ {rule=$0; getline; if ($1+0>0) {n=$1; print "RULE " rule " n=" n; k=0}; next}
     /^[ep] [0-9]+ [0-9]+$/ && n>0 && k<4 {getline; s=""; for(i=1;i<=NF;i++) s=s sprintf("%.3f ", $i/2000); print "   " s; k++}' $f
