load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   ;P1 + P2
   ; yrstrt = 197201
   ; yrlast = 201412
   
  ;P1
   yrstrt = 197201
   yrlast = 199212

  ;P2
   ; yrstrt = 199301
   ; yrlast = 201412

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  year=ispan(yrstrt_snow/100, yrlast_snow/100, 1)
  ;t = ispan(1970, 2014, 1)
;---------------W,E-index Region
  SST_ENP_N = 20
  SST_ENP_S = -20
  SST_ENP_L = 160
  SST_ENP_R = 220

  ; SST_ENP_N = 28
  ; SST_ENP_S = 10
  ; SST_ENP_L = 180
  ; SST_ENP_R = -140+360

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
   wks=gsn_open_wks("pdf", plotpath+"sst_reg")
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
   omegadata = addfile(nceppath+"omega.mon.mean.nc", "r")
   ; olrdata = addfile(nceppath+"olr.mon.mean.nc", "r")

   precipdata = addfile(precpath+"precip.mon.anom.nc", "r")
   ; precipdata = addfile(precpath+"/Land/precip.mon.mean.2.5x2.5.nc", "r")

   snowdata = addfile(snowpath+"snow.rutger.2.0deg.nc","r")
   ;---------------------------------------------------------------------------------------
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

   ;ao_mon 195001-201708
   ao_index = asciiread(indexpath+"monthly.ao.index.b50.current.ascii.txt", -1, "string")
   ao_mon = stringtofloat(str_get_field(ao_index, 3, " "))
   ao_djf = new((/67/), float)  ; ao_djf: 1950DJF-2016DJF
   ao_mam = new((/67/), float)  ; ao_mam: 1950MAM-2016MAM
   do i = 0,66
    ao_djf(i) = dim_avg_Wrap(ao_mon(i*12+11:i*12+13))
   end do
   do i = 0,66
    ao_mam(i) = dim_avg_Wrap(ao_mon(i*12+2:i*12+4))
   end do

   ;PNA 
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
 ;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})
   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR})
   z50_mon = hgtdata->hgt(iStrt:iLast,{50},{latS:latN},{lonL:lonR})
   
   u850_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR})
   v850_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR})

   nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   shf_mon = shfdata->shtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   lhf_mon = lhfdata->lhtfl(iStrt:iLast,{latS:latN},{lonL:lonR})

   tcc_mon = tccdata->tcdc(iStrt:iLast,{latS:latN},{lonL:lonR})
   
   soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})

   precip_mon = precipdata->precip(iStrt:iLast,{latS:latN},{lonL:lonR})

   omg850_mon = omegadata->omega(iStrt:iLast,{850},{latS:latN},{lonL:lonR})
   omg500_mon = omegadata->omega(iStrt:iLast,{500},{latS:latN},{lonL:lonR})

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)
   
;*************************************************
;Filter High-Frequency Pass
;*************************************************
 ;   ihp = 1
 ;   fca = 1.0/120.
 ;   fcb= -999
 ;   nsigma = 1.
 ;   nwt= 21
 ;   wgt_hf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

 ;   snow_mon_hf = wgt_runave_n_Wrap(snow_mon, wgt_hf, 0, 0)
 ;   air_mon_hf  = wgt_runave_n_Wrap(air_mon, wgt_hf, 0, 0)
 ;   slp_mon_hf  = wgt_runave_n_Wrap(slp_mon, wgt_hf, 0, 0)
 ;   z500_mon_hf = wgt_runave_n_Wrap(z500_mon, wgt_hf, 0, 0)
 ;   z200_mon_hf = wgt_runave_n_Wrap(z200_mon, wgt_hf, 0, 0)
 ;   sst_mon_hf  = wgt_runave_n_Wrap(sst_mon, wgt_hf, 0, 0)

 ; ;Low frequency
 ;   ihp = 0
 ;   wgt_lf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
 ;   snow_mon_lf = wgt_runave_n_Wrap(snow_mon, wgt_lf, 0, 0)
 ;   air_mon_lf  = wgt_runave_n_Wrap(air_mon, wgt_lf, 0, 0)
 ;   slp_mon_lf  = wgt_runave_n_Wrap(slp_mon, wgt_lf, 0, 0)
 ;   z500_mon_lf = wgt_runave_n_Wrap(z500_mon, wgt_lf, 0, 0)
 ;   z200_mon_lf = wgt_runave_n_Wrap(z200_mon, wgt_lf, 0, 0)
 ;   sst_mon_lf  = wgt_runave_n_Wrap(sst_mon, wgt_lf, 0, 0)

;************************************************
;Seasonal Mean
   ; snow_mam = month_to_season(snow_mon_hf, "MAM")
   season = "DJF"
   snow_mam = month_to_season(snow_mon, "SON")
   air_mam   = month_to_season(air_mon, season)
   slp_mam   = month_to_season(slp_mon, season)
   z500_mam = month_to_season(z500_mon, season)
   z200_mam = month_to_season(z200_mon, season)
   z50_mam = month_to_season(z50_mon, season)
   sst_mam   = month_to_season(sst_mon, season)
   u850_mam = month_to_season(u850_mon, season)
   v850_mam = month_to_season(v850_mon, season)
   precip_mam = month_to_season(precip_mon, "MAM")

   ; nswr_mam = month_to_season(nswr_mon, "MAM")
   ; nlwr_mam = month_to_season(nlwr_mon, "MAM")
   ; shf_mam = month_to_season(shf_mon, "MAM")
   ; lhf_mam = month_to_season(lhf_mon, "MAM")
   ; tcc_mam = month_to_season(tcc_mon, "MAM")
   ; soilw_mam = month_to_season(soilw_mon, "MAM")
   ; omg850_mam = month_to_season(omg850_mon, "MAM")
   ; omg500_mam = month_to_season(omg500_mon, "MAM")

   ; z500_mam_clim = dim_avg_n_Wrap(z500_mam, 0)
   ; printVarSummary(z500_mam_clim)
   ; fbinwrite(plotpath+"z500_clim.bin", z500_mam_clim)
;************************************************
; Calculate Index
;************************************************
  ; sst_region_enp = sst_mam(:,{SST_ENP_S:SST_ENP_N},{SST_ENP_L:SST_ENP_R})
  ; ssti_enp = wgt_areaave_Wrap(sst_region_enp, 1.0, 1.0, 1)
  ; ssti_enp = dim_standardize_Wrap(ssti_enp,0)
  ; ssti_enp = dtrend(ssti_enp, False)

  ; asciiwrite(indexpath+"trop_sst_72-15DJF.txt", ssti_enp)2
  ssti_enp = asciiread(indexpath+"trop_sst_72-15DJF.txt", -1, "float")
  
  dimsst = dimsizes(ssti_enp)

  ssti = ssti_enp(0:20)
  ; ssti = ssti_enp(21:dimsst-2)
  printVarSummary(ssti)
 ;*****************************************************************
 ;Partial Reg
 ;DJF
 ;--------------------------------------------------------------
 ;Remove NAO
 ;  ssti_weu_res = ssti_weu - nao_djf(16:63)*regline(nao_djf(16:63), ssti_weu)
 ;  ssti_eeu_res = ssti_eeu - nao_djf(16:63)*regline(nao_djf(16:63), ssti_eeu)
 ;  ssti_na_res  = ssti_na  - nao_djf(16:63)*regline(nao_djf(16:63), ssti_na)
 ; ;Remove AO
 ;  ssti_weu_res = ssti_weu - ao_djf(16:63)*regline(ao_djf(16:63), ssti_weu)
 ;  ssti_eeu_res = ssti_eeu - ao_djf(16:63)*regline(ao_djf(16:63), ssti_eeu)
 ;  ssti_na_res  = ssti_na  - ao_djf(16:63)*regline(ao_djf(16:63), ssti_na)
 ;Remove AO and NAO
  ; ssti_weu_res = ssti_weu - nao_djf(16:63)*regline(nao_djf(16:63), ssti_weu)- \
  ;                        ao_djf(16:63)*regline(ao_djf(16:63), ssti_weu)
  ; ssti_eeu_res = ssti_eeu - nao_djf(16:63)*regline(nao_djf(16:63), ssti_eeu)- \
  ;                        ao_djf(16:63)*regline(ao_djf(16:63), ssti_eeu)
  ; ssti_na_res  = ssti_na  - nao_djf(16:63)*regline(nao_djf(16:63), ssti_na)- \
  ;                        ao_djf(16:63)*regline(ao_djf(16:63), ssti_na)
  ;--------------------------------------------------------------

 ;MAM
 ;--------------------------------------------------------------
 ; print("Remove NAO")
 ;  ssti_weu_res = ssti_weu - nao_mam(17:64)*regline(nao_mam(17:64), ssti_weu)
 ;  ssti_eeu_res = ssti_eeu - nao_mam(17:64)*regline(nao_mam(17:64), ssti_eeu)
 ;  ssti_na_res  = ssti_na  - nao_mam(17:64)*regline(nao_mam(17:64), ssti_na)
 ; print("Remove AO")
 ;  ssti_weu_res = ssti_weu - ao_mam(17:64)*regline(ao_mam(17:64), ssti_weu)
 ;  ssti_eeu_res = ssti_eeu - ao_mam(17:64)*regline(ao_mam(17:64), ssti_eeu)
 ;  ssti_na_res  = ssti_na  - ao_mam(17:64)*regline(ao_mam(17:64), ssti_na)
  ; print("Remove AO and NAO")
  ; ssti_weu_res = ssti_weu - nao_mam(17:64)*regline(nao_mam(17:64), ssti_weu)- \
  ;                        ao_mam(17:64)*regline(ao_mam(17:64), ssti_weu)
  ; ssti_eeu_res = ssti_eeu - nao_mam(17:64)*regline(nao_mam(17:64), ssti_eeu)- \
  ;                        ao_mam(17:64)*regline(ao_mam(17:64), ssti_eeu)
  ; ssti_na_res  = ssti_na  - nao_mam(17:64)*regline(nao_mam(17:64), ssti_na)- \
  ;                        ao_mam(17:64)*regline(ao_mam(17:64), ssti_na)

;   print("Remove pna")
;   ssti_eeu_res = ssti_eeu - pna_mam(17:64)*regline(pna_mam(17:64), ssti_eeu)

;   ;--------------------------------------------------------------
;   ; print(escorc(ssti_weu_res, ssti_weu))
;   print(escorc(ssti_eeu_res, ssti_eeu))
;   ; print(escorc(ssti_na_res, ssti_na))
; ;**********************************************************
; ;3-D Data analysis
; ;**********************************************************
;  ;Reg and Cor
;   ;Define index

  ;snow data
  ssti_sce_rc = regCoef_n(ssti, snow_mam, 0, 0)
  copy_VarCoords(snow_mam(0,:,:), ssti_sce_rc)
  ssti_sce_cor = escorc_n(ssti, snow_mam, 0, 0)  
  ndim_snow = dimsizes(snow_mam)
  df_snow = ssti_sce_cor
  df_snow = ndim_snow(0) - 2
  t_sce = ssti_sce_cor*sqrt(df_snow/(1- ssti_sce_cor^2 ))
  p_sce = student_t(t_sce, df_snow)
  copy_VarCoords(snow_mam(0,:,:), p_sce)

  ;ncep data 
  ndim_ncep = dimsizes(air_mam)
  ssti_sat_rc = regCoef_n(ssti, air_mam, 0, 0)
  copy_VarCoords(air_mam(0,:,:), ssti_sat_rc)
  ssti_sat_cor = escorc_n(ssti, air_mam, 0, 0)

  df_ncep = ssti_sat_cor
  df_ncep = ndim_ncep(0) - 2
  t_sat = ssti_sat_cor*sqrt(df_ncep/(1- ssti_sat_cor^2))
  p_sat = student_t(t_sat, df_ncep)
  copy_VarCoords(air_mam(0,:,:), p_sat)

  ssti_slp_rc = regCoef_n(ssti, slp_mam, 0, 0)
  copy_VarCoords(slp_mam(0,:,:), ssti_slp_rc)
  ssti_slp_cor = escorc_n(ssti, slp_mam, 0, 0)
  p_slp = student_t(ssti_slp_cor*sqrt(df_ncep/(1- ssti_slp_cor^2)), df_ncep)
  copy_VarCoords(slp_mam(0,:,:), p_slp)

  ssti_u850_rc = regCoef_n(ssti, u850_mam, 0, 0)
  copy_VarCoords(u850_mam(0,:,:), ssti_u850_rc)
  ssti_u850_cor = escorc_n(ssti, u850_mam, 0, 0)
  p_u850 = student_t(ssti_u850_cor*sqrt(df_ncep/(1- ssti_u850_cor^2)), df_ncep)
  copy_VarCoords(u850_mam(0,:,:), p_u850)

  ssti_v850_rc = regCoef_n(ssti, v850_mam, 0, 0)
  copy_VarCoords(v850_mam(0,:,:), ssti_v850_rc)
  ssti_v850_cor = escorc_n(ssti, v850_mam, 0, 0)
  p_v850 = student_t(ssti_v850_cor*sqrt(df_ncep/(1- ssti_v850_cor^2)), df_ncep)
  copy_VarCoords(v850_mam(0,:,:), p_v850)

  ;mask wind
  ssti_uv850_rc = ssti_u850_rc
  ssti_uv850_rc = sqrt(ssti_u850_rc^2+ssti_v850_rc^2)
  ssti_u850_rc = mask(ssti_u850_rc, ssti_uv850_rc.ge.0.2, True)
  ssti_v850_rc = mask(ssti_v850_rc, ssti_uv850_rc.ge.0.2, True)

  ssti_z500_rc = regCoef_n(ssti, z500_mam, 0, 0)
  copy_VarCoords(z500_mam(0,:,:), ssti_z500_rc)
  ssti_z500_cor = escorc_n(ssti, z500_mam, 0, 0)
  p_z500 = student_t(ssti_z500_cor*sqrt(df_ncep/(1- ssti_z500_cor^2)), df_ncep)
  copy_VarCoords(z500_mam(0,:,:), p_z500)

  ssti_z200_rc = regCoef_n(ssti, z200_mam, 0, 0)
  copy_VarCoords(z200_mam(0,:,:), ssti_z200_rc)
  ssti_z200_cor = escorc_n(ssti, z200_mam, 0, 0)
  p_z200 = student_t(ssti_z200_cor*sqrt(df_ncep/(1- ssti_z200_cor^2)), df_ncep)
  copy_VarCoords(z200_mam(0,:,:), p_z200)

  ssti_z50_rc = regCoef_n(ssti, z50_mam, 0, 0)
  copy_VarCoords(z50_mam(0,:,:), ssti_z50_rc)
  ssti_z50_cor = escorc_n(ssti, z50_mam, 0, 0)
  p_z50 = student_t(ssti_z50_cor*sqrt(df_ncep/(1- ssti_z50_cor^2)), df_ncep)
  copy_VarCoords(z50_mam(0,:,:), p_z50)
  ; fbinwrite(plotpath+"z500_nat_p2.bin", ssti_z500_rc)

   ssti_precip_rc = regCoef_n(ssti, precip_mam, 0, 0)
   copy_VarCoords(precip_mam(0,:,:), ssti_precip_rc)
   df   := onedtond(ssti_precip_rc@nptxy, dimsizes(ssti_precip_rc)) - 2
   tval := onedtond(ssti_precip_rc@tval, dimsizes(ssti_precip_rc))
   b    := tval
   b    = 0.5
   prob_precip = betainc(df/(df+tval^2),df/2.0,b)
   copy_VarCoords(precip_mam(0,:,:), prob_precip)

   ; ssti_omg850_rc = regCoef_n(ssti, omg850_mam, 0, 0)
   ; copy_VarCoords(omg850_mam(0,:,:), ssti_omg850_rc)
   ; df   := onedtond(ssti_omg850_rc@nptxy, dimsizes(ssti_omg850_rc)) - 2
   ; tval := onedtond(ssti_omg850_rc@tval, dimsizes(ssti_omg850_rc))
   ; b    := tval
   ; b    = 0.5
   ; prob_omg850 = betainc(df/(df+tval^2),df/2.0,b)
   ; copy_VarCoords(omg850_mam(0,:,:), prob_omg850)

   ; ssti_omg500_rc = regCoef_n(ssti, omg500_mam, 0, 0)
   ; copy_VarCoords(omg500_mam(0,:,:), ssti_omg500_rc)
   ; df   := onedtond(ssti_omg500_rc@nptxy, dimsizes(ssti_omg500_rc)) - 2
   ; tval := onedtond(ssti_omg500_rc@tval, dimsizes(ssti_omg500_rc))
   ; b    := tval
   ; b    = 0.5
   ; prob_omg500 = betainc(df/(df+tval^2),df/2.0,b)
   ; copy_VarCoords(omg500_mam(0,:,:), prob_omg500)

  ;heat flux data (gaussian)
  ; ndim_htfl = dimsizes(nswr_mam)
  ; ssti_swr_rc = regCoef_n(ssti, nswr_mam, 0, 0)
  ; copy_VarCoords(nswr_mam(0,:,:), ssti_swr_rc)
  ; ssti_swr_cor = escorc_n(ssti, nswr_mam, 0, 0)
  ; df_htfl = ssti_swr_cor
  ; df_htfl = ndim_htfl(0) - 2
  ; prob_swr = student_t(ssti_swr_cor*sqrt(df_htfl/(1- ssti_swr_cor^2)), df_htfl)
  ; copy_VarCoords(nswr_mam(0,:,:), prob_swr)

  ; ssti_lwr_rc = regCoef_n(ssti, nlwr_mam, 0, 0)
  ; copy_VarCoords(nlwr_mam(0,:,:), ssti_lwr_rc)
  ; ssti_lwr_cor = escorc_n(ssti, nlwr_mam, 0, 0)
  ; df_htfl = ssti_lwr_cor
  ; df_htfl = ndim_htfl(0) - 2
  ; prob_lwr = student_t(ssti_lwr_cor*sqrt(df_htfl/(1- ssti_lwr_cor^2)), df_htfl)
  ; copy_VarCoords(nlwr_mam(0,:,:), prob_lwr)

  ; ssti_shf_rc = regCoef_n(ssti, shf_mam, 0, 0)
  ; copy_VarCoords(shf_mam(0,:,:), ssti_shf_rc)
  ; ssti_shf_cor = escorc_n(ssti, shf_mam, 0, 0)
  ; prob_shf = student_t(ssti_shf_cor*sqrt(df_htfl/(1- ssti_shf_cor^2)), df_htfl)
  ; copy_VarCoords(shf_mam(0,:,:), prob_shf)

  ; ssti_lhf_rc = regCoef_n(ssti, lhf_mam, 0, 0)
  ; copy_VarCoords(lhf_mam(0,:,:), ssti_lhf_rc)
  ; ssti_lhf_cor = escorc_n(ssti, lhf_mam, 0, 0)
  ; prob_lhf = student_t(ssti_lhf_cor*sqrt(df_htfl/(1- ssti_lhf_cor^2)), df_htfl)
  ; copy_VarCoords(lhf_mam(0,:,:), prob_lhf)

  ; ssti_tcc_rc = regCoef_n(ssti, tcc_mam, 0, 0)
  ; copy_VarCoords(tcc_mam(0,:,:), ssti_tcc_rc)
  ; ssti_tcc_cor = escorc_n(ssti, tcc_mam, 0, 0)
  ; prob_tcc = student_t(ssti_tcc_cor*sqrt(df_htfl/(1- ssti_tcc_cor^2)), df_htfl)
  ; copy_VarCoords(tcc_mam(0,:,:), prob_tcc)

  ;SST
  ssti_sst_rc = regCoef_n(ssti, sst_mam, 0, 0)
  copy_VarCoords(sst_mam(0,:,:), ssti_sst_rc)
  ssti_sst_cor = escorc_n(ssti, sst_mam, 0, 0)
  ndim_sst = dimsizes(sst_mam)
  df_sst = ssti_sst_cor
  df_sst = ndim_sst(0) - 2
  p_sst = student_t(ssti_sst_cor*sqrt(df_sst/(1- ssti_sst_cor^2)), df_sst)
  copy_VarCoords(sst_mam(0,:,:), p_sst)

  ; df_sce = onedtond(weu_sce_rc@nptxy,dimsizes(weu_sce_rc))- 2
  ; tval_sce = onedtond(weu_sce_rc@tval, dimsizes(weu_sce_rc))
  ; b = tval_sce
  ; b = 0.5
  ; prob_sce = betainc(df_sce/(df_sce+tval_sce^2), df_sce/2.0, b)
  ; copy_VarCoords(snow_mam(0,:,:), weu_sce_rc)
  ; copy_VarCoords(snow_mam(0,:,:), prob_sce)
  ; printVarSummary(prob_sce)
  ; printMinMax(prob_sce, False)

;   fbinwrite(plotpath+"z500_reg_hf.bin", ssti_z500_rc)
; ;---------------------------------------------------
; ;Percentage variance explained by regression
 
;    air_mam_std = dim_stddev_n_Wrap(air_mam, 0)

;    sat_reg_exp = ssti_sat_rc({30:60},{240:280}) ^2
;    air_mam_exp = air_mam_std({30:60},{240:280}) ^2

;    pct_sat = wgt_areaave_Wrap(sat_reg_exp, 1.0, 1.0, 1)/wgt_areaave_Wrap(air_mam_exp, 1.0, 1.0, 1)

;    print("Percentage explained: " + pct_sat)

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
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   resrc@lbBoxLinesOn = True
   resrc@pmLabelBarWidthF = 0.5
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
   resrc@pmLabelBarOrthogonalPosF = 0.20
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 360.
   resrc@mpMinLatF = -30.
   resrc@mpMaxLatF = 90.

   res_snow = resrc
   res_snow@lbLabelBarOn = True

   res_htfl = resrc

   res_precip = resrc
   res_precip@lbLabelBarOn = True

   resSST = resrc
   resSST@lbLabelBarOn = True
   resSST@mpMinLonF = 0.
   resSST@mpMaxLonF = 360.
   resSST@mpMinLatF = -50.
   resSST@mpMaxLatF = 90.
   ; resSST@mpCenterLonF = 180.

   ;For Line
   resrc2 = res
   resrc2@cnFillOn = False
   resrc2@cnLinesOn = True
   resrc2@cnInfoLabelOn = False
   resrc2@gsnContourNegLineDashPattern = 5
   resrc2@gsnContourZeroLineThicknessF = 0.
   resrc2@cnLineThicknessF = 2.0
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
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"  
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.73
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.5               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.015
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsBackgroundFillColor = "black"
   resP@gsnPanelFigureStringsFontColor = "white"
   ; resP@pmLabelBarWidthF = 0.4

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

  ;Draw Bar chart
  ; rts_bar@gsnXYBarChartBarWidth = 0.66
  ; rts_bar@gsnLeftString = "SCE_WEU"
  ; pbar_af1 = gsn_csm_xy(wks, year, ssti_weu, rts_bar)
  ; rts_bar@gsnLeftString = "SCE_EEU"  
  ; pbar_af2 = gsn_csm_xy(wks, year, ssti_eeu, rts_bar)
  ; rts_bar@gsnLeftString = "SCE_NA"
  ; pbar_af3 = gsn_csm_xy(wks, year, ssti_na, rts_bar)

  ; rts_bar@gsnLeftString = ""
  ; rts_bar@gsnRightString = ""
  ; rts_bar@gsnXYBarChartBarWidth = 0.35
  ; rts_bar@gsnAboveYRefLineColor = "red"
  ; rts_bar@gsnBelowYRefLineColor = "blue"
  ; pbar_hf1 = gsn_csm_xy(wks, year, ssti_weu_hf, rts_bar)
  ; pbar_hf2 = gsn_csm_xy(wks, year, ssti_eeu_hf, rts_bar)
  ; pbar_hf3 = gsn_csm_xy(wks, year, ssti_na_hf, rts_bar)
 
  ; overlay(pbar_af1, pbar_hf1)
  ; overlay(pbar_af2, pbar_hf2)
  ; overlay(pbar_af3, pbar_hf3)
  ; bar_panel = new(3, graphic)
  ; bar_panel(0) = pbar_af1
  ; bar_panel(1) = pbar_af2
  ; bar_panel(2) = pbar_af3
  ; gsn_panel(wks, bar_panel, (/3,1/), rtsP)

   ; Wrunave = runave_n_Wrap(SCAW, 11, 0, 0)
   ; Erunave = runave_n_Wrap(SCAE, 11, 0, 0) 
   
;****************************************************************
;Polyline

   ;Polyline Setting
   ENPxpts = (/SST_ENP_L, SST_ENP_L, SST_ENP_R, SST_ENP_R, SST_ENP_L/)
   ENPypts = (/SST_ENP_S, SST_ENP_N, SST_ENP_N, SST_ENP_S, SST_ENP_S/)

   plres = True
   plres@gsLineThicknessF = 1.5
   plres@gsLineLabelString = ""
   plres@gsLineColor = "red"

   dum1 = new(dimsizes(ENPxpts)-1, graphic)
   ; dum2 = new(dimsizes(Bxpts)-1, graphic)
   ; dum3 = new(dimsizes(Cxpts)-1, graphic)

; ;**********************************************************
; ;Draw contour

   res_snow@cnMaxLevelValF = 5.
   res_snow@cnMinLevelValF = -5.
   res_snow@cnLevelSpacingF = 0.1
   ; res_snow@lbBoxLinesOn = False
   ; res_snow@gsnPolar = "NH"
   ; res_snow@mpMinLatF = 20.
   ; res_snow@lbOrientation = "Vertical"
   ; res_snow@gsnLeftString = "SCE_WEU: Reg SCE MAM"
   res_snow@mpMinLatF = 30
   res_snow@mpMaxLatF = 80
   res_snow@mpMinLonF = 0
   res_snow@mpMaxLonF = 150
   snowplot = gsn_csm_contour_map(wks, ssti_sce_rc, res_snow)
   snowdot = gsn_csm_contour(wks, p_sce, rescor)
   overlay(snowplot, snowdot)
;   ; do i = 0, dimsizes(Wxpts)-2
;   ;   dum1(i) = gsn_add_polyline(wks, snowplot, Wxpts(i:i+1), \
;   ;                                Wypts(i:i+1), plres)
;   ;  end do
;    do i = 0, dimsizes(Expts)-2
;        dum2(i) = gsn_add_polyline(wks, snowplot, Expts(i:i+1), \
;                                   Eypts(i:i+1), plres)
;    end do
;    ; do i = 0, dimsizes(Expts)-2
;    ;     dum2(i) = gsn_add_polyline(wks, snowplot, NAxpts(i:i+1), \
;    ;                                NAypts(i:i+1), plres)
;    ; end do
    draw(snowplot)
    frame(wks)
   ; resrc@gsnPolar = "NH"
   ; resrc@mpMinLatF = 20.

   resSST@cnMaxLevelValF = 0.6
   resSST@cnMinLevelValF = -1*resSST@cnMaxLevelValF
   resSST@cnLevelSpacingF = 0.02
   ; resSST@cnFillPalette = "NCV_jaisnd"
   ; resSST@gsnLeftString = "b) SST  P2"
   sstplot = gsn_csm_contour_map(wks, ssti_sst_rc, resSST)
   sstsig = gsn_csm_contour(wks, p_sst, rescor)
   overlay(sstplot, sstsig)
   do i = 0, dimsizes(ENPxpts) -2 
      dum1(i) = gsn_add_polyline(wks, sstplot, ENPxpts(i:i+1), ENPypts(i:i+1), plres)
   end do
   draw(sstplot)
   frame(wks)

   resrc@lbLabelBarOn = True   
   resrc@cnMaxLevelValF = 1.2
   resrc@cnMinLevelValF = -1.2
   resrc@cnLevelSpacingF = 0.02
   ; resrc@lbOrientation = "Vertical"
   ; resrc@gsnLeftString = "d) SAT & Wind@850  P2"
   satplot = gsn_csm_contour_map(wks, ssti_sat_rc, resrc)
   satdot = gsn_csm_contour(wks, p_sat, rescor)
   vcplot= gsn_csm_vector(wks, ssti_u850_rc, ssti_v850_rc, resV)
   overlay(satplot, vcplot)
   overlay(satplot, satdot)
;    ; do i = 0, dimsizes(Wxpts)-2
;    ;   dum1(i) = gsn_add_polyline(wks, satplot, Wxpts(i:i+1), \
;    ;                                Wypts(i:i+1), plres)
;    ; end do

   resrc@cnMaxLevelValF = 3.6
   resrc@cnMinLevelValF = -3.6
   resrc@cnLevelSpacingF = 0.1
   slpplot = gsn_csm_contour_map(wks, ssti_slp_rc, resrc)
   slpdot = gsn_csm_contour(wks, p_slp, rescor)
   slpline = gsn_csm_contour(wks, ssti_slp_rc, resrc2)
   overlay(slpplot, slpline)
   overlay(slpplot, slpdot)

   resrc@cnMaxLevelValF = 24
   resrc@cnMinLevelValF = -24.
   resrc@cnLevelSpacingF = 1.
   ; resrc@gsnLeftString = "a) Z500 ENP P1"
   ; resrc@gsnLeftString = "b) Z500 ENP P2"
   z500plot = gsn_csm_contour_map(wks, ssti_z500_rc, resrc)
   z500dot = gsn_csm_contour(wks, p_z500, rescor)   
   z500line = gsn_csm_contour(wks, ssti_z500_rc, resrc2)
   overlay(z500plot, z500line)
   overlay(z500plot, z500dot)

   z200plot = gsn_csm_contour_map(wks, ssti_z200_rc, resrc)
   z200dot = gsn_csm_contour(wks, p_z200, rescor)   
   z200line = gsn_csm_contour(wks, ssti_z200_rc, resrc2)
   overlay(z200plot, z200line)
   overlay(z200plot, z200dot)

   z50plot = gsn_csm_contour_map(wks, ssti_z50_rc, resrc)
   z50dot = gsn_csm_contour(wks, p_z50, rescor)   
   z50line = gsn_csm_contour(wks, ssti_z50_rc, resrc2)
   overlay(z50plot, z50line)
   overlay(z50plot, z50dot)    
   
   panel_new = new(3, graphic)
   panel_new(0) = z50plot
   panel_new(1) = z200plot
   panel_new(2) = z500plot
   gsn_panel(wks, panel_new, (/3,1/), resP)

   res_precip@cnMaxLevelValF = 1.0
   res_precip@cnMinLevelValF = -1.0
   res_precip@cnLevelSpacingF = 0.01
   ; res_precip@cnFillPalette = "NCV_jet"
   precplot = gsn_csm_contour_map(wks, ssti_precip_rc, res_precip)
   precdot = gsn_csm_contour(wks, prob_precip, rescor)
   ; precline = gsn_csm_contour(wks, ssti_precip_rc, resrc2)
   ; overlay(precplot, precline)
   overlay(precplot, precdot)

   ; resrc@cnMinLevelValF = -0.012
   ; resrc@cnMaxLevelValF = 0.012
   ; resrc@cnLevelSpacingF = 0.0005
   ; omgplot = gsn_csm_contour_map(wks, ssti_omg500_rc , resrc)
   ; omgdot = gsn_csm_contour(wks, prob_omg500 , rescor)
   ; ; omgline = gsn_csm_contour(wks, ssti_omgip_rc, resrc2)
   ; ; overlay(omgplot, omgline)
   ; overlay(omgplot, omgdot)

   ; resrc@cnMinLevelValF = -4.
   ; resrc@cnMaxLevelValF = 4.
   ; resrc@cnLevelSpacingF = 0.2
   ; tccplot = gsn_csm_contour_map(wks, ssti_tcc_rc , resrc)
   ; tccdot = gsn_csm_contour(wks, prob_tcc , rescor)
   ; overlay(tccplot, tccdot)

  ;---------------------------------------------------------------------
  ;Panels
   plot_panel := new(3,graphic)
   plot_panel(0) = sstplot
   plot_panel(1) = satplot
   plot_panel(2) = z500plot
   ; plot_panel(2) = slpplot
   resP@gsnPanelXWhiteSpacePercent = 2
   resP@gsnPanelYWhiteSpacePercent = 5
   resP@gsnPanelFigureStrings = (/"a) SST  P1", "c) SAT&UV850  P1","e) Z500  P1"/)
   ; resP@gsnPanelFigureStrings = (/"b) SST  P2", "d) SAT&UV850  P2","f) Z500  P2"/)
   ; gsn_panel(wks, plot_panel, (/3,1/), resP)
  
   ; plot_panel := new(4,graphic)
   ; plot_panel(0) = snowplot
   ; plot_panel(1) = precplot
   ; plot_panel(2) = omgplot
   ; plot_panel(3) = tccplot
   ; resP@gsnPanelFigureStrings := (/"SCE", "Precip","Omega500","TCC"/)
   ; gsn_panel(wks, plot_panel, (/4,1/), resP)
  ;---------------------------------------------------------------------

   ;heat flux panel
   ; res_htfl@cnMaxLevelValF = 8.
   ; res_htfl@cnMinLevelValF = -8.
   ; res_htfl@cnLevelSpacingF = 0.5
   ; swrplot = gsn_csm_contour_map(wks, ssti_swr_rc, res_htfl)
   ; swrdot = gsn_csm_contour(wks, prob_swr, rescor)
   ; overlay(swrplot, swrdot)
   ; lwrplot = gsn_csm_contour_map(wks, ssti_lwr_rc, res_htfl)
   ; lwrdot = gsn_csm_contour(wks, prob_lwr, rescor)
   ; overlay(lwrplot, lwrdot)
   ; shfplot = gsn_csm_contour_map(wks, ssti_shf_rc, res_htfl)
   ; shfdot = gsn_csm_contour(wks, prob_shf, rescor)
   ; overlay(shfplot, shfdot)
   ; lhfplot = gsn_csm_contour_map(wks, ssti_lhf_rc, res_htfl)
   ; lhfdot = gsn_csm_contour(wks, prob_lhf, rescor)
   ; overlay(lhfplot, lhfdot)

   ; htfl_panel := new(4,graphic)
   ; htfl_panel(0) = swrplot
   ; htfl_panel(1) = lwrplot
   ; htfl_panel(2) = shfplot
   ; htfl_panel(3) = lhfplot
   ; resP@gsnPanelLabelBar = True
   ; resP@pmLabelBarWidthF = 0.6
   ; resP@gsnPanelFigureStrings := (/"SWR","LWR","SHF","LHF"/)
   ; gsn_panel(wks, htfl_panel, (/4,1/), resP)


end
