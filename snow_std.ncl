load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
  begin
;***
  yrstrt =197201
  yrlast =200912
;---------------A,B-index Region
  WlatS = 48
  WlatN = 58
  WlonL = 25
  WlonR = 50

  ClatS = 50
  ClatN = 60
  ClonL = 55
  ClonR = 85
  
  ElatS = 60
  ElatN = 70
  ElonL = 100
  ElonR = 125

  latS  = -90
  latN  = 90
  lonL  = 0
  lonR  = 360
;***********************************************
   cd = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"

   wks=gsn_open_wks("pdf", plotpath+"snow_std")
   gsn_define_colormap(wks, "WhiteBlueGreenYellowRed")
;************************************************
   filesnow = "/public/home/charlesxiami/data/snow/snow.nc"
   snowdata = addfile(filesnow,"r")
   airdata = addfile(cd+"air.mon.mean.nc", "r")
   slpdata = addfile(cd+"slp.mon.mean.nc", "r")
   hgtdata = addfile(cd+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(cd+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(cd+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(cd+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(cd+"nlwrs.sfc.mon.mean.nc", "r")
   sstdata = addfile(cd+"sst.mnmean.v4.nc", "r")
   soilwdata = addfile(cd+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(cd+"tcdc.eatm.mon.mean.nc", "r")
;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   year=ispan(1972, 2009, 1)

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)
   print(YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))
;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR})
   air_mam = month_to_season(air_mon, "MAM")
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR})
   slp_mam = month_to_season(slp_mon, "MAM")
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 
   z500_mam = month_to_season(z500_mon, "MAM")
   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   z200_mam = month_to_season(z200_mon, "MAM")
   
   u_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   u_mam = month_to_season(u_mon, "MAM")
   v_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   v_mam = month_to_season(v_mon, "MAM")
   uv_mam = sqrt(u_mam^2+v_mam^2)
   copy_VarCoords(u_mam, uv_mam)

   snow_mon  = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

;*************************************************
   snow_march = snow_mam
   snow_april = snow_mam
   snow_may   = snow_mam
   do i = 0, 37
    snow_march(i,:,:) = snow_mon(2+i*12,:,:)
    snow_april(i,:,:) = snow_mon(3+i*12,:,:)
    snow_may(i,:,:)   = snow_mon(4+i*12,:,:)
   end do 

   ;All periods
   snow_march_std = dim_stddev_n_Wrap(snow_march, 0)
   snow_april_std = dim_stddev_n_Wrap(snow_april, 0)
   snow_may_std   = dim_stddev_n_Wrap(snow_may, 0)
   snow_mam_std = dim_stddev_n_Wrap(snow_mam, 0)
   printVarSummary(snow_mam_std)
   
   ;Sub periods
    ;P1
    snow_march1 = snow_march(0:15,:,:)
    snow_april1 = snow_april(0:15,:,:)
    snow_may1   = snow_may(0:15,:,:)
    snow_mam1   = snow_mam(0:15,:,:)
    snow_march_std1 = dim_stddev_n_Wrap(snow_march1, 0)
    snow_april_std1 = dim_stddev_n_Wrap(snow_april1, 0)
    snow_may_std1   = dim_stddev_n_Wrap(snow_may1, 0)
    snow_mam_std1 = dim_stddev_n_Wrap(snow_mam1, 0)
    ;P2
    snow_march2 = snow_march(17:37,:,:)
    snow_april2 = snow_april(17:37,:,:)
    snow_may2   = snow_may(17:37,:,:)
    snow_mam2   = snow_mam(17:37,:,:)
    snow_march_std2 = dim_stddev_n_Wrap(snow_march2, 0)
    snow_april_std2 = dim_stddev_n_Wrap(snow_april2, 0)
    snow_may_std2   = dim_stddev_n_Wrap(snow_may2, 0)
    snow_mam_std2 = dim_stddev_n_Wrap(snow_mam2, 0)

    ;Difference
    ;Dif of climate
    ; snow_march_dif = snow_march2 - snow_march1
    ; snow_april_dif = snow_april2 - snow_april1
    ; snow_may_dif   = snow_may2 - snow_may1
    ; snow_mam_dif   = snow_mam2 - snow_mam1

    ;Dif of std
    snow_march_std_dif = snow_march_std2 - snow_march_std1
    snow_april_std_dif = snow_april_std2 - snow_april_std1
    snow_may_std_dif     = snow_may_std2 - snow_may_std1
    snow_mam_std_dif     = snow_mam_std2 - snow_mam_std1
    copy_VarCoords(snow_march_std2, snow_march_std_dif)
    copy_VarCoords(snow_april_std2, snow_april_std_dif)
    copy_VarCoords(snow_may_std2, snow_may_std_dif)
    copy_VarCoords(snow_mam_std2, snow_mam_std_dif)
;********************************************************
;Res Settings
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   ;For SAT
   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "AutomaticLevels"
   ; resrc@mpGridAndLimbOn = True
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpFillOn = False
   resrc@mpCenterLonF = 180.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.
   ;resrc@mpDataSetName         = "Earth..4"   ; This new database contains
   ;resrc@mpDataBaseVersion     = "LowRes"  ; Medium resolution database
   ;resrc@mpOutlineBoundarySets = "National"
   resrc@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   ;resrc@gsnStringFontHeightF = 0.08

   ;For SLP
   resrc2 = res
   resrc2@cnFillOn = False
   resrc2@cnLinesOn = True
   resrc2@cnInfoLabelOn = False
   resrc2@gsnContourNegLineDashPattern = 5
   resrc2@gsnContourZeroLineThicknessF = 0.
   resrc2@cnLineThicknessF = 2.8
   ;resrc2@cnLineColor = "red"
   resrc2@cnLineLabelsOn = True
   resrc2@cnLineLabelPerimOn = False
   resrc2@cnLineLabelBackgroundColor = 2
   resrc2@cnLineLabelPlacementMode = "Constant"
   resrc2@cnLineLabelInterval = 2
   resrc2@cnLineLabelFontHeightF = 0.015
   ;resrc2@cnLineLabelFontColor = 0
   resrc2@cnLineLabelFontThicknessF = 1.0
   resrc2@gsnAddCyclic = True

   ressnow = resrc
   ressnow@mpMinLatF = 30.
   ressnow@mpMaxLatF = 75.
   ressnow@mpMinLonF = 10.
   ressnow@mpMaxLonF = 150.
   ressnow@mpCenterLonF = 80.
   ressnow@lbLabelBarOn = False
   ressnow@cnLevelSelectionMode = "ManualLevels"
   ressnow@gsnRightString = " "
   ressnow@cnMinLevelValF = 0.
   ressnow@cnMaxLevelValF = 0.5
   ressnow@cnLevelSpacingF = 0.01

   ;Correlation res (with dots.)
   rescor = True
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False

   ;Wind Resources
   resV = True
   resV@gsnDraw = False
   resV@gsnFrame = False
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.0               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02
   resV@vcRefMagnitudeF = 1.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.58

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopRight"
   resP@gsnPanelLabelBar = True
   resP@pmLabelBarWidthF = 0.4
;********************************************************
;Draw plots
   ;ALl
   ressnow@gsnLeftString = "(a) SCE std March"
   plot_march = gsn_csm_contour_map(wks, snow_march_std, ressnow)
   ressnow@gsnLeftString = "(b) SCE std April"
   plot_april = gsn_csm_contour_map(wks, snow_april_std, ressnow)
   ressnow@gsnLeftString = "(c) SCE std May"
   plot_may = gsn_csm_contour_map(wks, snow_may_std, ressnow)
   ressnow@gsnLeftString = "(d) SCE std MAM"
   plot_mam = gsn_csm_contour_map(wks, snow_mam_std, ressnow)
   ;Panel plot
   stdpanel = new(4, "graphic")
   stdpanel(0) = plot_march
   stdpanel(1) = plot_april
   stdpanel(2) = plot_may
   stdpanel(3) = plot_mam
   gsn_panel(wks, stdpanel, (/2,3/), resP)

   ;sub periods
    ;P1
    ressnow@gsnLeftString = " SCE std March P1"
    plot_march1 = gsn_csm_contour_map(wks, snow_march_std1, ressnow)
    ressnow@gsnLeftString = " SCE std April P1"
    plot_april1 = gsn_csm_contour_map(wks, snow_april_std1, ressnow)
    ressnow@gsnLeftString = " SCE std May P1"
    plot_may1 = gsn_csm_contour_map(wks, snow_may_std1, ressnow)
    ressnow@gsnLeftString = " SCE std MAM P1"
    plot_mam1 = gsn_csm_contour_map(wks, snow_mam_std1, ressnow)

    ;P2
    ressnow@gsnLeftString = " SCE std March P2"
    plot_march2 = gsn_csm_contour_map(wks, snow_march_std2, ressnow)
    ressnow@gsnLeftString = " SCE std April P2"
    plot_april2 = gsn_csm_contour_map(wks, snow_april_std2, ressnow)
    ressnow@gsnLeftString = " SCE std May P2"
    plot_may2 = gsn_csm_contour_map(wks, snow_may_std2, ressnow)
    ressnow@gsnLeftString = " SCE std MAM P2"
    plot_mam2 = gsn_csm_contour_map(wks, snow_mam_std2, ressnow)

    substdpanel = new(8, "graphic")
    substdpanel(0) = plot_march1
    substdpanel(2) = plot_april1
    substdpanel(4) = plot_may1
    substdpanel(6) = plot_mam1
    substdpanel(1) = plot_march2
    substdpanel(3) = plot_april2
    substdpanel(5) = plot_may2
    substdpanel(7) = plot_mam2
    gsn_panel(wks, substdpanel, (/4,2/), resP)

    ;Dif Draw
    gsn_define_colormap(wks, "BlueWhiteOrangeRed")
    ressnow@cnMinLevelValF = -0.2
    ressnow@cnMaxLevelValF = 0.2
    ressnow@gsnLeftString = "SCE std_dif March"
    plot_march0 = gsn_csm_contour_map(wks, snow_march_std_dif, ressnow)
    ressnow@gsnLeftString = "SCE std_dif April"
    plot_april0 = gsn_csm_contour_map(wks, snow_april_std_dif, ressnow)
    ressnow@gsnLeftString = "SCE std_dif May"
    plot_may0 = gsn_csm_contour_map(wks, snow_may_std_dif, ressnow)
    ressnow@gsnLeftString = "SCE std_dif MAM"
    plot_mam0 = gsn_csm_contour_map(wks, snow_mam_std_dif, ressnow)

    stddifpanel = new(4, "graphic")
    stddifpanel(0) = plot_march0
    stddifpanel(1) = plot_april0
    stddifpanel(2) = plot_may0
    stddifpanel(3) = plot_mam0
    gsn_panel(wks, stddifpanel, (/2,3/), resP)


end
