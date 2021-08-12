 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

;***
  begin
;***
   yrstrt =196701
   yrlast =201412

   yrstrt_snow = 196701
   yrlast_snow = 201412

   t = ispan(yrstrt_snow/100, yrlast_snow/100, 1)

   latS     = 30.
   latN     = 70.
   lonL     = 60.
   lonR     = 140.

  SCI_EEU_N = 70
  SCI_EEU_S = 40
  SCI_EEU_L = 80
  SCI_EEU_R = 140
;**********************************************
;Calcute Snow Cover Index
;**********************************************
   datapath = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"
   snowpath = "/public/home/charlesxiami/data/snow/"
   indexpath = "/public/home/charlesxiami/data/index/"
;************************************************
;Setting Plot
;************************************************
   wks=gsn_open_wks("pdf", plotpath+"eof_snow")
   gsn_define_colormap(wks, "ViBlGrWhYeOrRe")
;***************************************
   snowdata = addfile(snowpath+"snow.rutger.2.0deg.nc","r")

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))
;********************************************
  snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
  snow_mam = month_to_season(snow_mon, "MAM")

  snow_mam = SqrtCosWeight(snow_mam)
  x = snow_mam(:,{latS:latN},{lonL:lonR})
  ; x = dtrend_n(x, False, 0)
  printVarSummary(x)

  EEU = snow_mam(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
  sci_eeu = -1*dim_standardize_Wrap(wgt_areaave_Wrap(EEU, 1.0, 1.0, 1),0)
 ;************************************************
 ;EOF 
 ;************************************************
   neof = 3
   optEOF = True
   optEOF@jopt = 0
   optETS = False
   eof    = eofunc_n_Wrap(x,neof,optEOF,0)
   eof_ts = eofunc_ts_n_Wrap(x,eof,optETS,0)
   eof_ts = dim_standardize_Wrap(eof_ts, 0)
   printVarSummary(eof)
   ; do i = 0, 2
   ; asciiwrite(indexpath+"pc"+(i+1)+"_1948-2017.txt", -1*eof_ts(i,:))
   ; end do
  ;*******************************************
  ; North significance test: Note any of the following could be used
  ;*******************************************
   dimp   = dimsizes(snow_mam)
   ntim   = dimp(0)

   prinfo = True
   ; sig_ev  = eofunc_north(eof@eval, ntim, prinfo)

   sig_pcv = eofunc_north(eof@pcvar, ntim, prinfo)
   ; sig_evt = eofunc_north(eof@eval_transpose, ntim, prinfo)
   ;print(eof_ts)
;********************************************
; Filter 
;********************************************
   ;high frequence component 
    ihp = 1
    fca = 1.0/10.0
    fcb= -999.
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    pc1_hf = wgt_runave_Wrap(eof_ts(0,:), wgt, 0)
    sci_eeu_hf = wgt_runave_Wrap(sci_eeu, wgt, 0)
    ;air_mam = wgt_runave_n_Wrap(air_mam, wgt, 0, 0)
    ;slp_mam = wgt_runave_n_Wrap(slp_mam, wgt, 0, 0)
    ;snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
    ;sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)

   ;low frequency
    ihp = 0  
    wgt2 = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    pc1_lf = wgt_runave_Wrap(eof_ts(0,:), wgt2, 0)

  print("percentage var= "+ dim_variance(pc1_hf)/dim_variance(eof_ts(0,:)))
  print("pc1-sci_avg=" +escorc(eof_ts(0,:), sci_eeu))
  print("pc1-sci_avg hf=" +escorc(pc1_hf, sci_eeu_hf))

;********************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   res@cnFillOn = True
   res@cnLinesOn = False
   res@lbLabelBarOn = False
   res@gsnAddCyclic = False
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF = -0.08
   res@cnMaxLevelValF = 0.08
   res@cnLevelSpacingF = 0.01
   res@mpFillOn             = False        ; turn off map fill
   res@mpMinLatF            = latS         ; zoom in on map
   res@mpMaxLatF            = latN
   res@mpMinLonF            = lonL
   res@mpMaxLonF            = lonR

   resP                 = True                 ; panel resources
   resP@txString        = "SCE MAM:"+ t(0)+"-"+t(dimsizes(t)-1) ; add center string
   resP@gsnPanelLabelBar    = True            ; add common colorbar
   resP@lbLabelAutoStride   = True
   resP@gsnMaximize         = False
   ;resP@gsnPanelDebug = True 

   plot = new(neof, "graphic")
  do n = 0, neof-1
    res@gsnLeftString  = "EOF "+(n+1)
    res@gsnRightString = sprintf("%5.1f", eof@pcvar(n))+"%"
    plot(n) = gsn_csm_contour_map(wks, eof(n,:,:), res)
  end do
  gsn_panel(wks,plot,(/neof,1/),resP)

;********************************************
;Time Series plot
;********************************************
  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               
  rts@vpHeightF = 0.30        ; Changes the aspect ratio
  rts@vpWidthF  = 0.80
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot 
  rts@tiYAxisString = ""                    ; y-axis label
  rts@gsnLeftStringFontHeightF = 0.015
  rts@gsnYRefLine = 0.
  rts@tmYLLabelFontHeightF = 0.015

  rts1 = rts  ; Bar Chart
  rts1@gsnXYBarChart         = True                  ; reference line
  rts1@gsnAboveYRefLineColor = "red"           
  rts1@gsnBelowYRefLineColor = "blue"   
  rts1@gsnLeftString = "(b)"
  ;rts1@tmXUseBottom = True
  rts1@tmXBMode = "Explicit"
  ; rts1@tmXBValues = ispan(1975, 2005, 5)
  ; rts1@tmXBLabels = ispan(1975, 2005, 5)
  ; rts1@tmXBMinorValues = ispan(1972, 2009, 1)
  rts1@tmXTOn = False
  rts1@tmYROn = False
  rts1@tiXAxisString = "Time (Year)"
  rts1@tiYAxisString = " "
  rts1@tiXAxisFontHeightF = 0.020
  rts1@tiYAxisFontHeightF = 0.020
  ; rts1@trXMinF = 1971.5
  ; rts1@trXMaxF = 2009.5
  rts1@gsnXYBarChartBarWidth = 0.3
  rts1@trYMaxF = 3.0
  rts1@trYMinF = -3.0

  rts2 = rts   ; Line 
  rts2@xyDashPattern         = 1
  rts2@xyLineThicknessF      = 4.
  rts2@xyLineColor = "black"

   rts@gsnYRefLine           = 0.              ; reference line   
   rts@gsnXYBarChart         = True            ; create bar chart 
   rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
   rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

    rtsP                     = True             ; modify the panel plot
    rtsP@gsnMaximize         = False             ; large format

  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,t,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)        
     
     ;pc1_run_avg = runave_n_Wrap(eof_ts(0,:), 11, 0, 0)
  rts1@vpHeightF = 0.2        ; Changes the aspect ratio
  rts1@vpWidthF  = 0.80
  ; rts1@vpXF      = 0.20        ; change start locations
  ; rts1@vpYF      = 0.60        ; the plot 
  rts1@tmYLLabelFontHeightF = 0.01
  rts1@tmXBLabelFontHeightF = 0.01

     ts_bar = gsn_csm_xy(wks, t, eof_ts(0,:),rts1)
     ts_line = gsn_csm_xy(wks,t,pc1_lf,rts2)
     overlay(ts_bar, ts_line)

;*********************************************************
   resrc = True
   resrc = res
   ;resrc@gsnAddCyclic = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@cnFillPalette = "BlueWhiteOrangeRed"
   resrc@cnLineLabelFormat  =  "@^sg"
   resrc@gsnContourNegLineDashPattern = 5
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMinLevelValF = -8.
   resrc@cnMaxLevelValF = 8.
   resrc@cnLevelSpacingF = 1.
   resrc@pmLabelBarOrthogonalPosF = 0.25
   ;resrc@pmLabelBarParallelPosF = 0.02
   resrc@cnInfoLabelOn = False
   ;resrc@cnInfoLabelString = "Dotted Area exceed 99% Sig Level"
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False
   resrc@gsnLeftStringFontHeightF = 0.01
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 360.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 10.
   resrc@mpCenterLonF = 180.

   rescor = True
   rescor@gsnDraw = False
   rescor@gsnFrame = False
   rescor@cnFillOn = True
   rescor@cnLinesOn = False
   rescor@cnInfoLabelOn = False
   ;rescor@lgLabelsOn = False
   rescor@cnLineLabelsOn = False
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/-0.320,0.320/)
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillColors = (/1,1,1/)
   rescor@lbLabelBarOn = False

   xpts = (/lonL, lonL, lonR, lonR, lonL/)
   ypts = (/latS, latN, latN, latS, latS/)
   dum = new(dimsizes(xpts)-1, graphic)
   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 2.8
   ;plres@gsLineLabelString = "sce"

  ;************************************************
    rc = regCoef(eof_ts,snow_mam(lat|:,lon|:,time|:))
    cor = escorc(eof_ts,snow_mam(lat|:,lon|:,time|:))
    do i = 0, neof-1
      copy_VarCoords(snow_mam(0,:,:), rc(i,:,:))
      copy_VarCoords(snow_mam(0,:,:), cor(i,:,:))
    end do
    resrc@gsnLeftString  = "(a) EOF 1"
    resrc@gsnRightString = sprintf("%5.1f", eof@pcvar(0))+"%"
    reg =  gsn_csm_contour_map(wks, rc(0,:,:),resrc)
    corre = gsn_csm_contour(wks, cor(0,:,:), rescor)
    overlay(reg, corre)
    do i = 0, dimsizes(xpts)-2
        dum(i) = gsn_add_polyline(wks, reg, xpts(i:i+1), \
                                  ypts(i:i+1), plres)
    end do

    plot2 = new(2,"graphic")
    plot2(0) = reg
    plot2(1) = ts_bar
    resP@gsnPanelLabelBar = False
    resP@txString = " "
    gsn_panel(wks, plot2, (/2,1/), resP)

    rc_hf = regCoef_n(pc1_hf, snow_mam, 0, 0)
    cor_hf = escorc_n(pc1_hf, snow_mam, 0, 0)
    copy_VarCoords(snow_mam(0,:,:), rc_hf)
    copy_VarCoords(snow_mam(0,:,:), cor_hf)
    reg =  gsn_csm_contour_map(wks, rc_hf,resrc)
    corre = gsn_csm_contour(wks, cor_hf, rescor)
    overlay(reg, corre)
    do i = 0, dimsizes(xpts)-2
        dum(i) = gsn_add_polyline(wks, reg, xpts(i:i+1), \
                                  ypts(i:i+1), plres)
    end do

    draw(reg)
    frame(wks)

end
