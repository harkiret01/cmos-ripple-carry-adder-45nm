;; Lets a running Virtuoso execute SKILL files dropped into hrWork/cmd.il, writing output to hrWork/out.txt.
;; Pair with scripts/hrrun.sh. Useful for driving Virtuoso from a terminal without clicking.
procedure(hrPoll()
  let((p oldp olde)
    when(isFile(strcat(hrWork "/cmd.il"))
      sh(sprintf(nil "mv %s/cmd.il %s/run.il; rm -f %s/done" hrWork hrWork hrWork))
      p = outfile(strcat(hrWork "/out.txt"))
      oldp = poport olde = errport poport = p errport = p
      unless(errset(load(strcat(hrWork "/run.il")) t) fprintf(p "\n*** LOAD ERROR\n"))
      poport = oldp errport = olde close(p)
      sh(sprintf(nil "touch %s/done" hrWork)))
    hiRegTimer("hrPoll()" 5)))
hiRegTimer("hrPoll()" 5)
