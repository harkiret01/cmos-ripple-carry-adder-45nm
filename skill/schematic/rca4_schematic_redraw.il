; redraw RCA4 schematic compactly with explicit carry wires (connectivity unchanged)
procedure(hrStub(cv x y dir net)
  let((x2 y2 w)
    x2 = x  y2 = y
    case(dir ("L" x2 = x - 0.25) ("R" x2 = x + 0.25) ("U" y2 = y + 0.25) ("D" y2 = y - 0.25))
    w = schCreateWire(cv "draw" "full" list(x:y x2:y2) 0.0625 0.0625 0.0)
    schCreateWireLabel(cv car(w) x2:y2 net "lowerCenter" "R0" "stick" 0.1 nil)))
procedure(hrRCA2()
  let((cv x)
    cv = hrOpenW("RCA4" "schematic" "schematic")
    for(i 0 3
      x = 3.0*i
      hrPlace(cv hrLib "FA_P2Q1" sprintf(nil "FA%d" i) x 0
        list(list("A" sprintf(nil "A%d" i)) list("B" sprintf(nil "B%d" i))
             list("Cin" sprintf(nil "C%d" i)) list("Cout" sprintf(nil "C%d" i+1))
             list("S" sprintf(nil "S%d" i)) list("vdd" "vdd") list("gnd" "gnd")) nil)
      schCreateNoteLabel(cv x+0.9:-0.9 sprintf(nil "FA%d (bit %d)" i i) "centerCenter" "R0" "stick" 0.14 "normalLabel")
      when(i < 3
        schCreateWire(cv "draw" "full" list(x+2.0:0 x+2.375:0 x+2.375:-0.25 x+2.75:-0.25) 0.0625 0.0625 0.0)))
    for(i 0 3
      hrPin(cv sprintf(nil "A%d" i) "input" -2.5 2.0-0.375*i)
      hrPin(cv sprintf(nil "B%d" i) "input" -2.5 0.375-0.375*i))
    hrPin(cv "C0" "input" -2.5 -1.5)
    hrPin(cv "vdd" "inputOutput" -2.5 -2.0) hrPin(cv "gnd" "inputOutput" -2.5 -2.375)
    for(i 0 3 hrPin(cv sprintf(nil "S%d" i) "output" 12.5 2.0-0.375*i))
    hrPin(cv "C4" "output" 12.5 0.25)
    schCreateNoteLabel(cv 5.0:-1.6 "Carry chain: C0 -> FA0 -> C1 -> FA1 -> C2 -> FA2 -> C3 -> FA3 -> C4" "centerCenter" "R0" "stick" 0.12 "normalLabel")
    hrFinish(cv)))
hrRCA2()
hrDump("RCA4")
