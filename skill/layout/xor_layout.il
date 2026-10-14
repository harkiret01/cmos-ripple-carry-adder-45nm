;; XOR layout generator (static CMOS, 2 x INV_1X + 8-transistor core)
;; Expects the XOR layout view to already contain the transistor instances
;; PM0 PM6 PM5 PM4 / NM2 NM6 NM5 NM4 and inverter instances I0, I1
;; (e.g. from Layout XL "Generate All From Source"). The script re-places them
;; and draws all routing; it is idempotent (deletes previous shapes first).
let((cv tf)
  cv = dbOpenCellViewByType(hrLib "xor" "layout" nil "a")
  tf = techGetTechFile(cv)
  hrCV = cv  hrTF = tf
  foreach(tm cv~>terminals foreach(p tm~>pins dbDeleteObject(p)))
  foreach(s cv~>shapes dbDeleteObject(s))
  foreach(v cv~>vias dbDeleteObject(v))
  foreach(i setof(x cv~>instances x~>cellName=="cellTmpl") dbDeleteObject(i))
  procedure(xP(n x y o) let((i) i=car(setof(z hrCV~>instances z~>name==n)) i~>orient=o i~>xy=x:y))
  procedure(xR(ly x1 y1 x2 y2) dbCreateRect(hrCV list(ly "drawing") list(x1:y1 x2:y2)))
  procedure(xV(nm x y o) dbCreateVia(hrCV techFindViaDefByName(hrTF nm) x:y o nil))
  procedure(xPin(tn x1 y1 x2 y2) let((f) f=xR("Metal1" x1 y1 x2 y2) dbCreatePin(dbFindTermByName(hrCV tn)~>net f)))
  ;; placement: inverters at both ends, core columns B, SA, SB, A on a 0.6 um pitch
  xP("I0" 0 0 "R0")  xP("I1" 4.74 0 "MY")
  foreach((n x) list("PM0" "PM6" "PM5" "PM4") list(1.4 2.0 2.6 3.2) xP(n x 1.3 "R0"))
  foreach((n x) list("NM2" "NM6" "NM5" "NM4") list(1.4 2.0 2.6 3.2) xP(n x 0.35 "R0"))
  dbCreateParamInstByMasterName(cv "gsclib045_tech" "cellTmpl" "layout" "TMPLX" 0.07:0.07 "R0" 1 list(list("width" "float" 4.6)))
  ;; shared poly gate per column + poly contact, M1 pad, M2 via
  foreach(x list(1.4 2.0 2.6 3.2) xR("Poly" x 0.57 x+0.045 1.2))
  foreach(p list(list(1.425 0.955) list(2.025 1.12) list(2.625 1.12) list(3.225 0.785))
    xV("M1_PO" car(p) cadr(p) "R0") xV("M2_M1" car(p) cadr(p) "R90")
    xR("Metal1" car(p)-0.065 cadr(p)-0.08 car(p)+0.065 cadr(p)+0.08))
  ;; Metal1: supplies, series nodes, output
  foreach(b list(list(1.29 1.3 1.35 1.78) list(3.295 1.3 3.355 1.78) list(1.29 0.07 1.35 0.47) list(1.89 0.07 1.95 0.47)
                 list(1.495 1.48 1.95 1.54) list(2.095 1.3 2.55 1.36) list(2.695 1.48 3.15 1.54) list(2.095 0.41 2.55 0.47)
                 list(2.695 0.35 3.15 0.41) list(2.29 0.57 2.35 1.36) list(2.29 0.57 2.95 0.63) list(2.89 0.35 2.95 0.63)
                 list(4.28 0.755 4.45 0.815) list(4.39 0.755 4.45 0.96) list(1.485 0.3 1.565 0.56) list(3.285 0.3 3.365 0.56))
    apply('xR cons("Metal1" b)))
  ;; Metal2: long horizontal nets A, B, SA, SB, net34
  xV("M2_M1" 1.525 0.41 "R0") xV("M2_M1" 3.325 0.41 "R0") xV("M2_M1" 0.4 0.785 "R90")
  xV("M2_M1" 4.42 0.955 "R0") xV("M2_M1" 1.02 1.12 "R90") xV("M2_M1" 3.72 1.12 "R90")
  foreach(b list(list(1.485 0.37 3.365 0.45) list(0.335 0.745 3.29 0.825) list(1.36 0.915 4.46 0.995)
                 list(0.955 1.08 2.09 1.16) list(2.56 1.08 3.785 1.16))
    apply('xR cons("Metal2" b)))
  ;; pins
  xPin("A" 0.36 0.755 0.42 0.815) xPin("B" 4.39 0.755 4.45 0.815) xPin("out" 2.29 0.9 2.35 0.96)
  xPin("vdd" 2.4 1.75 2.46 1.81) xPin("gnd" 2.4 0.04 2.46 0.1)
  dbSave(cv)
  printf("XOR layout built: shapes=%d vias=%d\n" length(cv~>shapes) length(cv~>vias)))
