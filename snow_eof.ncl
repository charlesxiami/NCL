begin
   snowpath  = "/public/home/charlesxiami/data/snow/"
   plotpath  = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"

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

   yrstrt =196701
   yrlast =201412

   sig = 0.320   ;95%
   ; sig1 = 0.497
   ; sig2 = 0.433
;*****************************************************
;I/O
;*****************************************************
   wks=gsn_open_wks("pdf", plotpath+"snow_eof")
   gsn_define_colormap(wks, "cmp_b2r")
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
   resrc@mpMinLonF = lonL
   resrc@mpMaxLonF = lonR
   resrc@mpMinLatF = latS
   resrc@mpMaxLatF = latN
   resrc@gsnAddCyclic = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMaxLevelValF = 0.08
   resrc@cnMinLevelValF = -0.08
   resrc@cnLevelSpacingF = 0.02
   resrc@trGridType = "TriangularMesh"
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

   ; resP = True
   ; resP@gsnMaximize = False
   ; resP@gsnPanelLabelBar = True
   ; ;resP@lblabel
   ; ;resP@gsnPanelFigureStrings = (/"a)","b)","c)","d)","e)","f)"/)
   ; resP@gsnPanelFigureStringsFontHeightF = 0.012
   ; resP@gsnPanelFigureStringsPerimOn = False
   ; resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   ; resP@amJust = "TopLeft"
   ; resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   ; resP@amParallelPosF = -0.50    ;X-axis

;-------------------------------------------------------------------
;Data read and process
   snow_file = addfile(snowpath+"RutgersSnow.mon.mean.nc", "r")
   snow_rutgerRegrid = addfile(snowpath+"snow.rutger.2.0deg.neareststod.nc", "r")
   pc1_all = asciiread(indexpath+"pc1.txt", -1, "float")
   ;print(snow_file->lon)

   YYYYMM = cd_calendar(snow_file->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print(YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   snow_mon = snow_file->snowcover(iStrt:iLast,:,:)
   snow_mon@_FillValue = -999
   delete(snow_mon@missing_value)
   snow_mam = month_to_season(snow_mon, "MAM")
   
   snow_mon2 = snow_rutgerRegrid->snowcover(iStrt:iLast,:,:)
   snow_mam2 = month_to_season(snow_mon2, "MAM")

   dim2 = dimsizes(snow_mon2)
   snow_march = snow_mon2(2:dim2(0)-1:12,:,:)
   snow_april = snow_mon2(3:dim2(0)-1:12,:,:)
   snow_may   = snow_mon2(4:dim2(0)-1:12,:,:)
   snow_am = snow_mam2
   snow_am = (snow_april+snow_may)/2.0
   snow_am@long_name = "AM SCE Rate"


   lat2d = snow_file->lat
   lon2d = snow_file->lon
   ; printMinMax(lat2d, 0)
   ; printMinMax(lon2d, 0)

   lat_array = (/latN_eof,latS_eof,latN_eof,latS_eof/)
   lon_array = (/lonW_eof,lonE_eof,lonE_eof,lonW_eof/)

   nm = getind_latlon2d(lat2d, lon2d, lat_array, lon_array)
   print(nm)
   jStrt = nm(0,0)
   jLast = nm(1,0)
   iStrt = nm(0,1)
   iLast = nm(1,1)
   lat2d_new = lat2d(jStrt:jLast,iStrt:iLast)
   lon2d_new = lon2d(jStrt:jLast,iStrt:iLast)

   printMinMax(lat2d_new, 0)
   printMinMax(lon2d_new, 0)

   rad = get_d2r("float")
   clat = snow_file->lat
   clat = sqrt(cos(rad*clat))
   wsnow_mam = snow_mam
   wsnow_mam = snow_mam*conform(snow_mam, clat, (/1,2/))
   wsnow_mam@long_name = "Wgt "+ wsnow_mam@long_name

   snow_mam_eof = wsnow_mam(:,jStrt:jLast,iStrt:iLast)

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
    ; snow_mam2 = dtrend_leftdim(snow_mam2, False)
    ; snow_am = dtrend_leftdim(snow_am, False)
;*************************************************

; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
  ; rad    = 4.*atan(1.)/180.
  ; clat   = snow_file->lat           
  ; clat   = sqrt( cos(rad*clat) ) 
; ; =================================================================
; ; weight all observations 
; ; =================================================================
;   wsnow_mam   = snow_mam                                   ; copy meta data
;   wsnow_mam   = snow_mam*conform(snow_mam, clat, 1)
    ;wsnow_am = SqrtCosWeight(snow_am)
    snow_am = SqrtCosWeight(snow_am)
    snow_mam2 = SqrtCosWeight(snow_mam2)

    ;x = snow_am(:,{latS:latN},{lonL:lonR})
    x = snow_mam2(:,{latS:latN},{lonL:lonR})

    neof = 3
    optEOF = True       
    optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
    optETS = False

    eof = eofunc_n_Wrap(x, neof, optEOF,0)
    eof = -1*eof
    eof_ts = eofunc_ts_n_Wrap(x, eof, optETS,0)
    eof_ts = dim_standardize_Wrap(eof_ts, 0)

    eof_ts_hf = wgt_runave_n_Wrap(eof_ts, wgt, 0, 1)

    ; eof@lat2d = lat2d_new
    ; eof@lon2d = lon2d_new

   ; dimxw  = dimsizes( x )
   ; mln    = dimxw(1)
   ; sumWgt = mln*sum( clat({lat|latS:latN}) )
   ; eof_ts = eof_ts/sumWgt
;*******************************************
; North significance test: Note any of the following could be used
;*******************************************
   dimp   = dimsizes(x)
   ntim   = dimp(0)

   prinfo = True
   sig_pcv = eofunc_north(eof@pcvar, ntim, prinfo)
   ; sig_ev  = eofunc_north(eof@eval, ntim, prinfo)
   ; sig_evt = eofunc_north(eof@eval_transpose, ntim, prinfo)
    

;--------------------------------------------------------
;Another EOF
    snow_mam2 = dtrend_leftdim(snow_mam2, False)   

    xx = snow_mam2(:,{latS:latN},{lonL:lonR}) 

    eof2 = eofunc_n_Wrap(xx, neof, optEOF,0)
    ;eof2 = -1*eof2
    eof_ts2 = eofunc_ts_n_Wrap(xx, eof2, optETS,0)
    eof_ts2 = dim_standardize_Wrap(eof_ts2, 0)

    print("PC-PC: " + escorc_n(eof_ts_hf, eof_ts2, 1, 1))

;*************************************************
;Regression, Correlation
;*************************************************    
   plot = new(neof,graphic)                ; create graphic array
   ;yyyymm = eof_ts&time
   yyyymm = cd_calendar(eof_ts&time, -1)
; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = False         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar

  nyrs = dimsizes(x&time)
  yStrt                    = yyyymm(0)/100
  yLast                    = yyyymm(nyrs-1)/100
  resP@txString            = "SCE: "+" "+yStrt+"-"+yLast

;*******************************************
; first plot
;*******************************************

  do n=0,neof-1
     resrc@gsnLeftString  = "EOF "+(n+1)
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
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
  rts@trYMaxF = 3.0
  rts@trYMinF = -3.0

; panel plot only resources
  rtsP                      = True            ; modify the panel plot
  rtsP@gsnMaximize          = True            ; large format
  rtsP@txString             = "SCE: "+" "+yStrt+"-"+yLast

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


end