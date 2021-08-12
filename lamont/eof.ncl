begin

   yrstrt = 197201
   yrlast = 199512

   ; yrstrt = 199601
   ; yrlast = 201912

   nyrs = yrlast/100 - yrstrt/100 + 1

   year_ind = ispan(yrstrt/100, yrlast/100, 1)

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  latS   =  40
  latN   =  75
  lonL   =  65
  lonR   =  150

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

   plotpath = "$HOME/output/"
;**************************************************
   wks = gsn_open_wks("pdf", "NH_EOF")
   gsn_define_colormap(wks, "cmp_b2r")
;**************************************************
;Read Data
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
 ;***************************************
   YYYYMM = cd_calendar(hgtdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))
;-------------------------------------------------------------------
;Data read and process
   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)

   sc_season  = month_to_season(snow_mon_wgt, "SON")
   sc_season_eu = sc_season(:,{latS_eof:latN_eof},{lonW_eof:lonE_eof})

   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{20:90},:)
   z500_season = month_to_season(z500_mon, "DJF")

   u_mon = uwnddata->uwnd(iStrt:iLast,:,:,:)
   u_season = month_to_season(u_mon, "DJF")
   u200_season = u_season(:,{70},{-10:90},:)
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
;Dtrend
   ; x = dtrend_n(sc_season_eu, False, 0)
   ; copy_VarCoords(sc_season_eu, x)

   ; x = dtrend_n(z500_season, False, 0)
   ; copy_VarCoords(z500_season, x)

   x = dtrend_n(u200_season, False, 0)
   copy_VarCoords(u200_season, x)
;*************************************************
    neof = 3
    optEOF = True       
    optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
    optETS = False

    eof = eofunc_n_Wrap(x, neof, optEOF,0)
    ; eof(0,:,:) = -1*eof(0,:,:)
    ; eof = -1*eof
    eof_ts = eofunc_ts_n_Wrap(x, eof, optETS,0)
    eof_ts = dim_standardize_Wrap(eof_ts, 0)

   ; dimxw  = dimsizes( x )
   ; mln    = dimxw(1)
   ; sumWgt = mln*sum( clat({lat|latS:latN}) )
   ; eof_ts = eof_ts/sumWgt

   print("Cor= "+ escorc(eof_ts(0,:), year_ind))

   ; asciiwrite(indexpath+"snow_pc1dt_"+yrstrt/100+"-"+yrlast/100+season+".txt", eof_ts(0,:))
   ; asciiwrite(indexpath+"snow_pc2dt_"+yrstrt/100+"-"+yrlast/100+season+".txt", eof_ts(1,:))
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

eofreg = regCoef_n(eof_ts(0,:), x, 0, 0)
copy_VarCoords(x(0,:,:), eofreg)

tval = onedtond(eofreg@tval , dimsizes(eofreg))
df   = onedtond(eofreg@nptxy, dimsizes(eofreg)) - 2
b = tval
b = 0.5
prob = betainc(df/(df+tval^2),df/2.0,b)
copy_VarCoords(x(0,:,:), prob)

; printVarSummary(prob)
; printMinMax(prob, 0)
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

   resrc@mpMinLatF = 20
   resrc@mpMaxLatF = 90
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 360
   resrc@mpCenterLonF = 180

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
   rescor@cnLevels = (/0.05/)  ;95%
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnFillColors = (/1,1/)
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False
   rescor@cnMonoFillScale = True   
   rescor@cnFillScaleF = 1.0
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillOpacityF = 1.0
   ; rescor@cnFillDrawOrder = "PreDraw"

   resP = True
   resP@gsnMaximize = False
   resP@gsnPanelLabelBar = True
   resP@pmLabelBarWidthF = 0.5
   resP@gsnPanelYWhiteSpacePercent = 6
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
  resP@txString            = yStrt+"-"+yLast

;*******************************************
; first plot
;*******************************************
  do n=0,neof-1
     resrc@gsnLeftString  = "EOF "+(n+1) ;+ "  "+ yrstrt/100 + "-"+ yrlast/100
     resrc@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n)=gsn_csm_contour_map(wks,eof(n,:,:),resrc)
  end do
  gsn_panel(wks,plot,(/neof,1/),resP)     ; now draw as one plot

  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               

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
  rtsP@gsnPanelYWhiteSpacePercent = 6

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

;*******************************************
  resrc@cnMaxLevelValF = 10.
  resrc@cnMinLevelValF = -1*resrc@cnMaxLevelValF
  resrc@cnLevelSpacingF = 1.

  resrc@lbLabelBarOn = True
  resrc@mpMinLatF = -10
  resrc@cnFillPalette = "BlueWhiteOrangeRed"

  resrc@gsnLeftString = " "
  resrc@gsnRightString = " "
  plot1 = gsn_csm_contour_map(wks, eofreg, resrc)
  plot2 = gsn_csm_contour(wks, prob, rescor)
  overlay(plot1, plot2)
  draw(plot1)
  frame(wks)

end