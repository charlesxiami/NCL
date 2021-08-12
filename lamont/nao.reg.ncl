load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
  ;P1+P2
   yrstrt = 197201
   yrlast = 201412

   yrstrt_snow = 197201
   yrlast_snow = 201412

   ;P1
   ; yrstrt = 197301
   ; yrlast = 199312

   ; yrstrt_snow = 197201
   ; yrlast_snow = 199212

  ;P2
   ; yrstrt = 199401
   ; yrlast = 201512

   ; yrstrt_snow = 199301
   ; yrlast_snow = 201412

   nyrs = yrlast/100-yrstrt/100+1
   print(nyrs+" years")

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_nao = yrstrt
   yrlast_nao = yrlast

   year = ispan(yrstrt_snow/100, yrlast_snow/100, 1)

;---------------W,E-index Region
   SCI_EEU_N = 70
   SCI_EEU_S = 40
   SCI_EEU_L = 80
   SCI_EEU_R = 140
 
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
   wks=gsn_open_wks("pdf", plotpath+"nao.reg")
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
   precipdata = addfile(precpath+"precip.mon.anom.nc", "r")

   ;Nao 195001-201806
   nao_index = asciiread(indexpath+"norm.nao.monthly.b5001.current.ascii.txt", -1, "string")
   nao_index2 = stringtofloat(str_get_field(nao_index, 3, " "))
   nao_index3 = nao_index2(0:dimsizes(nao_index2)-9)

   month_time = yyyymm_time(1950, 2018, "integer")
   month_time!0 = "time"
   month_time@long_name = "time"
   month_time@units = "month"
   nao_index3!0 = "time"
   nao_index3&time = month_time

   ;PNA 195001-
   pna_index = asciiread(indexpath+"norm.pna.monthly.b5001.current.ascii.txt", -1, "string")
   pna_mon = stringtofloat(str_get_field(pna_index, 3, " "))
   pna_djf = new((/67/), float)  ; pna_djf: 1950/51DJF-2016/7DJF
   pna_mam = new((/67/), float)  ; pna_mam: 1950MAM-2016MAM
   do i = 0,66
    pna_djf(i) = dim_avg_Wrap(pna_mon(i*12+11:i*12+13))
   end do 
   do i = 0,66
    pna_mam(i) = dim_avg_Wrap(pna_mon(i*12+2:i*12+4))
   end do

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

   iStrt4  = ind(nao_index3&time.eq.yrstrt_nao)
   iLast4  = ind(nao_index3&time.eq.yrlast_nao)
   print("nao time: "+nao_index3&time(iStrt4)+"--"+nao_index3&time(iLast4))
 ;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})

   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR})

   z70_mon = hgtdata->hgt(iStrt:iLast,{70},{latS:latN},{lonL:lonR})

   z50_mon = hgtdata->hgt(iStrt:iLast,{50},{latS:latN},{lonL:lonR})

   u850_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR})
   v850_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 

   u200_mon = uwnddata->uwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})
   v200_mon = vwnddata->vwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})

   nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   
   nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})

   shf_mon = shfdata->shtfl(iStrt:iLast,{latS:latN},{lonL:lonR})

   lhf_mon = lhfdata->lhtfl(iStrt:iLast,{latS:latN},{lonL:lonR})

   soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})

   precip_mon = precipdata->precip(iStrt:iLast,{latS:latN},{lonL:lonR})

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)

   nao_mon = nao_index3(iStrt4:iLast4) 
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
   nao_djf = month_to_season(nao_mon, "DJF")
   ndimnao = dimsizes(nao_djf)

   snow_mam  = month_to_season(snow_mon, "SON")

   season = "SON"
   air_mam    = month_to_season(air_mon, season)
   slp_mam    = month_to_season(slp_mon, season)
   z500_mam  = month_to_season(z500_mon, season)
   z200_mam  = month_to_season(z200_mon, season)
   z70_mam  = month_to_season(z70_mon, season)
   z50_mam  = month_to_season(z50_mon, season)
   ; zmulti_mam = month_to_season(zmulti_mon, season)
   sst_mam    = month_to_season(sst_mon, season)
   u850_mam  = month_to_season(u850_mon, season)
   v850_mam  = month_to_season(v850_mon, season)
   u200_mam  = month_to_season(u200_mon, season)
   precip_mam = month_to_season(precip_mon, season)

   nswr_mam   = month_to_season(nswr_mon, season)
   nlwr_mam   = month_to_season(nlwr_mon, season)
   shf_mam     = month_to_season(shf_mon, season)
   lhf_mam     = month_to_season(lhf_mon, season)
   soilw_mam = month_to_season(soilw_mon, season)

 ;*****************************************************************
   nao_djf = dtrend(nao_djf, False)

 ;*****************************************************************
   ihp = 1
   fca = 1.0/10.
   nwt = 7
   wgt_hf2 = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

   ; snow_eu_pc1 = wgt_runave_Wrap(snow_eu_pc1, wgt_hf2, 0)
   ; snow_eu_pc3 = wgt_runave_Wrap(snow_eu_pc3, wgt_hf2, 0)
   ; nao_mam = wgt_runave_Wrap(nao_mam, wgt_hf2, 0)

   ; snow_mam = wgt_runave_n_Wrap(snow_mam, wgt_hf2, 0, 0)
   ; air_mam  = wgt_runave_n_Wrap(air_mam, wgt_hf2, 0, 0)
   ; precip_mam = wgt_runave_n_Wrap(precip_mam, wgt_hf2, 0, 0)
   ; slp_mam  = wgt_runave_n_Wrap(slp_mam, wgt_hf2, 0, 0)
   ; z500_mam = wgt_runave_n_Wrap(z500_mam, wgt_hf2, 0, 0)
   ; z200_mam = wgt_runave_n_Wrap(z200_mam, wgt_hf2, 0, 0)
   ; z70_mam = wgt_runave_n_Wrap(z70_mam, wgt_hf2, 0, 0)
   ; z50_mam = wgt_runave_n_Wrap(z50_mam, wgt_hf2, 0, 0)
   ; ; zmulti_mam = wgt_runave_n_Wrap(zmulti_mam, wgt_hf2, 0, 0)
   ; u850_mam = wgt_runave_n_Wrap(u850_mam, wgt_hf2, 0, 0)
   ; v850_mam = wgt_runave_n_Wrap(v850_mam, wgt_hf2, 0, 0)
   ; u200_mam = wgt_runave_n_Wrap(u200_mam, wgt_hf2, 0, 0)
   ; sst_mam  = wgt_runave_n_Wrap(sst_mam, wgt_hf2, 0, 0)
;*****************************************************************
;*****************************************************************
 ;Partial Reg
 ;DJF
 ;--------------------------------------------------------------
 ;Remove NAO
 ;  sci_weu_res = sci_weu - nao_djf(16:63)*regline(nao_djf(16:63), sci_weu)
 ;  sci_eeu_res = sci_eeu - nao_djf(16:63)*regline(nao_djf(16:63), sci_eeu)
 ;  sci_na_res  = sci_na  - nao_djf(16:63)*regline(nao_djf(16:63), sci_na)
 ; ;Remove AO
 ;  sci_weu_res = sci_weu - ao_djf(16:63)*regline(ao_djf(16:63), sci_weu)
 ;  sci_eeu_res = sci_eeu - ao_djf(16:63)*regline(ao_djf(16:63), sci_eeu)
 ;  sci_na_res  = sci_na  - ao_djf(16:63)*regline(ao_djf(16:63), sci_na)
 ;Remove AO and NAO
  ; sci_weu_res = sci_weu - nao_djf(16:63)*regline(nao_djf(16:63), sci_weu)- \
  ;                        ao_djf(16:63)*regline(ao_djf(16:63), sci_weu)
  ; sci_eeu_res = sci_eeu - nao_djf(16:63)*regline(nao_djf(16:63), sci_eeu)- \
  ;                        ao_djf(16:63)*regline(ao_djf(16:63), sci_eeu)
  ; sci_na_res  = sci_na  - nao_djf(16:63)*regline(nao_djf(16:63), sci_na)- \
  ;                        ao_djf(16:63)*regline(ao_djf(16:63), sci_na)
  ;--------------------------------------------------------------

 ;MAM
 ;--------------------------------------------------------------
 ; print("Remove NAO")
 ;  sci_weu_res = sci_weu - nao_mam(17:64)*regline(nao_mam(17:64), sci_weu)
 ;  sci_eeu_res = sci_eeu - nao_mam(17:64)*regline(nao_mam(17:64), sci_eeu)
 ;  sci_na_res  = sci_na  - nao_mam(17:64)*regline(nao_mam(17:64), sci_na)
 ; print("Remove AO")
 ;  sci_weu_res = sci_weu - ao_mam(17:64)*regline(ao_mam(17:64), sci_weu)
 ;  sci_eeu_res = sci_eeu - ao_mam(17:64)*regline(ao_mam(17:64), sci_eeu)
 ;  sci_na_res  = sci_na  - ao_mam(17:64)*regline(ao_mam(17:64), sci_na)
  ; print("Remove AO and NAO")
  ; sci_weu_res = sci_weu - nao_mam(17:64)*regline(nao_mam(17:64), sci_weu)- \
  ;                        ao_mam(17:64)*regline(ao_mam(17:64), sci_weu)
  ; sci_eeu_res = sci_eeu - nao_mam(17:64)*regline(nao_mam(17:64), sci_eeu)- \
  ;                        ao_mam(17:64)*regline(ao_mam(17:64), sci_eeu)
  ; sci_na_res  = sci_na  - nao_mam(17:64)*regline(nao_mam(17:64), sci_na)- \
  ;                        ao_mam(17:64)*regline(ao_mam(17:64), sci_na)
  ;--------------------------------------------------------------

  ; print("Remove PNA")
  ; sci_eeu_res = sci_eeu - pna_mam(17:38)*regline(pna_mam(17:38), sci_eeu)  ;P1
  ; sci_eeu_res = sci_eeu - pna_mam(39:64)*regline(pna_mam(39:64), sci_eeu)  ;P2

  ; print(escorc(sci_eeu_res, sci_eeu))
  
  ; asciiwrite(plotpath+"sci_eeu_p1.txt", sci_eeu)
  ;********************************************
  ; print("SCI_EEU - PNA P1 =  "+ escorc(sci_eeu, pna_mam(17:38)))
  ; print("SCI_EEU - PNA P2 =  "+ escorc(sci_eeu, pna_mam(39:64)))
  ; print("EEU-PNA: "+ escorc(sci_eeu, pna_mam(39:64)))
;**********************************************************

;**********************************************************
;3-D Data analysis
;**********************************************************
 ;Reg and Cor

  ;Define index
  snow_index = nao_djf(0:ndimnao-1)
  ; snow_index = sci_eeu_res

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

  sci_slp_rc = regCoef_n(snow_index, slp_mam, 0, 0)
  copy_VarCoords(slp_mam(0,:,:), sci_slp_rc)
  sci_slp_cor = escorc_n(snow_index, slp_mam, 0, 0)
  p_slp = student_t(sci_slp_cor*sqrt(df_ncep/(1- sci_slp_cor^2)), df_ncep)
  copy_VarCoords(slp_mam(0,:,:), p_slp)

  sci_z500_rc = regCoef_n(snow_index, z500_mam, 0, 0)
  copy_VarCoords(z500_mam(0,:,:), sci_z500_rc)
  sci_z500_cor = escorc_n(snow_index, z500_mam, 0, 0)
  p_z500 = student_t(sci_z500_cor*sqrt(df_ncep/(1- sci_z500_cor^2)), df_ncep)
  copy_VarCoords(z500_mam(0,:,:), p_z500)

  sci_z200_rc = regCoef_n(snow_index, z200_mam, 0, 0)
  copy_VarCoords(z200_mam(0,:,:), sci_z200_rc)
  sci_z200_cor = escorc_n(snow_index, z200_mam, 0, 0)
  p_z200 = student_t(sci_z200_cor*sqrt(df_ncep/(1- sci_z200_cor^2)), df_ncep)
  copy_VarCoords(z200_mam(0,:,:), p_z200)

  sci_z50_rc = regCoef_n(snow_index, z50_mam, 0, 0)
  copy_VarCoords(z50_mam(0,:,:), sci_z50_rc)
  sci_z50_cor = escorc_n(snow_index, z50_mam, 0, 0)
  p_z50 = student_t(sci_z50_cor*sqrt(df_ncep/(1- sci_z50_cor^2)), df_ncep)
  copy_VarCoords(z50_mam(0,:,:), p_z50)

  ; sci_zmulti_rc = regCoef_n(snow_index, zmulti_mam, 0, 0)
  ; copy_VarCoords(zmulti_mam(0,:,:,:), sci_zmulti_rc)
  ; sci_zmulti_cor = escorc_n(snow_index, zmulti_mam, 0, 0)
  ; df_ncep_multi = sci_zmulti_cor
  ; df_ncep_multi = ndim_ncep(0) - 2
  ; p_zmulti = student_t(sci_zmulti_cor*sqrt(df_ncep_multi/(1- sci_zmulti_cor^2)), df_ncep_multi)
  ; copy_VarCoords(zmulti_mam(0,:,:,:), p_zmulti)

  sci_u200_rc = regCoef_n(snow_index, u200_mam, 0, 0)
  copy_VarCoords(u200_mam(0,:,:), sci_u200_rc)
  sci_u200_cor = escorc_n(snow_index, u200_mam, 0, 0)
  p_u200 = student_t(sci_u200_cor*sqrt(df_ncep/(1- sci_u200_cor^2)), df_ncep)
  copy_VarCoords(u200_mam(0,:,:), p_u200)

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

  sci_uv850_rc = sci_u850_rc
  sci_uv850_rc = sqrt(sci_u850_rc^2+sci_v850_rc^2)

  sci_u850_rc = mask(sci_u850_rc, sci_uv850_rc.ge.0.2, True)
  sci_v850_rc = mask(sci_v850_rc, sci_uv850_rc.ge.0.2, True)

  ;heat flux data (gaussian)
  ndim_htfl = dimsizes(nswr_mam)
  sci_swr_rc = regCoef_n(snow_index, nswr_mam, 0, 0)
  copy_VarCoords(nswr_mam(0,:,:), sci_swr_rc)
  sci_swr_cor = escorc_n(snow_index, nswr_mam, 0, 0)
  df_htfl = sci_swr_cor
  df_htfl = ndim_htfl(0) - 2
  p_swr = student_t(sci_swr_cor*sqrt(df_htfl/(1- sci_swr_cor^2)), df_htfl)
  copy_VarCoords(nswr_mam(0,:,:), p_swr)

  sci_lwr_rc = regCoef_n(snow_index, nlwr_mam, 0, 0)
  copy_VarCoords(nlwr_mam(0,:,:), sci_lwr_rc)
  sci_lwr_cor = escorc_n(snow_index, nlwr_mam, 0, 0)
  df_htfl = sci_lwr_cor
  df_htfl = ndim_htfl(0) - 2
  p_lwr = student_t(sci_lwr_cor*sqrt(df_htfl/(1- sci_lwr_cor^2)), df_htfl)
  copy_VarCoords(nlwr_mam(0,:,:), p_lwr)

  sci_shf_rc = regCoef_n(snow_index, shf_mam, 0, 0)
  copy_VarCoords(shf_mam(0,:,:), sci_shf_rc)
  sci_shf_cor = escorc_n(snow_index, shf_mam, 0, 0)
  p_shf = student_t(sci_shf_cor*sqrt(df_htfl/(1- sci_shf_cor^2)), df_htfl)
  copy_VarCoords(shf_mam(0,:,:), p_shf)

  sci_lhf_rc = regCoef_n(snow_index, lhf_mam, 0, 0)
  copy_VarCoords(lhf_mam(0,:,:), sci_lhf_rc)
  sci_lhf_cor = escorc_n(snow_index, lhf_mam, 0, 0)
  p_lhf = student_t(sci_lhf_cor*sqrt(df_htfl/(1- sci_lhf_cor^2)), df_htfl)
  copy_VarCoords(lhf_mam(0,:,:), p_lhf)

  sci_sst_rc = regCoef_n(snow_index, sst_mam, 0, 0)
  copy_VarCoords(sst_mam(0,:,:), sci_sst_rc)
  sci_sst_cor = escorc_n(snow_index, sst_mam, 0, 0)
  ndim_sst = dimsizes(sst_mam)
  df_sst = sci_sst_cor
  df_sst = ndim_sst(0) - 2
  p_sst = student_t(sci_sst_cor*sqrt(df_sst/(1- sci_sst_cor^2)), df_sst)
  copy_VarCoords(sst_mam(0,:,:), p_sst)

   sci_precip_rc = regCoef_n(snow_index, precip_mam, 0, 0)
   copy_VarCoords(precip_mam(0,:,:), sci_precip_rc)
   df   := precip_mam(0,:,:)
   df  = ndim_ncep(0) - 2
   tval := onedtond(sci_precip_rc@tval, dimsizes(sci_precip_rc))
   b    := tval
   b    = 0.5
   p_precip = betainc(df/(df+tval^2),df/2.0,b)
   copy_VarCoords(precip_mam(0,:,:), p_precip)

  ; df_sce = onedtond(weu_sce_rc@nptxy,dimsizes(weu_sce_rc))- 2
  ; tval_sce = onedtond(weu_sce_rc@tval, dimsizes(weu_sce_rc))
  ; b = tval_sce
  ; b = 0.5
  ; prob_sce = betainc(df_sce/(df_sce+tval_sce^2), df_sce/2.0, b)
  ; copy_VarCoords(snow_mam(0,:,:), weu_sce_rc)
  ; copy_VarCoords(snow_mam(0,:,:), prob_sce)
  ; printVarSummary(prob_sce)
  ; printMinMax(prob_sce, False)
  
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
   ; res_circ@mpMinLonF = 0
   ; res_circ@mpMaxLonF = 360
   ; res_circ@mpMaxLatF = 90
   res_circ@mpMinLatF = 0
   res_circ@mpCenterLonF = (res_circ@mpMinLonF+res_circ@mpMaxLonF)/2.

   res_snow = resrc
   res_snow@lbLabelBarOn = True

   res_htfl = res_circ
   res_htfl@cnMaxLevelValF = 8.
   res_htfl@cnMinLevelValF = -8.
   res_htfl@cnLevelSpacingF = 1.

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
;**********************************************************
;Time Series plot
  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               
  rts@vpHeightF = 0.35        ; Changes the aspect ratio
  rts@vpWidthF  = 0.80
  rts@vpXF      = 0.15        ; change start locations
  rts@vpYF      = 0.75        ; the plot 
  rts@gsnLeftStringFontHeightF = 0.025
  rts@tmYLLabelFontHeightF = 0.015
  rts@tmYLLabelFontHeightF = 0.015

  rts_bar = rts  ; Bar Chart
  rts_bar@gsnXYBarChart         = True
  rts_bar@gsnYRefLine = 0.
  ;rts_bar@gsnLeftString = "(b) PC1"
  ;rts_bar@tmXUseBottom = True
  rts_bar@tmXBMode = "Explicit"
  ; rts_bar@tmXBValues = ispan(1975, 2005, 5)
  ; rts_bar@tmXBLabels = ispan(1975, 2005, 5)
  ; rts_bar@tmXBMinorValues = ispan(1972, 2009, 1)
  rts_bar@tmXTOn = False
  rts_bar@tmYROn = False
  rts_bar@tiXAxisString = "Time (Year)"
  rts_bar@tiYAxisString = " "
  rts_bar@tiXAxisFontHeightF = 0.02
  rts_bar@tiYAxisFontHeightF = 0.02
  ; rts_bar@trXMinF = 1971.5
  ; rts_bar@trXMaxF = 2009.5
  rts_bar@trYMinF = -3.0
  rts_bar@trYMaxF = 3.0

  rts_line = rts   ; Line
  rts_line@xyDashPattern         = 1
  rts_line@xyLineThicknessF      = 4.
  rts_line@xyLineColor = "black"

  rtsP = True
  rtsP@lbLabelAutoStride = True
;****************************************************************
;Polyline
   ;Polyline Setting
   Expts = (/SCI_EEU_L, SCI_EEU_L, SCI_EEU_R, SCI_EEU_R, SCI_EEU_L/)
   Eypts = (/SCI_EEU_S, SCI_EEU_N, SCI_EEU_N, SCI_EEU_S, SCI_EEU_S/)

   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 1.5
   plres@gsLineLabelString = ""

   dum1 = new(dimsizes(Expts)-1, graphic)
   dum2 = new(dimsizes(Expts)-1, graphic)
   dum3 = new(dimsizes(Expts)-1, graphic)
;**********************************************************
;Draw contour

   res_snow@cnMaxLevelValF = 8
   res_snow@cnMinLevelValF = -1*res_snow@cnMaxLevelValF
   res_snow@cnLevelSpacingF = 0.5
   res_snow@mpMinLonF = 0
   res_snow@mpMaxLonF = 160
   res_snow@mpMaxLatF = 80
   res_snow@mpMinLatF = 20
   ; res_snow@gsnPolar = "NH"
   ; res_snow@mpMinLatF = 20.
   ; res_snow@lbOrientation = "Vertical"
  ; res_snow@gsnLeftString = "Snow Reg "+
  snowplot = gsn_csm_contour_map(wks, sci_sce_rc, res_snow)
  snowdot = gsn_csm_contour(wks, p_sce, rescor)
  overlay(snowplot, snowdot)
   ; do i = 0, dimsizes(Expts)-2
   ;     dum2(i) = gsn_add_polyline(wks, snowplot, Expts(i:i+1), \
   ;                                Eypts(i:i+1), plres)
   ; end do
   draw(snowplot)
   frame(wks)

   resrc@cnMaxLevelValF = 0.3
   resrc@cnMinLevelValF = -0.3
   resrc@cnLevelSpacingF = 0.01
   res_prec = resrc
   res_prec@cnFillPalette = "MPL_BrBG"
   precipplot = gsn_csm_contour_map(wks, sci_precip_rc, res_prec)
   precipdot = gsn_csm_contour(wks, p_precip, rescor)
   overlay(precipplot, precipdot)

   resrc@cnMaxLevelValF = 0.8
   resrc@cnMinLevelValF = -0.8
   resrc@cnLevelSpacingF = 0.05
   satplot = gsn_csm_contour_map(wks, sci_sat_rc, resrc)
   satdot = gsn_csm_contour(wks, p_sat, rescor)
   vcplot =  gsn_csm_vector(wks, sci_u850_rc, sci_v850_rc, resV)
   overlay(satplot, vcplot)
   overlay(satplot, satdot)

   resSST@cnMaxLevelValF = 0.5
   resSST@cnMinLevelValF = -1*resSST@cnMaxLevelValF
   resSST@cnLevelSpacingF = 0.01
   resSST@gsnLeftString = "SST Reg "+ season
   sstplot = gsn_csm_contour_map(wks, sci_sst_rc, resSST)
   sstsig = gsn_csm_contour(wks, p_sst, rescor)
   overlay(sstplot, sstsig)
   ; draw(sstplot)
   ; frame(wks)

   delete(res_circ@mpMinLonF)
   delete(res_circ@mpMaxLonF)
   delete(res_circ@mpMaxLatF)
   res_circ@gsnPolar = "NH"
   res_circ@mpMinLatF = 30
   res_circ@mpCenterLonF = 315

   res_circ@cnMaxLevelValF = 3.0
   res_circ@cnMinLevelValF = -3.0
   res_circ@cnLevelSpacingF = 0.3
   slpplot = gsn_csm_contour_map_polar(wks, sci_slp_rc, res_circ)
   slpdot = gsn_csm_contour(wks, p_slp, rescor)
   slpline = gsn_csm_contour(wks, sci_slp_rc, resrc2)
   overlay(slpplot, slpline)
   overlay(slpplot, slpdot)

   res_circ@cnMaxLevelValF = 30.
   res_circ@cnMinLevelValF = -30.
   res_circ@cnLevelSpacingF = 5.
   z500plot = gsn_csm_contour_map_polar(wks, sci_z500_rc, res_circ)
   z500dot = gsn_csm_contour(wks, p_z500, rescor)   
   z500line = gsn_csm_contour(wks, sci_z500_rc, resrc2)
   overlay(z500plot, z500line)
   overlay(z500plot, z500dot)

   z200plot = gsn_csm_contour_map_polar(wks, sci_z200_rc, res_circ)
   z200dot = gsn_csm_contour(wks, p_z200, rescor)   
   z200line = gsn_csm_contour(wks, sci_z200_rc, resrc2)
   overlay(z200plot, z200line)
   overlay(z200plot, z200dot)

   ; res_circ@cnMaxLevelValF = 50.
   ; res_circ@cnMinLevelValF = -50.
   ; res_circ@cnLevelSpacingF = 5.
   z50plot = gsn_csm_contour_map_polar(wks, sci_z50_rc, res_circ)
   z50dot = gsn_csm_contour(wks, p_z50, rescor)   
   z50line = gsn_csm_contour(wks, sci_z50_rc, resrc2)
   overlay(z50plot, z50line)
   overlay(z50plot, z50dot)

   plot_panel := new(4,graphic)
   plot_panel(0) = z50plot
   plot_panel(1) = z200plot
   plot_panel(2) = z500plot
   plot_panel(3) = slpplot
   resP@gsnPanelFigureStrings = (/"Z50","Z200","Z500","SLP"/)
   gsn_panel(wks, plot_panel, (/2,2/), resP)

   plot_panel := new(4,graphic)
   ; plot_panel(0) = snowplot
   plot_panel(1) = satplot
   plot_panel(2) = precipplot
   ; plot_panel(3) = sstplot
   resP@gsnPanelFigureStrings = (/"SCE","SAT","Precip","SST"/)
   ; gsn_panel(wks, plot_panel, (/4,1/), resP)

   resrc@cnMaxLevelValF = 3.0
   resrc@cnMinLevelValF = -3.0
   resrc@cnLevelSpacingF = 0.3
   resrc@mpMinLatF = 0
   ; resrc@gsnLeftString = "u200"
   u200plot = gsn_csm_contour_map(wks, sci_u200_rc, resrc)
   u200dot = gsn_csm_contour(wks, p_u200, rescor)
   u200line = gsn_csm_contour(wks, sci_u200_rc, resrc2)
   overlay(u200plot, u200line)
   overlay(u200plot, u200dot)
   ; draw(u200plot)
   ; frame(wks)

   swrplot = gsn_csm_contour_map(wks, sci_swr_rc, res_htfl)
   swrdot = gsn_csm_contour(wks, p_swr, rescor)
   overlay(swrplot, swrdot)
   lwrplot = gsn_csm_contour_map(wks, sci_lwr_rc, res_htfl)
   lwrdot = gsn_csm_contour(wks, p_lwr, rescor)
   overlay(lwrplot, lwrdot)
   shfplot = gsn_csm_contour_map(wks, sci_shf_rc, res_htfl)
   shfdot = gsn_csm_contour(wks, p_shf, rescor)
   overlay(shfplot, shfdot)
   lhfplot = gsn_csm_contour_map(wks, sci_lhf_rc, res_htfl)
   lhfdot = gsn_csm_contour(wks, p_lhf, rescor)
   overlay(lhfplot, lhfdot)

   htfl_panel := new(4,graphic)
   htfl_panel(0) = swrplot
   htfl_panel(1) = lwrplot
   htfl_panel(2) = shfplot
   htfl_panel(3) = lhfplot
   resP@gsnPanelLabelBar = True
   resP@gsnPanelFigureStrings = (/"SWR","LWR","SHF","LHF"/)
   ; gsn_panel(wks, htfl_panel, (/4,1/), resP)



end
