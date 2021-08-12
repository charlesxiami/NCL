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

  sig1 = 0.576   ; %95 12-years
  sig2 = 0.482   ; %95 17-years

   cd = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"

   wks=gsn_open_wks("pdf", plotpath+"leadlag_snow")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;***********************************************
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
   ;year=ispan(1972, 2009, 1)

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
   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   
   u850_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   u850_mam = month_to_season(u850_mon, "MAM")

   v850_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   v850_mam = month_to_season(v850_mon, "MAM")

   snow_mon  = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   sst_mam = month_to_season(sst_mon, "MAM")
;************************************************
; Calculate A,B Index
;************************************************
   snow_mam_wgt= SqrtCosWeight(snow_mam)
   Wregion=snow_mam_wgt(:,{WlatS:WlatN},{WlonL:WlonR})
   Cregion=snow_mam_wgt(:,{ClatS:ClatN},{ClonL:ClonR})
   Eregion=snow_mam_wgt(:,{ElatS:ElatN},{ElonL:ElonR})
   SCAW = wgt_areaave_Wrap(Wregion, 1.0, 1.0, 1)
   SCAE = wgt_areaave_Wrap(Eregion, 1.0, 1.0, 1)
   SCAW = dim_standardize_Wrap(SCAW, 0)
   SCAE = dim_standardize_Wrap(SCAE, 0)
;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    SCAW_hf = wgt_runave_Wrap(SCAW, wgt, 0)
    SCAE_hf = wgt_runave_Wrap(SCAE, wgt, 0)
    ;pc1_hf = wgt_runave_Wrap(pc1, wgt, 0)

    SCAE_hf = -1.0*SCAE_hf

    ; z200_mon = wgt_runave_n_Wrap(z200_mon, wgt, 0, 0)
    ; z500_mon = wgt_runave_n_Wrap(z200_mon, wgt, 0, 0)
    ; air_mon  = wgt_runave_n_Wrap(air_mon, wgt, 0, 0)
    ; u850_mon  = wgt_runave_n_Wrap(u850_mon, wgt, 0, 0)
    ; v850_mon  = wgt_runave_n_Wrap(v850_mon, wgt, 0, 0)

;*************************************************
   season = (/"DJF","JFM","FMA","MAM","AMJ","MJJ","JJA"/)
   z200_sea = month_to_seasonN(z200_mon, (/"DJF","JFM","FMA","MAM","AMJ","MJJ","JJA"/))
   z500_sea = month_to_seasonN(z500_mon, (/"DJF","JFM","FMA","MAM","AMJ","MJJ","JJA"/))
   air_sea = month_to_seasonN(air_mon, season)
   u850_sea = month_to_seasonN(u850_mon, season)
   v850_sea = month_to_seasonN(v850_mon, season)

;*RES***********************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   ;For SAT
   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@mpFillOn = False
   resrc@mpCenterLonF = 180.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.
   resrc@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@pmLabelBarHeightF = 0.01
   resrc@pmLabelBarWidthF  = 0.02
   resrc@lbLabelFontHeightF = 0.05

   ;For SLP
   resrc2 = res
   resrc2@cnFillOn = False
   resrc2@cnLinesOn = True
   resrc2@cnInfoLabelOn = False
   resrc2@gsnContourNegLineDashPattern = 1
   resrc2@gsnContourZeroLineThicknessF = 0.
   resrc2@cnLineThicknessF = 2.4
   ;resrc2@cnLineColor = "red"
   resrc2@cnLineLabelsOn = True
   resrc2@cnLineLabelPerimOn = False
   resrc2@cnLineLabelBackgroundColor = 2
   resrc2@cnLineLabelPlacementMode = "Constant"
   resrc2@cnLineLabelInterval = 2
   resrc2@cnLineLabelFontHeightF = 0.015
   ;resrc2@cnLineLabelFontColor = 0
   resrc2@cnLineLabelFontThicknessF = 2.0
   ;resrc2@gsnAddCyclic = True
   resrc2@cnMaxLevelValF = 30.
   resrc2@cnMinLevelValF = -30.
   resrc2@cnLevelSpacingF = 5.
   ; resrc2@cnLevelSelectionMode = "ExplicitLevels"
   ; resrc2@cnLevels = (/0/)
   ;resrc2@cnLineColor = (/"blue"/)

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
   resV@vcLineArrowThicknessF   = 2.0              ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02
   resV@vcRefMagnitudeF = 1.0
   resV@vcRefLengthF = 0.05
   resV@vcRefAnnoArrowLineColor = "black"
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.13

   resP = True
   resP@gsnFrame = False
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.015
   resP@gsnPanelFigureStringsPerimOn = False
   strings = (/"a(-3)","b(-2)","c(-1)","d(0)","e(+1)","f(+2)"/)
   resP@gsnPanelFigureStrings = strings
   ;(/"-3","-2","-1","0","e","f","g"/)
   resP@amJust = "TopLeft"
   resP@gsnPanelLabelBar = True
   resP@gsnPanelRowSpec = True
   resP@gsnPolarLabelFontHeightF = 0.007
   resP@pmLabelBarWidthF = 0.5

   resP_R = resP
   resP_R@gsnPanelLeft = 0.5
   resP_R@gsnPanelRowSpec = False
;********************************************
    plotrc = new(7, graphic)
    plotline = new(7, graphic)
    plotcor = new(7, graphic)
    plotuv = new(7, graphic)

    plotrc2 = new(5,graphic)
    plotline2 = new(5, graphic)
    plotcor2 = new(5, graphic)
    plotuv2 = new(5, graphic)
;******SCAE******
;200hPa
;--------------------------------------------------------
    resrc@cnMaxLevelValF = 40.
    resrc@cnMinLevelValF = -40.
    resrc@cnLevelSpacingF = 2. 

    rescor@cnLevels = (/-sig1,sig1/)
    rc = regCoef_n(SCAE_hf(0:15),z200_sea(:,0:15,:,:),0,1)
    cor = escorc_n(SCAE_hf(0:15),z200_sea(:,0:15,:,:),0,1)
    do i = 0,5
       copy_VarCoords(z200_mon(0,:,:), rc(i,:,:))
       copy_VarCoords(z200_mon(0,:,:), cor(i,:,:))
       plotrc(i) = gsn_csm_contour_map(wks, rc(i,:,:), resrc)
       plotline(i) = gsn_csm_contour(wks, rc(i,:,:), resrc2)
       plotcor(i) = gsn_csm_contour(wks, cor(i,:,:), rescor)
       ;overlay(plotrc(i), plotline(i))
       overlay(plotrc(i), plotcor(i))
    end do
    resP@gsnPanelMainString = "Lead-lag regression 200Hpa SCAEI 1972-1987"
    ; gsn_panel(wks, plotrc, (/2,2,2,1/), resP)
    ; frame(wks)

    rescor@cnLevels = (/-sig2,sig2/)
    delete(rc)
    delete(cor)
    rc = regCoef_n(SCAE_hf(17:37),z200_sea(:,17:37,:,:),0,1)
    cor = escorc_n(SCAE_hf(17:37),z200_sea(:,17:37,:,:),0,1)
    do i = 0,5
       copy_VarCoords(z200_mon(0,:,:), rc(i,:,:))
       copy_VarCoords(z200_mon(0,:,:), cor(i,:,:))
       plotrc(i) = gsn_csm_contour_map(wks, rc(i,:,:), resrc)
       plotline(i) = gsn_csm_contour(wks, rc(i,:,:), resrc2)
       plotcor(i) = gsn_csm_contour(wks, cor(i,:,:), rescor)
       ;overlay(plotrc(i), plotline(i))
       overlay(plotrc(i), plotcor(i))
    end do
    resP@gsnPanelMainString = "Lead-lag regression 200Hpa SCAEI 1989-2009"
    ; gsn_panel(wks, plotrc, (/2,2,2,1/), resP)
    ; frame(wks)

   ;z500
   ;-----------------------------------------------------------
    resrc@cnMaxLevelValF = 30.
    resrc@cnMinLevelValF = -30.
    resrc@cnLevelSpacingF = 2. 

    rescor@cnLevels = (/-sig1,sig1/)
    scae_z500_rc1 = regCoef_n(SCAE_hf(0:15),z500_sea(:,0:15,:,:),0,1)
    scae_z500_cor1 = escorc_n(SCAE_hf(0:15),z500_sea(:,0:15,:,:),0,1)
    do i = 0,5
       copy_VarCoords(z500_mon(0,:,:), scae_z500_rc1(i,:,:))
       copy_VarCoords(z500_mon(0,:,:), scae_z500_cor1(i,:,:))
       plotrc(i) = gsn_csm_contour_map(wks, scae_z500_rc1(i,:,:), resrc)
       plotline(i) = gsn_csm_contour(wks, scae_z500_rc1(i,:,:), resrc2)
       plotcor(i) = gsn_csm_contour(wks, scae_z500_cor1(i,:,:), rescor)
       ;overlay(plotrc(i), plotline(i))
       overlay(plotrc(i), plotcor(i))
    end do
    resP@gsnPanelMainString = "Lead-lag regression 500Hpa SCAEI 1972-1987"
    ; gsn_panel(wks, plotrc, (/2,2,2,1/), resP)
    ; frame(wks)
    
    rescor@cnLevels = (/-sig2,sig2/)
    scae_z500_rc2 = regCoef_n(SCAE_hf(17:37),z500_sea(:,17:37,:,:),0,1)
    scae_z500_cor2 = escorc_n(SCAE_hf(17:37),z500_sea(:,17:37,:,:),0,1)
    do i = 0,5
       copy_VarCoords(z500_mon(0,:,:), scae_z500_rc2(i,:,:))
       copy_VarCoords(z500_mon(0,:,:), scae_z500_cor2(i,:,:))
       plotrc(i) = gsn_csm_contour_map(wks, scae_z500_rc2(i,:,:), resrc)
       plotline(i) = gsn_csm_contour(wks, scae_z500_rc2(i,:,:), resrc2)
       plotcor(i) = gsn_csm_contour(wks, scae_z500_cor2(i,:,:), rescor)
       ;overlay(plotrc(i), plotline(i))
       overlay(plotrc(i), plotcor(i))
    end do
    resP@gsnPanelMainString = "Lead-lag regression 500Hpa SCAEI 1989-2009"
    ; gsn_panel(wks, plotrc, (/2,2,2,1/), resP)
    ; frame(wks)

  ;SAT + UV850
  ;--------------------------------------------------------------------
    resrc@cnMaxLevelValF = 1.6
    resrc@cnMinLevelValF = -1.6
    resrc@cnLevelSpacingF = 0.2
    
    rescor@cnLevels = (/-sig1,sig1/)
    delete(rc)
    delete(cor)
    rc = regCoef_n(SCAE_hf(0:15),air_sea(:,0:15,:,:),0,1)
    cor = escorc_n(SCAE_hf(0:15),air_sea(:,0:15,:,:),0,1)
    rc_u = regCoef_n(SCAE_hf(0:15),u850_sea(:,0:15,:,:),0,1)
    rc_v = regCoef_n(SCAE_hf(0:15),v850_sea(:,0:15,:,:),0,1)

    do i = 0,5
       copy_VarCoords(air_mon(0,:,:), rc(i,:,:))
       copy_VarCoords(air_mon(0,:,:), cor(i,:,:))

       copy_VarCoords(u850_mon(0,:,:), rc_u(i,:,:))
       copy_VarCoords(v850_mon(0,:,:), rc_v(i,:,:))
       plotrc(i) = gsn_csm_contour_map(wks, rc(i,:,:), resrc)
       plotline(i) = gsn_csm_contour(wks, rc(i,:,:), resrc2)
       plotcor(i) = gsn_csm_contour(wks, cor(i,:,:), rescor)
       plotuv(i) = gsn_csm_vector(wks, rc_u(i,:,:), rc_v(i,:,:), resV)
       ;overlay(plotrc(i), plotline(i))
       overlay(plotrc(i), plotcor(i))
       overlay(plotrc(i), plotuv(i))
    end do
    resP@gsnPanelMainString = "Lead-lag reg SAT+Wind850 SCAEI 1972-1987"
    gsn_panel(wks, plotrc, (/2,2,2,1/), resP)
    frame(wks)

    rescor@cnLevels = (/-sig2,sig2/)
    delete(rc)
    delete(cor)
    delete(rc_u)
    delete(rc_v)
    rc = regCoef_n(SCAE_hf(17:37),air_sea(:,17:37,:,:),0,1)
    cor = escorc_n(SCAE_hf(17:37),air_sea(:,17:37,:,:),0,1)
    rc_u = regCoef_n(SCAE_hf(17:37),u850_sea(:,17:37,:,:),0,1)
    rc_v = regCoef_n(SCAE_hf(17:37),v850_sea(:,17:37,:,:),0,1)
    do i = 0,5
       copy_VarCoords(air_mon(0,:,:), rc(i,:,:))
       copy_VarCoords(air_mon(0,:,:), cor(i,:,:))

       copy_VarCoords(u850_mon(0,:,:), rc_u(i,:,:))
       copy_VarCoords(v850_mon(0,:,:), rc_v(i,:,:))
       plotrc(i) = gsn_csm_contour_map(wks, rc(i,:,:), resrc)
       plotline(i) = gsn_csm_contour(wks, rc(i,:,:), resrc2)
       plotcor(i) = gsn_csm_contour(wks, cor(i,:,:), rescor)
       plotuv(i) = gsn_csm_vector(wks, rc_u(i,:,:), rc_v(i,:,:), resV)
       ;overlay(plotrc(i), plotline(i))
       overlay(plotrc(i), plotcor(i))
       overlay(plotrc(i), plotuv(i))
    end do
    resP@gsnPanelMainString = "Lead-lag reg SAT+Wind850 SCAEI 1989-2009"
    ; gsn_panel(wks, plotrc, (/2,2,2,1/), resP)
    ; frame(wks)


  ;******SCAW******
    ; delete(rc)
    ; delete(cor)
    ; rc = regCoef(SCAW_hf(17:37),z200_sea(season|:,lat|:,lon|:,time|:))
    ; cor = escorc(SCAW_hf(17:37),z200_sea(season|:,lat|:,lon|:,time|:))
    ; ;200hPa
    ; do i = 0,5
    ;    copy_VarCoords(z200_mon(0,:,:), rc(i,:,:))
    ;    copy_VarCoords(z200_mon(0,:,:), cor(i,:,:))
    ;    plotrc(i) = gsn_csm_contour_map(wks, rc(i,:,:), resrc)
    ;    plotline(i) = gsn_csm_contour(wks, rc(i,:,:), resrc2)
    ;    plotcor(i) = gsn_csm_contour(wks, cor(i,:,:), rescor)
    ;    ;overlay(plotrc(i), plotline(i))
    ;    overlay(plotrc(i), plotcor(i))
    ; end do
    ; resP@gsnPanelMainString = "Lead-lag regression 200Hpa-SCAWI:1989-2009"
    ; gsn_panel(wks, plotrc, (/2,2,2,1/), resP)

    ; ;500hPa
    ; delete(rc)
    ; delete(cor)
    ; rc = regCoef(SCAE_hf(17:37),z500_sea(season|:,lat|:,lon|:,time|:))
    ; cor = escorc(SCAE_hf(17:37),z500_sea(season|:,lat|:,lon|:,time|:))
    ; do i = 0,5
    ;    copy_VarCoords(z500_mon(0,:,:), rc(i,:,:))
    ;    copy_VarCoords(z500_mon(0,:,:), cor(i,:,:))
    ;    plotrc(i) = gsn_csm_contour_map(wks, rc(i,:,:), resrc)
    ;    plotline(i) = gsn_csm_contour(wks, rc(i,:,:), resrc2)
    ;    plotcor(i) = gsn_csm_contour(wks, cor(i,:,:), rescor)
    ;    ;overlay(plotrc(i), plotline(i))
    ;    overlay(plotrc(i), plotcor(i))
    ; end do
    ; resP@gsnPanelMainString = "Lead-lag regression 500Hpa-SCAWI:1989-2009"
    ; gsn_panel(wks, plotrc, (/2,2,2,1/), resP)
 
    ; resrc2@cnMaxLevelValF = 24.
    ; resrc2@cnMinLevelValF = -24.
    resrc2@cnLevelSpacingF = 8. 

    resrc@cnMaxLevelValF = 1.6
    resrc@cnMinLevelValF = -1.6
    resrc@cnLevelSpacingF = 0.2
    resrc@mpMaxLonF = 240.

    opt = True
    opt@gsnShadeFillType = "color"
    opt@gsnShadeLow      = "red"
    opt@gsnShadeHigh     = "blue"

    rescor@cnLevels = (/-sig1,sig1/)
    rc   := regCoef_n(SCAE_hf(0:15),air_sea(:,0:15,:,:),0,1)
    cor  := escorc_n(SCAE_hf(0:15),air_sea(:,0:15,:,:),0,1)
    rc_u := regCoef_n(SCAE_hf(0:15),u850_sea(:,0:15,:,:),0,1)
    rc_v := regCoef_n(SCAE_hf(0:15),v850_sea(:,0:15,:,:),0,1)

    rc_uv = sqrt(rc_u^2 + rc_v^2)
    rc_u = mask(rc_u, rc_uv.gt.0.2, True)
    rc_v = mask(rc_v, rc_uv.gt.0.2, True)
    do i = 0,4
       copy_VarCoords(air_mon(0,:,:), rc(i,:,:))
       copy_VarCoords(air_mon(0,:,:), cor(i,:,:))
       copy_VarCoords(u850_mon(0,:,:), rc_u(i,:,:))
       copy_VarCoords(v850_mon(0,:,:), rc_v(i,:,:))

       plotrc(i) = gsn_csm_contour_map(wks, rc(i,:,:), resrc)
       plotline(i) = gsn_csm_contour(wks, scae_z500_rc1(i,:,:), resrc2)
    ;plotline(i) = ColorNegDashZeroPosContour(plotline(i), "red", "Transparent","blue")

       plotcor(i) = gsn_csm_contour(wks, cor(i,:,:), rescor)
       plotuv(i) = gsn_csm_vector(wks, rc_u(i,:,:), rc_v(i,:,:), resV)
       overlay(plotrc(i), plotline(i))
       overlay(plotrc(i), plotcor(i))
       overlay(plotrc(i), plotuv(i))
    end do

    rescor@cnLevels = (/-sig2,sig2/)
    delete(rc)
    delete(cor)
    rc = regCoef_n(SCAE_hf(17:37),air_sea(:,17:37,:,:),0,1)
    cor = escorc_n(SCAE_hf(17:37),air_sea(:,17:37,:,:),0,1)
    rc_u := regCoef_n(SCAE_hf(17:37),u850_sea(:,17:37,:,:),0,1)
    rc_v := regCoef_n(SCAE_hf(17:37),v850_sea(:,17:37,:,:),0,1)

    rc_uv := sqrt(rc_u^2 + rc_v^2)
    rc_u = mask(rc_u, rc_uv.gt.0.2, True)
    rc_v = mask(rc_v, rc_uv.gt.0.2, True)
    do i = 0,4
       copy_VarCoords(air_mon(0,:,:), rc(i,:,:))
       copy_VarCoords(air_mon(0,:,:), cor(i,:,:))
       copy_VarCoords(u850_mon(0,:,:), rc_u(i,:,:))
       copy_VarCoords(v850_mon(0,:,:), rc_v(i,:,:))
       plotrc2(i) = gsn_csm_contour_map(wks, rc(i,:,:), resrc)
       plotline2(i) = gsn_csm_contour(wks, scae_z500_rc2(i,:,:), resrc2)
    ;plotline2(i) = ColorNegDashZeroPosContour(plotline2(i), "red", "Transparent","blue")

       plotcor2(i) = gsn_csm_contour(wks, cor(i,:,:), rescor)
       plotuv2(i) = gsn_csm_vector(wks, rc_u(i,:,:), rc_v(i,:,:), resV)
       overlay(plotrc2(i), plotline2(i))
       overlay(plotrc2(i), plotcor2(i))
       overlay(plotrc2(i), plotuv2(i))
    end do

    plotfuck = new(10, graphic)
    do i = 0, 4
        plotfuck(i*2) = plotrc(i)
        plotfuck(i*2+1) = plotrc2(i)
    end do
    resP@gsnPanelRowSpec = False
    ;resP@gsnPanelRight = 0.5
    resP@gsnPanelMainString = " "
    strings := (/"a(-3)","b(-3)","c(-2)","d(-2)","e(-1)","f(-1)", \
                 "g(0)", "h(0)","i(+1)","j(+1)"/)
    resP@gsnPanelFigureStrings := strings
    gsn_panel(wks, plotfuck, (/5,2/), resP)

    frame(wks)



end