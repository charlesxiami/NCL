load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
  ;This One for SON

   ; yrstrt = 197201
   ; yrlast = 201912

   ; yrstrt = 197201
   ; yrlast = 199412

   yrstrt = 199601
   yrlast = 201912

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
   ncep2path = "$HOME/data/ncep2/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"
   hadleypath = "$HOME/data/hadley/"
   wafpath = "$HOME/data/waf/tn/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", "snow.pc_reg")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   ; snowdata  = addfile(snowpath+"snow.rutger.2.0deg.nc","r")
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")
   precipdata= addfile(precpath+"precip.mon.anom.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.v5.nc", "r")
   sicdata = addfile(hadleypath+"HadISST_ice.nc", "r")

   ; ;3D-WAF(Plumb) 
   ; waf_Fx = addfile(wafpath+"waf.mon.Fx.nc", "r")
   ; waf_Fy = addfile(wafpath+"waf.mon.Fy.nc", "r")
   ; waf_Fz = addfile(wafpath+"waf.mon.Fz.nc", "r")

   ;3D-WAF(TN)
   waf_Fx = addfile(wafpath+"TN2001-Fx.monthly.nc", "r")
   waf_Fy = addfile(wafpath+"TN2001-Fy.monthly.nc", "r")
   waf_Fz = addfile(wafpath+"TN2001-Fz.monthly.nc", "r")

   ;NCEP 1
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   ; nswrdata  = addfile(ncep2path+"nswrs.sfc.mon.mean.nc", "r")
   ; nlwrdata  = addfile(ncep2path+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata   = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata   = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
   ; soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")

   tcc_file        = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")
   dlwrf_sfc_file  = addfile(nceppath+"dlwrf.sfc.mon.mean.nc","r")
   dswrf_ntat_file = addfile(nceppath+"dswrf.ntat.mon.mean.nc","r")
   dswrf_sfc_file  = addfile(nceppath+"dswrf.sfc.mon.mean.nc","r")
   lhtfl_sfc_file  = addfile(nceppath+"lhtfl.sfc.mon.mean.nc","r")
   prate_sfc_file  = addfile(nceppath+"prate.sfc.mon.mean.nc","r")
   shtfl_sfc_file  = addfile(nceppath+"shtfl.sfc.mon.mean.nc","r")
   ulwrf_ntat_file = addfile(nceppath+"ulwrf.ntat.mon.mean.nc","r")
   ulwrf_sfc_file  = addfile(nceppath+"ulwrf.sfc.mon.mean.nc","r")
   uswrf_ntat_file = addfile(nceppath+"uswrf.ntat.mon.mean.nc","r")
   uswrf_sfc_file  = addfile(nceppath+"uswrf.sfc.mon.mean.nc","r")
   air2m_sfc_file  = addfile(nceppath+"air.2m.mon.mean.nc","r")

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

   ; ;PNA 195001-
   ; pna_index = asciiread(indexpath+"norm.pna.monthly.b5001.current.ascii.txt", -1, "string")
   ; pna_mon = stringtofloat(str_get_field(pna_index, 3, " "))
   ; pna_djf = new((/67/), float)  ; pna_djf: 1950/51DJF-2016/7DJF
   ; pna_mam = new((/67/), float)  ; pna_mam: 1950MAM-2016MAM
   ; do i = 0,66
   ;  pna_djf(i) = dim_avg_Wrap(pna_mon(i*12+11:i*12+13))
   ; end do 
   ; do i = 0,66
   ;  pna_mam(i) = dim_avg_Wrap(pna_mon(i*12+2:i*12+4))
   ; end do

   ; nat_p1 = asciiread(indexpath+"nat_p1.txt", -1, "float")
   ; nat_p2 = asciiread(indexpath+"nat_p2.txt", -1, "float")
 ;*******************************************
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

   YYYYMM4 = cd_calendar(sicdata->time, 1)
   iStrt4  = ind(YYYYMM4.eq.yrstrt)
   iLast4  = ind(YYYYMM4.eq.yrlast)
   print("sea ice time: "+YYYYMM4(iStrt4)+"--"+YYYYMM4(iLast4))

   iStrt_ao  = ind(ao_mon_all&time.eq.yrstrt)
   iLast_ao  = ind(ao_mon_all&time.eq.yrlast)
   print("ao  time: "+ao_mon_all&time(iStrt_ao)+"--"+ao_mon_all&time(iLast_ao))
 ;********************************************
   air_mon  = airdata->air(iStrt:iLast, {latS:latN},{lonL:lonR})
   ; air_mon  = short2flt(airdata->air(iStrt:iLast, 0, {latS:latN},{lonL:lonR}))
   slp_mon  = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR})
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})
   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR})
  
   u_mon = uwnddata->uwnd(iStrt:iLast,:,:,:)
   u850_mon = u_mon(:,{850},:,:)
   u200_mon = u_mon(:,{200},:,:)

   v_mon = vwnddata->vwnd(iStrt:iLast,:,:,:)
   v850_mon = v_mon(:,{850},:,:)
   v200_mon = v_mon(:,{200},:,:)
   
   fx_mon = waf_Fx->Fx(iStrt:iLast,:,:,:)
   fy_mon = waf_Fy->Fy(iStrt:iLast,:,:,:)
   fz_mon = waf_Fz->Fz(iStrt:iLast,:,:,:)

   ; shf_mon  = shfdata->shtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   ; lhf_mon  = lhfdata->lhtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   ; nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   ; nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   ; soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})

   precip_mon = precipdata->precip(iStrt:iLast,{latS:latN},{lonL:lonR})

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)

   ao_mon = ao_mon_all(iStrt_ao:iLast_ao)
   ao_mam = month_to_season(ao_mon, "MAM")
   ; ao_mam = dtrend(ao_mam, False)
   ; asciiwrite(indexpath+"ao_1967-2019mam.txt", ao_mam)

   tcc_mon        = (tcc_file->tcdc(iStrt:iLast,{latS:latN},{lonL:lonR}))
   dlwrf_sfc_mon  = (dlwrf_sfc_file->dlwrf(iStrt:iLast,:,:))
   dswrf_ntat_mon = (dswrf_ntat_file->dswrf(iStrt:iLast,:,:))
   dswrf_sfc_mon  = (dswrf_sfc_file->dswrf(iStrt:iLast,:,:))
   prate_sfc_mon  = (prate_sfc_file->prate(iStrt:iLast,:,:))
   lhtfl_sfc_mon  = (lhtfl_sfc_file->lhtfl(iStrt:iLast,:,:)) ;positive = upward
   shtfl_sfc_mon  = (shtfl_sfc_file->shtfl(iStrt:iLast,:,:))
   ulwrf_ntat_mon = (ulwrf_ntat_file->ulwrf(iStrt:iLast,:,:))
   ulwrf_sfc_mon  = (ulwrf_sfc_file->ulwrf(iStrt:iLast,:,:))
   uswrf_ntat_mon = (uswrf_ntat_file->uswrf(iStrt:iLast,:,:))
   uswrf_sfc_mon  = (uswrf_sfc_file->uswrf(iStrt:iLast,:,:))
   air2m_sfc_mon  = (air2m_sfc_file->air(iStrt:iLast,:,:))

   q1_mon = dswrf_sfc_mon
   q1_mon = (shtfl_sfc_mon + lhtfl_sfc_mon) + (ulwrf_sfc_mon - ulwrf_ntat_mon + uswrf_sfc_mon - uswrf_ntat_mon + \
                      dswrf_ntat_mon - dswrf_sfc_mon - dlwrf_sfc_mon) + prate_sfc_mon*1859*air2m_sfc_mon

   nswr_mon = dswrf_sfc_mon 
   nswr_mon = dswrf_sfc_mon - uswrf_sfc_mon

   nlwr_mon = dlwrf_sfc_mon
   nlwr_mon = dlwrf_sfc_mon - ulwrf_sfc_mon

   nhf_mon = nswr_mon
   nhf_mon = nswr_mon + nlwr_mon - shtfl_sfc_mon - lhtfl_sfc_mon ;reverse the sign of SHF and LHF
;*************************************************
;Filter High-Frequency Pass
;*************************************************
 ;   fcb= -999
 ;   nsigma = 1.
 ;   ihp = 1
 ;   fca = 1.0/120.
 ;   nwt= 21
 ;   wgt_hf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

 ;   snow_mon_hf = wgt_runave_n_Wrap(snow_mon, wgt_hf, 0, 0)
 ;   air_mon_hf  = wgt_runave_n_Wrap(air_mon, wgt_hf, 0, 0)
 ;   slp_mon_hf  = wgt_runave_n_Wrap(slp_mon, wgt_hf, 0, 0)
 ;   z500_mon_hf = wgt_runave_n_Wrap(z500_mon, wgt_hf, 0, 0)
 ;   z200_mon_hf = wgt_runave_n_Wrap(z200_mon, wgt_hf, 0, 0)
 ;   sst_mon_hf  = wgt_runave_n_Wrap(sst_mon, wgt_hf, 0, 0)
 ;   u850_mon_hf = wgt_runave_n_Wrap(u850_mon, wgt_hf, 0, 0)
 ;   v850_mon_hf = wgt_runave_n_Wrap(v850_mon, wgt_hf, 0, 0)
 ;   u200_mon_hf = wgt_runave_n_Wrap(u200_mon, wgt_hf, 0, 0)

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
   season_string = "SON"
   print("season:  " + season_string)   
   snow_mam  = month_to_season(snow_mon, "SON")
   air_mam    = month_to_season(air_mon, season_string)
   slp_mam    = month_to_season(slp_mon, season_string)
   z500_mam  = month_to_season(z500_mon, season_string)
   z200_mam  = month_to_season(z200_mon, season_string)
   sst_mam    = month_to_season(sst_mon, season_string)
   u_mam = month_to_season(u_mon, season_string)
   v_mam = month_to_season(v_mon, season_string)
   u850_mam  = month_to_season(u850_mon, season_string)
   v850_mam  = month_to_season(v850_mon, season_string)
   u200_mam  = month_to_season(u200_mon, season_string)
   precip_mam = month_to_season(precip_mon, season_string)
   nswr_mam   = month_to_season(nswr_mon, season_string)
   nlwr_mam   = month_to_season(nlwr_mon, season_string)
   shf_mam     = month_to_season(shtfl_sfc_mon, season_string)
   lhf_mam     = month_to_season(lhtfl_sfc_mon, season_string)
   nhf_mam     = month_to_season(nhf_mon, season_string)
   ; soilw_mam = month_to_season(soilw_mon, season_string)
   tcc_mam     = month_to_season(tcc_mon, season_string)
   q1_mam = month_to_season(q1_mon, season_string)

   uv850_mam = u850_mam
   uv850_mam = sqrt(u850_mam^2 + v850_mam^2)


   fx_mam = month_to_season(fx_mon, season_string)

   fy_mam = month_to_season(fy_mon, season_string)
   fy_mam = fy_mon(9::12,:,:,:)

   fz_mam = month_to_season(fz_mon, season_string)
   fz_mam = fz_mon(9::12,:,:,:)
;************************************************
; Calculate Index
;************************************************
   snow_son_pc = asciiread(indexpath+"snow_pc1dt_1972-2019SON.txt", -1, "float")
   ; snow_son_pc = asciiread(indexpath+"snow_pc2dt_1972-2019SON.txt", -1, "float")

   pc_p1 = snow_son_pc(0:22)     ;1972-1994 SON for PC_P1
   pc_p2 = snow_son_pc(24:)      ;1996-2018 SON for PC_P2

   ;Define index
   ; snow_index = pc_p1
   snow_index = pc_p2
 ;*****************************************************************
   ; ihp = 1
   ; fca = 1.0/10.
   ; nwt = 13
   ; wgt_hf2 = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
   ; sci_eeu = wgt_runave_Wrap(sci_eeu, wgt_hf2, 0)

   ; snow_mam = wgt_runave_n_Wrap(snow_mam, wgt_hf2, 0, 0)
   ; air_mam  = wgt_runave_n_Wrap(air_mam, wgt_hf2, 0, 0)
   ; slp_mam  = wgt_runave_n_Wrap(slp_mam, wgt_hf2, 0, 0)
   ; z500_mam = wgt_runave_n_Wrap(z500_mam, wgt_hf2, 0, 0)
   ; z200_mam = wgt_runave_n_Wrap(z200_mam, wgt_hf2, 0, 0)
   ; sst_mam  = wgt_runave_n_Wrap(sst_mam, wgt_hf2, 0, 0)
   ; u850_mam = wgt_runave_n_Wrap(u850_mam, wgt_hf2, 0, 0)
   ; v850_mam = wgt_runave_n_Wrap(v850_mam, wgt_hf2, 0, 0)
   ; u200_mam = wgt_runave_n_Wrap(u200_mam, wgt_hf2, 0, 0)
;*****************************************************************
;**********************************************************
;3-D Data analysis
;**********************************************************
 ;Reg and Cor

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

  ; fbinwrite(plotpath+"sc_z500_rc1.bin", sci_z500_rc)
  ; fbinwrite(plotpath+"sc_z500_rc2.bin", sci_z500_rc)

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

  sci_uv850_rc = regCoef_n(snow_index, uv850_mam, 0, 0)
  copy_VarCoords(uv850_mam(0,:,:), sci_uv850_rc)
  sci_uv850_cor = escorc_n(snow_index, uv850_mam, 0, 0)
  p_uv850 = student_t(sci_uv850_cor*sqrt(df_ncep/(1- sci_uv850_cor^2)), df_ncep)
  copy_VarCoords(uv850_mam(0,:,:), p_uv850)
  ; printMinMax(p_uv850, 0)

   w850_rc = sci_u850_rc
   w850_rc = sqrt(sci_u850_rc^2 + sci_v850_rc^2)

   sci_u850_rc = mask(sci_u850_rc, w850_rc.ge.0.1, True)
   sci_v850_rc = mask(sci_v850_rc, w850_rc.ge.0.1, True)

   sig_level = 0.1
  ; sci_u850_rc = mask(sci_u850_rc, p_uv850.le.0.1, True)
  ; sci_v850_rc = mask(sci_v850_rc, p_uv850.le.0.1, True)
  ; sci_u850_rc = mask(sci_u850_rc, p_u850.le.sig_level.or.p_v850.le.sig_level, True)
  ; sci_v850_rc = mask(sci_v850_rc, p_u850.le.sig_level.or.p_v850.le.sig_level, True)
  
  sci_fx_rc = regCoef_n(snow_index, fx_mam, 0, 0)
  copy_VarCoords(fx_mam(0,:,:,:), sci_fx_rc)
  df_ncep2 = conform(sci_fx_rc, df_ncep, (/1,2/))
  sci_fx_cor = escorc_n(snow_index, fx_mam, 0, 0)
  p_fx = student_t(sci_fx_cor*sqrt(df_ncep2/(1- sci_fx_cor^2)), df_ncep2)
  copy_VarCoords(fx_mam(0,:,:,:), p_fx)

  sci_fy_rc = regCoef_n(snow_index, fy_mam, 0, 0)
  copy_VarCoords(fy_mam(0,:,:,:), sci_fy_rc)
  sci_fy_cor = escorc_n(snow_index, fy_mam, 0, 0)
  p_fy = student_t(sci_fy_cor*sqrt(df_ncep2/(1- sci_fy_cor^2)), df_ncep2)
  copy_VarCoords(fy_mam(0,:,:,:), p_fy)

  sci_fz_rc = regCoef_n(snow_index, fz_mam, 0, 0)
  copy_VarCoords(fz_mam(0,:,:,:), sci_fz_rc)
  sci_fz_cor = escorc_n(snow_index, fz_mam, 0, 0)
  p_fz = student_t(sci_fz_cor*sqrt(df_ncep2/(1- sci_fz_cor^2)), df_ncep2)
  copy_VarCoords(fz_mam(0,:,:,:), p_fz)

  sci_u_rc = regCoef_n(snow_index, u_mam, 0, 0)
  copy_VarCoords(u_mam(0,:,:,:), sci_u_rc)
  sci_u_cor = escorc_n(snow_index, u_mam, 0, 0)
  p_u = student_t(sci_u_cor*sqrt(df_ncep2/(1- sci_u_cor^2)), df_ncep2)
  copy_VarCoords(u_mam(0,:,:,:), p_u)

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

  sci_shf_rc = -1*regCoef_n(snow_index, shf_mam, 0, 0)
  copy_VarCoords(shf_mam(0,:,:), sci_shf_rc)
  sci_shf_cor = escorc_n(snow_index, shf_mam, 0, 0)
  p_shf = student_t(sci_shf_cor*sqrt(df_htfl/(1- sci_shf_cor^2)), df_htfl)
  copy_VarCoords(shf_mam(0,:,:), p_shf)

  sci_lhf_rc = -1*regCoef_n(snow_index, lhf_mam, 0, 0)
  copy_VarCoords(lhf_mam(0,:,:), sci_lhf_rc)
  sci_lhf_cor = escorc_n(snow_index, lhf_mam, 0, 0)
  p_lhf = student_t(sci_lhf_cor*sqrt(df_htfl/(1- sci_lhf_cor^2)), df_htfl)
  copy_VarCoords(lhf_mam(0,:,:), p_lhf)

  sci_nhf_rc = regCoef_n(snow_index, nhf_mam, 0, 0)
  copy_VarCoords(nhf_mam(0,:,:), sci_nhf_rc)
  sci_nhf_cor = escorc_n(snow_index, nhf_mam, 0, 0)
  p_nhf = student_t(sci_nhf_cor*sqrt(df_htfl/(1- sci_nhf_cor^2)), df_htfl)
  copy_VarCoords(nhf_mam(0,:,:), p_nhf)

  sci_tcc_rc = regCoef_n(snow_index, tcc_mam, 0, 0)
  copy_VarCoords(tcc_mam(0,:,:), sci_tcc_rc)
  sci_tcc_cor = escorc_n(snow_index, tcc_mam, 0, 0)
  p_tcc = student_t(sci_tcc_cor*sqrt(df_htfl/(1- sci_tcc_cor^2)), df_htfl)
  copy_VarCoords(tcc_mam(0,:,:), p_tcc)

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

  sci_q1_rc = regCoef_n(snow_index, q1_mam, 0, 0)
  copy_VarCoords(q1_mam(0,:,:), sci_q1_rc)
  sci_q1_cor = escorc_n(snow_index, q1_mam, 0, 0)
  p_q1 = student_t(sci_q1_cor*sqrt(df_htfl/(1- sci_q1_cor^2)), df_htfl)
  copy_VarCoords(q1_mam(0,:,:), p_q1)

  ; df_sce = onedtond(weu_sce_rc@nptxy,dimsizes(weu_sce_rc))- 2
  ; tval_sce = onedtond(weu_sce_rc@tval, dimsizes(weu_sce_rc))
  ; b = tval_sce
  ; b = 0.5
  ; prob_sce = betainc(df_sce/(df_sce+tval_sce^2), df_sce/2.0, b)
  ; copy_VarCoords(snow_mam(0,:,:), weu_sce_rc)
  ; copy_VarCoords(snow_mam(0,:,:), prob_sce)
  ; printVarSummary(prob_sce)
  ; printMinMax(prob_sce, False)

 ;---------------------------------------------------------------
  ; printVarSummary(sci_sst_rc)
  ; fbinwrite(plotpath+"sc_reg_sst_p2.bin", sci_sst_rc)
  ; asciiwrite(indexpath+"sc_eeu_p2.txt", sci_eeu)

   ; output = addfile(plotpath+"sc_reg_sst_p1.nc", "c")
   ; output->sst = sci_sst_rc

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
   ; resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
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
   res_snow@lbBoxLinesOn = False
      ; res_snow@lbOrientation = "Vertical"
   ; cmap = read_colormap_file("BlueWhiteOrangeRed")
   ; colormap = cmap(49:253-50,:)
   ; res_snow@cnFillPalette = colormap

   res_htfl = resrc
   res_htfl@cnMaxLevelValF := 10.5
   res_htfl@cnMinLevelValF = -1*res_htfl@cnMaxLevelValF
   res_htfl@cnLevelSpacingF = 0.5
   res_htfl@cnFillPalette = "cmp_b2r"
   ; res_htfl@cnFillPalette = "BlWhRe"

   resSST = res_circ
   ; resSST@lbLabelBarOn = True
   resSST@mpMaxLonF = 360
   resSST@mpMinLonF = 0
   resSST@mpMaxLatF = 80
   resSST@mpMinLatF = -20
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
   rescor@cnFillScaleF = 1.0
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
   resV@vcMinDistanceF     = 0.015

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

   res_snow@cnMaxLevelValF = 10
   res_snow@cnMinLevelValF = -1*res_snow@cnMaxLevelValF
   res_snow@cnLevelSpacingF = 1
   ; res_snow@cnLevelSelectionMode = "ExplicitLevels"
   ; res_snow@cnLevels = ispan(-10, 10, 2)
   ; res_snow@cnFillColors = (/35,55,65,75,85,105,137,160,165,173,182,190/)
   res_snow@mpMinLonF = 0
   res_snow@mpMaxLonF = 160
   res_snow@mpMaxLatF = 80
   res_snow@mpMinLatF = 20
   res_snow@gsnLeftStringFontHeightF = 0.015
   ; res_snow@gsnLeftString = "a) SCE"
   ; res_snow@gsnLeftString = "b) SCE P2"

   res_snow@cnFillPalette = "MPL_RdBu"
   ; res_snow@tmXBOn = False
   ; res_snow@tmXTOn = False
   ; res_snow@tmYLOn = False
   ; res_snow@tmYROn = False

  snowplot = gsn_csm_contour_map(wks, sci_sce_rc, res_snow)
  snowdot = gsn_csm_contour(wks, p_sce, rescor)
  overlay(snowplot, snowdot)
  ;  do i = 0, dimsizes(Expts)-2
  ;      dum2(i) = gsn_add_polyline(wks, snowplot, Expts(i:i+1), \
  ;                                 Eypts(i:i+1), plres)
  ;  end do
   draw(snowplot)
   frame(wks)


   ; resrc@vpXF = 0.52
   ; resrc@tmYLOn = False
   ; resrc@tmYROn = True
   ; resrc@tmYRLabelsOn = True
   resrc@cnMaxLevelValF = 0.8
   resrc@cnMinLevelValF = -0.8
   resrc@cnLevelSpacingF = 0.05
   ; resrc@lbLabelBarOn = False
   ; resrc@gsnLeftString = "a) SAT&UV850  P1"
   resrc@gsnLeftString = "a) SAT&UV850"
   resrc@gsnLeftStringFontHeightF = 0.015
   satplot = gsn_csm_contour_map(wks, sci_sat_rc, resrc)
   satdot = gsn_csm_contour(wks, p_sat, rescor)
   vcplot =  gsn_csm_vector(wks, sci_u850_rc, sci_v850_rc, resV)
   overlay(satplot, vcplot)
   overlay(satplot, satdot)
   
   plot_panel := new(2,graphic)
   plot_panel(0) = snowplot
   plot_panel(1) = satplot
   ; gsn_panel(wks, plot_panel, (/2,1/), resP)

   ; rescor2@gsnLeftString = "a) UV@850 P1"
   ; rescor2@gsnLeftString = "b) UV@850 P2"
   ; resV@vcRefAnnoOrthogonalPosF = -0.2
   ; sigplot = gsn_csm_contour_map(wks, p_uv850, rescor2)
   ; vcplot  = gsn_csm_vector(wks, sci_u850_rc, sci_v850_rc, resV)
   ; overlay(sigplot, vcplot)
   ; draw(sigplot)
   ; frame(wks)

  ;  ; resrc@vpXF = 0.08
  ;  ; resrc@vpYF = 0.98
  ;  ; resrc@vpWidthF = 0.4
  ;  ; resrc@vpHeightF = 0.3
   ; resrc@tmYROn = False
   ; resrc@tmYRLabelsOn = False
   resrc@cnMaxLevelValF = 0.3
   resrc@cnMinLevelValF = -0.3
   resrc@cnLevelSpacingF = 0.01
   res_prec = resrc
   res_prec@cnFillPalette = "MPL_BrBG"
   ; res_prec@gsnLeftString = "a) Precip"
   res_prec@gsnLeftString = "c) Precip"
   precipplot = gsn_csm_contour_map(wks, sci_precip_rc, res_prec)
   precipdot = gsn_csm_contour(wks, p_precip, rescor)
   overlay(precipplot, precipdot)
   ; draw(precipplot)
   ; frame(wks)

  ;  ; res_circ@vpXF = 0.10
  ;  ; res_circ@vpYF = 0.6
  ;  ; res_circ@vpKeepAspect = True
  ;  ; res_circ@vpWidthF = 0.8
  ;  ; ; res_circ@vpHeightF = 0.2
  ;  ; res_circ@tmXBOn = False
  ;  ; res_circ@tmXBLabelsOn = False
   res_circ@pmLabelBarOrthogonalPosF = 0.2
   res_circ@cnMaxLevelValF = 3.0
   res_circ@cnMinLevelValF = -3.0
   res_circ@cnLevelSpacingF = 0.3
   ; res_circ@gsnLeftString = "a) SLP  P1"
   res_circ@gsnLeftString = "b) SLP  P2"
   slpplot = gsn_csm_contour_map(wks, sci_slp_rc, res_circ)
   slpdot = gsn_csm_contour(wks, p_slp, rescor)
   slpline = gsn_csm_contour(wks, sci_slp_rc, resrc2)
   overlay(slpplot, slpline)
   overlay(slpplot, slpdot)

   ; res_circ@vpYF = 0.3
   ; res_circ@tmXBOn = True
   ; res_circ@tmXBLabelsOn = True
   res_circ@cnMaxLevelValF = 30.
   res_circ@cnMinLevelValF = -30.
   res_circ@cnLevelSpacingF = 3.
   ; res_circ@gsnLeftString = "c) Z500  P1"
   res_circ@gsnLeftString = "d) Z500  P2"
   z500plot = gsn_csm_contour_map(wks, sci_z500_rc, res_circ)
   z500dot = gsn_csm_contour(wks, p_z500, rescor)   
   z500line = gsn_csm_contour(wks, sci_z500_rc, resrc2)
   overlay(z500plot, z500line)
   overlay(z500plot, z500dot)

  ;  ; psres = True
  ;  ; maximize_output(wks,psres)

  ;  plot_panel := new(4,graphic)
  ;  plot_panel(0) = snowplot
  ;  plot_panel(1) = satplot
  ;  plot_panel(2) = slpplot
  ;  plot_panel(3) = z500plot
  ;  resP@gsnPanelFigureStrings = (/"SCE","SAT","SLP","Z500"/)
  ;  ; gsn_panel(wks, plot_panel, (/4,1/), resP)
   ; delete(resP@gsnPanelFigureStrings)


  ;  resrc@cnMaxLevelValF = 3.0
  ;  resrc@cnMinLevelValF = -3.0
  ;  resrc@cnLevelSpacingF = 0.3
  ;  resrc@mpMinLatF = 0
  ;  resrc@gsnLeftString = "u200"
  ;  u200plot = gsn_csm_contour_map(wks, sci_u200_rc, resrc)
  ;  u200dot = gsn_csm_contour(wks, p_u200, rescor)
  ;  u200line = gsn_csm_contour(wks, sci_u200_rc, resrc2)
  ;  overlay(u200plot, u200line)
  ;  overlay(u200plot, u200dot)
  ;  ; draw(u200plot)
  ;  ; frame(wks)

;--------------------------------------------------------------------------------------------------
   res_htfl@lbLabelBarOn = False
   res_htfl@mpMinLonF = 40
   res_htfl@mpMaxLonF = 160
   res_htfl@mpMinLatF = 30
   res_htfl@mpMaxLatF = 80

   res_htfl@cnMaxLevelValF := 5.5
   res_htfl@cnMinLevelValF = -1*res_htfl@cnMaxLevelValF
   res_htfl@cnLevelSpacingF = 0.5

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
   nhfplot = gsn_csm_contour_map(wks, sci_nhf_rc, res_htfl)
   nhfdot = gsn_csm_contour(wks, p_nhf, rescor)
   overlay(nhfplot, nhfdot)

   tccplot = gsn_csm_contour_map(wks, sci_tcc_rc, res_htfl)
   tccdot = gsn_csm_contour(wks, p_tcc, rescor)
   overlay(tccplot, tccdot)

   htfl_panel := new(6,graphic)
   htfl_panel(0) = nhfplot
   htfl_panel(1) = swrplot
   htfl_panel(2) = lwrplot
   htfl_panel(3) = shfplot
   htfl_panel(4) = lhfplot
   htfl_panel(5) = tccplot
   resP@gsnPanelLabelBar = True
   resP@pmLabelBarOrthogonalPosF = -0.005
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStrings := (/"a) NHF","b) SWR","c) LWR","d) SHF","e) LHF","f) TCC"/)
   ; resP@gsnPanelFigureStrings := (/"g) NHF","h) SWR","i) LWR","j) SHF","k) LHF", "l) TCC"/)
   ; gsn_panel(wks, htfl_panel, (/6,1/), resP)

   res_htfl@cnMaxLevelValF := 8
   res_htfl@cnMinLevelValF = -1*res_htfl@cnMaxLevelValF
   res_htfl@cnLevelSpacingF = 0.5
   res_htfl@mpMinLonF = 40
   res_htfl@mpMaxLonF = 150
   res_htfl@gsnLeftString = "a) Q1 P1"
   ; res_htfl@gsnLeftString = "b) Q1 P2"
   ; res_htfl@gsnLeftString = "Q1 Whole Period"
   res_htfl@lbLabelBarOn = True
   q1plot = gsn_csm_contour_map(wks, sci_q1_rc, res_htfl)
   q1dot = gsn_csm_contour(wks, p_q1, rescor)
   overlay(q1plot, q1dot)
   ; draw(q1plot)
   ; frame(wks)

;WAF plot
   u_mam_zm  = dim_avg_n_Wrap(sci_u_rc, 2)
   fx_mam_zm = dim_avg_n_Wrap(sci_fx_rc, 2)
   fy_mam_zm = dim_avg_n_Wrap(sci_fy_rc, 2)
   fz_mam_zm = 100*dim_avg_n_Wrap(sci_fz_rc, 2)
   copy_VarCoords(sci_fz_rc(:,:,0), fz_mam_zm)

   fz_mam_zm = mask(fz_mam_zm, abs(fz_mam_zm).ge.1.5, False)

   printMinMax(fy_mam_zm, 0)
   printMinMax(fz_mam_zm, 0)

   res_circ@cnMaxLevelValF = 2.
   res_circ@cnMinLevelValF = -1*res_circ@cnMaxLevelValF
   res_circ@cnLevelSpacingF = 0.2
   res_circ@pmLabelBarOrthogonalPosF = 0.05

   res_circ@vcRefMagnitudeF = 0.5
   res_circ@vcRefLengthF = 0.03
   res_circ@vcRefAnnoArrowLineColor = "black"  
   res_circ@vcRefAnnoArrowUseVecColor = False
   res_circ@vcRefAnnoFontHeightF = 0.008
   res_circ@vcRefAnnoPerimOn = True
   res_circ@vcRefAnnoString2On = False
   res_circ@vcRefAnnoOrthogonalPosF = -0.65
   res_circ@vcGlyphStyle = "LineArrow"
   res_circ@vcLineArrowColor        = "black"           ; change vector color
   res_circ@vcLineArrowThicknessF   = 1.8               ; change vector thickness
   res_circ@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   res_circ@vcMinDistanceF     = 0.015
  
   res_circ@gsnLeftString = "c)"
   plot_waf = gsn_csm_pres_hgt_vector(wks, u_mam_zm(:,{10:90}), \
                 fy_mam_zm(:,{10:90}), fz_mam_zm(:,{10:90}), res_circ)
   ; plot_waf = gsn_csm_pres_hgt(wks, fz_mam_zm(:,{0:90}), res_circ)

   draw(plot_waf)
   frame(wks)
;--------------------------------------------------------------------------------------------------
;Polyline

   ;Polyline Setting
   plres = True
   plres@gsLineThicknessF = 1.0
   plres@gsLineLabelString = ""
   plres@gsLineColor = "red"

   SST_A_N = 70
   SST_A_S = 45
   SST_A_L = -60+360
   SST_A_R = -25+360

   SST_B_N = 38
   SST_B_S = 23
   SST_B_L = -80+360
   SST_B_R = -60+360

   SST_C_N = 30
   SST_C_S = 10
   SST_C_L = -60+360
   SST_C_R = -25+360

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
   resSST@cnMaxLevelValF = 0.6
   resSST@cnMinLevelValF = -1*resSST@cnMaxLevelValF
   resSST@cnLevelSpacingF = 0.1*resSST@cnMaxLevelValF
   resSST@pmLabelBarOrthogonalPosF = 0.22
   ; resSST@lbLabelBarOn = False
   ; resSST@gsnLeftString = "a) SST"
   resSST@gsnLeftString = "b) SST"

   resSST@tmXBOn = False
   resSST@tmXTOn = False
   resSST@tmYLOn = False
   resSST@tmYROn = False

   sstplot = gsn_csm_contour_map(wks, sci_sst_rc, resSST)
   sstsig = gsn_csm_contour(wks, p_sst, rescor)
   overlay(sstplot, sstsig)
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
   ; txres = True
   ; txres@txFontHeightF = 0.015
   ; dum := gsn_add_text(wks, sstplot, "A", 344, 55, txres)
   ; dum := gsn_add_text(wks, sstplot, "B", 290, 31, txres)
   ; dum := gsn_add_text(wks, sstplot, "C", 330, 15, txres)
   ; dum := gsn_add_text(wks, sstplot, "D", 196, 40, txres)
   draw(sstplot)
   frame(wks)



end
