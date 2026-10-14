;; Bind only the DUT instance of a testbench to the Quantus av_extracted view, then simulate.
;; Drivers and loads stay on their schematic views.
procedure(hrMakeExtractedConfig(tb)
  let((cfg)
    cfg = hdbOpen(hrLib tb "config" "w")
    hdbSetTopCellViewName(cfg hrLib tb "schematic")
    hdbSetDefaultViewListString(cfg "spectre schematic veriloga ahdl")
    hdbSetDefaultStopListString(cfg "spectre")
    hdbSetObjBindRule(cfg list(list(hrLib tb "schematic" "DUT")) list('hdbcBindingRule list(nil nil "av_extracted")))
    hdbSave(cfg) hdbClose(cfg)))
;; usage: hrMakeExtractedConfig("FA_P2Q1_tb")  hrSimFA("FA_P2Q1_tb" "config")
