begin

   ; yrstrt = 197201
   ; yrlast = 199212

   ; yrstrt = 199301
   ; yrlast = 201412

   yrstrt = 197201
   yrlast = 201412

   nyrs = yrlast/100 - yrstrt/100 + 1

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  latS   =  40
  latN   =  75
  lonL   =  65
  lonR   =  150

  WlatS = 48
  WlatN = 58
  WlonL = 25
  WlonR = 50
  
  ElatS = 60
  ElatN = 70
  ElonL = 100
  ElonR = 125

   latS_eof = 40
   latN_eof = 70
   lonW_eof = 20
   lonE_eof = 140

   sig = 0.320   ;95%
   ; sig1 = 0.497
   ; sig2 = 0.433
   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"
;**************************************************
   ; wks = gsn_open_wks("pdf", plotpath+"snow_eof_72-93")
   wks = gsn_open_wks("pdf", plotpath+"snow_eof")
   gsn_define_colormap(wks, "cmp_b2r")
;**************************************************
;Read Data
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.nc", "r")

   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
   soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")
   snowdata = addfile(snowpath+"snow.rutger.2.0deg.nc","r")
   precipdata = addfile(precpath+"precip.mon.anom.nc", "r")

 ;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt_sst)
   iLast2  = ind(YYYYMM2.eq.yrlast_sst)
   print("sst  time: "+YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))
;-------------------------------------------------------------------
;Data read and process
   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)

   season = "SON"
   snow_mam  = month_to_season(snow_mon_wgt, season)
   snow_eu_mam = snow_mam(:,{latS_eof:latN_eof},{lonW_eof:lonE_eof})

   snow_region = wgt_areaave(snow_eu_mam, 1.0, 1.0, 0)
   printVarSummary(snow_region)
   ; x = snow_eu_mam
;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1          ; 0=low pass, 1=high pass, 2=band-pass
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 7
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    ;pc1 = wgt_runave_Wrap(pc1_all, wgt, 0)
    ;snow_mam2  = wgt_runave_n_Wrap(snow_mam2, wgt, 0, 0)
;*************************************************
; Running average
   ; snow_eu_mam_lf = runave_n_Wrap(snow_eu_mam, 21, -1, 0)
   ; x = snow_eu_mam - snow_eu_mam_lf
   ; copy_VarCoords(snow_eu_mam, x)

;*************************************************
;Dtrend
   x = dtrend_n(snow_eu_mam, False, 0)
   copy_VarCoords(snow_eu_mam, x)
;*************************************************
    neof = 3
    optEOF = True       
    optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
    optETS = False

    eof = eofunc_n_Wrap(x, neof, optEOF,0)
    ; eof(0,:,:) = -1*eof(0,:,:)
    eof = -1*eof
    eof_ts = eofunc_ts_n_Wrap(x, eof, optETS,0)
    eof_ts = dim_standardize_Wrap(eof_ts, 0)

    ; eof_ts_hf = wgt_runave_n_Wrap(eof_ts, wgt, 0, 1)

   ; dimxw  = dimsizes( x )
   ; mln    = dimxw(1)
   ; sumWgt = mln*sum( clat({lat|latS:latN}) )
   ; eof_ts = eof_ts/sumWgt

   ; asciiwrite(indexpath+"snow."+str_lower(season)+".pc1_72-93"+".txt", eof_ts(0,:))
   ; asciiwrite(indexpath+"snow."+str_lower(season)+".dt.pc1"+".txt", eof_ts(0,:))
   ; asciiwrite(indexpath+"snow."+str_lower(season)+".dt.pc2"+".txt", eof_ts(1,:))
   ; asciiwrite(indexpath+"snow."+str_lower(season)+".dt.pc3"+".txt", eof_ts(2,:))

   ; asciiwrite(indexpath+"snow.pc1.p2"+".txt", eof_ts(0,:))
   ; asciiwrite(indexpath+"snow.pc2.p2"+".txt", eof_ts(1,:))
;*******************************************
; North significance test: Note any of the following could be used
;*******************************************
   dimp   = dimsizes(x)
   ntim   = dimp(0)

   prinfo = True
   sig_pcv = eofunc_north(eof@pcvar, ntim, prinfo)
   ; sig_ev  = eofunc_north(eof@eval, ntim, prinfo)
   ; sig_evt = eofunc_north(eof@eval_transpose, ntim, prinfo)

;*************************************************
;Regression, Correlation
;*************************************************    
;Res
;*************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   resmap = True
   resmap@mpFillOn = False
   resmap@mpCenterLonF = 180.
   resmap@mpMinLonF = 0.
   resmap@mpMaxLonF = 240.
   resmap@mpMaxLatF = 90.
   resmap@mpMinLatF = 0.
   resmap@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)

   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   resrc@pmLabelBarOrthogonalPosF = 0.5
   ;resrc@lbOrientation = "Vertical"
   resrc@cnInfoLabelOn = False
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = False
   ;resrc@mpCenterLonF = 0
   ; resrc@mpMinLonF = lonW_eof
   ; resrc@mpMaxLonF = lonE_eof
   ; resrc@mpMinLatF = latS_eof
   ; resrc@mpMaxLatF = latN_eof
   resrc@mpMinLatF = latS_eof
   resrc@mpMaxLatF = latN_eof
   resrc@mpMinLonF = lonW_eof
   resrc@mpMaxLonF = lonE_eof
   resrc@gsnAddCyclic = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMaxLevelValF = 0.08
   resrc@cnMinLevelValF = -0.08
   resrc@cnLevelSpacingF = 0.01
   ; resrc@trGridType = "TriangularMesh"
   ;resrc@gsnPolar = "NH"
   ;resrc@mpMinLatF = 35
   ;resrc@cnFillMode = "RasterFill"

   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnMonoFillPattern = False
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False
   rescor@cnFillPatterns = (/17,-1,17/)

   resP = True
   resP@gsnMaximize = False
   resP@gsnPanelLabelBar = True
   resP@pmLabelBarWidthF = 0.5
   ; ;resP@gsnPanelFigureStrings = (/"a)","b)","c)","d)","e)","f)"/)
   ; resP@gsnPanelFigureStringsFontHeightF = 0.012
   ; resP@gsnPanelFigureStringsPerimOn = False
   ; resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   ; resP@amJust = "TopLeft"
   ; resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   ; resP@amParallelPosF = -0.50    ;X-axis

   plot = new(neof,graphic)                ; create graphic array
   ;yyyymm = eof_ts&time
   yyyymm = cd_calendar(eof_ts&time, -1)

  nyrs = dimsizes(x&time)
  yStrt                    = yyyymm(0)/100
  yLast                    = yyyymm(nyrs-1)/100
  ; resP@txString            = "SCE: "+" "+yStrt+"-"+yLast

;*******************************************
; first plot
;*******************************************
  do n=0,neof-1
     resrc@gsnLeftString  = "EOF "+(n+1)+ "  "+ yrstrt/100 + "-"+ yrlast/100
     resrc@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n)=gsn_csm_contour_map(wks,eof(n,:,:),resrc)
  end do
  gsn_panel(wks,plot,(/neof,1/),resP)     ; now draw as one plot

  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               

; these four rtsources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot


  rts@tiYAxisString = " "                    ; y-axis label      

  rts@gsnYRefLine           = 0.              ; reference line   
  rts@gsnXYBarChart         = True            ; create bar chart 
  rts@gsnXYBarChartBarWidth = 0.6
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
  rts@trYMaxF = 3.0
  rts@trYMinF = -3.0

; panel plot only resources
  rtsP                      = True            ; modify the panel plot
  rtsP@gsnMaximize          = True            ; large format
  ; rtsP@txString             = "SCE: "+" "+yStrt+"-"+yLast

  ;year = ispan(yrstrt/100, yrlast/100, 1)
  year =  yyyymm/100
  ;year = ispan(1972, 2004, 1)
  
; create individual plots
  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,year,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)     ; now draw as one plot

  ;  resrc@cnMaxLevelValF = 10.0
  ;  resrc@cnMinLevelValF = -10.0  
  ; resrc@lbLabelBarOn = True
  ; snow_mam_avg = dim_avg_n_Wrap(snow_mam, 0)
  ; plot1 = gsn_csm_contour_map(wks, snow_mam_avg, resrc)
  ; draw(plot1)
  ; frame(wks)

end