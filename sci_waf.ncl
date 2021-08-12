load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   yrstrt = 196701   ;P1
   yrlast = 198812

   ; yrstrt = 198901   ;P2
   ; yrlast = 191412

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

   nceppath = "/public/home/charlesxiami/data/ncep/"
   snowpath = "/public/home/charlesxiami/data/snow/"
   indexpath = "/public/home/charlesxiami/data/index/"

   plotpath = "/public/home/charlesxiami/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"sci_waf")
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

   pc1 = asciiread(indexpath+"pc1_1948-2017.txt", -1, "float")

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
   print(iStrt+"------"+iLast)

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
   
   u_mon = uwnddata->uwnd(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 

   v_mon = vwnddata->vwnd(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 

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
;*************************************************
;Filter High-Frequency Pass
;*************************************************
   ihp = 1
   fca = 1.0/120.
   fcb= -999
   nsigma = 1.
   nwt= 21
   wgt_hf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

   snow_mon_hf = wgt_runave_n_Wrap(snow_mon, wgt_hf, 0, 0)
   air_mon_hf  = wgt_runave_n_Wrap(air_mon, wgt_hf, 0, 0)
   slp_mon_hf  = wgt_runave_n_Wrap(slp_mon, wgt_hf, 0, 0)
   z500_mon_hf = wgt_runave_n_Wrap(z500_mon, wgt_hf, 0, 0)
   z200_mon_hf = wgt_runave_n_Wrap(z200_mon, wgt_hf, 0, 0)
   sst_mon_hf  = wgt_runave_n_Wrap(sst_mon, wgt_hf, 0, 0)
   u_mon_hf    = wgt_runave_n_Wrap(u_mon, wgt_hf, 0, 0)
   v_mon_hf    = wgt_runave_n_Wrap(v_mon, wgt_hf, 0, 0)

 ;Low frequency
   ihp = 0
   wgt_lf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
   snow_mon_lf = wgt_runave_n_Wrap(snow_mon, wgt_lf, 0, 0)
   air_mon_lf  = wgt_runave_n_Wrap(air_mon, wgt_lf, 0, 0)
   slp_mon_lf  = wgt_runave_n_Wrap(slp_mon, wgt_lf, 0, 0)
   z500_mon_lf = wgt_runave_n_Wrap(z500_mon, wgt_lf, 0, 0)
   z200_mon_lf = wgt_runave_n_Wrap(z200_mon, wgt_lf, 0, 0)
   sst_mon_lf  = wgt_runave_n_Wrap(sst_mon, wgt_lf, 0, 0)
   u_mon_lf    = wgt_runave_n_Wrap(u_mon, wgt_lf, 0, 0)
   v_mon_lf    = wgt_runave_n_Wrap(v_mon, wgt_lf, 0, 0)

  ;************************************************
  ;Seasonal Mean
   ; snow_mam = month_to_season(snow_mon_hf, "MAM")
   snow_mam = month_to_season(snow_mon, "MAM")
   air_mam   = month_to_season(air_mon, "MAM")
   slp_mam   = month_to_season(slp_mon, "MAM")
   z500_mam = month_to_season(z500_mon, "MAM")
   z200_mam = month_to_season(z200_mon, "MAM")
   sst_mam   = month_to_season(sst_mon, "DJF")
   u_mam = month_to_season(u_mon, "MAM")
   v_mam = month_to_season(v_mon, "MAM")


   ;Climatic Mean
   z500_mam_clim = dim_avg_n_Wrap(z500_mam, 0)
   u_mam_clim = dim_avg_n_Wrap(u_mam, 0)
   v_mam_clim = dim_avg_n_Wrap(v_mam, 0)
   uv_mam_clim = sqrt(u_mam_clim^2+v_mam_clim^2)
   copy_VarCoords(u_mam_clim, uv_mam_clim)

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
  sci_eeu_res = sci_eeu - pna_mam(17:38)*regline(pna_mam(17:38), sci_eeu)  ;P1
  ; sci_eeu_res = sci_eeu - pna_mam(39:64)*regline(pna_mam(39:64), sci_eeu)  ;P2

  print(escorc(sci_eeu_res, sci_eeu))

;**********************************************************
;3-D Data analysis
;**********************************************************
 ;Reg and Cor
  ;Define index
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

  ; printVarSummary(sci_z500_rc)
  ; fbinwrite(plotpath+"z500_reg.bin", sci_z500_rc)

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

  ; df_sce = onedtond(weu_sce_rc@nptxy,dimsizes(weu_sce_rc))- 2
  ; tval_sce = onedtond(weu_sce_rc@tval, dimsizes(weu_sce_rc))
  ; b = tval_sce
  ; b = 0.5
  ; prob_sce = betainc(df_sce/(df_sce+tval_sce^2), df_sce/2.0, b)
  ; copy_VarCoords(snow_mam(0,:,:), weu_sce_rc)
  ; copy_VarCoords(snow_mam(0,:,:), prob_sce)
  ; printVarSummary(prob_sce)
  ; printMinMax(prob_sce, False)

;****************************************************************
;Wave activity flux
;****************************************************************
  ;Define
   Ra = 290   ;gas constant
   a = 6400000   ;earth radius
   pai = 4.*atan(1.0)

   ;center diff
   lat = hgtdata&lat
   lon = hgtdata&lon

   r = 1
   ; dlat = center_finite_diff(lat, r, False, 0)
   ; dlon = center_finite_diff(lon, r, False, 0)
   dlat = -2.5
   dlon = 2.5

   coslat = cos(lat*pai/180)
   sinlat = sin(lat*pai/180)
   coslat_2d = conform(uv_mam_clim, coslat, 0)
   sinlat_2d = conform(uv_mam_clim, sinlat, 0)

   f = 2*7.24/100000*sinlat
   f = where(f.eq.0, 2*7.24/100000*sin(43*pai/180), 2*7.24/100000*sinlat)
   f_2d = conform(sci_z500_rc, f, 0)
   ;f0 = 2*7.24/100000*sin(43*pai/180)
   g = 9.8

   psia = sci_z500_rc*g/f_2d

   magU = uv_mam_clim
 
   rCyclic = False
   dpsidlon = center_finite_diff_n(psia, r, rCyclic, 0, 1)/dlon
   ddpsidlonlon = center_finite_diff_n(dpsidlon, r, rCyclic, 0, 1)/dlon

   dpsidlat = center_finite_diff_n(psia, r, rCyclic, 0, 0)/dlat
   ddpsidlatlat = center_finite_diff_n(dpsidlat, r, rCyclic, 0, 0)/dlat
   ddpsidlatlon = center_finite_diff_n(dpsidlat, r, rCyclic, 0, 1)/dlon

   termxu = dpsidlon*dpsidlon-psia*ddpsidlonlon
   termxv = dpsidlon*dpsidlat-psia*ddpsidlatlon
   termyv = dpsidlat*dpsidlat-psia*ddpsidlatlat

   coeff = coslat_2d*0.5/(2*magU)

   px = 10^5*coeff/(a^2*coslat_2d)*(u_mam_clim*termxu/coslat_2d + v_mam_clim*termxv)
   py = 10^5*coeff/(a^2)*(u_mam_clim*termxv/coslat_2d + v_mam_clim*termyv)
   copy_VarCoords(u_mam_clim, px)
   copy_VarCoords(v_mam_clim, py)

   printMinMax(px, 0)
   printMinMax(py, 0)
   printMinMax(psia, 0)

   lat_2d = conform(u_mam_clim, lat, 0)
   py = mask(py, abs(lat_2d).ge.10.and.magU.ge.5, True)

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
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 360.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.

   res_snow = resrc
   res_snow@lbLabelBarOn = True

   res_htfl = resrc
   res_htfl@cnMaxLevelValF = 8.
   res_htfl@cnMinLevelValF = -8.
   res_htfl@cnLevelSpacingF = 1.

   resSST = resrc
   resSST@lbLabelBarOn = True
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
   resV@vcRefMagnitudeF = 5
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"  
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.13
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.0               ; change vector thickness
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

  ;  res_snow@cnMaxLevelValF = 5.
  ;  res_snow@cnMinLevelValF = -5.
  ;  res_snow@cnLevelSpacingF = 0.5
  ; ;res_snow@gsnLeftString = "SCE_WEU: Reg SCE MAM"
  ; snowplot = gsn_csm_contour_map(wks, sci_sce_rc, res_snow)
  ; snowdot = gsn_csm_contour(wks, p_sce, rescor)
  ; overlay(snowplot, snowdot)

  ;  do i = 0, dimsizes(Expts)-2
  ;      dum2(i) = gsn_add_polyline(wks, snowplot, Expts(i:i+1), \
  ;                                 Eypts(i:i+1), plres)
  ;  end do

   resrc@lbLabelBarOn = True   
   resrc@cnMaxLevelValF = 0.8
   resrc@cnMinLevelValF = -0.8
   resrc@cnLevelSpacingF = 0.05
   satplot = gsn_csm_contour_map(wks, sci_sat_rc, resrc)
   satdot = gsn_csm_contour(wks, p_sat, rescor)
   overlay(satplot, satdot)
   ; do i = 0, dimsizes(Wxpts)-2
   ;   dum1(i) = gsn_add_polyline(wks, satplot, Wxpts(i:i+1), \
   ;                                Wypts(i:i+1), plres)
   ; end do

   resrc@cnMaxLevelValF = 20.
   resrc@cnMinLevelValF = -20.
   resrc@cnLevelSpacingF = 1.

   resrc2@cnMaxLevelValF = 24.
   resrc2@cnMinLevelValF = -24.
   resrc2@cnLevelSpacingF = 4.
   resrc2@mpCenterLonF = 180.
   resrc2@mpFillOn = False
   resrc2@mpMinLonF = 0.
   resrc2@mpMaxLonF = 360.
   resrc2@mpMaxLatF = 90.
   resrc2@mpMinLatF = 0.
   resrc2@cnLineThicknessF = 1.0

   resV@vcLineArrowThicknessF   = 1.5
   hgtplot = gsn_csm_contour_map(wks, sci_z500_rc, resrc)
   ; hgtplot = gsn_csm_contour_map(wks, sci_z500_rc, resrc2)
   hgtdot = gsn_csm_contour(wks, p_z500, rescor)
   wafvc = gsn_csm_vector(wks, px, py, resV)
   overlay(hgtplot, wafvc)
   overlay(hgtplot, hgtdot)
   draw(hgtplot)
   frame(wks)

    ; pxplot = gsn_csm_contour_map(wks, px, resrc)
    ; draw(pxplot)
    ; frame(wks)


end
