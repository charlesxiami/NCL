load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   ; yrstrt = 196701   ;P1
   ; yrlast = 198812

   yrstrt = 198901  ;P2
   yrlast = 201412

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

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
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"
   binpath = "$HOME/data/binary/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"sci_eeu_waf")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
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

  ;ao 195001-201708
   ao_table = asciiread(indexpath+"monthly.ao.index.b50.current.ascii.txt", -1, "string")
   ao_index_origin = stringtofloat(str_get_field(ao_table, 3, " "))
   ao_mon_all = ao_index_origin(0:803)
   month_time2 = yyyymm_time(1950, 2016, "integer")
   month_time2!0 = "time"
   month_time2@long_name = "time"
   month_time2@units = "month"

   ao_mon_all!0 = "time"
   ao_mon_all&time = month_time2
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

   iStrt_ao  = ind(ao_mon_all&time.eq.yrstrt)
   iLast_ao  = ind(ao_mon_all&time.eq.yrlast)
   print("ao  time: "+ao_mon_all&time(iStrt_ao)+"--"+ao_mon_all&time(iLast_ao))   
 ;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})

   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   
   u850_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR})
   v850_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 

   u500_mon = uwnddata->uwnd(iStrt:iLast,{500},{latS:latN},{lonL:lonR})
   v500_mon = vwnddata->vwnd(iStrt:iLast,{500},{latS:latN},{lonL:lonR})

   u200_mon = uwnddata->uwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})
   v200_mon = vwnddata->vwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})

   nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nswr_mam = month_to_season(nswr_mon, "MAM")
   
   nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nlwr_mam = month_to_season(nlwr_mon, "MAM")
   
   shf_mon = shfdata->shtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   shf_mam = month_to_season(shf_mon, "MAM")
   
   lhf_mon = lhfdata->lhtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   lhf_mam = month_to_season(lhf_mon, "MAM")
   
   soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})
   soilw_mam = month_to_season(soilw_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)

   ao_mon = ao_mon_all(iStrt_ao:iLast_ao)
   ao_mam = month_to_season(ao_mon, "MAM")
;*************************************************
;Filter High-Frequency Pass
;*************************************************
   fcb= -999
   nsigma = 1.
   ihp = 1
   fca = 1.0/120.
   nwt= 21
   wgt_hf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

   snow_mon_hf = wgt_runave_n_Wrap(snow_mon, wgt_hf, 0, 0)
   air_mon_hf  = wgt_runave_n_Wrap(air_mon, wgt_hf, 0, 0)
   slp_mon_hf  = wgt_runave_n_Wrap(slp_mon, wgt_hf, 0, 0)
   z500_mon_hf = wgt_runave_n_Wrap(z500_mon, wgt_hf, 0, 0)
   z200_mon_hf = wgt_runave_n_Wrap(z200_mon, wgt_hf, 0, 0)
   sst_mon_hf  = wgt_runave_n_Wrap(sst_mon, wgt_hf, 0, 0)
   u850_mon_hf = wgt_runave_n_Wrap(u850_mon, wgt_hf, 0, 0)
   v850_mon_hf = wgt_runave_n_Wrap(v850_mon, wgt_hf, 0, 0)
   u200_mon_hf = wgt_runave_n_Wrap(u200_mon, wgt_hf, 0, 0)

 ;Low frequency
   ihp = 0
   wgt_lf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
   snow_mon_lf = wgt_runave_n_Wrap(snow_mon, wgt_lf, 0, 0)
   air_mon_lf  = wgt_runave_n_Wrap(air_mon, wgt_lf, 0, 0)
   slp_mon_lf  = wgt_runave_n_Wrap(slp_mon, wgt_lf, 0, 0)
   z500_mon_lf = wgt_runave_n_Wrap(z500_mon, wgt_lf, 0, 0)
   z200_mon_lf = wgt_runave_n_Wrap(z200_mon, wgt_lf, 0, 0)
   sst_mon_lf  = wgt_runave_n_Wrap(sst_mon, wgt_lf, 0, 0)

;************************************************
;Seasonal Mean
   snow_mam  = month_to_season(snow_mon, "MAM")
   air_mam    = month_to_season(air_mon, "MAM")
   slp_mam    = month_to_season(slp_mon, "MAM")
   z500_mam  = month_to_season(z500_mon, "MAM")
   z200_mam  = month_to_season(z200_mon, "MAM")
   sst_mam    = month_to_season(sst_mon, "MAM")
   u850_mam  = month_to_season(u850_mon, "MAM")
   v850_mam  = month_to_season(v850_mon, "MAM")
   u200_mam  = month_to_season(u200_mon, "MAM")
   v200_mam  = month_to_season(v200_mon, "MAM")
   u500_mam  = month_to_season(u500_mon, "MAM")
   v500_mam  = month_to_season(v500_mon, "MAM")

   ; z500_mam_clim = dim_avg_n_Wrap(z500_mam, 0)
   ; printVarSummary(z500_mam_clim)
   ; fbinwrite(plotpath+"z500_clim.bin", z500_mam_clim)
   ;---------------------------------------------------------------------
   px1 = fbindirread(binpath+"/waf/px_p1.bin", 0, (/73,144/), "float")
   py1 = fbindirread(binpath+"/waf/py_p1.bin", 0, (/73,144/), "float")
   copy_VarCoords(u200_mam(0,:,:), px1)
   copy_VarCoords(u200_mam(0,:,:), py1)
   px1@_FillValue = -9.99e+08
   py1@_FillValue = -9.99e+08

   pxy1 = px1
   pxy1 = sqrt(px1^2+py1^2)
   pxlat = conform(px1, u200_mam&lat, 0)
   px1 = mask(px1, abs(pxlat).gt.10, True)
   px1 = mask(px1, pxy1.gt.0.02, True)

   py1 = mask(py1, abs(pxlat).gt.10, True)
   py1 = mask(py1, pxy1.gt.0.02, True)
   ;---------------------------------------------------------------------
   ;---------------------------------------------------------------------
   px2 = fbindirread(binpath+"/waf/px_p2.bin", 0, (/73,144/), "float")
   py2 = fbindirread(binpath+"/waf/py_p2.bin", 0, (/73,144/), "float")
   copy_VarCoords(u200_mam(0,:,:), px2)
   copy_VarCoords(u200_mam(0,:,:), py2)
   px2@_FillValue = -9.99e+08
   py2@_FillValue = -9.99e+08

   pxy2 = px2
   pxy2 = sqrt(px2^2+py2^2)
   pxlat = conform(px2, u200_mam&lat, 0)
   px2 = mask(px2, abs(pxlat).gt.10, True)
   px2 = mask(px2, pxy2.gt.0.02, True)

   py2 = mask(py2, abs(pxlat).gt.10, True)
   py2 = mask(py2, pxy2.gt.0.02, True)
   ; printVarSummary(py2)

   ; printMinMax(px2, False)
   ; printMinMax(py2, False)
   ;---------------------------------------------------------------------
;************************************************
; Calculate Index
;************************************************
  EEU = snow_mam(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
  sci_eeu = dim_standardize_Wrap(wgt_areaave_Wrap(EEU, 1.0, 1.0, 1),0)
  sci_eeu = dtrend(sci_eeu, False)

   sci_eeu_res = sci_eeu - ao_mam*regline(ao_mam, sci_eeu)
   ; print("cor partial vs ori: "+ escorc(sci_eeu, sci_eeu_res))
 ;*****************************************************************
  ; snow_index = sci_eeu
  snow_index = sci_eeu_res

  ;ncep data 
  ndim_ncep = dimsizes(air_mam)
  sci_sat_rc = regCoef_n(snow_index, air_mam, 0, 0)
  copy_VarCoords(air_mam(0,:,:), sci_sat_rc)
  sci_sat_cor = escorc_n(snow_index, air_mam, 0, 0)

  df_ncep = sci_sat_cor
  df_ncep = ndim_ncep(0) - 2
  t_sat = sci_sat_cor*sqrt(df_ncep/(1- sci_sat_cor^2))
  p_sat = student_t(t_sat, df_ncep)
  copy_VarCoords(air_mam(0,:,:), p_sat)

  sci_z500_rc = regCoef_n(snow_index, z500_mam, 0, 0)
  copy_VarCoords(z500_mam(0,:,:), sci_z500_rc)
  sci_z500_cor = escorc_n(snow_index, z500_mam, 0, 0)
  p_z500 = student_t(sci_z500_cor*sqrt(df_ncep/(1- sci_z500_cor^2)), df_ncep)
  copy_VarCoords(z500_mam(0,:,:), p_z500)

  sci_u200_rc = regCoef_n(snow_index, u200_mam, 0, 0)
  copy_VarCoords(u200_mam(0,:,:), sci_u200_rc)
  sci_u200_cor = escorc_n(snow_index, u200_mam, 0, 0)
  p_u200 = student_t(sci_u200_cor*sqrt(df_ncep/(1- sci_u200_cor^2)), df_ncep)
  copy_VarCoords(u200_mam(0,:,:), p_u200)

  sci_v200_rc = regCoef_n(snow_index, v200_mam, 0, 0)
  copy_VarCoords(v200_mam(0,:,:), sci_v200_rc)
  sci_v200_cor = escorc_n(snow_index, v200_mam, 0, 0)
  p_v200 = student_t(sci_v200_cor*sqrt(df_ncep/(1- sci_v200_cor^2)), df_ncep)
  copy_VarCoords(v200_mam(0,:,:), p_v200)

  sci_u500_rc = regCoef_n(snow_index, u500_mam, 0, 0)
  copy_VarCoords(u500_mam(0,:,:), sci_u500_rc)
  sci_u500_cor = escorc_n(snow_index, u500_mam, 0, 0)
  p_u500 = student_t(sci_u500_cor*sqrt(df_ncep/(1- sci_u500_cor^2)), df_ncep)
  copy_VarCoords(u500_mam(0,:,:), p_u500)

  sci_v500_rc = regCoef_n(snow_index, v500_mam, 0, 0)
  copy_VarCoords(v500_mam(0,:,:), sci_v500_rc)
  sci_v500_cor = escorc_n(snow_index, v500_mam, 0, 0)
  p_v500 = student_t(sci_v500_cor*sqrt(df_ncep/(1- sci_v500_cor^2)), df_ncep)
  copy_VarCoords(v500_mam(0,:,:), p_v500)

  sfvp200 = uv2sfvpF(sci_u200_rc, sci_v200_rc) * 1e-5
  copy_VarCoords(sci_u200_rc, sfvp200(0,:,:))
  copy_VarCoords(sci_u200_rc, sfvp200(1,:,:))
  printMinMax(sfvp200, 0)

  sfvp500 = uv2sfvpF(sci_u500_rc, sci_v500_rc) * 1e-5
  copy_VarCoords(sci_u500_rc, sfvp500(0,:,:))
  copy_VarCoords(sci_u500_rc, sfvp500(1,:,:))
  printMinMax(sfvp500, 0)
;****************************************************************
;Partial Cor
   z500_mam_reform = z500_mam(lat|:,lon|:,time|:)
   sci_eeu_3d = conform(z500_mam_reform, sci_eeu, 2)
   ao_mam_3d = conform(z500_mam_reform, ao_mam, 2)

   xx = sci_eeu_3d
   yy = z500_mam_reform
   zz = ao_mam_3d   ;control variable
   pcor = (escorc(xx, yy) - escorc(xx, zz)*escorc(yy, zz))/(sqrt(1-escorc(xx,zz)^2)*sqrt(1-escorc(yy,zz)))
   copy_VarCoords(z500_mam(0,:,:), pcor)
   
   ndim0 = ndim_ncep(0)
   df_pcor = df_ncep
   df_pcor = df_ncep - 1 
   p_pcor = student_t(pcor*sqrt((ndim0-2)/(1-pcor^2)), df_pcor)   
   copy_VarCoords(z500_mam(0,:,:), p_pcor)
;****************************************************************
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
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@mpGridAndLimbOn = False
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpFillOn = False
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.25
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 360.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.

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
   rescor@cnFillScaleF = 1.
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillOpacityF = 1.0

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
   resV@vcRefMagnitudeF = 0.5
   resV@vcRefLengthF = 0.06
   resV@vcRefAnnoArrowLineColor = "black"  
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.75
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.8               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
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
;**********************************************************
;Draw contour
   
   resrc@cnMaxLevelValF = 20.
   resrc@cnMinLevelValF = -20.
   resrc@cnLevelSpacingF = 2.
   ; resrc@gsnLeftString = "a) WAF + SF P1"
   resrc@gsnLeftString = "b) WAF + Z500 P2"
   ; phgt = gsn_csm_contour_map(wks, sci_z500_rc, resrc)
   ; phgt = gsn_csm_contour_map(wks, sfvp500(0,:,:), resrc)

   resrc@cnMaxLevelValF = 1.0
   resrc@cnMinLevelValF = -1.0
   resrc@cnLevelSpacingF = 0.05
   phgt = gsn_csm_contour_map(wks, pcor, resrc)
   pcordot = gsn_csm_contour(wks, p_pcor, rescor)

   ; pwaf = gsn_csm_vector(wks, px1, py1, resV)
   pwaf = gsn_csm_vector(wks, px2, py2, resV)

   overlay(phgt, pwaf)
   overlay(phgt, pcordot)

   draw(phgt)
   frame(wks)
  


end
