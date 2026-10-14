; ---- 4-bit ripple carry adder from FA_P2Q1 ----
procedure(hrRCA()
  let((cv)
    cv = hrOpenW("RCA4" "schematic" "schematic")
    for(i 0 3
      hrPlace(cv hrLib "FA_P2Q1" sprintf(nil "FA%d" i) (3-i)*5.0 0
        list(list("A" sprintf(nil "A%d" i)) list("B" sprintf(nil "B%d" i))
             list("Cin" sprintf(nil "C%d" i)) list("Cout" sprintf(nil "C%d" i+1))
             list("S" sprintf(nil "S%d" i)) list("vdd" "vdd") list("gnd" "gnd")) nil))
    for(i 0 3
      hrPin(cv sprintf(nil "A%d" i) "input" -3 4-0.5*i)
      hrPin(cv sprintf(nil "B%d" i) "input" -3 1.5-0.5*i))
    hrPin(cv "C0" "input" -3 -1)
    hrPin(cv "vdd" "inputOutput" -3 -2) hrPin(cv "gnd" "inputOutput" -3 -2.5)
    for(i 0 3 hrPin(cv sprintf(nil "S%d" i) "output" 22 4-0.5*i))
    hrPin(cv "C4" "output" 22 1.5)
    hrFinish(cv)
    hrMakeSym("RCA4")))

procedure(hrRCA_tb()
  let((cv nets ins y)
    cv = hrOpenW("RCA4_tb" "schematic" "schematic")
    ins = list("A0" "A1" "A2" "A3" "B0" "B1" "B2" "B3" "C0")
    nets = list(list("vdd" "vdd") list("gnd" "gnd!") list("C4" "C4"))
    foreach(n ins nets = cons(list(n strcat("d" n)) nets))
    for(i 0 3 nets = cons(list(sprintf(nil "S%d" i) sprintf(nil "S%d" i)) nets))
    hrPlace(cv hrLib "RCA4" "DUT" 0 0 nets nil)
    y = 6
    foreach(n ins
      hrPlace(cv hrLib "INV" strcat("DRV" n) -8 y
        list(list("in_a" strcat("src" n)) list("out_a" strcat("d" n)) list("Vdd" "vdd") list("GND" "gnd!")) nil)
      y = y - 1.5)
    y = 6
    foreach(n list("S0" "S1" "S2" "S3" "C4")
      hrPlace(cv hrLib "INV_2X" strcat("LD" n) 10 y
        list(list("in_a" n) list("out_a" strcat(n "_ld")) list("Vdd" "vdd") list("GND" "gnd!")) nil)
      y = y - 1.5)
    hrPlace(cv "analogLib" "vdc" "VDD" -14 6 '(("PLUS" "vdd") ("MINUS" "gnd!")) list(list("vdc" "string" "1")))
    hrFinish(cv)))

; stimulus: slots of 1ns. desired (A,B,C0) = (15,15,1) (14,1,0) (12,3,1) (15,0,0) (15,0,1) (15,0,0)
; sources drive inverting INV_1X drivers, so src bits are inverted
hrStim = strcat(hrWork "/rca_stim.scs")
procedure(hrWriteStim()
  let((p)
    p = outfile(hrStim)
    foreach(s '(("A0" "011000") ("A1" "001000") ("A2" "000000") ("A3" "000000")
                ("B0" "000111") ("B1" "010111") ("B2" "011111") ("B3" "011111") ("C0" "010101"))
      fprintf(p "_v%s (src%s 0) vsource type=bit data=\"%s\" val1=1 val0=0 rise=10p fall=10p period=1n rptstart=1 rpttimes=0\n"
        car(s) car(s) cadr(s)))
    close(p)))

procedure(hrSimRCA(view)
  let((t0 v c r1 r2 c4 s3 c4r c4f s3f s3r)
    hrWriteStim()
    simulator('spectre)
    design(hrLib "RCA4_tb" view)
    resultsDir(strcat(strcat(hrWork "/sim/RCA4_tb_") view))
    modelFile(list(hrModel "mc"))
    stimulusFile(?xlate nil hrStim)
    analysis('tran ?stop "6n" ?errpreset "conservative")
    temp(27)
    save('all)
    run()
    selectResult('tran)
    printf("FUNC slot: A B C0 -> C4 S3 S2 S1 S0 (sampled at 0.9ns into each slot)\n")
    for(k 0 5
      t0 = k*1e-9 + 0.9e-9
      printf("  slot%d t=%.1fns  dA=%d%d%d%d dB=%d%d%d%d dC0=%d -> C4=%d S=%d%d%d%d\n" k t0*1e9
        round(value(VT("/dA3") t0)) round(value(VT("/dA2") t0)) round(value(VT("/dA1") t0)) round(value(VT("/dA0") t0))
        round(value(VT("/dB3") t0)) round(value(VT("/dB2") t0)) round(value(VT("/dB1") t0)) round(value(VT("/dB0") t0))
        round(value(VT("/dC0") t0))
        round(value(VT("/C4") t0))
        round(value(VT("/S3") t0)) round(value(VT("/S2") t0)) round(value(VT("/S1") t0)) round(value(VT("/S0") t0))))
    c = VT("/dC0")
    r1 = cross(clip(c 3.5n 6n) 0.5 1 "rising")
    r2 = cross(clip(c 4.5n 6n) 0.5 1 "falling")
    c4r = cross(clip(VT("/C4") r1 6n) 0.5 1 "rising")
    s3f = cross(clip(VT("/S3") r1 6n) 0.5 1 "falling")
    c4f = cross(clip(VT("/C4") r2 6n) 0.5 1 "falling")
    s3r = cross(clip(VT("/S3") r2 6n) 0.5 1 "rising")
    printf("WORST C0 rise at %.4gns, fall at %.4gns\n" r1*1e9 r2*1e9)
    printf("  C4 tPLH=%.4g ps tPHL=%.4g ps avg=%.4g ps\n" (c4r-r1)*1e12 (c4f-r2)*1e12 ((c4r-r1)+(c4f-r2))*0.5e12)
    printf("  S3 tPHL=%.4g ps tPLH=%.4g ps avg=%.4g ps\n" (s3f-r1)*1e12 (s3r-r2)*1e12 ((s3f-r1)+(s3r-r2))*0.5e12)
    foreach(n '("C1" "C2" "C3")
      errset(printf("  internal %s rises at +%.4g ps\n" n (cross(clip(VT(strcat("/DUT/" n)) r1 6n) 0.5 1 "rising")-r1)*1e12)))))
printf("rca.il loaded\n")
