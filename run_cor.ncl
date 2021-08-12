load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/run_cor.ncl"
load "/public/home/charlesxiami/nclscript/undef_function/run_cor_pcc.ncl"
;***********************************************
begin
  ;***
  yrstrt =197201
  yrlast =200912

  latS     = -90               
  latN     = 90
  lonL     =   0
  lonR     = 360

  nceppath = "/public/home/charlesxiami/data/ncep/"
  indexpath = "/public/home/charlesxiami/data/index/"
  plotpath = "/public/home/charlesxiami/output/"
  time = ispan(1972, 2009, 1)

  wks  = gsn_open_wks ("pdf",plotpath+"run_cor_combine")
  ;*******************************
  WEU = asciiread(indexpath+"WEU.txt", -1, "float")
  CEU = asciiread(indexpath+"CEU.txt", -1, "float")
  EEU = asciiread(indexpath+"EEU.txt", -1, "float")
  pc1 = asciiread(indexpath+"pc1.txt", -1, "float")
   ao_index = asciiread(indexpath+"monthly.ao.index.b50.current.ascii.txt", -1, "string")
   ao_mon = stringtofloat(str_get_field(ao_index, 3, " "))
   ;printVarSummary(ao_mon)
   ao_djf_all = new((/67/), float)  ; ao_djf: 1950DJF-2016DJF
   ao_mam_all = new((/67/), float)  ; ao_mam: 1950MAM-2016MAM
   do i = 0,66
    ao_djf_all(i) = dim_avg_Wrap(ao_mon(i*12+11:i*12+13))
   end do 
   do i = 0,66
    ao_mam_all(i) = dim_avg_Wrap(ao_mon(i*12+2:i*12+4))
   end do
   printVarSummary(ao_mam_all)
;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    WEU_hf = wgt_runave_Wrap(WEU, wgt, 0)
    CEU_hf = wgt_runave_Wrap(CEU, wgt, 0)
    EEU_hf = wgt_runave_Wrap(EEU, wgt, 0)
    pc1_hf = wgt_runave_Wrap(pc1, wgt, 0)
    ao_djf = wgt_runave_Wrap(ao_djf_all, wgt, 0)
    ao_mam = wgt_runave_Wrap(ao_mam_all, wgt, 0)
;*******************************************
; Running Correlation
;*******************************************
    wSize = 15
    time!0 = "time"
    time@long_name = " "
    time@units = "Year"

    ;run cor
    Wruncor =  run_cor(WEU_hf, pc1_hf(2:39), time, wSize)
    Cruncor =  run_cor(CEU_hf, pc1_hf(2:39), time, wSize)
    Eruncor =  run_cor(EEU_hf, pc1_hf(2:39), time, wSize)
    ;printVarSummary(Wruncor)

    rcordata = new((/2,dimsizes(Wruncor)/), float)
    rcordata(0,:) = Wruncor
    ;rcordata(1,:) = Cruncor
    rcordata(1,:) = Eruncor
    printVarSummary(rcordata)

    ;run cor partial
    Wruncor2 = run_cor_pcc(WEU_hf, pc1_hf(2:39),ao_mam(22:59),time, wSize)
    Cruncor2 = run_cor_pcc(CEU_hf, pc1_hf(2:39),ao_mam(22:59),time, wSize)
    Eruncor2 = run_cor_pcc(EEU_hf, pc1_hf(2:39),ao_mam(22:59),time, wSize)

    rcordata2 = new((/2,dimsizes(Wruncor2)/), float)
    rcordata2(0,:) = Wruncor2
    ;rcordata(1,:) = Cruncor
    rcordata2(1,:) = Eruncor2
    printVarSummary(rcordata2)
;*******************************************
;Lag Correlation 
;*******************************************
    ; mxlag = 6
    ; totlag= 2*mxlag-1
    ; Accr1 = esccr(WEU, pc1_hf(2:39), mxlag)
    ; Accr2 = esccr(pc1_hf(2:39), WEU, mxlag)
    ; Bccr1 = esccr(EEU, pc1_hf(2:39), mxlag)
    ; Bccr2 = esccr(pc1_hf(2:39), EEU, mxlag)

    ; x =ispan(-mxlag+1, mxlag-1, 1)
    
    ; Accrtot = new((/totlag/), float)
    ; Accrtot(0:mxlag-1) = Accr2(0:mxlag-1:-1) 
    ; Accrtot(mxlag:)       = Accr1(1:mxlag-1)

    ; Bccrtot = new((/totlag/), float)
    ; Bccrtot(0:mxlag-1) = Bccr2(0:mxlag-1:-1) 
    ; Bccrtot(mxlag:)       = Bccr1(1:mxlag-1)

    ; Accrtot@long_name = "WEU-PC1_hf Cor"
    ; Bccrtot@long_name = "EEU-PC1_hf Cor"
    ; printVarSummary(Accrtot)
;*******************************************
; Plot
;*******************************************
; resources for "left" variable
   res = True 
   res@gsnDraw = False
   res@gsnFrame =  False
   res@vpHeightF = 0.30        ; Changes the aspect ratio
   res@vpWidthF  = 0.60
   res@vpXF      = 0.20       ; change start locations
   res@vpYF      = 0.40        ; the plot   
   ;res@tiMainString  = "Sliding Correlation"
   ;res@gsnRightString  = "Index - PC_hf "
   ;res@tiYAxisString = " A -"+"[blue]"
   res@xyMarkLineMode = "MarkLines"
   res@gsnLeftStringFontHeightF = 0.015
   ;res@xyLineColors = (/"red","blue"/)
   res@pmLegendDisplayMode = "Always"
   res@pmLegendSide = "Top"
   res@pmLegendParallelPosF = 0.15
   res@pmLegendOrthogonalPosF = -1.05
   res@pmLegendWidthF = 0.10
   res@pmLegendHeightF = 0.06
   res@lgPerimOn = False
   res@lgLabelFontHeightF = 0.010
   res@gsnYRefLineDashPattern = 2
   res@tmYUseLeft = False
   res@tmYRLabelsOn = True
   res@tmYRMode = "Explicit"
   res@gsnYRefLine    = (/-0.514, -0.641/) ;reference line
   res@tmYRValues = (/-0.514, -0.641/)
   res@tmYRLabels = (/"95%","99%"/)
   res@tmYLLabelFontHeightF = 0.010
   ;res@tmYLLabelFontThicknessF = 10.0
   res@tmXBMode = "Manual"
   res@tmXBValues = ispan(1980, 2005, 5)
   res@tmXBLabels = ispan(1980, 2005, 5)
   res@tmXBMinorValues = ispan(min(time)+7, max(time)-7, 1)

   resP = True
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopRight"
   ;resP@pmLabelBarWidthF = 0.5
;****************************************************
;plot 
;****************************************************
   ;Running Correlation
   res@trYMaxF = -0.
   res@trYMinF = -0.9
   res@xyMarkers = (/4,16/)
   res@xyLineThicknesses = (/2.6,2.6,2.6/)
   ;res@xyDashPatterns = (/1, 2, 0/)
   res@xyDashPatterns = (/1, 0/)
   ;res@lgItemOrder = (/2,1,0/)
   res@lgItemOrder = (/1,0/)
   res@gsnLeftString = "(a) Run cor<PC1,snow index>"
   res@xyExplicitLegendLabels = (/" SCAW - PC1", " SCAE - PC1"/)
   slid_cor = gsn_csm_xy(wks, time(7:dimsizes(time)-8), rcordata, res)

   ;**********************************
   ;Running PCC
   res@trYMaxF = -0.
   res@trYMinF = -0.9
   delete(res@xyMarkers)
   delete(res@xyDashPatterns)
   delete(res@xyExplicitLegendLabels)
   delete(res@lgItemOrder)
   res@xyDashPatterns = (/1, 0/)
   res@xyMarkers = (/4,16/)
   res@lgItemOrder = (/1,0/)
   res@xyExplicitLegendLabels = (/" SCAW - PC1"," SCAE - PC1"/)
   res@tiXAxisString = "Year"
   res@tiXAxisFontHeightF = 0.015
   res@gsnLeftString = "(b) Run partial cor(PC1-snow index, AO removed)"
   slid_cor2 = gsn_csm_xy(wks, time(7:dimsizes(time)-8), rcordata2, res)

   runcor = new(2, "graphic")
   runcor(0) = slid_cor
   runcor(1) = slid_cor2
   gsn_panel(wks, runcor, (/2,1/), resP)



end