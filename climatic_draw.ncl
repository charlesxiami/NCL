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

  sig1 = 0.497   ; %95
  sig2 = 0.433   ; %95

   nceppath  = "/public/home/charlesxiami/data/ncep/"
   plotpath  = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"

   wks=gsn_open_wks("pdf", plotpath+"climatic_draw")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;***********************************************
;************************************************
   filesnow = "/public/home/charlesxiami/data/snow/snow.nc"
   snowdata = addfile(filesnow,"r")
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
  uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
  vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.v4.nc", "r")
 soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")

   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata  = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata  = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")

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

   nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nswr_mam = month_to_season(nswr_mon, "MAM")

   nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nlwr_mam = month_to_season(nlwr_mon, "MAM")

   lhf_mon = lhfdata->lhtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   lhf_mam = month_to_season(lhf_mon, "MAM")

   shf_mon = shfdata->shtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   shf_mam = month_to_season(shf_mon, "MAM")

   soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})
   soilw_mam = month_to_season(soilw_mon, "MAM")

   snow_mon  = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   tcc_mon = tccdata->tcdc(iStrt:iLast,{latS:latN},{lonL:lonR})
   tcc_mam = month_to_season(tcc_mon, "MAM")
   
   ; cfnsf_mon = cfnsfdata->cfnsf(iStrt:iLast,{latS:latN},{lonL:lonR})
   ; cfnsf_mam = month_to_season(cfnsf_mon, "MAM")

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
   SCAC = wgt_areaave_Wrap(Cregion, 1.0, 1.0, 1)
   SCAE = wgt_areaave_Wrap(Eregion, 1.0, 1.0, 1)
   SCAW = dim_standardize_Wrap(SCAW, 0)
   SCAC = dim_standardize_Wrap(SCAC, 0)
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
    SCAC_hf = wgt_runave_Wrap(SCAC, wgt, 0)
    SCAE_hf = wgt_runave_Wrap(SCAE, wgt, 0)
   ;Reserve AI and BI 
    SCAW_hf = -1*SCAW_hf
    SCAC_hf = -1*SCAC_hf
    SCAE_hf = -1*SCAE_hf

   ;*************************************************
   snow_mam1 = snow_mam(0:15,:,:)
   air_mam1  = air_mam(0:15,:,:)
   slp_mam1  = slp_mam(0:15,:,:)
   u_mam1    = u_mam(0:15,:,:)
   v_mam1    = v_mam(0:15,:,:)
   z500_mam1 = z500_mam(0:15,:,:)
   z200_mam1 = z200_mam(0:15,:,:)
   sst_mam1  = sst_mam(0:15,:,:)
   ;sst_mam_hf1  = sst_mam_hf(0:15,:,:)
   tcc_mam1  = tcc_mam(0:15,:,:)
   soilw_mam1 = soilw_mam(0:15,:,:)
   nswr_mam1 = nswr_mam(0:15,:,:)
   nlwr_mam1 = nlwr_mam(0:15,:,:)
   nswr_mam1 = nswr_mam(0:15,:,:)
   nlwr_mam1 = nlwr_mam(0:15,:,:)
   lhf_mam1 = lhf_mam(0:15,:,:)
   shf_mam1 = shf_mam(0:15,:,:)

   snow_mam2 = snow_mam(17:37,:,:)
   air_mam2  = air_mam(17:37,:,:)
   slp_mam2  = slp_mam(17:37,:,:)
   u_mam2    = u_mam(17:37,:,:)
   v_mam2    = v_mam(17:37,:,:)
   z500_mam2 = z500_mam(17:37,:,:)
   z200_mam2 = z200_mam(17:37,:,:)
   sst_mam2  = sst_mam(17:37,:,:)
   ;sst_mam_hf2  = sst_mam_hf(17:37,:,:)
   tcc_mam2  = tcc_mam(17:37,:,:)
   soilw_mam2 = soilw_mam(17:37,:,:)
   nswr_mam2 = nswr_mam(17:37,:,:)
   nlwr_mam2 = nlwr_mam(17:37,:,:)
   lhf_mam2 = lhf_mam(17:37,:,:)
   shf_mam2 = shf_mam(17:37,:,:)
;***************************************************
   nswr_mam_clim = dim_avg_n_Wrap(nswr_mam, 0)
   nlwr_mam_clim = dim_avg_n_Wrap(nlwr_mam, 0)
   lhf_mam_clim = dim_avg_n_Wrap(lhf_mam, 0)
   shf_mam_clim = dim_avg_n_Wrap(shf_mam, 0)

   nhf_mam_clim = nswr_mam_clim + nlwr_mam_clim + lhf_mam_clim + shf_mam_clim
   copy_VarCoords(nswr_mam_clim, nhf_mam_clim)

   printMinMax(nswr_mam_clim, 0)
   printMinMax(nlwr_mam_clim, 0)
   printMinMax(lhf_mam_clim, 0)
   printMinMax(shf_mam_clim, 0)

;********************************************************
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
   resrc@pmLabelBarOrthogonalPosF = 0.08
   resrc@gsnStringFontHeightF = 0.03

   ressnow = resrc
   ressnow@mpMinLatF = 20.
   ressnow@mpMaxLatF = 80.
   ressnow@mpMinLonF = 10.
   ressnow@mpMaxLonF = 150.
   ressnow@mpCenterLonF = 80.
   ressnow@lbLabelBarOn = True

   ressoil = resrc
   ressoil@mpMaxLonF = 150.
   ressoil@mpMaxLatF = 80.
   ressoil@mpMinLatF = 10.

   resSST = resrc
   resSST@mpMaxLonF = 10.
   resSST@mpMinLonF = -80.
   resSST@mpMaxLatF = 80.
   resSST@mpMinLatF = -10.
   resSST@mpCenterLonF = 0.

   resHF = resrc
   resHF@mpMinLonF = 0.
   resHF@mpMaxLonF = 360.
   resHF@mpMaxLatF = 90.
   resHF@mpMinLatF = 0.
   resHF@mpCenterLonF = 180.
   resHF@cnLevelSelectionMode = "AutomaticLevels"
   resHF@pmLabelBarOrthogonalPosF = 0.18

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
   resP@gsnPanelLabelBar = False
   resP@gsnPanelRowSpec = True
   resP@gsnPanelCenter = True

;**************************************************
;P1 
;**************************************************
   resHF@gsnLeftString = "SWR MAM Clim"
   Pswr = gsn_csm_contour_map(wks, nswr_mam_clim, resHF)

   resHF@gsnLeftString = "LWR MAM Clim"
   Plwr = gsn_csm_contour_map(wks, nlwr_mam_clim, resHF)
   
   resHF@gsnLeftString = "LHF MAM Clim"
   Plhf = gsn_csm_contour_map(wks, lhf_mam_clim, resHF)
   
   resHF@gsnLeftString = "SHF MAM Clim"
   Pshf = gsn_csm_contour_map(wks, shf_mam_clim, resHF)
   
   resHF@gsnLeftString = "NHF MAM Clim"
   Pnhf = gsn_csm_contour_map(wks, nhf_mam_clim, resHF)

   E_HF = new(5, "graphic")
   E_HF(0) = Pnhf
   E_HF(1) = Pswr
   E_HF(2) = Plwr
   E_HF(3) = Plhf
   E_HF(4) = Pshf
   gsn_panel(wks, E_HF, (/1,2,2/), resP)




end
