load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
;***
   begin
;*** ; P1:1972-1987,16a ; P2:1989-2009, 21a
    yrstrt =197201
    yrlast =200912

   ; yrstrt =197201
   ; yrlast =198712
    sig1 = 0.497   ; %95

   ; yrstrt =198901
   ; yrlast =200912
    sig2 = 0.433   ; %95

   latS     = -90.
   latN     = 90.
   lonL     = 0.
   lonR     = 360.

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

   cd = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"

   wks=gsn_open_wks("pdf", plotpath+"pc1_2p")
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
   ;cfnsfdata = addfile(cd+"cfnsf.sfc.mon.mean.nc", "r")

   pc1 = asciiread(indexpath+"pc1.txt", -1, "float")
   tele_index = asciiread(indexpath+"tele_index.nh.txt", -1, "string")
;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   year=ispan(1972, 2009, 1)

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)
   print(YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))

   air_mon = airdata->air(iStrt:iLast,:,:)
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

   snow_mon = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nswr_mam = month_to_season(nswr_mon, "MAM")

   nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nlwr_mam = month_to_season(nlwr_mon, "MAM")

   soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})
   soilw_mam = month_to_season(soilw_mon, "MAM")

   tcc_mon = tccdata->tcdc(iStrt:iLast,{latS:latN},{lonL:lonR})
   tcc_mam = month_to_season(tcc_mon, "MAM")
   
   ; cfnsf_mon = cfnsfdata->cfnsf(iStrt:iLast,{latS:latN},{lonL:lonR})
   ; cfnsf_mam = month_to_season(cfnsf_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   sst_mam = month_to_season(sst_mon, "MAM")

   ;Filter
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    pc1 = wgt_runave_Wrap(pc1, wgt, 0)
    ; air_mam = wgt_runave_n_Wrap(air_mam, wgt, 0, 0)
    ; slp_mam = wgt_runave_n_Wrap(slp_mam, wgt, 0, 0)
    ; u_mam = wgt_runave_n_Wrap(u_mam, wgt, 0, 0)
    ; v_mam = wgt_runave_n_Wrap(v_mam, wgt, 0, 0)
    snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
    sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)

  ;make sub datasets
   air_mam1   = air_mam(0:15,:,:)
   slp_mam1   = slp_mam(0:15,:,:)
   u_mam1     = u_mam(0:15,:,:)
   v_mam1     = v_mam(0:15,:,:)
   z500_mam1  = z500_mam(0:15,:,:)
   z200_mam1  = z200_mam(0:15,:,:)
   snow_mam1  = snow_mam(0:15,:,:)
   tcc_mam1   = tcc_mam(0:15,:,:)
   nswr_mam1  = nswr_mam(0:15,:,:)
   nlwr_mam1  = nlwr_mam(0:15,:,:)
   soilw_mam1 = soilw_mam(0:15,:,:)
   sst_mam1 = sst_mam(0:15,:,:)

   air_mam2   = air_mam(17:37,:,:)
   slp_mam2   = slp_mam(17:37,:,:)
   u_mam2     = u_mam(17:37,:,:)
   v_mam2     = v_mam(17:37,:,:)
   z500_mam2  = z500_mam(17:37,:,:)
   z200_mam2  = z200_mam(17:37,:,:)
   snow_mam2  = snow_mam(17:37,:,:)
   tcc_mam2   = tcc_mam(17:37,:,:)
   nswr_mam2  = nswr_mam(17:37,:,:)
   nlwr_mam2  = nlwr_mam(17:37,:,:)
   soilw_mam2 = soilw_mam(17:37,:,:)
   sst_mam2 = sst_mam(17:37,:,:)
   ;
   ;P1
   pc_sat_rc1    = regCoef(pc1(2:17),air_mam1(lat|:,lon|:,time|:))
   pc_sat_cor1   =  escorc(pc1(2:17),air_mam1(lat|:,lon|:,time|:))
   pc_slp_rc1    = regCoef(pc1(2:17),slp_mam1(lat|:,lon|:,time|:))
   pc_slp_cor1   =  escorc(pc1(2:17),slp_mam1(lat|:,lon|:,time|:))
   pc_z500_rc1   = regCoef(pc1(2:17),z500_mam1(lat|:,lon|:,time|:))
   pc_z500_cor1  =  escorc(pc1(2:17),z500_mam1(lat|:,lon|:,time|:))
   pc_z200_rc1   = regCoef(pc1(2:17),z200_mam1(lat|:,lon|:,time|:))
   pc_z200_cor1  =  escorc(pc1(2:17),z200_mam1(lat|:,lon|:,time|:))
   pc_u_rc1      = regCoef(pc1(2:17),u_mam1(lat|:,lon|:,time|:))
   pc_u_cor1     =  escorc(pc1(2:17),u_mam1(lat|:,lon|:,time|:))
   pc_v_rc1      = regCoef(pc1(2:17),v_mam1(lat|:,lon|:,time|:))
   pc_v_cor1     =  escorc(pc1(2:17),v_mam1(lat|:,lon|:,time|:))
   pc_tcc_rc1    = regCoef(pc1(2:17),tcc_mam1(lat|:,lon|:,time|:))
   pc_tcc_cor1   =  escorc(pc1(2:17),tcc_mam1(lat|:,lon|:,time|:))
   ; pc_cfnsf_rc1  = regCoef(pc1(2:17),cfnsf_mam1(lat|:,lon|:,time|:))
   ; pc_cfnsf_cor1 =  escorc(pc1(2:17),cfnsf_mam1(lat|:,lon|:,time|:))
   ; pc_nswr_rc1   = regCoef(pc1(2:17),nswr_mam1(lat|:,lon|:,time|:))
   ; pc_nswr_cor1  =  escorc(pc1(2:17),nswr_mam1(lat|:,lon|:,time|:))
   ; pc_nlwr_rc1   = regCoef(pc1(2:17),nlwr_mam1(lat|:,lon|:,time|:))
   ; pc_nlwr_cor1  =  escorc(pc1(2:17),nlwr_mam1(lat|:,lon|:,time|:))
   ; pc_soilw_rc1  = regCoef(pc1(2:17),soilw_mam1(lat|:,lon|:,time|:))
   ; pc_soilw_cor1 =  escorc(pc1(2:17),soilw_mam1(lat|:,lon|:,time|:))
   pc_sst_rc1    = regCoef(pc1(2:17),sst_mam1(lat|:,lon|:,time|:))
   pc_sst_cor1    = escorc(pc1(2:17),sst_mam1(lat|:,lon|:,time|:))
   
   ;P2
   pc_sat_rc2   = regCoef(pc1(19:39),air_mam2(lat|:,lon|:,time|:))
   pc_sat_cor2  = escorc(pc1(19:39),air_mam2(lat|:,lon|:,time|:))
   pc_slp_rc2   = regCoef(pc1(19:39),slp_mam2(lat|:,lon|:,time|:))
   pc_slp_cor2  = escorc(pc1(19:39),slp_mam2(lat|:,lon|:,time|:))
   pc_z500_rc2  = regCoef(pc1(19:39),z500_mam2(lat|:,lon|:,time|:))
   pc_z500_cor2 = escorc(pc1(19:39),z500_mam2(lat|:,lon|:,time|:))
   pc_z200_rc2  = regCoef(pc1(19:39),z200_mam2(lat|:,lon|:,time|:))
   pc_z200_cor2 = escorc(pc1(19:39),z200_mam2(lat|:,lon|:,time|:))
   pc_u_rc2     = regCoef(pc1(19:39),u_mam2(lat|:,lon|:,time|:))
   pc_u_cor2    = escorc(pc1(19:39),u_mam2(lat|:,lon|:,time|:))
   pc_v_rc2     = regCoef(pc1(19:39),v_mam2(lat|:,lon|:,time|:))
   pc_v_cor2    = escorc(pc1(19:39),v_mam2(lat|:,lon|:,time|:))
   pc_tcc_rc2   = regCoef(pc1(19:39),tcc_mam2(lat|:,lon|:,time|:))
   pc_tcc_cor2  =  escorc(pc1(19:39),tcc_mam2(lat|:,lon|:,time|:))
   ; pc_cfnsf_rc2   = regCoef(pc1(19:39),cfnsf_mam2(lat|:,lon|:,time|:))
   ; pc_cfnsf_cor2  =  escorc(pc1(19:39),cfnsf_mam2(lat|:,lon|:,time|:))
   ; pc_nswr_rc2   = regCoef(pc1(19:39),nswr_mam2(lat|:,lon|:,time|:))
   ; pc_nswr_cor2  =  escorc(pc1(19:39),nswr_mam2(lat|:,lon|:,time|:))
   ; pc_nlwr_rc2   = regCoef(pc1(19:39),nlwr_mam2(lat|:,lon|:,time|:))
   ; pc_nlwr_cor2  =  escorc(pc1(19:39),nlwr_mam2(lat|:,lon|:,time|:))
   ; pc_soilw_rc2  = regCoef(pc1(19:39),soilw_mam2(lat|:,lon|:,time|:))
   ; pc_soilw_cor2 =  escorc(pc1(19:39),soilw_mam2(lat|:,lon|:,time|:))
   pc_sst_rc2    = regCoef(pc1(19:39),sst_mam2(lat|:,lon|:,time|:))
   pc_sst_cor2    = escorc(pc1(19:39),sst_mam2(lat|:,lon|:,time|:))

  ;p1
   pc_sce_rc1 = 100*regCoef(pc1(2:17),snow_mam1(lat|:,lon|:,time|:))
   pc_sce_cor1 = escorc(pc1(2:17),snow_mam1(lat|:,lon|:,time|:))
  ;p2
   pc_sce_rc2 = 100*regCoef(pc1(19:39),snow_mam2(lat|:,lon|:,time|:))
   pc_sce_cor2 = escorc(pc1(19:39),snow_mam2(lat|:,lon|:,time|:))

   copy_VarCoords(air_mam(0,:,:), pc_sat_rc1)
   copy_VarCoords(air_mam(0,:,:), pc_sat_cor1)
   copy_VarCoords(slp_mam(0,:,:), pc_slp_rc1)
   copy_VarCoords(slp_mam(0,:,:), pc_slp_cor1)
   copy_VarCoords(z500_mam(0,:,:), pc_z500_rc1)
   copy_VarCoords(z500_mam(0,:,:), pc_z500_cor1)
   copy_VarCoords(z200_mam(0,:,:), pc_z200_rc1)
   copy_VarCoords(z200_mam(0,:,:), pc_z200_cor1)
   copy_VarCoords(u_mam(0,:,:), pc_u_rc1)
   copy_VarCoords(v_mam(0,:,:), pc_v_rc1)
   copy_VarCoords(tcc_mam(0,:,:), pc_tcc_rc1)
   copy_VarCoords(tcc_mam(0,:,:), pc_tcc_cor1)
   ; copy_VarCoords(cfnsf_mam(0,:,:), pc_cfnsf_rc1)
   ; copy_VarCoords(cfnsf_mam(0,:,:), pc_cfnsf_cor1)
   ; copy_VarCoords(nswr_mam(0,:,:), pc_nswr_rc1)
   ; copy_VarCoords(nswr_mam(0,:,:), pc_nswr_cor1)
   ; copy_VarCoords(nlwr_mam(0,:,:), pc_nlwr_rc1)
   ; copy_VarCoords(nlwr_mam(0,:,:), pc_nlwr_cor1)

   copy_VarCoords(air_mam(0,:,:), pc_sat_rc2)
   copy_VarCoords(air_mam(0,:,:), pc_sat_cor2)
   copy_VarCoords(slp_mam(0,:,:), pc_slp_rc2)
   copy_VarCoords(slp_mam(0,:,:), pc_slp_cor2)
   copy_VarCoords(z500_mam(0,:,:), pc_z500_rc2)
   copy_VarCoords(z500_mam(0,:,:), pc_z500_cor2)
   copy_VarCoords(z200_mam(0,:,:), pc_z200_rc2)
   copy_VarCoords(z200_mam(0,:,:), pc_z200_cor2)
   copy_VarCoords(u_mam(0,:,:), pc_u_rc2)
   copy_VarCoords(v_mam(0,:,:), pc_v_rc2)
   copy_VarCoords(tcc_mam(0,:,:), pc_tcc_rc2)
   copy_VarCoords(tcc_mam(0,:,:), pc_tcc_cor2)
   ; copy_VarCoords(cfnsf_mam(0,:,:), pc_cfnsf_rc2)
   ; copy_VarCoords(cfnsf_mam(0,:,:), pc_cfnsf_cor2)
   ; copy_VarCoords(nswr_mam(0,:,:), pc_nswr_rc2)
   ; copy_VarCoords(nswr_mam(0,:,:), pc_nswr_cor2)
   ; copy_VarCoords(nlwr_mam(0,:,:), pc_nlwr_rc2)
   ; copy_VarCoords(nlwr_mam(0,:,:), pc_nlwr_cor2)
   ; copy_VarCoords(soilw_mam(0,:,:), pc_soilw_rc1)
   ; copy_VarCoords(soilw_mam(0,:,:), pc_soilw_rc2)
   ; copy_VarCoords(soilw_mam(0,:,:), pc_soilw_cor1)
   ; copy_VarCoords(soilw_mam(0,:,:), pc_soilw_cor2)

   copy_VarCoords(snow_mam(0,:,:), pc_sce_rc1)
   copy_VarCoords(snow_mam(0,:,:), pc_sce_cor1)
   copy_VarCoords(snow_mam(0,:,:), pc_sce_rc2)
   copy_VarCoords(snow_mam(0,:,:), pc_sce_cor2)
   copy_VarCoords(sst_mam(0,:,:), pc_sst_rc1)
   copy_VarCoords(sst_mam(0,:,:), pc_sst_cor1)
   copy_VarCoords(sst_mam(0,:,:), pc_sst_rc2)
   copy_VarCoords(sst_mam(0,:,:), pc_sst_cor2)

;*******************************************************
  ;Resources Settings
   res = True
   res@gsnDraw = False
   res@gsnFrame = False   

   resrc = res
   ;resrc@cnFillPalette = "BlueWhiteOrangeRed"
   resrc@gsnDraw = False
   resrc@gsnFrame = False
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@mpFillOn = False
   resrc@mpCenterLonF = 180.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.   
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.13

   resSST = resrc
   resSST@mpMinLonF = -70.
   resSST@mpMaxLonF = 30.
   resSST@mpMaxLatF = 90.
   resSST@mpMinLatF = -10.
   resSST@mpCenterLonF = 0.

   ressnow = resrc
   ressnow@lbLabelBarOn = False
   ressnow@mpMinLonF = 1
   ressnow@mpMaxLonF = 150
   ressnow@mpMaxLatF = 80
   ressnow@mpMinLatF = 20
   ressnow@mpCenterLonF = 90.
   ressnow@cnMinLevelValF = -1.
   ressnow@cnMaxLevelValF = 1.
   ressnow@cnLevelSpacingF = 0.1
   
  ;For Contour Lines
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

   ;Vector res setting
   resV = True
   resV@gsnDraw = False
   resV@gsnFrame = False
   resV@vcRefMagnitudeF = 1.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.56
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.0               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

    resP                 = True                 ; panel resources
    ;resP@txString        = "Moving T-test of PCs"  ; add center string
    ;resP@gsnPanelLabelBar    = True            ; add common colorbar
    resP@lbLabelAutoStride   = True
    resP@gsnMaximize         = False
    ;resP@gsnPanelFigureStrings = (/"PC1","PC2","PC3"/)
    resP@gsnPanelFigureStringsFontHeightF = 0.01
    resP@gsnPanelFigureStringsPerimOn = False
    resP@amJust = "TopRight"
    ; resP@gsnPanelYWhiteSpacePercent = 5
    ; resP@gsnPanelXWhiteSpacePercent = 5

   ; Polyline Setting
   Wxpts = (/WlonL, WlonL, WlonR, WlonR, WlonL/)
   Wypts = (/WlatS, WlatN, WlatN, WlatS, WlatS/)

   Cxpts = (/ClonL, ClonL, ClonR, ClonR, ClonL/)
   Cypts = (/ClatS, ClatN, ClatN, ClatS, ClatS/)

   Expts = (/ElonL, ElonL, ElonR, ElonR, ElonL/)
   Eypts = (/ElatS, ElatN, ElatN, ElatS, ElatS/)

   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 2.0
   ;plres@gsLineLabelString = "sce"

   dum1 = new(dimsizes(Wxpts)-1, graphic)
   dum2 = new(dimsizes(Cxpts)-1, graphic)
   dum3 = new(dimsizes(Expts)-1, graphic)
   dum11 = new(dimsizes(Wxpts)-1, graphic)
   dum22 = new(dimsizes(Cxpts)-1, graphic)
   dum33 = new(dimsizes(Expts)-1, graphic)

   snowpc = new(2,"graphic")
   sstpc = new(2, "graphic")
;*************************************
;P1
;*************************************
   rescor@cnLevels = (/-sig1,sig1/)

   resrc@cnMinLevelValF = -2.0
   resrc@cnMaxLevelValF = 2.0
   resrc@cnLevelSpacingF = 0.1
   resrc@gsnLeftString = "(a) PC1:P1 SAT+Wind(850hpa)"
   airrc1 = gsn_csm_contour_map(wks, pc_sat_rc1, resrc)
   aircor = gsn_csm_contour(wks, pc_sat_cor1, rescor)
   windrc = gsn_csm_vector(wks, pc_u_rc1, pc_v_rc1, resV)
   overlay(airrc1, windrc)
   overlay(airrc1, aircor)

   resrc@cnMinLevelValF = -36.
   resrc@cnMaxLevelValF = 36.
   resrc@cnLevelSpacingF = 2
   resrc@gsnLeftString = "(c) PC1:P1 Z500"
   z500rc1 = gsn_csm_contour_map(wks, pc_z500_rc1, resrc)
   z500line1 = gsn_csm_contour(wks, pc_z500_rc1, resrc2)
   z500cor1 = gsn_csm_contour(wks, pc_z500_cor1, rescor)
   overlay(z500rc1, z500line1)
   overlay(z500rc1, z500cor1)

   resrc@cnMinLevelValF = -10.
   resrc@cnMaxLevelValF = 10.
   resrc@cnLevelSpacingF = 1.
   resrc@gsnLeftString = "PC1:P1 Total Cloud Cover"
   tccrc = gsn_csm_contour_map(wks, pc_tcc_rc1, resrc)
   tcccor = gsn_csm_contour(wks, pc_tcc_cor1, rescor)
   overlay(tccrc, tcccor)
   draw(tccrc)
   frame(wks)

   ; resrc@gsnLeftString = "PC1_hf:P1 nswr"
   ; tccrc = gsn_csm_contour_map(wks, pc_nswr_rc1, resrc)
   ; tcccor = gsn_csm_contour(wks, pc_nswr_cor1, rescor)
   ; overlay(tccrc, tcccor)
   ; draw(tccrc)
   ; frame(wks)

   ; resrc@gsnLeftString = "PC1_hf:P1 nlwr"
   ; tccrc = gsn_csm_contour_map(wks, pc_nlwr_rc1, resrc)
   ; tcccor = gsn_csm_contour(wks, pc_nlwr_cor1, rescor)
   ; overlay(tccrc, tcccor)
   ; draw(tccrc)
   ; frame(wks)

   ; resrc@gsnLeftString = "PC1_hf:P1 Cloud Forcing Net Solar Flux at Surface"
   ; cfnsfrc = gsn_csm_contour_map(wks, pc_cfnsf_rc1, resrc)
   ; cfnsfcor = gsn_csm_contour(wks, pc_cfnsf_cor1, rescor)
   ; overlay(cfnsfrc, cfnsfcor)
   ; draw(cfnsfrc)
   ; frame(wks)

   ; resrc@cnMinLevelValF = -50.
   ; resrc@cnMaxLevelValF = 50.
   ; resrc@cnLevelSpacingF = 2.
   ; resrc@gsnLeftString = "PC1_hf:P1 soil moisture"
   ; soilrc = gsn_csm_contour_map(wks, pc_soilw_rc1, resrc)
   ; soilcor = gsn_csm_contour(wks, pc_soilw_cor1, rescor)
   ; overlay(soilrc, soilcor)
   ; draw(soilrc)
   ; frame(wks)

   resrc@cnMinLevelValF = -4.
   resrc@cnMaxLevelValF = 4.
   resrc@cnLevelSpacingF = 0.2
   resrc@gsnLeftString = "PC1:P1 SLP"
   slprc1 = gsn_csm_contour_map(wks, pc_slp_rc1, resrc)
   slpcor = gsn_csm_contour(wks, pc_slp_cor1, rescor)
   line = gsn_csm_contour(wks, pc_slp_rc1, resrc2)
   overlay(slprc1, line)
   overlay(slprc1, slpcor)
   draw(slprc1)
   frame(wks)

   resSST@cnMinLevelValF = -0.6
   resSST@cnMaxLevelValF = 0.6
   resSST@cnLevelSpacingF = 0.1
   resSST@gsnLeftString = "PC1:P1 SST"
   plotcn = gsn_csm_contour_map(wks, pc_sst_rc1, resSST)
   plotsig = gsn_csm_contour(wks, pc_sst_cor1, rescor)
   overlay(plotcn, plotsig)
   draw(plotcn)
   frame(wks)
   sstpc(0) = plotcn

;*************************************
;P2
;*************************************
   rescor@cnLevels = (/-sig2,sig2/)

   resrc@cnMinLevelValF = -2.0
   resrc@cnMaxLevelValF = 2.0
   resrc@cnLevelSpacingF = 0.1
   resrc@gsnLeftString = "(b) PC1:P2 SAT+Wind(850hpa)"
   airrc2 = gsn_csm_contour_map(wks, pc_sat_rc2, resrc)
   aircor = gsn_csm_contour(wks, pc_sat_cor2, rescor)
   windrc = gsn_csm_vector(wks, pc_u_rc2, pc_v_rc2, resV)
   overlay(airrc2, windrc)
   overlay(airrc2, aircor)

   resrc@cnMinLevelValF = -36.
   resrc@cnMaxLevelValF = 36.
   resrc@cnLevelSpacingF = 2
   resrc@gsnLeftString = "(d) PC1:P2 Z500"
   z500rc2 = gsn_csm_contour_map(wks, pc_z500_rc2, resrc)
   z500line2 = gsn_csm_contour(wks, pc_z500_rc2, resrc2)
   z500cor2 = gsn_csm_contour(wks, pc_z500_cor2, rescor)
   overlay(z500rc2, z500line2)
   overlay(z500rc2, z500cor2)  

   resrc@cnMinLevelValF = -4.
   resrc@cnMaxLevelValF = 4.
   resrc@cnLevelSpacingF = 0.2
   resrc@gsnLeftString = "PC1:P2 SLP"
   slprc2 = gsn_csm_contour_map(wks, pc_slp_rc2, resrc)
   slpcor = gsn_csm_contour(wks, pc_slp_cor2, rescor)
   line = gsn_csm_contour(wks, pc_slp_rc2, resrc2)
   overlay(slprc2, line)
   overlay(slprc2, slpcor)
   draw(slprc2)
   frame(wks)  

   resrc@cnMinLevelValF = -10.
   resrc@cnMaxLevelValF = 10.
   resrc@cnLevelSpacingF = 1.
   resrc@gsnLeftString = "PC1:P2 Total Cloud Cover"
   tccrc = gsn_csm_contour_map(wks, pc_tcc_rc2, resrc)
   tcccor = gsn_csm_contour(wks, pc_tcc_cor2, rescor)
   overlay(tccrc, tcccor)
   draw(tccrc)
   frame(wks)

   ; resrc@gsnLeftString = "PC1_hf:P2 nswr"
   ; tccrc = gsn_csm_contour_map(wks, pc_nswr_rc2, resrc)
   ; tcccor = gsn_csm_contour(wks, pc_nswr_cor2, rescor)
   ; overlay(tccrc, tcccor)
   ; draw(tccrc)
   ; frame(wks)

   ; resrc@gsnLeftString = "PC1_hf:P2 nlwr"
   ; tccrc = gsn_csm_contour_map(wks, pc_nlwr_rc2, resrc)
   ; tcccor = gsn_csm_contour(wks, pc_nlwr_cor2, rescor)
   ; overlay(tccrc, tcccor)
   ; draw(tccrc)
   ; frame(wks)

   ; resrc@gsnLeftString = "PC1_hf:P2 Cloud Forcing Net Solar Flux at Surface"
   ; cfnsfrc = gsn_csm_contour_map(wks, pc_cfnsf_rc2, resrc)
   ; cfnsfcor = gsn_csm_contour(wks, pc_cfnsf_cor2, rescor)
   ; overlay(cfnsfrc, cfnsfcor)
   ; draw(cfnsfrc)
   ; frame(wks)

   ; resrc@cnMinLevelValF = -50.
   ; resrc@cnMaxLevelValF = 50.
   ; resrc@cnLevelSpacingF = 2.
   ; resrc@gsnLeftString = "PC1_hf:P2 soil moisture"
   ; soilrc = gsn_csm_contour_map(wks, pc_soilw_rc2, resrc)
   ; soilcor = gsn_csm_contour(wks, pc_soilw_cor2, rescor)
   ; overlay(soilrc, soilcor)
   ; draw(soilrc)
   ; frame(wks)

   resSST@gsnLeftString = "PC1:P2 SST"
   plotcn = gsn_csm_contour_map(wks, pc_sst_rc2, resSST)
   plotsig = gsn_csm_contour(wks, pc_sst_cor2, rescor)
   overlay(plotcn, plotsig)
   draw(plotcn)
   frame(wks)
   sstpc(1) = plotcn

   ;
   rescor@cnLevels = (/-sig1,sig1/)
   ressnow@gsnLeftString = "(a) PC1:P1 SCE MAM "
   snowrc = gsn_csm_contour_map(wks, pc_sce_cor1, ressnow)
   snowcor = gsn_csm_contour(wks, pc_sce_cor1, rescor)
   overlay(snowrc, snowcor)
   ;add polyline 
    do i = 0, dimsizes(Wxpts)-2
        dum1(i) = gsn_add_polyline(wks, snowrc, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    ; do i = 0, dimsizes(Expts)-2
    ;     dum2(i) = gsn_add_polyline(wks, snowrc, Cxpts(i:i+1), Cypts(i:i+1), plres)
    ; end do
    do i = 0, dimsizes(Expts)-2
        dum3(i) = gsn_add_polyline(wks, snowrc, Expts(i:i+1), Eypts(i:i+1), plres)
    end do

   rescor@cnLevels = (/-sig2,sig2/)
   ressnow@gsnLeftString = "(b) PC1:P2 SCE MAM"
   snowrc2 = gsn_csm_contour_map(wks, pc_sce_cor2, ressnow)
   snowcor2 = gsn_csm_contour(wks, pc_sce_cor2, rescor)
   overlay(snowrc2, snowcor2)
   ;add polyline 
    do i = 0, dimsizes(Wxpts)-2
        dum11(i) = gsn_add_polyline(wks, snowrc2, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    ; do i = 0, dimsizes(Cxpts)-2
    ;     dum22(i) = gsn_add_polyline(wks, snowrc2, Cxpts(i:i+1), Cypts(i:i+1), plres)
    ; end do
    do i = 0, dimsizes(Expts)-2
        dum33(i) = gsn_add_polyline(wks, snowrc2, Expts(i:i+1), Eypts(i:i+1), plres)
    end do

   gsn_panel(wks, sstpc, (/1,2/), resP)

   satslpP = new(4,"graphic")
   satslpP(0) = airrc1
   satslpP(2) = slprc1
   satslpP(1) = airrc2
   satslpP(3) = slprc2
   ;gsn_panel(wks, satslpP, , resP)

   satgph = new(4,"graphic")
   satgph(0) = airrc1
   satgph(2) = z500rc1
   satgph(1) = airrc2
   satgph(3) = z500rc2  
   gsn_panel(wks, satgph, (/2,2/), resP)  

   snowpc(0) = snowrc
   snowpc(1) = snowrc2
   resP@gsnPanelLabelBar = True
   resP@gsnPanelYWhiteSpacePercent = 7
   resP@pmLabelBarWidthF = 0.6
   gsn_panel(wks, snowpc, (/2,1/), resP)

  end