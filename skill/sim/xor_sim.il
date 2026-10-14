procedure(hrSimXOR()
  let((p a b o res wr wf)
    p = outfile(strcat(hrWork "/xor_stim.scs"))
    fprintf(p "_vvdd (vdd 0) vsource dc=1 type=dc\n_vgnd (gnd 0) vsource dc=0 type=dc\n")
    fprintf(p "_vA (A 0) vsource type=bit data=\"001101100\" val1=1 val0=0 rise=10p fall=10p period=1n rptstart=1 rpttimes=0\n")
    fprintf(p "_vB (B 0) vsource type=bit data=\"011000110\" val1=1 val0=0 rise=10p fall=10p period=1n rptstart=1 rpttimes=0\n")
    close(p)
    simulator('spectre)
    design(hrLib "xor_tb" "schematic")
    resultsDir(strcat(hrWork "/sim/xor_tb"))
    modelFile(list(hrModel "mc"))
    stimulusFile(?xlate nil strcat(hrWork "/xor_stim.scs"))
    analysis('tran ?stop "9.5n" ?errpreset "conservative")
    temp(27) save('all) run()
    selectResult('tran)
    a = VT("/dut_in_a") b = VT("/dut_in_b") o = VT("/dut_out")
    hrXorEdges = nil
    for(k 1 8
      let((t0 tin tout sig e oe)
        t0 = k*1e-9
        foreach(s list(list("A" a) list("B" b))
          foreach(e '("rising" "falling")
            tin = cross(clip(cadr(s) t0 t0+0.5n) 0.5 1 e)
            when(tin
              sig = car(s)
              foreach(oe '("rising" "falling")
                tout = cross(clip(o tin t0+0.9n) 0.5 1 oe)
                when(tout
                  printf("XOR edge %d: %s %s at %.4gns (A=%d B=%d after) -> out %s delay %.4g ps\n" k sig e tin*1e9
                    round(value(a t0+0.9n)) round(value(b t0+0.9n)) oe (tout-tin)*1e12)
                  hrXorEdges = cons(list(k sig e oe tin tout) hrXorEdges))))))))
    t))
printf("xorsim loaded\n")
