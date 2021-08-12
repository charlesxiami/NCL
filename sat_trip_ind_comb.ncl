load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   yrstrt = 196701   ;P1
   yrlast = 198812

   ; yrstrt = 198901  ;P2
   ; yrlast = 201912

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

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"sat_trip_ind_comb")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   sstdata = addfile(nceppath+"sst.mnmean.v5.nc", "r")
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")
   precipdata = addfile(precpath+"precip.mon.anom.nc", "r")

   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
   ; soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")

  ; ;Nao 195001-201806
  ;  nao_index = asciiread(indexpath+"norm.nao.monthly.b5001.current.ascii.txt", -1, "string")
  ;  nao_mon = stringtofloat(str_get_field(nao_index, 3, " "))
  ;  nao_djf = new((/67/), float)  ; nao_djf: 1950/51DJF-2016/7DJF
  ;  nao_mam = new((/67/), float)  ; nao_mam: 1950MAM-2016MAM
  ;  do i = 0,66
  ;   nao_djf(i) = dim_avg_Wrap(nao_mon(i*12+11:i*12+13))
  ;  end do 
  ;  do i = 0,66
  ;   nao_mam(i) = dim_avg_Wrap(nao_mon(i*12+2:i*12+4))
  ;  end do

  ;nino34
   nino34_table = readAsciiTable(indexpath+"nino34.long.anom.data.txt", 13, "float", (/1,7/))
   nino34_table2 = nino34_table(0:149,1:12)
   nino34 = ndtooned(nino34_table2)

   month_time = yyyymm_time(1870, 2019, "integer")
   month_time!0 = "time"
   month_time@long_name = "time"
   month_time@units = "month"

   nino34!0 = "time"
   nino34&time = month_time
   nsize = dimsizes(nino34)

  ;ao 195001-201912
   ao_table = asciiread(indexpath+"monthly.ao.index.b50.current.ascii.txt", -1, "string")
   ao_index_origin = stringtofloat(str_get_field(ao_table, 3, " "))
   ao_mon_all = ao_index_origin(0:839)
   month_time2 = yyyymm_time(1950, 2019, "integer")
   month_time2!0 = "time"
   month_time2@long_name = "time"
   month_time2@units = "month"

   ao_mon_all!0 = "time"
   ao_mon_all&time = month_time2

  ;north atlantic tripole
   nat_p1 = asciiread(indexpath+"nat_p1.txt", -1, "float")
   nat_p2 = asciiread(indexpath+"nat_p2.txt", -1, "float")
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

   iStrt4  = ind(nino34&time.eq.yrstrt)
   iLast4  = ind(nino34&time.eq.yrlast)
   print("nino time: "+nino34&time(iStrt4)+"--"+nino34&time(iLast4))

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
   
   ; soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})
   ; soilw_mam = month_to_season(soilw_mon, "MAM")
   
   precip_mon = precipdata->precip(iStrt:iLast,{latS:latN},{lonL:lonR})

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)

   nino34_mon = nino34(iStrt4:iLast4)
   nino34_mam = month_to_season(nino34_mon, "MAM")

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
   season = "MAM"
   print("season:  " + season)
   snow_mam  = month_to_season(snow_mon, "MAM")
   air_mam    = month_to_season(air_mon, season)
   slp_mam    = month_to_season(slp_mon, season)
   z500_mam  = month_to_season(z500_mon, season)
   z200_mam  = month_to_season(z200_mon, season)
   sst_mam    = month_to_season(sst_mon, season)
   u850_mam  = month_to_season(u850_mon, season)
   v850_mam  = month_to_season(v850_mon, season)
   u200_mam  = month_to_season(u200_mon, season)
   precip_mam = month_to_season(precip_mon, season)

   uv850_mam = u850_mam
   uv850_mam = sqrt(u850_mam^2 + v850_mam^2)
;************************************************
; Calculate Index
;************************************************
  EEU = snow_mam(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
  sci_eeu = dim_standardize_Wrap(wgt_areaave_Wrap(EEU, 1.0, 1.0, 1),0)
 ;*****************************************************************
  sci_eeu = dtrend(sci_eeu, False)

   sci_eeu_res = sci_eeu - ao_mam*regline(ao_mam, sci_eeu) - nino34_mam*regline(nino34_mam, sci_eeu)
   ao_mam_res = ao_mam - sci_eeu*regline(sci_eeu, ao_mam) - nino34_mam*regline(nino34_mam, ao_mam)
   nino34_mam_res = nino34_mam - sci_eeu*regline(sci_eeu, nino34_mam) - ao_mam*regline(ao_mam, nino34_mam)

  ; print("Remove NAT")
  ; sci_eeu_res = sci_eeu - nat_p1*regline(nat_p1, sci_eeu)  ;P1
  ; sci_eeu_res = sci_eeu - nat_p2*regline(nat_p2, sci_eeu)  ;P2

;**********************************************************
;Data analysis
;**********************************************************
 ;Reg and Cor
  snow_index = sci_eeu_res
  ;snow data
  sci_sce_rc = regCoef_n(snow_index, snow_mam, 0, 0)
  copy_VarCoords(snow_mam(0,:,:), sci_sce_rc)
  sci_sce_cor = escorc_n(snow_index, snow_mam, 0, 0)  
  ndim_snow = dimsizes(snow_mam)
  df_snow = sci_sce_cor
  df_snow = ndim_snow(0) - 2
  t_sce = sci_sce_cor*sqrt(df_snow/(1- sci_sce_cor^2 ))
  p_sce = student_t(t_sce, df_snow)
  copy_VarCoords(snow_mam(0,:,:), p_sce)

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

  sci_u850_rc = regCoef_n(snow_index, u850_mam, 0, 0)
  copy_VarCoords(u850_mam(0,:,:), sci_u850_rc)
  sci_u850_cor = escorc_n(snow_index, u850_mam, 0, 0)
  p_u850 = student_t(sci_u850_cor*sqrt(df_ncep/(1- sci_u850_cor^2)), df_ncep)
  copy_VarCoords(u850_mam(0,:,:), p_u850)

  sci_v850_rc = regCoef_n(snow_index, v850_mam, 0, 0)
  copy_VarCoords(v850_mam(0,:,:), sci_v850_rc)
  sci_v850_cor = escorc_n(snow_index, v850_mam, 0, 0)
  p_v850 = student_t(sci_v850_cor*sqrt(df_ncep/(1- sci_v850_cor^2)), df_ncep)
  copy_VarCoords(v850_mam(0,:,:), p_v850)

  sci_uv850_rc = regCoef_n(snow_index, uv850_mam, 0, 0)
  copy_VarCoords(uv850_mam(0,:,:), sci_uv850_rc)
  sci_uv850_cor = escorc_n(snow_index, uv850_mam, 0, 0)
  p_uv850 = student_t(sci_uv850_cor*sqrt(df_ncep/(1- sci_uv850_cor^2)), df_ncep)
  copy_VarCoords(uv850_mam(0,:,:), p_uv850)

  sc_w850_rc = sci_u850_rc
  sc_w850_rc = sqrt(sci_u850_rc^2+sci_v850_rc^2)

  sci_u850_rc = mask(sci_u850_rc, sc_w850_rc.ge.0.1, True)
  sci_v850_rc = mask(sci_v850_rc, sc_w850_rc.ge.0.1, True)

;------------------------------------------------------------------------------
  ; nino_index = nino34_mam
  nino_index = nino34_mam_res

  ;ncep data 
  ndim_ncep = dimsizes(air_mam)
  nino34_sat_rc = regCoef_n(nino_index, air_mam, 0, 0)
  copy_VarCoords(air_mam(0,:,:), nino34_sat_rc)
  nino34_sat_cor = escorc_n(nino_index, air_mam, 0, 0)

  t_nino_sat = nino34_sat_cor*sqrt(df_ncep/(1- nino34_sat_cor^2))
  p_nino_sat = student_t(t_nino_sat, df_ncep)
  copy_VarCoords(air_mam(0,:,:), p_nino_sat)

  nino34_u850_rc = regCoef_n(nino_index, u850_mam, 0, 0)
  copy_VarCoords(u850_mam(0,:,:), nino34_u850_rc)
  nino34_u850_cor = escorc_n(nino_index, u850_mam, 0, 0)
  p_nino_u850 = student_t(nino34_u850_cor*sqrt(df_ncep/(1- nino34_u850_cor^2)), df_ncep)
  copy_VarCoords(u850_mam(0,:,:), p_nino_u850)

  nino34_v850_rc = regCoef_n(nino_index, v850_mam, 0, 0)
  copy_VarCoords(v850_mam(0,:,:), nino34_v850_rc)
  nino34_v850_cor = escorc_n(nino_index, v850_mam, 0, 0)
  p_nino_v850 = student_t(nino34_v850_cor*sqrt(df_ncep/(1- nino34_v850_cor^2)), df_ncep)
  copy_VarCoords(v850_mam(0,:,:), p_nino_v850)

  nino34_uv850_rc = nino34_u850_rc
  nino34_uv850_rc = sqrt(nino34_u850_rc^2+nino34_v850_rc^2)

  nino34_u850_rc = mask(nino34_u850_rc, nino34_uv850_rc.ge.0.1, True)
  nino34_v850_rc = mask(nino34_v850_rc, nino34_uv850_rc.ge.0.1, True)
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
  ; ao_index = ao_mam
  ao_index = -1*ao_mam_res

  ;ncep data 
  ndim_ncep = dimsizes(air_mam)
  ao_sat_rc = regCoef_n(ao_index, air_mam, 0, 0)
  copy_VarCoords(air_mam(0,:,:), ao_sat_rc)
  ao_sat_cor = escorc_n(ao_index, air_mam, 0, 0)

  t_ao_sat = ao_sat_cor*sqrt(df_ncep/(1- ao_sat_cor^2))
  p_ao_sat = student_t(t_ao_sat, df_ncep)
  copy_VarCoords(air_mam(0,:,:), p_ao_sat)

  ao_u850_rc = regCoef_n(ao_index, u850_mam, 0, 0)
  copy_VarCoords(u850_mam(0,:,:), ao_u850_rc)
  ao_u850_cor = escorc_n(ao_index, u850_mam, 0, 0)
  p_ao_u850 = student_t(ao_u850_cor*sqrt(df_ncep/(1- ao_u850_cor^2)), df_ncep)
  copy_VarCoords(u850_mam(0,:,:), p_ao_u850)

  ao_v850_rc = regCoef_n(ao_index, v850_mam, 0, 0)
  copy_VarCoords(v850_mam(0,:,:), ao_v850_rc)
  ao_v850_cor = escorc_n(ao_index, v850_mam, 0, 0)
  p_ao_v850 = student_t(ao_v850_cor*sqrt(df_ncep/(1- ao_v850_cor^2)), df_ncep)
  copy_VarCoords(v850_mam(0,:,:), p_ao_v850)

  ao_uv850_rc = regCoef_n(ao_index, uv850_mam, 0, 0)
  copy_VarCoords(uv850_mam(0,:,:), ao_uv850_rc)
  ao_uv850_cor = escorc_n(ao_index, uv850_mam, 0, 0)
  p_ao_uv850 = student_t(ao_uv850_cor*sqrt(df_ncep/(1- ao_uv850_cor^2)), df_ncep)
  copy_VarCoords(uv850_mam(0,:,:), p_ao_uv850)

  ao_w850_rc = ao_u850_rc
  ao_w850_rc = sqrt(ao_u850_rc^2+ao_v850_rc^2)

  ao_u850_rc = mask(ao_u850_rc, ao_w850_rc.ge.0.1, True)
  ao_v850_rc = mask(ao_v850_rc, ao_w850_rc.ge.0.1, True)

  ; sci_z500_rc = regCoef_n(snow_index, z500_mam, 0, 0)
  ; copy_VarCoords(z500_mam(0,:,:), sci_z500_rc)
  ; sci_z500_cor = escorc_n(snow_index, z500_mam, 0, 0)
  ; p_z500 = student_t(sci_z500_cor*sqrt(df_ncep/(1- sci_z500_cor^2)), df_ncep)
  ; copy_VarCoords(z500_mam(0,:,:), p_z500)

  ; sci_u200_rc = regCoef_n(snow_index, u200_mam, 0, 0)
  ; copy_VarCoords(u200_mam(0,:,:), sci_u200_rc)
  ; sci_u200_cor = escorc_n(snow_index, u200_mam, 0, 0)
  ; p_u200 = student_t(sci_u200_cor*sqrt(df_ncep/(1- sci_u200_cor^2)), df_ncep)
  ; copy_VarCoords(u200_mam(0,:,:), p_u200)

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

   resSST = res_circ
   ; resSST@lbLabelBarOn = True
   resSST@mpMaxLonF = 360
   resSST@mpMinLonF = 0
   resSST@mpMaxLatF = 90
   resSST@mpMinLatF = -30
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
   rescor@cnFillScaleF = 1.
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
   resV@vcRefAnnoOrthogonalPosF = -0.25
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.8               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelLabelBar = True
   resP@pmLabelBarWidthF = 0.5
   resP@pmLabelBarOrthogonalPosF = -0.03
   resP@amJust = "TopLeft"   
   resP@gsnPanelFigureStringsFontHeightF = 0.02
   resP@gsnPanelFigureStringsPerimOn = False
   resP@gsnPanelFigureStringsBackgroundFillColor = "white"
   resP@gsnPanelYWhiteSpacePercent = 5
;**********************************************************

;**********************************************************
;Draw contour

   ; resrc@cnMaxLevelValF = 0.3
   ; resrc@cnMinLevelValF = -0.3
   ; resrc@cnLevelSpacingF = 0.01
   ; res_prec = resrc
   ; res_prec@cnFillPalette = "MPL_BrBG"
   ; precipplot = gsn_csm_contour_map(wks, sci_precip_rc, res_prec)
   ; precipdot = gsn_csm_contour(wks, p_precip, rescor)
   ; overlay(precipplot, precipdot)

   ; resrc@vpXF = 0.05
   ; resrc@vpYF = 0.98
   ; resrc@vpHeightF = 0.3
   ; resrc@vpWidthF = 0.4
   resrc@lbLabelBarOn = False
   ; resrc@tmXBLabelsOn = False
   resrc@cnMaxLevelValF = 1.0
   resrc@cnMinLevelValF = -1.0
   resrc@cnLevelSpacingF = 0.1
   resrc@gsnLeftStringFontHeightF = 0.015

   resrc@gsnLeftString = "a) SAT&UV850 regressed on SI in P1"
   ; resrc@gsnLeftString = "c) SAT&UV850 regressed on SI in P2"
   satplot = gsn_csm_contour_map(wks, sci_sat_rc, resrc)
   satdot = gsn_csm_contour(wks, p_sat, rescor)
   vcplot =  gsn_csm_vector(wks, sci_u850_rc, sci_v850_rc, resV)
   overlay(satplot, vcplot)
   overlay(satplot, satdot)

   ; resrc@gsnLeftString = "b) SAT&UV850 regressed on Nino34 in P2"
   ; ninoplot = gsn_csm_contour_map(wks, nino34_sat_rc, resrc)
   ; ninodot = gsn_csm_contour(wks, p_nino_sat, rescor)
   ; vcplot :=  gsn_csm_vector(wks, nino34_u850_rc, nino34_v850_rc, resV)
   ; overlay(ninoplot, vcplot)
   ; overlay(ninoplot, ninodot)
   ; ; draw(ninoplot)
   ; ; frame(wks)

   ; resrc@vpYF = 0.53
   ; resrc@tmXBLabelsOn = True
   resrc@gsnLeftString = "b) SAT&UV850 regressed on AO in P1"
   ; resrc@gsnLeftString = "d) SAT&UV850 regressed on AO in P2"
   aoplot = gsn_csm_contour_map(wks, ao_sat_rc, resrc)
   aodot = gsn_csm_contour(wks, p_ao_sat, rescor)
   vcplot :=  gsn_csm_vector(wks, ao_u850_rc, ao_v850_rc, resV)
   overlay(aoplot, vcplot)
   overlay(aoplot, aodot)

   trip_panel = new(2, graphic)
   trip_panel(0) = satplot
   ; trip_panel(1) = ninoplot
   trip_panel(1) = aoplot
   ; resP@gsnPanelFigureStrings = (/"b)","d)","f)"/)
   resP@pmLabelBarOrthogonalPosF = 0.01
   ; resP@gsnPanelDebug = True
   gsn_panel(wks, trip_panel, (/2,1/), resP)

  ;----------------------------------------------------------------------
   rescor2@gsnLeftString = "a) UV@850 regressed on SI in P1"
   ; rescor2@gsnLeftString = "c) UV@850 regressed on SI in P2"
   sigplot1 = gsn_csm_contour_map(wks, p_uv850, rescor2)
   vcplot :=  gsn_csm_vector(wks, sci_u850_rc, sci_v850_rc, resV)
   overlay(sigplot1, vcplot)

   rescor2@gsnLeftString = "b) UV@850 regressed on AO in P1"
   ; rescor2@gsnLeftString = "d) UV@850 regressed on AO in P2"
   sigplot2 = gsn_csm_contour_map(wks, p_ao_uv850, rescor2)
   vcplot :=  gsn_csm_vector(wks, ao_u850_rc, ao_v850_rc, resV)
   overlay(sigplot2, vcplot)

   wind_panel = new(2, graphic)
   wind_panel(0) = sigplot1
   wind_panel(1) = sigplot2
   gsn_panel(wks, wind_panel, (/2,1/), resP)

end
