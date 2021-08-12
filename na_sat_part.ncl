load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   yrstrt = 196701   ;P1+P2
   yrlast = 201412

   ; yrstrt = 196701   ;P1
   ; yrlast = 198812

   ; yrstrt = 198901  ;P2
   ; yrlast = 201412

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  year=ispan(yrstrt_snow/100, yrlast_snow/100, 1)
  ;t = ispan(1970, 2014, 1)
;---------------W,E-index Region
  SCI_EEU_N = 70
  SCI_EEU_S = 40
  SCI_EEU_L = 80
  SCI_EEU_R = 140
  
  AREA_NA_N = 60
  AREA_NA_S = 30
  AREA_NA_L = -100+360
  AREA_NA_R = -80+360

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "/public/home/charlesxiami/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"na_sat_part")
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
   nao_mon = stringtofloat(str_get_field(nao_index, 3, " "))
   nao_djf = new((/67/), float)  ; nao_djf: 1950/51DJF-2016/7DJF
   nao_mam = new((/67/), float)  ; nao_mam: 1950MAM-2016MAM
   do i = 0,66
    nao_djf(i) = dim_avg_Wrap(nao_mon(i*12+11:i*12+13))
   end do 
   do i = 0,66
    nao_mam(i) = dim_avg_Wrap(nao_mon(i*12+2:i*12+4))
   end do

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

   nino34_table = readAsciiTable(indexpath+"nino34.long.anom.data.txt", 13, "float", (/1,7/))
   nino34_table2 = nino34_table(0:147,1:12)
   nino34 = ndtooned(nino34_table2)

   month_time = yyyymm_time(1870, 2017, "integer")
   month_time!0 = "time"
   month_time@long_name = "time"
   month_time@units = "month"

   nino34!0 = "time"
   nino34&time = month_time

   ;ao 195001-201708
   ao_table = asciiread(indexpath+"monthly.ao.index.b50.current.ascii.txt", -1, "string")
   ao_ind = stringtofloat(str_get_field(ao_table, 3, " "))
   ao_mon_all = ao_ind(0:803)
   month_time2 = yyyymm_time(1950, 2016, "integer")
   month_time2!0 = "time"
   month_time2@long_name = "time"
   month_time2@units = "month"

   ao_mon_all!0 = "time"
   ao_mon_all&time = month_time2

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

   iStrt_ao  = ind(ao_mon_all&time.eq.yrstrt)
   iLast_ao  = ind(ao_mon_all&time.eq.yrlast)
   print("ao  time: "+ao_mon_all&time(iStrt_ao)+"--"+ao_mon_all&time(iLast_ao))

   iStrt_nino  = ind(nino34&time.eq.yrstrt)
   iLast_nino  = ind(nino34&time.eq.yrlast)
   print("nino  time: "+nino34&time(iStrt_nino)+"--"+nino34&time(iLast_nino))   
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
   
   soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})
   soilw_mam = month_to_season(soilw_mon, "MAM")
   
   precip_mon = precipdata->precip(iStrt:iLast,{latS:latN},{lonL:lonR})

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)

   nino34_mon = nino34(iStrt_nino:iLast_nino)
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
;************************************************
; Calculate Index
;************************************************
  EEU = snow_mam(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
  sci_eeu = dim_standardize_Wrap(wgt_areaave_Wrap(EEU, 1.0, 1.0, 1),0)
 ;*****************************************************************
  sci_eeu = dtrend(sci_eeu, False)
  ; nino34_mam = dtrend(nino34_mam, False)
  ; ao_mam = dtrend(ao_mam, False)
  ; print(dim_avg(sci_eeu))
  ; print(dim_stddev(sci_eeu))

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


  ; print("Remove NAT")
  ; sci_eeu_res = sci_eeu - nat_p1*regline(nat_p1, sci_eeu)  ;P1
  ; sci_eeu_res = sci_eeu - nat_p2*regline(nat_p2, sci_eeu)  ;P2

  ;********************************************
  ; print("SCI_EEU - PNA P1 =  "+ escorc(sci_eeu, pna_mam(17:38)))
  ; print("SCI_EEU - PNA P2 =  "+ escorc(sci_eeu, pna_mam(39:64)))
  ; print("EEU-PNA: "+ escorc(sci_eeu, pna_mam(39:64)))

   sci_eeu_res = sci_eeu - ao_mam*regline(ao_mam, sci_eeu) - nino34_mam*regline(nino34_mam, sci_eeu)
   ao_mam_res = ao_mam - sci_eeu*regline(sci_eeu, ao_mam) - nino34_mam*regline(nino34_mam, ao_mam)
   nino34_mam_res = nino34_mam - sci_eeu*regline(sci_eeu, nino34_mam) - ao_mam*regline(ao_mam, nino34_mam)

;**********************************************************

;**********************************************************
;3-D Data analysis
;**********************************************************
 ;Reg and Cor

  ;-----------------------------------------------------------------------------
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

  sci_precip_rc = regCoef_n(snow_index, precip_mam, 0, 0)
  copy_VarCoords(precip_mam(0,:,:), sci_precip_rc)
  df   := onedtond(sci_precip_rc@nptxy, dimsizes(sci_precip_rc)) - 2
  tval := onedtond(sci_precip_rc@tval, dimsizes(sci_precip_rc))
  b    := tval
  b    = 0.5
  p_precip = betainc(df/(df+tval^2),df/2.0,b)
  copy_VarCoords(precip_mam(0,:,:), p_precip)
  ;-----------------------------------------------------------------------------
  ;-----------------------------------------------------------------------------
  nino_index = nino34_mam

  ;ncep data 
  ndim_ncep = dimsizes(air_mam)
  nino_sat_rc = regCoef_n(nino_index, air_mam, 0, 0)
  copy_VarCoords(air_mam(0,:,:), nino_sat_rc)
  nino_sat_cor = escorc_n(nino_index, air_mam, 0, 0)

  df_ncep = nino_sat_cor
  df_ncep = ndim_ncep(0) - 2
  nino_t_sat = nino_sat_cor*sqrt(df_ncep/(1- nino_sat_cor^2))
  nino_p_sat = student_t(nino_t_sat, df_ncep)
  copy_VarCoords(air_mam(0,:,:), nino_p_sat)

  nino_z500_rc = regCoef_n(nino_index, z500_mam, 0, 0)
  copy_VarCoords(z500_mam(0,:,:), nino_z500_rc)
  nino_z500_cor = escorc_n(nino_index, z500_mam, 0, 0)
  nino_p_z500 = student_t(nino_z500_cor*sqrt(df_ncep/(1- nino_z500_cor^2)), df_ncep)
  copy_VarCoords(z500_mam(0,:,:), nino_p_z500)

  nino_precip_rc = regCoef_n(nino_index, precip_mam, 0, 0)
  copy_VarCoords(precip_mam(0,:,:), nino_precip_rc)
  df   := onedtond(nino_precip_rc@nptxy, dimsizes(nino_precip_rc)) - 2
  tval := onedtond(nino_precip_rc@tval, dimsizes(nino_precip_rc))
  b    := tval
  b    = 0.5
  nino_p_precip = betainc(df/(df+tval^2),df/2.0,b)
  copy_VarCoords(precip_mam(0,:,:), nino_p_precip)
  ;-----------------------------------------------------------------------------
  ;-----------------------------------------------------------------------------
  ao_index = ao_mam_res

  ;ncep data 
  ndim_ncep = dimsizes(air_mam)
  ao_sat_rc = regCoef_n(ao_index, air_mam, 0, 0)
  copy_VarCoords(air_mam(0,:,:), ao_sat_rc)
  ao_sat_cor = escorc_n(ao_index, air_mam, 0, 0)

  df_ncep = ao_sat_cor
  df_ncep = ndim_ncep(0) - 2
  ao_t_sat = ao_sat_cor*sqrt(df_ncep/(1- ao_sat_cor^2))
  ao_p_sat = student_t(ao_t_sat, df_ncep)
  copy_VarCoords(air_mam(0,:,:), ao_p_sat)

  ao_z500_rc = regCoef_n(ao_index, z500_mam, 0, 0)
  copy_VarCoords(z500_mam(0,:,:), ao_z500_rc)
  ao_z500_cor = escorc_n(ao_index, z500_mam, 0, 0)
  ao_p_z500 = student_t(ao_z500_cor*sqrt(df_ncep/(1- ao_z500_cor^2)), df_ncep)
  copy_VarCoords(z500_mam(0,:,:), ao_p_z500)

  ao_precip_rc = regCoef_n(ao_index, precip_mam, 0, 0)
  copy_VarCoords(precip_mam(0,:,:), ao_precip_rc)
  df   := onedtond(ao_precip_rc@nptxy, dimsizes(ao_precip_rc)) - 2
  tval := onedtond(ao_precip_rc@tval, dimsizes(ao_precip_rc))
  b    := tval
  b    = 0.5
  ao_p_precip = betainc(df/(df+tval^2),df/2.0,b)
  copy_VarCoords(precip_mam(0,:,:), p_precip)
  ;-----------------------------------------------------------------------------
  ;-----------------------------------------------------------------------------
  ;calculate percentage
  sat_std_mam = dim_stddev_n_Wrap(air_mam, 0)

  sat_std_na = sat_std_mam({AREA_NA_S:AREA_NA_N},{AREA_NA_L:AREA_NA_R})

  sci_sat_na = sci_sat_rc({AREA_NA_S:AREA_NA_N},{AREA_NA_L:AREA_NA_R})
  ao_sat_na = ao_sat_rc({AREA_NA_S:AREA_NA_N},{AREA_NA_L:AREA_NA_R})
  nino_sat_na = nino_sat_rc({AREA_NA_S:AREA_NA_N},{AREA_NA_L:AREA_NA_R})

  ;mask ocean
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
  lsdata = a->LSMASK
  lsm = landsea_mask(lsdata,sci_sat_na&lat,sci_sat_na&lon)

  sat_std_na_land = mask(sat_std_na, lsm.eq.1, True)
  sci_sat_na_land = mask(sci_sat_na, lsm.eq.1, True)
  ao_sat_na_land = mask(ao_sat_na, lsm.eq.1, True)
  nino_sat_na_land = mask(nino_sat_na, lsm.eq.1, True)
  copy_VarCoords(sci_sat_na, sci_sat_na_land)
  copy_VarCoords(ao_sat_na, ao_sat_na_land)
  copy_VarCoords(nino_sat_na, nino_sat_na_land)

  ; print(nino_sat_na({30:50},{220:230}))
  ; print(nino_sat_na_land({30:50},{220:230}))

  sat_sqr = sat_std_na_land^2
  sci_sat_sqr =  sci_sat_na_land^2
  nino_sat_sqr = nino_sat_na_land^2
  ao_sat_sqr = ao_sat_na_land^2
  copy_VarCoords(sat_std_mam({AREA_NA_S:AREA_NA_N},{AREA_NA_L:AREA_NA_R}), sat_sqr)
  copy_VarCoords(sat_std_mam({AREA_NA_S:AREA_NA_N},{AREA_NA_L:AREA_NA_R}), sci_sat_sqr)
  copy_VarCoords(sat_std_mam({AREA_NA_S:AREA_NA_N},{AREA_NA_L:AREA_NA_R}), nino_sat_sqr)
  copy_VarCoords(sat_std_mam({AREA_NA_S:AREA_NA_N},{AREA_NA_L:AREA_NA_R}), ao_sat_sqr)

  pct_sci  = wgt_areaave_Wrap(sci_sat_sqr, 1., 1., 1)/wgt_areaave_Wrap(sat_sqr, 1., 1., 1)
  pct_nino = wgt_areaave_Wrap(nino_sat_sqr, 1., 1., 1)/wgt_areaave_Wrap(sat_sqr, 1., 1., 1)
  pct_ao   = wgt_areaave_Wrap(ao_sat_sqr, 1., 1., 1)/wgt_areaave_Wrap(sat_sqr, 1., 1., 1)

  print("Explained by Snow:  " + pct_sci)
  print("Explained by ENSO:  " + pct_nino)
  print("Explained by AO:  " + pct_ao)
;**********************************************************
;Calculate index
  sat_mam_na = air_mam(:,{AREA_NA_S:AREA_NA_N},{AREA_NA_L:AREA_NA_R})
  sat_na_index = wgt_areaave_Wrap(sat_mam_na, 1., 1., 1)
  sat_na_index = dim_standardize_Wrap(sat_na_index, 1)

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
   resrc@mpMinLonF = 180.
   resrc@mpMaxLonF = 330.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.
   resrc@mpCenterLonF = (resrc@mpMinLonF+resrc@mpMaxLonF)/2.
   resrc@mpAreaMaskingOn = True
   resrc@mpOceanFillColor = "white"
   resrc@mpLandFillColor = "Transparent"
   ; resrc@mpMaskAreaSpecifiers =(/"China","Taiwan"/)

   res_circ = resrc
   res_circ@mpFillOn = False   
   res_circ@mpMinLonF = 0.
   res_circ@mpMaxLonF = 360.
   res_circ@mpMaxLatF = 90.
   res_circ@mpMinLatF = 0.
   res_circ@mpCenterLonF = (res_circ@mpMinLonF+res_circ@mpMaxLonF)/2.

   res_snow = resrc
   res_snow@lbLabelBarOn = True

   res_htfl = res_circ
   res_htfl@cnMaxLevelValF = 8.
   res_htfl@cnMinLevelValF = -8.
   res_htfl@cnLevelSpacingF = 1.

   resSST = res_circ
   ; resSST@lbLabelBarOn = True
   resSST@mpMaxLonF = 360.
   resSST@mpMinLonF = 0.
   resSST@mpMaxLatF = 90.
   resSST@mpMinLatF = -30.
   resSST@mpCenterLonF = 180.

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
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"

;****************************************************************
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
  ; rts_bar@gsnAboveYRefLineColor = (/"blue"/)
  ; rts_bar@gsnBelowYRefLineColor = (/"red"/)
  ; rts_bar@gsnAboveYRefLineBarColors = (/"blue", "green", "mediumaquamarine"/)
  ; rts_bar@gsnBelowYRefLineBarColors = (/"red", "orange","brown"/)
  rts_bar@gsnXYBarChartBarWidth = 0.4
  ;rts_bar@gsnLeftString = "(b) PC1"
  ;rts_bar@tmXUseBottom = True
  ; rts_bar@tmXBMode = "Explicit"
  ; rts_bar@tmXBValues = ispan(1975, 2005, 5)
  ; rts_bar@tmXBLabels = ispan(1975, 2005, 5)
  ; rts_bar@tmXBMinorValues = ispan(1972, 2009, 1)
  rts_bar@tmXTOn = False
  rts_bar@tmYROn = False
  ; rts_bar@tiXAxisString = "Year"
  rts_bar@tiYAxisString = " "
  rts_bar@tiXAxisFontHeightF = 0.02
  rts_bar@tiYAxisFontHeightF = 0.02
  ; rts_bar@trXMinF = 1971.5
  ; rts_bar@trXMaxF = 2009.5
  rts_bar@trYMinF = -3.0
  rts_bar@trYMaxF = 3.0

  rts_line = rts   ; Line
  rts_line@xyDashPatterns         = (/0,1,16/)
  rts_line@xyLineThicknessF      = 2
  rts_line@xyLineColors = (/"blue","green4","brown"/)

  rtsP = True
  rtsP@lbLabelAutoStride = True

 ;---------------------------------------------------------------
   ; time =  new((/3,dimsizes(sci_eeu)/),float)
   ; time(0,:) = ispan(yrstrt/100, yrlast/100, 1)
   ; time(1,:) = ispan(yrstrt/100, yrlast/100, 1)
   ; time(2,:) = ispan(yrstrt/100, yrlast/100, 1)
   ; ; time(3,:) = ispan(yrstrt/100, yrlast/100, 1)


   ; multi_index = new((/3,dimsizes(sci_eeu)/), float)
   ; ; multi_index(0,:) = sat_na_index
   ; multi_index(0,:) = sci_eeu
   ; multi_index(1,:) = nino34_mam
   ; multi_index(2,:) = ao_mam

   ; plot_bar = gsn_csm_xy(wks, ispan(yrstrt/100, yrlast/100, 1), sat_na_index, rts_bar)
   ; plot_line = gsn_csm_xy(wks, time, multi_index, rts_line)

   ; overlay(plot_bar, plot_line)
   ; draw(plot_bar)
   ; frame(wks)
 
   rts_bar@gsnDraw = False
   rts_bar@gsnXYBarChartBarWidth = 0.2
   rts_bar@gsnXYBarChartColors = (/"red"/)
   plot1 =  gsn_csm_xy(wks, fspan(yrstrt/100, yrlast/100,dimsizes(sci_eeu)), sat_na_index, rts_bar)
   rts_bar@gsnXYBarChartColors = (/"black"/)
   plot2 =  gsn_csm_xy(wks, fspan(yrstrt/100+0.2, yrlast/100+0.2,dimsizes(sci_eeu)), sci_eeu_res, rts_bar)
   rts_bar@gsnXYBarChartColors = (/"blue"/)
   plot3 =  gsn_csm_xy(wks, fspan(yrstrt/100+0.4, yrlast/100+0.4,dimsizes(sci_eeu)), nino34_mam_res, rts_bar)
   rts_bar@gsnXYBarChartColors = (/"green"/)
   plot4 =  gsn_csm_xy(wks, fspan(yrstrt/100+0.6, yrlast/100+0.6,dimsizes(sci_eeu)), ao_mam_res, rts_bar)

   overlay(plot1, plot2)
   overlay(plot1, plot3)
   overlay(plot1, plot4)
   draw(plot1)

     lbres                    = True          ; labelbar only resources
     lbres@vpWidthF           = 0.3           ; labelbar width
     lbres@vpHeightF          = 0.1           ; labelbar height
     lbres@lbBoxMajorExtentF  = 0.36          ; puts space between color boxes
     lbres@lbFillColors       = (/"green","blue"/)
     lbres@lbMonoFillPattern  = True          ; Solid fill pattern
     lbres@lbLabelFontHeightF = 0.015         ; font height. default is small
     lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
     lbres@lbPerimOn          = False
     lbres@lgPerimColor    = "white"
     labels = (/"ao","nino34"/)
     gsn_labelbar_ndc(wks,2,labels,0.52,0.30,lbres) ; draw right labelbar column
  
     lbres@lbFillColors       = (/"black","red"/)
     labels = (/"snow","SAT_NA_region"/)
     gsn_labelbar_ndc(wks,2,labels,0.17,0.30,lbres) ; draw left labelbar column


   frame(wks)


   ; time_in_one = fspan(yrstrt/100, yrlast/100, 4*dimsizes(sci_eeu))
   ; rts_bar@gsnXYBarChartColors = (/"red","black","blue","green"/)
   ; index_in_one = new((/dimsizes(sci_eeu)*4/), float)
   ; do i = 0, dimsizes(sci_eeu) -1
   ;     index_in_one(0+i*4) = sat_na_index(i)
   ;     index_in_one(1+i*4) = sci_eeu_res(i)
   ;     index_in_one(2+i*4) = nino34_mam_res(i)
   ;     index_in_one(3+i*4) = ao_mam_res(i)
   ;   end do
   ; plot = gsn_csm_xy(wks, time_in_one, index_in_one, rts_bar)
   ; draw(plot)
   ; frame(wks)


end
