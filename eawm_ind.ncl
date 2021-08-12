;***
   begin
;***
   yrstrt_short = 197901
   yrlast_short = 201812

   yrstrt_era40 = 195801
   yrlast_era40 = 200112

   ; yrstrt_long = 195801
   ; yrlast_long = 201812
   yrstrt_long = 197901
   yrlast_long = 201812

   latS = -90
   latN = 90
   lonL = 0
   lonR = 360

   eawm_def1_s = 40
   eawm_def1_n = 60
   eawm_def1_w = 70
   eawm_def1_e = 120

   eawm_def2_s = 30
   eawm_def2_n = 50
   eawm_def2_w = 140
   eawm_def2_e = 190

   eawm_def3_s = -20
   eawm_def3_n = 10
   eawm_def3_w = 110
   eawm_def3_e = 160

   ea_def_s = 20
   ea_def_n = 50
   ea_def_w = 100
   ea_def_e = 140

   ; t = ispan(yrstrt/100, yrlast/100, 1)

;*********************************************** 
   nceppath = "$HOME/data/ncep/"
   ncep2path = "$HOME/data/ncep2/"
   ecpath = "$HOME/data/ecmwf/"
   indexpath = "$HOME/data/index/"
   plotpath = "$HOME/output/"
;********************************************
   wks_type          = "pdf"
   ;wks_type@wkOrientation = "landscape"
   ; wks_type@wkPaperHeightF = 11
   ; wks_type@wkPaperWidthF  = 8.5
   wks_type@wkPaperSize = "A4"

   wks = gsn_open_wks(wks_type, plotpath+"eawm_ind")
;************************************************
   slpdata_ncep1 = addfile(nceppath+"slp.mon.mean.nc", "r")
   satdata_ncep1 = addfile(nceppath+"air.mon.mean.nc", "r")

   slpdata_ncep2 = addfile(ncep2path+"mslp.mon.mean.nc", "r")
   satdata_ncep2 = addfile(ncep2path+"air.2m.mon.mean.nc", "r")

   slpdata_eraint = addfile(ecpath+"era_interim/msl.nc", "r")
   satdata_eraint = addfile(ecpath+"era_interim/t2m.nc", "r")

   ; slpdata_era40 = addfile(ecpath+"era40/era40.msl.1957sep-2002aug.nc", "r")
   ; satdata_era40 = addfile(ecpath+"era40/era40.t2m.1957sep-2002aug.nc", "r")

;****************************************************
   YYYYMM_ncep1 = cd_calendar(slpdata_ncep1->time, 1)
   iStrt_ncep1  = ind(YYYYMM_ncep1.eq.yrstrt_long)
   iLast_ncep1  = ind(YYYYMM_ncep1.eq.yrlast_long)
   print("ncep1 time: "+YYYYMM_ncep1(iStrt_ncep1)+"--"+YYYYMM_ncep1(iLast_ncep1))

   YYYYMM_ncep2 = cd_calendar(slpdata_ncep2->time, 1)
   ; print(YYYYMM_ncep2)
   iStrt_ncep2  = ind(YYYYMM_ncep2.eq.yrstrt_short)
   iLast_ncep2  = ind(YYYYMM_ncep2.eq.yrlast_short)
   print("ncep2 time: "+YYYYMM_ncep2(iStrt_ncep2)+"--"+YYYYMM_ncep2(iLast_ncep2))

   YYYYMM_eraint = cd_calendar(slpdata_eraint->time, 1)
   iStrt_eraint  = ind(YYYYMM_eraint.eq.yrstrt_short)
   iLast_eraint  = ind(YYYYMM_eraint.eq.yrlast_short)
   print("eraint time: "+YYYYMM_eraint(iStrt_eraint)+"--"+YYYYMM_eraint(iLast_eraint))

   ; YYYYMM_era40 = cd_calendar(slpdata_era40->time, 1)
   ; iStrt_era40  = ind(YYYYMM_era40.eq.yrstrt_era40)
   ; iLast_era40  = ind(YYYYMM_era40.eq.yrlast_era40)
   ; print("era40 time: "+YYYYMM_era40(iStrt_era40)+"--"+YYYYMM_era40(iLast_era40))
;****************************************************
   slp_mon_ncep1 = slpdata_ncep1->slp(iStrt_ncep1:iLast_ncep1,{latS:latN},{lonL:lonR})
   sat_mon_ncep1 = satdata_ncep1->air(iStrt_ncep1:iLast_ncep1,{latS:latN},{lonL:lonR})

   slp_mon_ncep2 = short2flt(slpdata_ncep2->mslp(iStrt_ncep2:iLast_ncep2,{latS:latN},{lonL:lonR}))
   sat_mon_ncep2 = short2flt(satdata_ncep2->air(iStrt_ncep2:iLast_ncep2,0,{latS:latN},{lonL:lonR}))

   slp_mon_eraint = slpdata_eraint->msl(iStrt_eraint:iLast_eraint,{latS:latN},{lonL:lonR})
   sat_mon_eraint = satdata_eraint->t2m(iStrt_eraint:iLast_eraint,{latS:latN},{lonL:lonR})

   ; slp_mon_era40 = slpdata_era40->msl(iStrt_era40:iLast_era40,{latS:latN},{lonL:lonR})
   ; sat_mon_era40 = satdata_era40->t2m(iStrt_era40:iLast_era40,{latS:latN},{lonL:lonR})
;********************************************
; Filter 
;********************************************
   ; high frequence component 
    fca = 1.0/(12*10)
    fcb= -999.
    nsigma = 1.
    nwt= 31

   ; high frequency 
    ihp = 1
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    ; pdsi_nci_mon_hf = wgt_runave_Wrap(pdsi_nci_mon, wgt, 0)
   ;  ;air_mam = wgt_runave_n_Wrap(air_mam, wgt, 0, 0)


   ;low frequency
    ihp = 0  
    wgt_lf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    slp_mon_lf_ncep1 = wgt_runave_n_Wrap(slp_mon_ncep1, wgt_lf, 0, 0)
    sat_mon_lf_ncep1 = wgt_runave_n_Wrap(sat_mon_ncep1, wgt_lf, 0, 0)
    slp_mon_lf_ncep2 = wgt_runave_n_Wrap(slp_mon_ncep2, wgt_lf, 0, 0)
    sat_mon_lf_ncep2 = wgt_runave_n_Wrap(sat_mon_ncep2, wgt_lf, 0, 0)
    slp_mon_lf_eraint = wgt_runave_n_Wrap(slp_mon_eraint, wgt_lf, 0, 0)
    sat_mon_lf_eraint = wgt_runave_n_Wrap(sat_mon_eraint, wgt_lf, 0, 0)

    ; fca = 1.0/120.
    ; wgt_lf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    ; pdo_lf = wgt_runave_Wrap(pdo, wgt_lf, 0)
    ; pdo_lf_son = month_to_season(pdo_lf, "SON")
;***************************************************************************
;Season Mean
;***************************************************************************
   season = "DJF"

  ;All frequency
   slp_djf_ncep1 = month_to_season(slp_mon_ncep1, season)
   sat_djf_ncep1 = month_to_season(sat_mon_ncep1, season)

   slp_djf_ncep2 = month_to_season(slp_mon_ncep2, season)
   sat_djf_ncep2 = month_to_season(sat_mon_ncep2, season)
   
   slp_djf_eraint = month_to_season(slp_mon_eraint, season)
   sat_djf_eraint = month_to_season(sat_mon_eraint, season)

   ; slp_djf_era40 = month_to_season(slp_mon_era40, season)
   ; sat_djf_era40 = month_to_season(sat_mon_era40, season)

  ;Low frequency 
   slp_djf_lf_ncep1 = month_to_season(slp_mon_lf_ncep1, season)
   sat_djf_lf_ncep1 = month_to_season(sat_mon_lf_ncep1, season)

   slp_djf_lf_ncep2 = month_to_season(slp_mon_lf_ncep2, season)
   sat_djf_lf_ncep2 = month_to_season(sat_mon_lf_ncep2, season)
   
   slp_djf_lf_eraint = month_to_season(slp_mon_lf_eraint, season)
   sat_djf_lf_eraint = month_to_season(sat_mon_lf_eraint, season)
;***************************************************************************
;EAWM index
;***************************************************************************
  ;ncep1
  eawm_area1_ncep1 = wgt_areaave_Wrap(slp_djf_ncep1(:,{eawm_def1_s:eawm_def1_n},{eawm_def1_w:eawm_def1_e}), 1.0, 1.0, 1)
  eawm_area2_ncep1 = wgt_areaave_Wrap(slp_djf_ncep1(:,{eawm_def2_s:eawm_def2_n},{eawm_def2_w:eawm_def3_e}), 1.0, 1.0, 1)
  eawm_area3_ncep1 = wgt_areaave_Wrap(slp_djf_ncep1(:,{eawm_def3_s:eawm_def3_n},{eawm_def3_w:eawm_def3_e}), 1.0, 1.0, 1) 
  eawm_ind_ncep1 = eawm_area1_ncep1
  eawm_ind_ncep1 = (2*eawm_area1_ncep1 - eawm_area2_ncep1 - eawm_area3_ncep1)/2.0
  eawm_ind_ncep1 = dim_standardize_Wrap(eawm_ind_ncep1, 1)
  ; printMinMax(eawm_ind_ncep1, 0)

  ;ncep2
  eawm_area1_ncep2 = wgt_areaave_Wrap(slp_djf_ncep2(:,{eawm_def1_s:eawm_def1_n},{eawm_def1_w:eawm_def1_e}), 1.0, 1.0, 1)
  eawm_area2_ncep2 = wgt_areaave_Wrap(slp_djf_ncep2(:,{eawm_def2_s:eawm_def2_n},{eawm_def2_w:eawm_def3_e}), 1.0, 1.0, 1)
  eawm_area3_ncep2 = wgt_areaave_Wrap(slp_djf_ncep2(:,{eawm_def3_s:eawm_def3_n},{eawm_def3_w:eawm_def3_e}), 1.0, 1.0, 1)
  eawm_ind_ncep2 = eawm_area1_ncep2
  eawm_ind_ncep2 = (2*eawm_area1_ncep2 - eawm_area2_ncep2 - eawm_area3_ncep2)/2.0
  eawm_ind_ncep2 = dim_standardize_Wrap(eawm_ind_ncep2, 1)
  ; printMinMax(eawm_ind_ncep2, 0)

  ;eraint
  eawm_area1_eraint = wgt_areaave_Wrap(slp_djf_eraint(:,{eawm_def1_s:eawm_def1_n},{eawm_def1_w:eawm_def1_e}), 1.0, 1.0, 1)
  eawm_area2_eraint = wgt_areaave_Wrap(slp_djf_eraint(:,{eawm_def2_s:eawm_def2_n},{eawm_def2_w:eawm_def3_e}), 1.0, 1.0, 1)
  eawm_area3_eraint = wgt_areaave_Wrap(slp_djf_eraint(:,{eawm_def3_s:eawm_def3_n},{eawm_def3_w:eawm_def3_e}), 1.0, 1.0, 1)
  eawm_ind_eraint = eawm_area1_eraint
  eawm_ind_eraint = (2*eawm_area1_eraint - eawm_area2_eraint - eawm_area3_eraint)/2.0
  eawm_ind_eraint = dim_standardize_Wrap(eawm_ind_eraint, 1)
  ; printMinMax(eawm_ind_eraint, 0)

  nyrs = dimsizes(eawm_ind_ncep1)
  eawm_ind_multi = new((/3,nyrs/), float)
  eawm_ind_multi(0,:) = eawm_ind_ncep1
  eawm_ind_multi(1,:) = eawm_ind_ncep2 +3
  eawm_ind_multi(2,:) = doubletofloat(eawm_ind_eraint) +3*2

  ;Low frequency
  ;-----------------------------------------------------------------------------------------
  eawm_area1_lf_ncep1 = wgt_areaave_Wrap(slp_djf_lf_ncep1(:,{eawm_def1_s:eawm_def1_n},{eawm_def1_w:eawm_def1_e}), 1.0, 1.0, 1)
  eawm_area2_lf_ncep1 = wgt_areaave_Wrap(slp_djf_lf_ncep1(:,{eawm_def2_s:eawm_def2_n},{eawm_def2_w:eawm_def3_e}), 1.0, 1.0, 1)
  eawm_area3_lf_ncep1 = wgt_areaave_Wrap(slp_djf_lf_ncep1(:,{eawm_def3_s:eawm_def3_n},{eawm_def3_w:eawm_def3_e}), 1.0, 1.0, 1) 
  eawm_ind_lf_ncep1 = eawm_area1_lf_ncep1
  eawm_ind_lf_ncep1 = (2*eawm_area1_lf_ncep1 - eawm_area2_lf_ncep1 - eawm_area3_lf_ncep1)/2.0
  eawm_ind_lf_ncep1 = dim_standardize_Wrap(eawm_ind_lf_ncep1, 1)
  ; printMinMax(eawm_ind_lf_ncep1, 0)

  ;ncep2
  eawm_area1_lf_ncep2 = wgt_areaave_Wrap(slp_djf_lf_ncep2(:,{eawm_def1_s:eawm_def1_n},{eawm_def1_w:eawm_def1_e}), 1.0, 1.0, 1)
  eawm_area2_lf_ncep2 = wgt_areaave_Wrap(slp_djf_lf_ncep2(:,{eawm_def2_s:eawm_def2_n},{eawm_def2_w:eawm_def3_e}), 1.0, 1.0, 1)
  eawm_area3_lf_ncep2 = wgt_areaave_Wrap(slp_djf_lf_ncep2(:,{eawm_def3_s:eawm_def3_n},{eawm_def3_w:eawm_def3_e}), 1.0, 1.0, 1)
  eawm_ind_lf_ncep2 = eawm_area1_lf_ncep2
  eawm_ind_lf_ncep2 = (2*eawm_area1_lf_ncep2 - eawm_area2_lf_ncep2 - eawm_area3_lf_ncep2)/2.0
  eawm_ind_lf_ncep2 = dim_standardize_Wrap(eawm_ind_lf_ncep2, 1)
  ; printMinMax(eawm_ind_lf_ncep2, 0)

  ;eraint
  eawm_area1_lf_eraint = wgt_areaave_Wrap(slp_djf_lf_eraint(:,{eawm_def1_s:eawm_def1_n},{eawm_def1_w:eawm_def1_e}), 1.0, 1.0, 1)
  eawm_area2_lf_eraint = wgt_areaave_Wrap(slp_djf_lf_eraint(:,{eawm_def2_s:eawm_def2_n},{eawm_def2_w:eawm_def3_e}), 1.0, 1.0, 1)
  eawm_area3_lf_eraint = wgt_areaave_Wrap(slp_djf_lf_eraint(:,{eawm_def3_s:eawm_def3_n},{eawm_def3_w:eawm_def3_e}), 1.0, 1.0, 1)
  eawm_ind_lf_eraint = eawm_area1_lf_eraint
  eawm_ind_lf_eraint = (2*eawm_area1_lf_eraint - eawm_area2_lf_eraint - eawm_area3_lf_eraint)/2.0
  eawm_ind_lf_eraint = dim_standardize_Wrap(eawm_ind_lf_eraint, 1)
  ; printMinMax(eawm_ind_lf_eraint, 0)

  nyrs = dimsizes(eawm_ind_lf_ncep1)
  eawm_ind_lf_multi = new((/3,nyrs/), float)
  eawm_ind_lf_multi(0,:) = eawm_ind_lf_ncep1
  eawm_ind_lf_multi(1,:) = eawm_ind_lf_ncep2 +6
  eawm_ind_lf_multi(2,:) = doubletofloat(eawm_ind_lf_eraint) +12
;***************************************************************************
;EA_SAT index
;***************************************************************************
  ;ncep1
  easat_ncep1 = wgt_areaave_Wrap(sat_djf_ncep1(:,{ea_def_s:ea_def_n},{ea_def_w:ea_def_e}), 1.0, 1.0, 1)
  easat_ind_ncep1 = easat_ncep1
  easat_ind_ncep1 = dim_standardize_Wrap(easat_ind_ncep1, 1)
  ; printMinMax(easat_ind_ncep1, 0)

  ;ncep2
  easat_ncep2 = wgt_areaave_Wrap(sat_djf_ncep2(:,{ea_def_s:ea_def_n},{ea_def_w:ea_def_e}), 1.0, 1.0, 1)
  easat_ind_ncep2 = easat_ncep2
  easat_ind_ncep2 = dim_standardize_Wrap(easat_ind_ncep2, 1)
  ; printMinMax(easat_ind_ncep2, 0)

  ;eraint
  easat_eraint = wgt_areaave_Wrap(sat_djf_eraint(:,{ea_def_s:ea_def_n},{ea_def_w:ea_def_e}), 1.0, 1.0, 1)
  easat_ind_eraint = easat_eraint
  easat_ind_eraint = dim_standardize_Wrap(easat_ind_eraint, 1)
  ; printMinMax(easat_ind_eraint, 0)

  ; nyrs = dimsizes(eawm_ind_ncep1)
  easat_ind_multi = new((/3,nyrs/), float)
  easat_ind_multi(0,:) = easat_ind_ncep1
  easat_ind_multi(1,:) = easat_ind_ncep2 + 6
  easat_ind_multi(2,:) = doubletofloat(easat_ind_eraint) + 12
  printMinMax(easat_ind_multi(0,:), 0)
  printMinMax(easat_ind_multi(1,:), 0)
  printMinMax(easat_ind_multi(2,:), 0)

  ;Low frequency
  ;---------------------------------------------------------------------------------
  ;ncep1
  easat_lf_ncep1 = wgt_areaave_Wrap(sat_djf_lf_ncep1(:,{ea_def_s:ea_def_n},{ea_def_w:ea_def_e}), 1.0, 1.0, 1)
  easat_ind_lf_ncep1 = easat_lf_ncep1
  easat_ind_lf_ncep1 = dim_standardize_Wrap(easat_ind_lf_ncep1, 1)
  ; printMinMax(easat_ind_lf_ncep1, 0)

  ;ncep2
  easat_lf_ncep2 = wgt_areaave_Wrap(sat_djf_lf_ncep2(:,{ea_def_s:ea_def_n},{ea_def_w:ea_def_e}), 1.0, 1.0, 1)
  easat_ind_lf_ncep2 = easat_lf_ncep2
  easat_ind_lf_ncep2 = dim_standardize_Wrap(easat_ind_lf_ncep2, 1)
  ; printMinMax(easat_ind_lf_ncep2, 0)

  ;eraint
  easat_lf_eraint = wgt_areaave_Wrap(sat_djf_lf_eraint(:,{ea_def_s:ea_def_n},{ea_def_w:ea_def_e}), 1.0, 1.0, 1)
  easat_ind_lf_eraint = easat_lf_eraint
  easat_ind_lf_eraint = dim_standardize_Wrap(easat_ind_lf_eraint, 1)
  ; printMinMax(easat_ind_lf_eraint, 0)

  ; nyrs = dimsizes(eawm_ind_ncep1)
  easat_ind_lf_multi = new((/3,nyrs/), float)
  easat_ind_lf_multi(0,:) = easat_ind_lf_ncep1
  easat_ind_lf_multi(1,:) = easat_ind_lf_ncep2
  easat_ind_lf_multi(2,:) = doubletofloat(easat_ind_lf_eraint)

;**********************************************************
;Res
;**********************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   ; res@vpHeightF = 3.0
   ; res@vpWidthF  = 0.8

   resrc = res
   resrc@cnFillPalette = "BlueWhiteOrangeRed"
   resrc@gsnAddCyclic = False
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   ; resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.20
   resrc@pmTickMarkDisplayMode = "Always"
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False
   ; resrc@cnFillDrawOrder = "PreDraw"
   
   ;map_projection = (/"Orthographic", "Stereographic","LambertEqualArea","Gnomonic"/)
   ; resrc@mpProjection = "Satellite "
   ; resrc@mpLimitMode = "Angles"
   ; resrc@mpPerimOn = False
   ; resrc@mpOutlineOn = True
   ; resrc@mpDataBaseVersion = "MediumRes"
   ; ; resrc@mpDataBaseVersion = "LowRes"
   ; resrc@mpDataSetName = "Earth..4"
   ; ; resrc@mpDataResolution = "Medium"
   ; resrc@mpOutlineSpecifiers = (/"China","Taiwan"/)
   ; ; resrc@mpOutlineDrawOrder = "PreDraw"
   ; ; resrc@mpCenterLonF = (cn_northL + cn_northR)/2
   ; ; ; resrc@mpCenterLatF = -10
   ; ; resrc@mpFillDrawOrder = "PostDraw"
   ; resrc@mpFillOn = True
   ; ; resrc@mpFillAreaSpecifiers        = (/"Land" ,"Water"/)
   ; ; resrc@mpSpecifiedFillColors       = (/"Transparent", "white"/)  
   ; resrc@mpAreaMaskingOn = True
   ; resrc@mpMaskAreaSpecifiers =(/"China:states","Taiwan"/)
   ; ; resrc@mpInlandWaterFillColor = "white"
   ; resrc@mpOceanFillColor = "white"
   ; resrc@mpLandFillColor = "white"
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 360
   resrc@mpMinLatF = 0
   resrc@mpMaxLatF = 90
   resrc@mpCenterLonF = (resrc@mpMinLonF+resrc@mpMaxLonF)/2.

   ;Correlation res setting
   rescor = True
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   rescor@cnFillDrawOrder = "PreDraw"
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False
   rescor@cnMonoFillPattern = False
   rescor@cnLevels = (/0.05/)
   rescor@cnFillPatterns = (/17,-1/)
   rescor@cnFillColors = (/1,1/)
   rescor@cnMonoFillScale = True   
   rescor@cnFillScaleF = 2.
   rescor@cnFillDotSizeF = 0.004
   rescor@cnFillOpacityF = 1.0
   ;Vector res setting

   resV = res
   resV@vcRefMagnitudeF = 1.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.25
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.2               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True
   resP@gsnFrame = False
   resP@gsnMaximize = False
   resP@gsnPanelLabelBar = True
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsFontHeightF = 0.012
   resP@gsnPanelFigureStringsPerimOn = True
   resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black "Transparent"
   ; resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsJust = "TopLeft"
   resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   resP@amParallelPosF = -0.50    ;X-axis
   resP@gsnPanelYWhiteSpacePercent = 1
   resP@gsnPanelXWhiteSpacePercent = 1

   resP2 = resP

;********************************************
;Time Series plot
;********************************************
   rts           = True
   rts@gsnDraw   = False       ; don't draw yet
   rts@gsnFrame  = False       ; don't advance frame yet
   rts@gsnScale  = True        ; force text scaling               
   rts@vpHeightF = 0.35        ; Changes the aspect ratio
   rts@vpWidthF  = 0.85
   rts@vpXF      = 0.15        ; change start locations
   rts@vpYF      = 0.75        ; the plot 
   rts@gsnLeftStringFontHeightF = 0.025
   rts@tmYLLabelFontHeightF = 0.015
   rts@tmYLLabelFontHeightF = 0.015

   rts1 = rts  ; Bar Chart
   rts1@gsnXYBarChart         = True
   rts1@gsnYRefLine = 0
   rts1@gsnAboveYRefLineColor = "red"
   rts1@gsnBelowYRefLineColor = "blue"
   rts1@gsnXYBarChartBarWidth = 0.5   
   ;rts1@gsnLeftString = "(b) PC1"
   ;rts1@tmXUseBottom = True
   ; rts1@tmXBMode = "Explicit"
   rts1@tmXTOn = False
   rts1@tmYROn = False
   ; rts1@tiXAxisString = "Time (Year)"
   rts1@tiYAxisString = " "
   rts1@tiXAxisString = " "
   rts1@tiXAxisFontHeightF = 0.02
   rts1@tiYAxisFontHeightF = 0.02
   rts1@trYMinF = -2.8
   rts1@trYMaxF =  2.8

   rts2 = rts   ; Line 
   ; rts2@xyDashPattern         = 0
   rts2@xyLineThicknessF      = 3.
   rts2@xyLineColor = "black"
   ; rts2@gsnYRefLine = 0.
   rts2@trYMinF = -4.0
   rts2@trYMaxF = 4.0
   ; rts2@trXMinF = yrstrt/100 + -0.5
   ; rts2@trXMaxF = yrlast/100 + 0.5

   rts3 = rts2
   rts3@xyDashPattern = 1
   rts3@xyLineThicknesses = 2.0

   ; xpts = (/1962, 2013/)
   ; ypts = (/-1, -1/)

   plres = True
   plres@cnLineDrawOrder = "PostDraw"
   plres@gsLineColor = "red"
   plres@gsLineDashPattern = 0
   plres@gsLineThicknessF = 2.0

   ; dum = new(dimsizes(xpts), graphic)

   year = ispan(yrstrt_short/100, yrlast_short/100, 1)
   year@long_name = "Years"

   panel_ind = new(3, graphic)
   rts1@tmXBOn = False
   panel_ind(0) = gsn_csm_xy(wks, year, eawm_ind_ncep1, rts1)
   panel_ind(1) = gsn_csm_xy(wks, year, eawm_ind_ncep2, rts1)
   rts1@tmXBOn = True
   panel_ind(2) = gsn_csm_xy(wks, year, eawm_ind_eraint, rts1)
   
   panel_lf = new(3, graphic)
   panel_lf(0) = gsn_csm_xy(wks, year, eawm_ind_lf_ncep1, rts2)
   panel_lf(1) = gsn_csm_xy(wks, year, eawm_ind_lf_ncep2, rts2)
   panel_lf(2) = gsn_csm_xy(wks, year, eawm_ind_lf_eraint, rts2)

   do i = 0, 2
     overlay(panel_ind(i), panel_lf(i))
   end do

   resP3 = True
   resP3@gsnPanelYWhiteSpacePercent = 10
   ; resP3@gsnAttachBorderOn = False
   resP3@amJust = "TopLeft"
   resP3@gsnPanelFigureStrings = (/"(a) NCEP1","(b) NCEP2", "(c) ERA-Interim"/)
   resP3@gsnPanelFigureStringsPerimOn = False
   resP3@gsnPanelFigureStringsFontHeightF = 0.02
   gsn_panel(wks, panel_ind, (/3,1/), resP3)

   panel_ind := new(3, graphic)
   rts1@tmXBOn = False
   panel_ind(0) = gsn_csm_xy(wks, year, easat_ind_ncep1, rts1)
   panel_ind(1) = gsn_csm_xy(wks, year, easat_ind_ncep2, rts1)
   rts1@tmXBOn = True
   panel_ind(2) = gsn_csm_xy(wks, year, easat_ind_eraint, rts1)
   
   panel_lf := new(3, graphic)
   panel_lf(0) = gsn_csm_xy(wks, year, easat_ind_lf_ncep1, rts2)
   panel_lf(1) = gsn_csm_xy(wks, year, easat_ind_lf_ncep2, rts2)
   panel_lf(2) = gsn_csm_xy(wks, year, easat_ind_lf_eraint, rts2)

   do i = 0, 2
     overlay(panel_ind(i), panel_lf(i))
   end do

   gsn_panel(wks, panel_ind, (/3,1/), resP3)

   ; rts1@trYMaxF = 15.0
   ; rts1@gsnYRefLine := (/0, 6, 12/)
   ; plot = gsn_csm_xy(wks, year, eawm_ind_multi , rts1)
   ; draw(plot)
   ; frame(wks)

;***********************************************
;Plot
    ; plot1 = gsn_csm_contour_map(wks, dim_avg_n_Wrap(slp_djf_ncep1, 0), resrc)
    ; draw(plot1)
    ; frame(wks)

    ; plot1 = gsn_csm_contour_map(wks, 0.01*dim_avg_n_Wrap(slp_djf_ncep2, 0), resrc)
    ; draw(plot1)
    ; frame(wks)

    ; plot1 = gsn_csm_contour_map(wks, 0.01*dim_avg_n_Wrap(slp_djf_eraint, 0), resrc)
    ; draw(plot1)
    ; frame(wks)

    ; plot1 = gsn_csm_contour_map(wks, dim_avg_n_Wrap(sat_djf_ncep1, 0), resrc)
    ; draw(plot1)
    ; frame(wks)

    ; plot1 = gsn_csm_contour_map(wks, dim_avg_n_Wrap(sat_djf_ncep2, 0), resrc)
    ; draw(plot1)
    ; frame(wks)

    ; plot1 = gsn_csm_contour_map(wks, dim_avg_n_Wrap(sat_djf_eraint, 0), resrc)
    ; draw(plot1)
    ; frame(wks)

   system("date")


end
