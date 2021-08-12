 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

;***
  begin
;***
   yrstrt = 196701
   yrlast = 201912

   ; yrstrt = 196701
   ; yrlast = 198812

   ; yrstrt = 198901
   ; yrlast = 201912

   t = ispan(yrstrt/100, yrlast/100, 1)

   latS     = 20               
   latN     = 90
   lonL     = 0
   lonR     = 360
;**********************************************
;Calcute Snow Cover Index
;*********************************************
   nceppath = "$HOME/data/ncep/"
   ncep2path = "$HOME/data/ncep2/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"
   hadleypath = "$HOME/data/hadley/"

   plotpath = "$HOME/output/"
;************************************************
;Setting Plot
;************************************************
   wks=gsn_open_wks("pdf", plotpath+"eof_air")
   gsn_define_colormap(wks, "ViBlGrWhYeOrRe")
;***************************************
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")

   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("years = "+ YYYYMM(iStrt) + "---" + YYYYMM(iLast))

   air_mon = airdata->air(iStrt:iLast,:,:)
   air_mam = month_to_season(air_mon, "MAM")
   ; air_mam = dtrend_n(air_mam, 0, 0)

;********************************************
  rad   = 4.*atan(1.)/180.
  clat  = airdata->lat        
  clat  = sqrt( cos(rad*clat) ) 
  ;***
  ;Compare two way of weighted cosine
  ; Wair_mam = air_mam
  ; Wair_mam = air_mam*conform(air_mam, clat, 1)
  ; Wair_mam@long_name = "Wgt:"+ Wair_mam@long_name
  ;x = Wair_mam({lat|latS:latN}, {lon|lonL:lonR},time|:)
  ;*** 
  air_mam_wgt = air_mam
  air_mam_wgt = SqrtCosWeight(air_mam)
  ; air_mam_clim = dim_avg_n_Wrap(air_mam_wgt, 0)
  ; air_mam_clim2 = conform(air_mam_wgt, air_mam_clim, (/1,2/))
  ; ;printVarSummary(air_mam_clim2)
  ; air_mam_ano = air_mam_wgt - air_mam_clim2
  ; copy_VarCoords(air_mam_wgt, air_mam_ano)
  ; ;printVarSummary(air_mam_ano)
  ; x = air_mam_ano({lat|latS:latN},{lon|lonL:lonR},time|:)
  ; nlat = dimsizes(air_mam_wgt&lat)
  ; nlon = dimsizes(air_mam_wgt&lon)
  ;printVarSummary(air_mam_wgt)
  ;printVarSummary(x)
   x = air_mam_wgt(:,{latS:latN},{lonL:lonR})
   x = dtrend_n(x, 0, 0)

 ;************************************************
 ;EOF 
 ;************************************************
   neof = 3
   optEOF = True
   optEOF@jopt = 0
   optETS = False
   eof    = eofunc_n_Wrap(x,neof,optEOF, 0)
   eof_ts = eofunc_ts_n_Wrap(x,eof,optETS, 0)
   eof_ts = dim_standardize_n_Wrap(eof_ts, 0, 0)
   ; printVarSummary(eof)
   ; printVarSummary(eof_ts)
   ; do i = 0, 2
   ; asciiwrite(indexpath+"pc"+(i+1)+"_1948-2017.txt", -1*eof_ts(i,:))
   ; end do
  ;*******************************************
  ; North significance test: Note any of the following could be used
  ;*******************************************
   dimp   = dimsizes(air_mam_wgt)
   ntim   = dimp(0)

   prinfo = True
   sig_ev  = eofunc_north(eof@eval, ntim, prinfo)

   sig_pcv = eofunc_north(eof@pcvar, ntim, prinfo)
   sig_evt = eofunc_north(eof@eval_transpose, ntim, prinfo)
   ;print(eof_ts)
;********************************************
; Filter 
;********************************************
   ;high frequence component 
    ihp = 1
    fca = 1.0/10.0
    fcb= -999.
    nsigma = 1.
    nwt= 7
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    pc1_hf = wgt_runave_Wrap(eof_ts(0,:), wgt, 0)
    ;air_mam = wgt_runave_n_Wrap(air_mam, wgt, 0, 0)
    ;slp_mam = wgt_runave_n_Wrap(slp_mam, wgt, 0, 0)
    ;snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
    ;sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)

    ; low frequency
    ihp = 0  
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    ;pc1_lf = wgt_runave_Wrap(eof_ts(0,:), wts, 0)

    pc1_lf = wgt_runave_Wrap(eof_ts(0,:), wgt, 0)
;************************************************
    ; rc = regCoef(eof_ts,air_mam_wgt(lat|:,lon|:,time|:))
    ; cor = escorc(eof_ts,air_mam_wgt(lat|:,lon|:,time|:))
    
    ; eof_ts = -1*eof_ts
    rc = regCoef_n(eof_ts, air_mam, 1, 0)
    cor = escorc_n(eof_ts, air_mam, 1, 0)

   tval = onedtond(rc@tval , dimsizes(rc))
   df   = onedtond(rc@nptxy, dimsizes(rc)) - 2
   b = tval    ; b must be same size as tval (and df)
   b = 0.5
   prob = betainc(df/(df+tval^2),df/2.0,b)       ; prob(nlat,nlon)

   do i = 0, neof -1 
    copy_VarCoords(air_mam(0,:,:), rc(i,:,:))
    copy_VarCoords(air_mam(0,:,:), cor(i,:,:))
    copy_VarCoords(air_mam(0,:,:), prob(i,:,:))
   end do 
;********************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   res@cnFillOn = True
   res@cnLinesOn = False
   res@lbLabelBarOn = False
   res@gsnAddCyclic = False
   res@mpFillOn             = False        ; turn off map fill
   res@mpMinLatF            = latS         ; zoom in on map
   res@mpMaxLatF            = latN
   res@mpMinLonF            = lonL
   res@mpMaxLonF            = lonR
   res@mpCenterLonF = 180
   res@pmLabelBarWidthF = 0.6
   res@cnLevelSelectionMode = "ManualLevels"

   resP                 = True                 ; panel resources
   resP@txString        = "SAT:MAM:"+yrstrt/100+"-"+yrlast/100 ; add center string
   resP@gsnPanelLabelBar    = True            ; add common colorbar
   resP@lbLabelAutoStride   = True
   resP@gsnMaximize         = False
   resP@pmLabelBarWidthF = 0.6
   ;resP@gsnPanelDebug = True      
   plot = new(neof, "graphic")
  do n = 0, neof-1
    res@gsnLeftString  = "EOF "+(n+1)
    res@gsnRightString = sprintf("%5.1f", eof@pcvar(n))+"%"
    plot(n) = gsn_csm_contour_map(wks, eof(n,:,:), res)
  end do
  ; gsn_panel(wks,plot,(/neof,1/),resP)
;********************************************
;Time Series plot
;********************************************
     rts           = True
     rts@gsnDraw   = False       ; don't draw yet
     rts@gsnFrame  = False       ; don't advance frame yet
     rts@gsnScale  = True        ; force text scaling               
     rts@vpHeightF = 0.35        ; Changes the aspect ratio
     rts@vpWidthF  = 0.85
     rts@vpXF      = 0.10        ; change start locations
     rts@vpYF      = 0.75        ; the plot 
     rts@tiYAxisString = ""                    ; y-axis label
     rts@gsnLeftStringFontHeightF = 0.025
     rts@gsnYRefLine = 0.
     rts@tmYLLabelFontHeightF = 0.015
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
     rts1@tiXAxisFontHeightF = 0.02
     rts1@tiYAxisFontHeightF = 0.02
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
     rts@gsnXYBarChartBarWidth = 0.6

     rtsP                     = True             ; modify the panel plot
     rtsP@gsnMaximize         = False             ; large format

     do n=0,neof-1
       rts@gsnLeftString  = "EOF "+(n+1)
       rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
       plot(n) = gsn_csm_xy (wks,t,eof_ts(n,:),rts)
     end do
     ; gsn_panel(wks,plot,(/neof,1/),rtsP)        ; draw all 'neof' as one plot

     ;pc1_run_avg = runave_n_Wrap(eof_ts(0,:), 11, 0, 0)

     ts_bar = gsn_csm_xy(wks, t, eof_ts(0,:),rts1)
     ts_line = gsn_csm_xy(wks,t,pc1_lf,rts2)
     overlay(ts_bar, ts_line)
;*********************************************************
   resrc = res
   ;resrc@gsnAddCyclic = True
   resrc@cnLinesOn = False
   resrc@cnFillPalette = "BlueWhiteOrangeRed"
   resrc@cnLineLabelsOn = False
   resrc@cnLineLabelFormat  =  "@^sg"
   resrc@gsnContourNegLineDashPattern = 5
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMinLevelValF = -1.6
   resrc@cnMaxLevelValF = -1*resrc@cnMinLevelValF
   resrc@cnLevelSpacingF = 0.1
   resrc@pmLabelBarOrthogonalPosF = 0.12
   resrc@cnInfoLabelOn = False
   ;resrc@cnInfoLabelString = "Dotted Area exceed 99% Sig Level"
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False
   ; resrc@gsnLeftStringFontHeightF = 0.025
   resrc@gsnStringFontHeightF = 0.015
   resrc@mpFillOn = True
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 360
   resrc@mpMaxLatF = 90
   resrc@mpMinLatF = 0
   resrc@mpAreaMaskingOn = True

   rescor = True
   rescor@gsnDraw = False
   rescor@gsnFrame = False
   rescor@cnFillOn = True
   rescor@cnLinesOn = False
   rescor@cnInfoLabelOn = False
   ;rescor@lgLabelsOn = False
   rescor@cnLineLabelsOn = False
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/0.05/)
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1/)
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillColors = (/1,1,1/)
   rescor@lbLabelBarOn = False
   rescor@cnFillDrawOrder = "PreDraw"

   xpts = (/lonL, lonL, lonR, lonR, lonL/)
   ypts = (/latS, latN, latN, latS, latS/)
   dum = new(dimsizes(xpts)-1, graphic)
   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 2.8
   ;plres@gsLineLabelString = "sce"
;*********************************************************
    resrc@gsnLeftString  = "(a) EOF 1"
    resrc@gsnRightString = sprintf("%5.1f", eof@pcvar(0))+"%"
    reg =  gsn_csm_contour_map(wks, rc(0,:,:),resrc)
    corre = gsn_csm_contour(wks, prob(0,:,:), rescor)
    overlay(reg, corre)
    do i = 0, dimsizes(xpts)-2
        dum(i) = gsn_add_polyline(wks, reg, xpts(i:i+1), ypts(i:i+1), plres)
    end do

    plot2 = new(2,"graphic")
    plot2(0) = reg
    plot2(1) = ts_bar
    resP@gsnPanelLabelBar = False
    resP@txString = " "
    ; gsn_panel(wks, plot2, (/2,1/), resP)

   resrc@lbLabelBarOn = False
   resP@gsnPanelLabelBar = True
  ;  plot := new(neof, "graphic")
  ; do n = 0, neof-1
  ;   resrc@gsnLeftString  = "EOF "+(n+1)
  ;   resrc@gsnRightString = sprintf("%5.1f", eof@pcvar(n))+"%"
  ;   plot(n) = gsn_csm_contour_map(wks, rc(n,:,:), resrc)
  ;   dotcn := gsn_csm_contour(wks, prob(n,:,:), rescor)
  ;   overlay(plot(n), dotcn)
  ; end do
  ; gsn_panel(wks,plot,(/neof,1/),resP)
    
    resrc@cnFillDrawOrder = "PreDraw"
    ; resrc@mpFillDrawOrder = "PostDraw"
    resrc@mpOceanFillColor = "White"
    resrc@mpLandFillColor = "Transparent"
    resrc@tmXBLabelFontHeightF = 0.015
    resrc@tmYLLabelFontHeightF = 0.015
    resrc@gsnLeftString = "a) EOF1 Whole Period"
    ; resrc@gsnLeftString = "b) EOF1 P1"
    ; resrc@gsnLeftString = "c) EOF1 P2"
    ; resrc@gsnRightString = yrstrt/100 +" - "+yrlast/100
    resrc@gsnRightString = sprintf("%5.1f", eof@pcvar(0))+"%"
    plot := gsn_csm_contour_map(wks, rc(0,:,:), resrc)
    dotcn := gsn_csm_contour(wks, prob(0,:,:), rescor)
    overlay(plot, dotcn)
    draw(plot)
    frame(wks)

   


end
