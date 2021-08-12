load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   yrstrt1 = 196701   ;P1
   yrlast1 = 198812

   yrstrt2 = 198901  ;P2
   yrlast2 = 201412

   ; yrstrt_sst = yrstrt
   ; yrlast_sst = yrlast

   yrstrt_snow = 196701
   yrlast_snow = 201412

  year=ispan(yrstrt_snow/100, yrlast_snow/100, 1)
  ;t = ispan(1970, 2014, 1)
;---------------W,E-index Region
  SCI_WEU_N = 70
  SCI_WEU_S = 40
  SCI_WEU_L = 20
  SCI_WEU_R = 50

  SCI_EEU_N = 70
  SCI_EEU_S = 40
  SCI_EEU_L = 80
  SCI_EEU_R = 140
  
  SCI_NA_N = 70
  SCI_NA_S = 40
  SCI_NA_L = 240-360
  SCI_NA_R = 300-360

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   nceppath = "$HOME/data/ncep/"
   ncep2path = "$HOME/data/ncep2/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"q1_2p")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   snowdata  = addfile(snowpath+"snow.rutger.2.0deg.nc","r")
   precipdata= addfile(precpath+"precip.mon.anom.nc", "r")

   ;NCEP 1
   air2m_sfc_file1  = addfile(nceppath+"air.2m.mon.mean.nc","r")
   dlwrf_sfc_file1  = addfile(nceppath+"dlwrf.sfc.mon.mean.nc","r")
   dswrf_ntat_file1 = addfile(nceppath+"dswrf.ntat.mon.mean.nc","r")
   dswrf_sfc_file1  = addfile(nceppath+"dswrf.sfc.mon.mean.nc","r")
   lhtfl_sfc_file1  = addfile(nceppath+"lhtfl.sfc.mon.mean.nc","r")
   prate_sfc_file1  = addfile(nceppath+"prate.sfc.mon.mean.nc","r")
   shtfl_sfc_file1  = addfile(nceppath+"shtfl.sfc.mon.mean.nc","r")
   ulwrf_ntat_file1 = addfile(nceppath+"ulwrf.ntat.mon.mean.nc","r")
   ulwrf_sfc_file1  = addfile(nceppath+"ulwrf.sfc.mon.mean.nc","r")
   uswrf_ntat_file1 = addfile(nceppath+"uswrf.ntat.mon.mean.nc","r")
   uswrf_sfc_file1  = addfile(nceppath+"uswrf.sfc.mon.mean.nc","r")
   tcc_file1        = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")
   
   ;NCEP 2
   air2m_sfc_file2  = addfile(ncep2path+"air.2m.mon.mean.nc","r")
   dlwrf_sfc_file2  = addfile(ncep2path+"dlwrf.sfc.mon.mean.nc","r")
   dswrf_ntat_file2 = addfile(ncep2path+"dswrf.ntat.mon.mean.nc","r")
   dswrf_sfc_file2  = addfile(ncep2path+"dswrf.sfc.mon.mean.nc","r")
   lhtfl_sfc_file2  = addfile(ncep2path+"lhtfl.sfc.mon.mean.nc","r")
   prate_sfc_file2  = addfile(ncep2path+"prate.sfc.mon.mean.nc","r")
   shtfl_sfc_file2  = addfile(ncep2path+"shtfl.sfc.mon.mean.nc","r")
   ulwrf_ntat_file2 = addfile(ncep2path+"ulwrf.ntat.mon.mean.nc","r")
   ulwrf_sfc_file2  = addfile(ncep2path+"ulwrf.sfc.mon.mean.nc","r")
   uswrf_ntat_file2 = addfile(ncep2path+"uswrf.ntat.mon.mean.nc","r")
   uswrf_sfc_file2  = addfile(ncep2path+"uswrf.sfc.mon.mean.nc","r")
   tcc_file2        = addfile(ncep2path+"tcdc.eatm.mon.mean.nc", "r")

 ;*******************************************
   YYYYMM = cd_calendar(air2m_sfc_file1->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt1)
   iLast  = ind(YYYYMM.eq.yrlast1)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM2 = cd_calendar(air2m_sfc_file2->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt2)
   iLast2  = ind(YYYYMM2.eq.yrlast2)
   print("ncep2 time: "+YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))

   YYYYMM4 = cd_calendar(precipdata->time, 1)
   iStrt4  = ind(YYYYMM4.eq.yrstrt_snow)
   iLast4  = ind(YYYYMM4.eq.yrlast_snow)
   print("snow time: "+YYYYMM4(iStrt4)+"--"+YYYYMM4(iLast4))
 ;********************************************
   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)
   iyr = 21

   precip_mon  = precipdata->precip(iStrt4:iLast4,:,:)
   precip_mon1 = precip_mon(:iyr*12-1,:,:)
   precip_mon2 = precip_mon((iyr+1)*12:,:,:)

   air2m_sfc_mon1    = air2m_sfc_file1->air(iStrt:iLast,:,:)
   dlwrf_sfc_mon1  = (dlwrf_sfc_file1->dlwrf(iStrt:iLast,:,:))
   dswrf_ntat_mon1 = (dswrf_ntat_file1->dswrf(iStrt:iLast,:,:))
   dswrf_sfc_mon1  = (dswrf_sfc_file1->dswrf(iStrt:iLast,:,:))
   prate_sfc_mon1  = (prate_sfc_file1->prate(iStrt:iLast,:,:))
   lhtfl_sfc_mon1  = (lhtfl_sfc_file1->lhtfl(iStrt:iLast,:,:)) ;positive = upward
   shtfl_sfc_mon1  = (shtfl_sfc_file1->shtfl(iStrt:iLast,:,:))
   ulwrf_ntat_mon1 = (ulwrf_ntat_file1->ulwrf(iStrt:iLast,:,:))
   ulwrf_sfc_mon1  = (ulwrf_sfc_file1->ulwrf(iStrt:iLast,:,:))
   uswrf_ntat_mon1 = (uswrf_ntat_file1->uswrf(iStrt:iLast,:,:))
   uswrf_sfc_mon1  = (uswrf_sfc_file1->uswrf(iStrt:iLast,:,:))
   tcc_mon1        = (tcc_file1->tcdc(iStrt:iLast,:,:))

   air2m_sfc_mon2     = short2flt(air2m_sfc_file2->air(iStrt2:iLast2,0,:,:))
   dlwrf_sfc_mon2   = short2flt(dlwrf_sfc_file2->dlwrf(iStrt2:iLast2,:,:))
   dswrf_ntat_mon2 = short2flt(dswrf_ntat_file2->dswrf(iStrt2:iLast2,:,:))
   dswrf_sfc_mon2   = short2flt(dswrf_sfc_file2->dswrf(iStrt2:iLast2,:,:))
   prate_sfc_mon2   = short2flt(prate_sfc_file2->prate(iStrt2:iLast2,:,:))
   lhtfl_sfc_mon2   =          (lhtfl_sfc_file2->lhtfl(iStrt2:iLast2,:,:)) ;positive = upward
   shtfl_sfc_mon2   = short2flt(shtfl_sfc_file2->shtfl(iStrt2:iLast2,:,:))
   ulwrf_ntat_mon2 = short2flt(ulwrf_ntat_file2->ulwrf(iStrt2:iLast2,:,:))
   ulwrf_sfc_mon2   = short2flt(ulwrf_sfc_file2->ulwrf(iStrt2:iLast2,:,:))
   uswrf_ntat_mon2 = short2flt(uswrf_ntat_file2->uswrf(iStrt2:iLast2,:,:))
   uswrf_sfc_mon2   = short2flt(uswrf_sfc_file2->uswrf(iStrt2:iLast2,:,:))
   tcc_mon2        = tcc_file2->tcdc(iStrt2:iLast2,:,:)

   q1_mon1 = dswrf_sfc_mon1
   q1_mon1 = (shtfl_sfc_mon1 + lhtfl_sfc_mon1) + (ulwrf_sfc_mon1 - ulwrf_ntat_mon1 + uswrf_sfc_mon1 - uswrf_ntat_mon1 + \
            dswrf_ntat_mon1 - dswrf_sfc_mon1 - dlwrf_sfc_mon1) + prate_sfc_mon1*1859*air2m_sfc_mon1

   q1_mon2 = dswrf_sfc_mon2
   q1_mon2 = (shtfl_sfc_mon2 + lhtfl_sfc_mon2) + (ulwrf_sfc_mon2 - ulwrf_ntat_mon2 + uswrf_sfc_mon2 - uswrf_ntat_mon2 + \
            dswrf_ntat_mon2 - dswrf_sfc_mon2 - dlwrf_sfc_mon2) + prate_sfc_mon2*1859*air2m_sfc_mon2

   ; nswr_mon = dswrf_sfc_mon 
   ; nswr_mon = dswrf_sfc_mon - uswrf_sfc_mon

   ; nlwr_mon = dlwrf_sfc_mon
   ; nlwr_mon = dlwrf_sfc_mon - ulwrf_sfc_mon

   ; nhf_mon = nswr_mon
   ; nhf_mon = nswr_mon + nlwr_mon - shtfl_sfc_mon - lhtfl_sfc_mon ;reverse the sign of SHF and LHF

;************************************************
;Seasonal Mean
   season_string = "MAM"
   print("season:  " + season_string)

   ; slp_mam    = month_to_season(slp_mon, season_string)
   ; z500_mam  = month_to_season(z500_mon, season_string)
   ; z200_mam  = month_to_season(z200_mon, season_string)
   ; sst_mam    = month_to_season(sst_mon, season_string)
   ; u850_mam  = month_to_season(u850_mon, season_string)
   ; v850_mam  = month_to_season(v850_mon, season_string)
   ; u200_mam  = month_to_season(u200_mon, season_string)
   ; nswr_mam   = month_to_season(nswr_mon, season_string)
   ; nlwr_mam   = month_to_season(nlwr_mon, season_string)
   ; shf_mam     = month_to_season(shtfl_sfc_mon, season_string)
   ; lhf_mam     = month_to_season(lhtfl_sfc_mon, season_string)
   ; nhf_mam     = month_to_season(nhf_mon, season_string)
   ; soilw_mam = month_to_season(soilw_mon, season_string)
   ; tcc_mam     = month_to_season(tcc_mon, season_string)

   snow_mam  = month_to_season(snow_mon, "MAM")

   air_mam1    = month_to_season(air2m_sfc_mon1, season_string)
   precip_mam1 = month_to_season(precip_mon1, season_string)
   q1_mam1 = month_to_season(q1_mon1, season_string)

   air_mam2    = month_to_season(air2m_sfc_mon2, season_string)
   precip_mam2 = month_to_season(precip_mon2, season_string)
   q1_mam2 = month_to_season(q1_mon2, season_string)
;************************************************
; Calculate Index
;************************************************
  WEU = snow_mam(:,{SCI_WEU_S:SCI_WEU_N},{SCI_WEU_L:SCI_WEU_R})
  EEU = snow_mam(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
  NA  = snow_mam(:,{SCI_NA_S:SCI_NA_N},{SCI_NA_L:SCI_NA_R})
  sci_weu = dim_standardize_Wrap(wgt_areaave_Wrap(WEU, 1.0, 1.0, 1),0)
  sci_eeu = dim_standardize_Wrap(wgt_areaave_Wrap(EEU, 1.0, 1.0, 1),0)
  sci_na  = dim_standardize_Wrap(wgt_areaave_Wrap(NA, 1.0, 1.0, 1),0)
 ;*****************************************************************
  ; sci_eeu = dtrend(sci_eeu, False)
;**********************************************************
;3-D Data analysis
;**********************************************************
 ;Reg and Cor
  ;Define index
  snow_index1 = dtrend(sci_eeu(:iyr), False)
  snow_index2 = dtrend(sci_eeu(iyr+1:), False)
  ; snow_index = sci_eeu_res

  ;snow data
  ; sci_sce_rc = regCoef_n(snow_index, snow_mam, 0, 0)
  ; copy_VarCoords(snow_mam(0,:,:), sci_sce_rc)
  ; sci_sce_cor = escorc_n(snow_index, snow_mam, 0, 0)  
  ; ndim_snow = dimsizes(snow_mam)
  ; df_snow = sci_sce_cor
  ; df_snow = ndim_snow(0) - 2
  ; t_sce = sci_sce_cor*sqrt(df_snow/(1- sci_sce_cor^2 ))
  ; p_sce = student_t(t_sce, df_snow)
  ; copy_VarCoords(snow_mam(0,:,:), p_sce)

  ; ;ncep data 
  ; ndim_ncep = dimsizes(air_mam)
  ; sci_sat_rc = regCoef_n(snow_index, air_mam, 0, 0)
  ; copy_VarCoords(air_mam(0,:,:), sci_sat_rc)
  ; sci_sat_cor = escorc_n(snow_index, air_mam, 0, 0)

  ; df_ncep = sci_sat_cor
  ; df_ncep = ndim_ncep(0) - 2
  ; t_sat = sci_sat_cor*sqrt(df_ncep/(1- sci_sat_cor^2))
  ; p_sat = student_t(t_sat, df_ncep)
  ; copy_VarCoords(air_mam(0,:,:), p_sat)

  ;heat flux data (gaussian)
  ndim_htfl1 = dimsizes(q1_mam1)
  sci_q1_rc1 = regCoef_n(snow_index1, q1_mam1, 0, 0)
  copy_VarCoords(q1_mam1(0,:,:), sci_q1_rc1)
  sci_q1_cor1 = escorc_n(snow_index1, q1_mam1, 0, 0)
  df_htfl1 = sci_q1_cor1
  df_htfl1 = ndim_htfl1(0) - 2
  p_q1_1 = student_t(sci_q1_cor1*sqrt(df_htfl1/(1- sci_q1_cor1^2)), df_htfl1)
  copy_VarCoords(q1_mam1(0,:,:), p_q1_1)

  ndim_htfl2 = dimsizes(q1_mam2)
  sci_q1_rc2 = regCoef_n(snow_index2, q1_mam2, 0, 0)
  copy_VarCoords(q1_mam2(0,:,:), sci_q1_rc2)
  sci_q1_cor2 = escorc_n(snow_index2, q1_mam2, 0, 0)
  df_htfl2 = sci_q1_cor2
  df_htfl2 = ndim_htfl2(0) - 2
  p_q1_2 = student_t(sci_q1_cor2*sqrt(df_htfl2/(1- sci_q1_cor2^2)), df_htfl2)
  copy_VarCoords(q1_mam2(0,:,:), p_q1_2)

  q1_dif = sci_q1_rc2
  q1_dif = sci_q1_rc2 - sci_q1_rc1

;**********************************************************
;Resources Setting
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   ;For Fills
   resrc = True    
   resrc@gsnDraw = False
   resrc@gsnFrame = False
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnInfoLabelString = " "
   resrc@cnLineLabelsOn = False
   resrc@cnFillDrawOrder = "PreDraw"   
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   resrc@pmLabelBarWidthF = 0.5
   resrc@pmLabelBarHeightF = 0.06
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@mpGridAndLimbOn = False
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = True
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 360
   ; resrc@mpMinLonF = 180
   ; resrc@mpMaxLonF = 330
   resrc@mpMaxLatF = 90
   resrc@mpMinLatF = 0
   resrc@mpCenterLonF = (resrc@mpMinLonF+resrc@mpMaxLonF)/2.
   resrc@mpAreaMaskingOn = True
   resrc@mpOceanFillColor = "white"
   resrc@mpLandFillColor = "Transparent"
   ; resrc@mpMaskAreaSpecifiers =(/"China","Taiwan"/)

   res_circ = resrc
   res_circ@mpFillOn = False   
   res_circ@mpMinLonF = 0
   res_circ@mpMaxLonF = 360
   res_circ@mpMaxLatF = 90
   res_circ@mpMinLatF = 0
   res_circ@mpCenterLonF = (res_circ@mpMinLonF+res_circ@mpMaxLonF)/2.

   res_snow = resrc
   res_snow@lbLabelBarOn = True

   res_htfl = resrc
   res_htfl@cnMaxLevelValF := 10.5
   res_htfl@cnMinLevelValF = -1*res_htfl@cnMaxLevelValF
   res_htfl@cnLevelSpacingF = 0.5
   ; res_htfl@cnFillPalette = "cmp_b2r"
   res_htfl@cnFillPalette = "BlWhRe"

   resSST = res_circ
   ; resSST@lbLabelBarOn = True
   resSST@mpMaxLonF = 360
   resSST@mpMinLonF = 0
   resSST@mpMaxLatF = 80
   resSST@mpMinLatF = 0
   resSST@mpCenterLonF = 180

   ;For Line
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
   resrc2@cnLineLabelFontHeightF = 0.010
   ;resrc2@cnLineLabelFontColor = 0
   resrc2@cnLineLabelFontThicknessF = 1.0
   resrc2@gsnAddCyclic = True
   resrc2@cnLevelSelectionMode = "ManualLevels"

   ;Correlation res (with dots.)
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
   rescor@cnFillScaleF = 0.5
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillOpacityF = 1.0
   rescor@cnFillDrawOrder = "PreDraw"

   rescor2 = res
   rescor2@cnLinesOn = False
   rescor2@cnFillOn = True
   rescor2@cnInfoLabelOn = False
   rescor2@lbLabelBarOn = False
   ; rescor2@cnMonoFillPattern = True
   rescor2@cnLevelSelectionMode = "ExplicitLevels"
   rescor2@cnLevels = (/0.01, 0.05/)
   rescor2@cnFillColors = (/"grey35", "grey65", "Transparent"/)   
   ; rescor2@cnFillColors = (/1, 2, 4/)
   rescor2@mpCenterLonF = 180.
   rescor2@mpFillOn = False
   rescor2@mpMinLonF = 0.
   rescor2@mpMaxLonF = 360.
   rescor2@mpMaxLatF = 90.
   rescor2@mpMinLatF = 0.

   ;Wind Resources
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
   resV@vcRefAnnoOrthogonalPosF = -0.65
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.8               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.015
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsBackgroundFillColor = "black"
   resP@gsnPanelFigureStringsFontColor = "white"
;****************************************************************
;Polyline

   ;Polyline Setting
   Wxpts = (/SCI_WEU_L, SCI_WEU_L, SCI_WEU_R, SCI_WEU_R, SCI_WEU_L/)
   Wypts = (/SCI_WEU_S, SCI_WEU_N, SCI_WEU_N, SCI_WEU_S, SCI_WEU_S/)

   Expts = (/SCI_EEU_L, SCI_EEU_L, SCI_EEU_R, SCI_EEU_R, SCI_EEU_L/)
   Eypts = (/SCI_EEU_S, SCI_EEU_N, SCI_EEU_N, SCI_EEU_S, SCI_EEU_S/)

   NAxpts = (/SCI_NA_L, SCI_NA_L, SCI_NA_R, SCI_NA_R, SCI_NA_L/)
   NAypts = (/SCI_NA_S, SCI_NA_N, SCI_NA_N, SCI_NA_S, SCI_NA_S/)

   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 1.5
   plres@gsLineLabelString = ""

   dum1 = new(dimsizes(Wxpts)-1, graphic)
   dum2 = new(dimsizes(Expts)-1, graphic)
   dum3 = new(dimsizes(Expts)-1, graphic)
;--------------------------------------------------------------------------------------------------
   res_htfl@lbLabelBarOn = False
   res_htfl@mpMinLonF = 40
   res_htfl@mpMaxLonF = 160
   res_htfl@mpMinLatF = 30
   res_htfl@mpMaxLatF = 80

   res_htfl@cnMaxLevelValF := 5.5
   res_htfl@cnMinLevelValF = -1*res_htfl@cnMaxLevelValF
   res_htfl@cnLevelSpacingF = 0.5

   ; swrplot = gsn_csm_contour_map(wks, sci_swr_rc, res_htfl)
   ; swrdot = gsn_csm_contour(wks, p_swr, rescor)
   ; overlay(swrplot, swrdot)
   ; lwrplot = gsn_csm_contour_map(wks, sci_lwr_rc, res_htfl)
   ; lwrdot = gsn_csm_contour(wks, p_lwr, rescor)
   ; overlay(lwrplot, lwrdot)
   ; shfplot = gsn_csm_contour_map(wks, sci_shf_rc, res_htfl)
   ; shfdot = gsn_csm_contour(wks, p_shf, rescor)
   ; overlay(shfplot, shfdot)
   ; lhfplot = gsn_csm_contour_map(wks, sci_lhf_rc, res_htfl)
   ; lhfdot = gsn_csm_contour(wks, p_lhf, rescor)
   ; overlay(lhfplot, lhfdot)
   ; nhfplot = gsn_csm_contour_map(wks, sci_nhf_rc, res_htfl)
   ; nhfdot = gsn_csm_contour(wks, p_nhf, rescor)
   ; overlay(nhfplot, nhfdot)

   ; tccplot = gsn_csm_contour_map(wks, sci_tcc_rc, res_htfl)
   ; tccdot = gsn_csm_contour(wks, p_tcc, rescor)
   ; overlay(tccplot, tccdot)

   ; htfl_panel := new(6,graphic)
   ; htfl_panel(0) = nhfplot
   ; htfl_panel(1) = swrplot
   ; htfl_panel(2) = lwrplot
   ; htfl_panel(3) = shfplot
   ; htfl_panel(4) = lhfplot
   ; htfl_panel(5) = tccplot
   ; resP@gsnPanelLabelBar = True
   ; resP@pmLabelBarOrthogonalPosF = -0.005
   ; resP@gsnPanelFigureStringsFontHeightF = 0.01
   ; ; resP@gsnPanelFigureStrings := (/"a) NHF","b) SWR","c) LWR","d) SHF","e) LHF","f) TCC"/)
   ; resP@gsnPanelFigureStrings := (/"g) NHF","h) SWR","i) LWR","j) SHF","k) LHF", "l) TCC"/)
   ; gsn_panel(wks, htfl_panel, (/6,1/), resP)

   res_htfl@mpMinLonF = 40
   res_htfl@mpMaxLonF = 150
   res_htfl@lbLabelBarOn = False
   ; res_htfl@cnMaxLevelValF := 6
   ; res_htfl@cnMinLevelValF = -1*res_htfl@cnMaxLevelValF
   ; res_htfl@cnLevelSpacingF = 0.5
   res_htfl@cnLevelSelectionMode = "ExplicitLevels"
   res_htfl@cnLevels = fspan(-8, 8, 9)
   res_htfl@cnFillColors = (/5,10,25,35,45,54,58,62,64,68/)
   res_htfl@gsnLeftString = "a) Q1 P1"
   q1plot1 = gsn_csm_contour_map(wks, sci_q1_rc1, res_htfl)
   q1dot1 = gsn_csm_contour(wks, p_q1_1, rescor)
   overlay(q1plot1, q1dot1)

   res_htfl@gsnLeftString = "b) Q1 P2"
   q1plot2 = gsn_csm_contour_map(wks, sci_q1_rc2, res_htfl)
   q1dot2 = gsn_csm_contour(wks, p_q1_2, rescor)
   overlay(q1plot2, q1dot2)
   
   res_htfl@gsnLeftString = "c) Q1 P2-P1"
   q1plot3 = gsn_csm_contour_map(wks, q1_dif, res_htfl)
   
   q1panel = new(3, graphic)
   q1panel(0) = q1plot1
   q1panel(1) = q1plot2
   q1panel(2) = q1plot3
   resP@gsnPanelLabelBar = True
   resP@pmLabelBarWidthF = 0.5
   gsn_panel(wks, q1panel, (/3,1/), resP)
   frame(wks)
;--------------------------------------------------------------------------------------------------
;Polyline

   ;Polyline Setting
   plres = True
   plres@gsLineThicknessF = 1.0
   plres@gsLineLabelString = ""
   plres@gsLineColor = "red"

   SST_A_N = 60
   SST_A_S = 45
   SST_A_L = -55+360
   SST_A_R = 340

   SST_B_N = 40
   SST_B_S = 25
   SST_B_L = -75+360
   SST_B_R = -45+360

   SST_C_N = 24
   SST_C_S = 5
   SST_C_L = -50+360
   SST_C_R = 340

   SST_ENP_N = 50
   SST_ENP_S = 28
   SST_ENP_L = -160+360
   SST_ENP_R = -130+360

   Axpts = (/SST_A_L, SST_A_L, SST_A_R, SST_A_R, SST_A_L/)
   Aypts = (/SST_A_S, SST_A_N, SST_A_N, SST_A_S, SST_A_S/)

   Bxpts = (/SST_B_L, SST_B_L, SST_B_R, SST_B_R, SST_B_L/)
   Bypts = (/SST_B_S, SST_B_N, SST_B_N, SST_B_S, SST_B_S/)

   Cxpts = (/SST_C_L, SST_C_L, SST_C_R, SST_C_R, SST_C_L/)
   Cypts = (/SST_C_S, SST_C_N, SST_C_N, SST_C_S, SST_C_S/)

   ENPxpts = (/SST_ENP_L, SST_ENP_L, SST_ENP_R, SST_ENP_R, SST_ENP_L/)
   ENPypts = (/SST_ENP_S, SST_ENP_N, SST_ENP_N, SST_ENP_S, SST_ENP_S/)

   dum1 = new(dimsizes(Axpts)-1, graphic)
   dum2 = new(dimsizes(Bxpts)-1, graphic)
   dum3 = new(dimsizes(Cxpts)-1, graphic)
   dum4 = new(dimsizes(ENPxpts)-1, graphic)
;--------------------------------------------------------------------------------------------------
   ; resSST@cnMaxLevelValF = 0.3
   ; resSST@cnMinLevelValF = -1*resSST@cnMaxLevelValF
   ; resSST@cnLevelSpacingF = 0.03
   ; resSST@pmLabelBarOrthogonalPosF = 0.22
   ; ; resSST@lbLabelBarOn = False
   ; ; resSST@gsnLeftString = "a) SST  P1"
   ; resSST@gsnLeftString = "b) SST  P2"
   ; sstplot = gsn_csm_contour_map(wks, sci_sst_rc, resSST)
   ; sstsig = gsn_csm_contour(wks, p_sst, rescor)
   ; overlay(sstplot, sstsig)
   ; do i = 0, dimsizes(ENPxpts) -2 
   ;    dum4(i) = gsn_add_polyline(wks, sstplot, ENPxpts(i:i+1), ENPypts(i:i+1), plres)
   ; end do
   ; do i = 0, dimsizes(Axpts) -2 
   ;    dum1(i) = gsn_add_polyline(wks, sstplot, Axpts(i:i+1), Aypts(i:i+1), plres)
   ;    dum2(i) = gsn_add_polyline(wks, sstplot, Cxpts(i:i+1), Cypts(i:i+1), plres)
   ; end do
   ; plres@gsLineColor = "blue"
   ; do i = 0, dimsizes(Axpts) -2 
   ;    dum3(i) = gsn_add_polyline(wks, sstplot, Bxpts(i:i+1), Bypts(i:i+1), plres)
   ; end do
   ; draw(sstplot)
   ; frame(wks)



end
