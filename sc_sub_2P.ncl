load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
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

  ; sig1 = 0.497   ; %95
  ; sig2 = 0.433   ; %95

  sig1 = 0.576   ; %95 12-years
  sig2 = 0.482   ; %95 17-years

   cd = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"

   wks=gsn_open_wks("pdf", plotpath+"snow_reg_2p")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;***********************************************
;************************************************
   filesnow = "/public/home/charlesxiami/data/snow/snow.nc"
   snowdata = addfile(filesnow,"r")
   airdata = addfile(cd+"air.mon.mean.nc", "r")
   slpdata = addfile(cd+"slp.mon.mean.nc", "r")
   hgtdata = addfile(cd+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(cd+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(cd+"vwnd.mon.mean.nc", "r")
   sstdata = addfile(cd+"sst.mnmean.v4.nc", "r")
   soilwdata = addfile(cd+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(cd+"tcdc.eatm.mon.mean.nc", "r")

   nswrdata = addfile(cd+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(cd+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata  = addfile(cd+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata  = addfile(cd+"shtfl.sfc.mon.mean.nc", "r")

   ;cfnsfdata = addfile(cd+"cfnsf.sfc.mon.mean.nc", "r")
   pc1 = asciiread(indexpath+"pc1.txt", -1, "float")
   tele_index = asciiread(indexpath+"tele_index.nh.txt", -1, "string")
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

;*************************************************************
;Mask
   b = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc", "r")
   lsm_t62 = landsea_mask(b->LSMASK,nswr_mon&lat,nswr_mon&lon)
   nswr_mam = mask(nswr_mam, lsm_t62.eq.1, True)
   nlwr_mam = mask(nlwr_mam, lsm_t62.eq.1, True)
   shf_mam = mask(shf_mam, lsm_t62.eq.1, True)
   lhf_mam = mask(lhf_mam, lsm_t62.eq.1, True)
   tcc_mam = mask(tcc_mam, lsm_t62.eq.1, True)

   nhf_mam = nswr_mam + nlwr_mam + shf_mam + lhf_mam
   copy_VarCoords(nswr_mam, nhf_mam)

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
   print("cor: SCAW-SCAC = "+ escorc(SCAW, SCAC))
   print("cor: SCAW-SCAC:P1 = "+ escorc(SCAW(0:15), SCAC(0:15)))
   print("cor: SCAW-SCAC:P2 = "+ escorc(SCAW(17:37), SCAC(17:37)))
   print("------------------------------------")
   print("cor: SCAE-SCAC = "+ escorc(SCAE, SCAC))
   print("cor: SCAE-SCAC:P1 = "+ escorc(SCAE(0:15), SCAC(0:15)))
   print("cor: SCAE-SCAC:P2 = "+ escorc(SCAE(17:37), SCAC(17:37)))
   print("------------------------------------")
   print("cor: PC1-SCAC = "+ escorc(pc1(2:39), SCAC))
   print("cor: PC1-SCAC:P1 = "+ escorc(pc1(2:17), SCAC(0:15)))
   print("cor: PC1-SCAC:P2 = "+ escorc(pc1(19:39), SCAC(17:37)))
   print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

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
    pc1_hf = wgt_runave_Wrap(pc1, wgt, 0)
   ;Reserve AI and BI 
    SCAW_hf = -1*SCAW_hf
    SCAC_hf = -1*SCAC_hf
    SCAE_hf = -1*SCAE_hf
    print("cor: SCAW-SCAC:hf = "+ escorc(SCAW_hf, SCAC_hf))
    print("cor: SCAW-SCAC:hf:P1 = "+ escorc(SCAW_hf(0:15), SCAC_hf(0:15)))
    print("cor: SCAW-SCAC:hf:P2 = "+ escorc(SCAW_hf(17:37), SCAC_hf(17:37)))
    print("------------------------------------")
    print("cor: SCAE-SCAC:hf = "+ escorc(SCAE_hf, SCAC_hf))
    print("cor: SCAE-SCAC:hf:P1 = "+ escorc(SCAE_hf(0:15), SCAC_hf(0:15)))
    print("cor: SCAE-SCAC:hf:P2 = "+ escorc(SCAE_hf(17:37), SCAC_hf(17:37)))
    print("------------------------------------")
    print("cor: PC1-SCAC:hf = "+ escorc(pc1_hf(2:39), SCAC_hf))
    print("cor: PC1-SCAC:hf:P1 = "+ escorc(pc1_hf(2:17), SCAC_hf(0:15)))
    print("cor: PC1-SCAC:hf:P2 = "+ escorc(pc1_hf(19:39), SCAC_hf(17:37)))

    snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
    sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)
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

   nswr_mam1 = -1*nswr_mam(0:15,:,:)
   nlwr_mam1 = -1*nlwr_mam(0:15,:,:)
   lhf_mam1  = -1*lhf_mam(0:15,:,:)
   shf_mam1  = -1*shf_mam(0:15,:,:)
   nhf_mam1  = -1*nhf_mam(0:15,:,:)
   copy_VarCoords(nswr_mam(0:15,:,:), nswr_mam1)
   copy_VarCoords(nlwr_mam(0:15,:,:), nlwr_mam1)
   copy_VarCoords(lhf_mam(0:15,:,:), lhf_mam1)
   copy_VarCoords(shf_mam(0:15,:,:), shf_mam1)
   copy_VarCoords(nhf_mam(0:15,:,:), nhf_mam1)

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
   nswr_mam2 = -1*nswr_mam(17:37,:,:)
   nlwr_mam2 = -1*nlwr_mam(17:37,:,:)
   lhf_mam2  = -1*lhf_mam(17:37,:,:)
   shf_mam2  = -1*shf_mam(17:37,:,:)
   nhf_mam2  = -1*nhf_mam(17:37,:,:)
   copy_VarCoords(nswr_mam(17:37,:,:), nswr_mam2)
   copy_VarCoords(nlwr_mam(17:37,:,:), nlwr_mam2)
   copy_VarCoords(lhf_mam(17:37,:,:), lhf_mam2)
   copy_VarCoords(shf_mam(17:37,:,:), shf_mam2)
   copy_VarCoords(nhf_mam(17:37,:,:), nhf_mam2)

;******************************************
;Regression
;******************************************
   ;P1
  ;SCE
   SCAW_sce_rc1 = 100*regCoef(SCAW_hf(0:15),snow_mam1(lat|:,lon|:,time|:))
   SCAE_sce_rc1 = 100*regCoef(SCAE_hf(0:15),snow_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(snow_mam(0,:,:), SCAW_sce_rc1)
   copy_VarCoords(snow_mam(0,:,:), SCAE_sce_rc1)
   SCAW_sce_cor1  = escorc(SCAW_hf(0:15),snow_mam1(lat|:,lon|:,time|:))
   SCAE_sce_cor1  = escorc(SCAE_hf(0:15),snow_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(snow_mam(0,:,:), SCAW_sce_cor1)
   copy_VarCoords(snow_mam(0,:,:), SCAE_sce_cor1)
   ;SAT
   SCAW_sat_rc1  = regCoef(SCAW_hf(0:15),air_mam1(lat|:,lon|:,time|:))
   SCAW_sat_cor1  = escorc(SCAW_hf(0:15),air_mam1(lat|:,lon|:,time|:))
   SCAE_sat_rc1  = regCoef(SCAE_hf(0:15),air_mam1(lat|:,lon|:,time|:))
   SCAE_sat_cor1  = escorc(SCAE_hf(0:15),air_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(air_mam(0, :, :), SCAW_sat_rc1)
   copy_VarCoords(air_mam(0, :, :), SCAW_sat_cor1)
   copy_VarCoords(air_mam(0, :, :), SCAE_sat_rc1)
   copy_VarCoords(air_mam(0, :, :), SCAE_sat_cor1)
   ;SLP
   SCAW_slp_rc1  = regCoef(SCAW_hf(0:15),slp_mam1(lat|:,lon|:,time|:))
   SCAW_slp_cor1  = escorc(SCAW_hf(0:15),slp_mam1(lat|:,lon|:,time|:))
   SCAE_slp_rc1  = regCoef(SCAE_hf(0:15),slp_mam1(lat|:,lon|:,time|:))
   SCAE_slp_cor1  = escorc(SCAE_hf(0:15),slp_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(slp_mam(0, :, :), SCAW_slp_rc1)
   copy_VarCoords(slp_mam(0, :, :), SCAW_slp_cor1)
   copy_VarCoords(slp_mam(0, :, :), SCAE_slp_rc1)
   copy_VarCoords(slp_mam(0, :, :), SCAE_slp_cor1)
   ;Z500
   SCAW_z500_rc1 = regCoef(SCAW_hf(0:15),z500_mam1(lat|:,lon|:,time|:))
   SCAW_z500_cor1 = escorc(SCAW_hf(0:15),z500_mam1(lat|:,lon|:,time|:))
   SCAE_z500_rc1 = regCoef(SCAE_hf(0:15),z500_mam1(lat|:,lon|:,time|:))
   SCAE_z500_cor1 = escorc(SCAE_hf(0:15),z500_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(z500_mam(0, :, :), SCAW_z500_rc1)
   copy_VarCoords(z500_mam(0, :, :), SCAW_z500_cor1)
   copy_VarCoords(z500_mam(0, :, :), SCAE_z500_rc1)
   copy_VarCoords(z500_mam(0, :, :), SCAE_z500_cor1)
   ;Z200
   SCAW_z200_rc1 = regCoef(SCAW_hf(0:15),z200_mam1(lat|:,lon|:,time|:))
   SCAW_z200_cor1 = escorc(SCAW_hf(0:15),z200_mam1(lat|:,lon|:,time|:))
   SCAE_z200_rc1 = regCoef(SCAE_hf(0:15),z200_mam1(lat|:,lon|:,time|:))
   SCAE_z200_cor1 = escorc(SCAE_hf(0:15),z200_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(z200_mam(0, :, :), SCAW_z200_rc1)
   copy_VarCoords(z200_mam(0, :, :), SCAW_z200_cor1)
   copy_VarCoords(z200_mam(0, :, :), SCAE_z200_rc1)
   copy_VarCoords(z200_mam(0, :, :), SCAE_z200_cor1)
   ;U-wind
   SCAW_u_rc1    = regCoef(SCAW_hf(0:15),u_mam1(lat|:,lon|:,time|:))
   SCAW_u_cor1    = escorc(SCAW_hf(0:15),u_mam1(lat|:,lon|:,time|:))
   SCAE_u_rc1    = regCoef(SCAE_hf(0:15),u_mam1(lat|:,lon|:,time|:))
   SCAE_u_cor1    = escorc(SCAE_hf(0:15),u_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(u_mam(0, :, :), SCAW_u_rc1)
   copy_VarCoords(u_mam(0, :, :), SCAW_u_cor1)
   copy_VarCoords(u_mam(0, :, :), SCAE_u_rc1)
   copy_VarCoords(u_mam(0, :, :), SCAE_u_cor1)
   ;V-wind
   SCAW_v_rc1    = regCoef(SCAW_hf(0:15),v_mam1(lat|:,lon|:,time|:))
   SCAW_v_cor1    = escorc(SCAW_hf(0:15),v_mam1(lat|:,lon|:,time|:))
   SCAE_v_rc1    = regCoef(SCAE_hf(0:15),v_mam1(lat|:,lon|:,time|:))
   SCAE_v_cor1    = escorc(SCAE_hf(0:15),v_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(v_mam(0, :, :), SCAW_v_rc1)
   copy_VarCoords(v_mam(0, :, :), SCAW_v_cor1)
   copy_VarCoords(v_mam(0, :, :), SCAE_v_rc1)
   copy_VarCoords(v_mam(0, :, :), SCAE_u_cor1)
   ;SST
   SCAW_sst_rc1  = regCoef(SCAW_hf(0:15),sst_mam1(lat|:,lon|:,time|:))
   SCAW_sst_cor1  = escorc(SCAW_hf(0:15),sst_mam1(lat|:,lon|:,time|:))
   SCAE_sst_rc1  = regCoef(SCAE_hf(0:15),sst_mam1(lat|:,lon|:,time|:))
   SCAE_sst_cor1  = escorc(SCAE_hf(0:15),sst_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(sst_mam(0,:,:), SCAW_sst_rc1)
   copy_VarCoords(sst_mam(0,:,:), SCAW_sst_cor1)
   copy_VarCoords(sst_mam(0,:,:), SCAE_sst_rc1)
   copy_VarCoords(sst_mam(0,:,:), SCAE_sst_cor1)
   ;TCC
   SCAW_tcc_rc1  = regCoef(SCAW_hf(0:15),tcc_mam1(lat|:,lon|:,time|:))
   SCAW_tcc_cor1  = escorc(SCAW_hf(0:15),tcc_mam1(lat|:,lon|:,time|:))
   SCAE_tcc_rc1  = regCoef(SCAE_hf(0:15),tcc_mam1(lat|:,lon|:,time|:))
   SCAE_tcc_cor1  = escorc(SCAE_hf(0:15),tcc_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(tcc_mam(0,:,:), SCAW_tcc_rc1)
   copy_VarCoords(tcc_mam(0,:,:), SCAW_tcc_cor1)
   copy_VarCoords(tcc_mam(0,:,:), SCAE_tcc_rc1)
   copy_VarCoords(tcc_mam(0,:,:), SCAE_tcc_cor1)
   ;Soil moisture
   SCAW_soilw_rc1  = regCoef(SCAW_hf(0:15),soilw_mam1(lat|:,lon|:,time|:))
   SCAW_soilw_cor1  = escorc(SCAW_hf(0:15),soilw_mam1(lat|:,lon|:,time|:))
   SCAE_soilw_rc1  = regCoef(SCAE_hf(0:15),soilw_mam1(lat|:,lon|:,time|:))
   SCAE_soilw_cor1  = escorc(SCAE_hf(0:15),soilw_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(soilw_mam(0,:,:), SCAW_soilw_rc1)
   copy_VarCoords(soilw_mam(0,:,:), SCAW_soilw_cor1)
   copy_VarCoords(soilw_mam(0,:,:), SCAE_soilw_rc1)
   copy_VarCoords(soilw_mam(0,:,:), SCAE_soilw_cor1)
   ;MaskNotLand lanseamask
   ;NSWR
   SCAW_nswr_rc1 = regCoef(SCAW_hf(0:15),nswr_mam1(lat|:,lon|:,time|:))
   SCAW_nswr_cor1 = escorc(SCAW_hf(0:15),nswr_mam1(lat|:,lon|:,time|:))
   SCAE_nswr_rc1 = regCoef(SCAE_hf(0:15),nswr_mam1(lat|:,lon|:,time|:))
   SCAE_nswr_cor1 = escorc(SCAE_hf(0:15),nswr_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(nswr_mam(0,:,:), SCAW_nswr_rc1)
   copy_VarCoords(nswr_mam(0,:,:), SCAW_nswr_cor1)
   copy_VarCoords(nswr_mam(0,:,:), SCAE_nswr_rc1)
   copy_VarCoords(nswr_mam(0,:,:), SCAE_nswr_cor1)
   ;NLWR
   SCAW_nlwr_rc1 = regCoef(SCAW_hf(0:15),nlwr_mam1(lat|:,lon|:,time|:))
   SCAW_nlwr_cor1 = escorc(SCAW_hf(0:15),nlwr_mam1(lat|:,lon|:,time|:))
   SCAE_nlwr_rc1 = regCoef(SCAE_hf(0:15),nlwr_mam1(lat|:,lon|:,time|:))
   SCAE_nlwr_cor1 = escorc(SCAE_hf(0:15),nlwr_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(nlwr_mam(0,:,:), SCAW_nlwr_rc1)
   copy_VarCoords(nlwr_mam(0,:,:), SCAW_nlwr_cor1)
   copy_VarCoords(nlwr_mam(0,:,:), SCAE_nlwr_rc1)
   copy_VarCoords(nlwr_mam(0,:,:), SCAE_nlwr_cor1)
   ;Latent HF
   SCAW_lhf_rc1 = regCoef_n(SCAW_hf(0:15),lhf_mam1, 0, 0)
   SCAW_lhf_cor1 = escorc_n(SCAW_hf(0:15),lhf_mam1, 0, 0)
   SCAE_lhf_rc1 = regCoef_n(SCAE_hf(0:15),lhf_mam1, 0, 0)
   SCAE_lhf_cor1 = escorc_n(SCAE_hf(0:15),lhf_mam1, 0, 0)
   copy_VarCoords(lhf_mam(0,:,:), SCAW_lhf_rc1)
   copy_VarCoords(lhf_mam(0,:,:), SCAW_lhf_cor1)
   copy_VarCoords(lhf_mam(0,:,:), SCAE_lhf_rc1)
   copy_VarCoords(lhf_mam(0,:,:), SCAE_lhf_cor1)
   ;Sensible HF
   SCAW_shf_rc1 = regCoef_n(SCAW_hf(0:15),shf_mam1, 0, 0)
   SCAW_shf_cor1 = escorc_n(SCAW_hf(0:15),shf_mam1, 0, 0)
   SCAE_shf_rc1 = regCoef_n(SCAE_hf(0:15),shf_mam1, 0, 0)
   SCAE_shf_cor1 = escorc_n(SCAE_hf(0:15),shf_mam1, 0, 0)
   copy_VarCoords(shf_mam(0,:,:), SCAW_shf_rc1)
   copy_VarCoords(shf_mam(0,:,:), SCAW_shf_cor1)
   copy_VarCoords(shf_mam(0,:,:), SCAE_shf_rc1)
   copy_VarCoords(shf_mam(0,:,:), SCAE_shf_cor1)
   ;Net Heat Flux
   SCAW_nhf_rc1 = regCoef_n(SCAW_hf(0:15),nhf_mam1, 0, 0)
   SCAW_nhf_cor1 = escorc_n(SCAW_hf(0:15),nhf_mam1, 0, 0)
   SCAE_nhf_rc1 = regCoef_n(SCAE_hf(0:15),nhf_mam1, 0, 0)
   SCAE_nhf_cor1 = escorc_n(SCAE_hf(0:15),nhf_mam1, 0, 0)
   copy_VarCoords(nhf_mam(0,:,:), SCAW_nhf_rc1)
   copy_VarCoords(nhf_mam(0,:,:), SCAW_nhf_cor1)
   copy_VarCoords(nhf_mam(0,:,:), SCAE_nhf_rc1)
   copy_VarCoords(nhf_mam(0,:,:), SCAE_nhf_cor1)

  ;*******************************************************************
  ;P2
   ;SCE
   SCAW_sce_rc2 = 100*regCoef(SCAW_hf(17:37),snow_mam2(lat|:,lon|:,time|:))
   SCAE_sce_rc2 = 100*regCoef(SCAE_hf(17:37),snow_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(snow_mam(0,:,:), SCAW_sce_rc2)
   copy_VarCoords(snow_mam(0,:,:), SCAE_sce_rc2)
   SCAW_sce_cor2  = escorc(SCAW_hf(17:37),snow_mam2(lat|:,lon|:,time|:))
   SCAE_sce_cor2  = escorc(SCAE_hf(17:37),snow_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(snow_mam(0,:,:), SCAW_sce_cor2)
   copy_VarCoords(snow_mam(0,:,:), SCAE_sce_cor2)
   ;SAT
   SCAW_sat_rc2  = regCoef(SCAW_hf(17:37),air_mam2(lat|:,lon|:,time|:))
   SCAW_sat_cor2  = escorc(SCAW_hf(17:37),air_mam2(lat|:,lon|:,time|:))
   SCAE_sat_rc2  = regCoef(SCAE_hf(17:37),air_mam2(lat|:,lon|:,time|:))
   SCAE_sat_cor2  = escorc(SCAE_hf(17:37),air_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(air_mam(0, :, :), SCAW_sat_rc2)
   copy_VarCoords(air_mam(0, :, :), SCAW_sat_cor2)
   copy_VarCoords(air_mam(0, :, :), SCAE_sat_rc2)
   copy_VarCoords(air_mam(0, :, :), SCAE_sat_cor2)
   ;SLP
   SCAW_slp_rc2  = regCoef(SCAW_hf(17:37),slp_mam2(lat|:,lon|:,time|:))
   SCAW_slp_cor2  = escorc(SCAW_hf(17:37),slp_mam2(lat|:,lon|:,time|:))
   SCAE_slp_rc2  = regCoef(SCAE_hf(17:37),slp_mam2(lat|:,lon|:,time|:))
   SCAE_slp_cor2  = escorc(SCAE_hf(17:37),slp_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(slp_mam(0, :, :), SCAW_slp_rc2)
   copy_VarCoords(slp_mam(0, :, :), SCAW_slp_cor2)
   copy_VarCoords(slp_mam(0, :, :), SCAE_slp_rc2)
   copy_VarCoords(slp_mam(0, :, :), SCAE_slp_cor2)
   ;Z500
   SCAW_z500_rc2 = regCoef(SCAW_hf(17:37),z500_mam2(lat|:,lon|:,time|:))
   SCAW_z500_cor2 = escorc(SCAW_hf(17:37),z500_mam2(lat|:,lon|:,time|:))
   SCAE_z500_rc2 = regCoef(SCAE_hf(17:37),z500_mam2(lat|:,lon|:,time|:))
   SCAE_z500_cor2 = escorc(SCAE_hf(17:37),z500_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(z500_mam(0, :, :), SCAW_z500_rc2)
   copy_VarCoords(z500_mam(0, :, :), SCAW_z500_cor2)
   copy_VarCoords(z500_mam(0, :, :), SCAE_z500_rc2)
   copy_VarCoords(z500_mam(0, :, :), SCAE_z500_cor2)
   ;Z200
   SCAW_z200_rc2 = regCoef(SCAW_hf(17:37),z200_mam2(lat|:,lon|:,time|:))
   SCAW_z200_cor2 = escorc(SCAW_hf(17:37),z200_mam2(lat|:,lon|:,time|:))
   SCAE_z200_rc2 = regCoef(SCAE_hf(17:37),z200_mam2(lat|:,lon|:,time|:))
   SCAE_z200_cor2 = escorc(SCAE_hf(17:37),z200_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(z200_mam(0, :, :), SCAW_z200_rc2)
   copy_VarCoords(z200_mam(0, :, :), SCAW_z200_cor2)
   copy_VarCoords(z200_mam(0, :, :), SCAE_z200_rc2)
   copy_VarCoords(z200_mam(0, :, :), SCAE_z200_cor2)
   ;U-wind
   SCAW_u_rc2    = regCoef(SCAW_hf(17:37),u_mam2(lat|:,lon|:,time|:))
   SCAW_u_cor2    = escorc(SCAW_hf(17:37),u_mam2(lat|:,lon|:,time|:))
   SCAE_u_rc2    = regCoef(SCAE_hf(17:37),u_mam2(lat|:,lon|:,time|:))
   SCAE_u_cor2    = escorc(SCAE_hf(17:37),u_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(u_mam(0, :, :), SCAW_u_rc2)
   copy_VarCoords(u_mam(0, :, :), SCAW_u_cor2)
   copy_VarCoords(u_mam(0, :, :), SCAE_u_rc2)
   copy_VarCoords(u_mam(0, :, :), SCAE_u_cor2)
   ;V-wind
   SCAW_v_rc2    = regCoef(SCAW_hf(17:37),v_mam2(lat|:,lon|:,time|:))
   SCAW_v_cor2    = escorc(SCAW_hf(17:37),v_mam2(lat|:,lon|:,time|:))
   SCAE_v_rc2    = regCoef(SCAE_hf(17:37),v_mam2(lat|:,lon|:,time|:))
   SCAE_v_cor2    = escorc(SCAE_hf(17:37),v_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(v_mam(0, :, :), SCAW_v_rc2)
   copy_VarCoords(v_mam(0, :, :), SCAW_v_cor2)
   copy_VarCoords(v_mam(0, :, :), SCAE_v_rc2)
   copy_VarCoords(v_mam(0, :, :), SCAE_u_cor2)
   ;Soil moisture
   SCAW_soilw_rc2  = regCoef(SCAW_hf(17:37),soilw_mam2(lat|:,lon|:,time|:))
   SCAW_soilw_cor2  = escorc(SCAW_hf(17:37),soilw_mam2(lat|:,lon|:,time|:))
   SCAE_soilw_rc2  = regCoef(SCAE_hf(17:37),soilw_mam2(lat|:,lon|:,time|:))
   SCAE_soilw_cor2  = escorc(SCAE_hf(17:37),soilw_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(soilw_mam(0,:,:), SCAW_soilw_rc2)
   copy_VarCoords(soilw_mam(0,:,:), SCAW_soilw_cor2)
   copy_VarCoords(soilw_mam(0,:,:), SCAE_soilw_rc2)
   copy_VarCoords(soilw_mam(0,:,:), SCAE_soilw_cor2)
   ;SST
   SCAW_sst_rc2  = regCoef(SCAW_hf(17:37),sst_mam2(lat|:,lon|:,time|:))
   SCAW_sst_cor2  = escorc(SCAW_hf(17:37),sst_mam2(lat|:,lon|:,time|:))
   SCAE_sst_rc2  = regCoef(SCAE_hf(17:37),sst_mam2(lat|:,lon|:,time|:))
   SCAE_sst_cor2  = escorc(SCAE_hf(17:37),sst_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(sst_mam(0,:,:), SCAW_sst_rc2)
   copy_VarCoords(sst_mam(0,:,:), SCAW_sst_cor2)
   copy_VarCoords(sst_mam(0,:,:), SCAE_sst_rc2)
   copy_VarCoords(sst_mam(0,:,:), SCAE_sst_cor2)
   ;NSWR
   SCAW_nswr_rc2 = regCoef(SCAW_hf(17:37),nswr_mam2(lat|:,lon|:,time|:))
   SCAW_nswr_cor2 = escorc(SCAW_hf(17:37),nswr_mam2(lat|:,lon|:,time|:))
   SCAE_nswr_rc2 = regCoef(SCAE_hf(17:37),nswr_mam2(lat|:,lon|:,time|:))
   SCAE_nswr_cor2 = escorc(SCAE_hf(17:37),nswr_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(nswr_mam(0,:,:), SCAW_nswr_rc2)
   copy_VarCoords(nswr_mam(0,:,:), SCAW_nswr_cor2)
   copy_VarCoords(nswr_mam(0,:,:), SCAE_nswr_rc2)
   copy_VarCoords(nswr_mam(0,:,:), SCAE_nswr_cor2)
   ;NLWR
   SCAW_nlwr_rc2 = regCoef(SCAW_hf(17:37),nlwr_mam2(lat|:,lon|:,time|:))
   SCAW_nlwr_cor2 = escorc(SCAW_hf(17:37),nlwr_mam2(lat|:,lon|:,time|:))
   SCAE_nlwr_rc2 = regCoef(SCAE_hf(17:37),nlwr_mam2(lat|:,lon|:,time|:))
   SCAE_nlwr_cor2 = escorc(SCAE_hf(17:37),nlwr_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(nlwr_mam(0,:,:), SCAW_nlwr_rc2)
   copy_VarCoords(nlwr_mam(0,:,:), SCAW_nlwr_cor2)
   copy_VarCoords(nlwr_mam(0,:,:), SCAE_nlwr_rc2)
   copy_VarCoords(nlwr_mam(0,:,:), SCAE_nlwr_cor2)
   ;Latent HF
   SCAW_lhf_rc2 = regCoef_n(SCAW_hf(17:37),lhf_mam2, 0, 0)
   SCAW_lhf_cor2 = escorc_n(SCAW_hf(17:37),lhf_mam2, 0, 0)
   SCAE_lhf_rc2 = regCoef_n(SCAE_hf(17:37),lhf_mam2, 0, 0)
   SCAE_lhf_cor2 = escorc_n(SCAE_hf(17:37),lhf_mam2, 0, 0)
   copy_VarCoords(lhf_mam(0,:,:), SCAW_lhf_rc2)
   copy_VarCoords(lhf_mam(0,:,:), SCAW_lhf_cor2)
   copy_VarCoords(lhf_mam(0,:,:), SCAE_lhf_rc2)
   copy_VarCoords(lhf_mam(0,:,:), SCAE_lhf_cor2)
   ;Sensible HF
   SCAW_shf_rc2 = regCoef_n(SCAW_hf(17:37),shf_mam2, 0, 0)
   SCAW_shf_cor2 = escorc_n(SCAW_hf(17:37),shf_mam2, 0, 0)
   SCAE_shf_rc2 = regCoef_n(SCAE_hf(17:37),shf_mam2, 0, 0)
   SCAE_shf_cor2 = escorc_n(SCAE_hf(17:37),shf_mam2, 0, 0)
   copy_VarCoords(shf_mam(0,:,:), SCAW_shf_rc2)
   copy_VarCoords(shf_mam(0,:,:), SCAW_shf_cor2)
   copy_VarCoords(shf_mam(0,:,:), SCAE_shf_rc2)
   copy_VarCoords(shf_mam(0,:,:), SCAE_shf_cor2)
   ;TCC
   SCAW_tcc_rc2  = regCoef(SCAW_hf(17:37),tcc_mam2(lat|:,lon|:,time|:))
   SCAW_tcc_cor2  = escorc(SCAW_hf(17:37),tcc_mam2(lat|:,lon|:,time|:))
   SCAE_tcc_rc2  = regCoef(SCAE_hf(17:37),tcc_mam2(lat|:,lon|:,time|:))
   SCAE_tcc_cor2  = escorc(SCAE_hf(17:37),tcc_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(tcc_mam(0,:,:), SCAW_tcc_rc2)
   copy_VarCoords(tcc_mam(0,:,:), SCAW_tcc_cor2)
   copy_VarCoords(tcc_mam(0,:,:), SCAE_tcc_rc2)
   copy_VarCoords(tcc_mam(0,:,:), SCAE_tcc_cor2)
   ;Net Heat Flux
   SCAW_nhf_rc2 = regCoef_n(SCAW_hf(17:37),nhf_mam2, 0, 0)
   SCAW_nhf_cor2 = escorc_n(SCAW_hf(17:37),nhf_mam2, 0, 0)
   SCAE_nhf_rc2 = regCoef_n(SCAE_hf(17:37),nhf_mam2, 0, 0)
   SCAE_nhf_cor2 = escorc_n(SCAE_hf(17:37),nhf_mam2, 0, 0)
   copy_VarCoords(nhf_mam(0,:,:), SCAW_nhf_rc2)
   copy_VarCoords(nhf_mam(0,:,:), SCAW_nhf_cor2)
   copy_VarCoords(nhf_mam(0,:,:), SCAE_nhf_rc2)
   copy_VarCoords(nhf_mam(0,:,:), SCAE_nhf_cor2)

  ;Center EU
   SCAC_sce_cor2  = escorc(SCAC_hf(17:37),snow_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(snow_mam(0,:,:), SCAC_sce_cor2)
   SCAC_sat_rc2  = regCoef(SCAC_hf(17:37),air_mam2(lat|:,lon|:,time|:))
   SCAC_sat_cor2  = escorc(SCAC_hf(17:37),air_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(air_mam(0, :, :), SCAC_sat_rc2)
   copy_VarCoords(air_mam(0, :, :), SCAC_sat_cor2)
   ;SLP
   SCAC_slp_rc2  = regCoef(SCAC_hf(17:37),slp_mam2(lat|:,lon|:,time|:))
   SCAC_slp_cor2  = escorc(SCAC_hf(17:37),slp_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(slp_mam(0, :, :), SCAC_slp_rc2)
   copy_VarCoords(slp_mam(0, :, :), SCAC_slp_cor2)
   ;Z500
   SCAC_z500_rc2 = regCoef(SCAC_hf(17:37),z500_mam2(lat|:,lon|:,time|:))
   SCAC_z500_cor2 = escorc(SCAC_hf(17:37),z500_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(z500_mam(0, :, :), SCAC_z500_rc2)
   copy_VarCoords(z500_mam(0, :, :), SCAC_z500_cor2)
   ; ;Z200
   ; SCAC_z200_rc2 = regCoef(SCAC_hf(17:37),z200_mam2(lat|:,lon|:,time|:))
   ; SCAC_z200_cor2 = escorc(SCAC_hf(17:37),z200_mam2(lat|:,lon|:,time|:))
   ; copy_VarCoords(z200_mam(0, :, :), SCAC_z200_rc2)
   ; copy_VarCoords(z200_mam(0, :, :), SCAC_z200_cor2)
   ;U-wind
   SCAC_u_rc2    = regCoef(SCAC_hf(17:37),u_mam2(lat|:,lon|:,time|:))
   SCAC_u_cor2    = escorc(SCAC_hf(17:37),u_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(u_mam(0, :, :), SCAC_u_rc2)
   copy_VarCoords(u_mam(0, :, :), SCAC_u_cor2)
   ;V-wind
   SCAC_v_rc2    = regCoef(SCAC_hf(17:37),v_mam2(lat|:,lon|:,time|:))
   SCAC_v_cor2    = escorc(SCAC_hf(17:37),v_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(v_mam(0, :, :), SCAC_v_rc2)
   copy_VarCoords(v_mam(0, :, :), SCAC_v_cor2)
   ; ;NSWR
   ; SCAC_nswr_rc2 = regCoef(SCAC_hf(17:37),nswr_mam2(lat|:,lon|:,time|:))
   ; SCAC_nswr_cor2 = escorc(SCAC_hf(17:37),nswr_mam2(lat|:,lon|:,time|:))
   ; copy_VarCoords(nswr_mam(0,:,:), SCAC_nswr_rc2)
   ; copy_VarCoords(nswr_mam(0,:,:), SCAC_nswr_cor2)
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

   ;For SLP
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
   resrc2@cnLineLabelFontHeightF = 0.015
   ;resrc2@cnLineLabelFontColor = 0
   resrc2@cnLineLabelFontThicknessF = 1.0
   resrc2@gsnAddCyclic = True

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

   resHeat = resrc
   resHeat@lbLabelBarOn = False
   resHeat@mpMinLonF = 70.
   resHeat@mpMaxLonF = 150.
   resHeat@mpMaxLatF = 80.
   resHeat@mpMinLatF = 20.
   resHeat@cnMinLevelValF = -6.
   resHeat@cnMaxLevelValF = 6.
   resHeat@cnLevelSpacingF = 0.5
   resHeat@mpAreaMaskingOn = True
   ;resHeat@mpGridMaskMode = "MaskLand"
   ;resHeat@mpMaskAreaSpecifiers = (/"Russia","China","korean","japan","indo"/)

   restcc = resrc
   restcc@lbLabelBarOn = False
   restcc@mpMinLonF = 70.
   restcc@mpMaxLonF = 150.
   restcc@mpMaxLatF = 80.
   restcc@mpMinLatF = 20.
   restcc@cnMinLevelValF = -8.
   restcc@cnMaxLevelValF = 8.
   restcc@cnLevelSpacingF = 0.5
   restcc@mpAreaMaskingOn = True
   restcc@lbLabelBarOn = False

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
   resP@gsnPanelFigureStringsFontHeightF = 0.012
   resP@gsnPanelFigureStringsPerimOn = False
   resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   resP@amJust = "TopLeft"
   resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   resP@amParallelPosF = -0.50    ;X-axis

;**************************************************
;P1 
;************************************************ 
   rescor@cnLevels = (/-sig1,sig1/)
   print("P1:Sig = "+sig1)
   ;SAT + Wind
   resrc@cnMinLevelValF = -2.
   resrc@cnMaxLevelValF = 2.
   resrc@cnLevelSpacingF = 0.1
   resrc@gsnLeftString = "(c) SCAWI:P1"+" SAT+Wind(850hPa)"
   Wsat1 = gsn_csm_contour_map(wks, SCAW_sat_rc1 ,resrc)
   Wwnd1 = gsn_csm_vector(wks, SCAW_u_rc1, SCAW_v_rc1, resV)
   Wsatcor1 = gsn_csm_contour(wks, SCAW_sat_cor1, rescor)
   overlay(Wsat1, Wwnd1)
   overlay(Wsat1, Wsatcor1)
   ; draw(Wsat1)
   ; frame(wks)
   resrc@gsnLeftString = "(a) SCAEI:P1"+" SAT+Wind(850hPa)"
   Esat1 = gsn_csm_contour_map(wks, SCAE_sat_rc1 ,resrc) ;Regression Map as based map
   Ewnd1 = gsn_csm_vector(wks, SCAE_u_rc1, SCAE_v_rc1, resV) 
   Esatcor1 = gsn_csm_contour(wks, SCAE_sat_cor1, rescor) ; Correlation overlay
   overlay(Esat1, Ewnd1)
   overlay(Esat1, Esatcor1)
   ; draw(Esat1)
   ; frame(wks)

   ;SLP-Wind
   resrc@cnMinLevelValF = -3.
   resrc@cnMaxLevelValF = 3.
   resrc@cnLevelSpacingF = 0.2
   resrc@gsnLeftString = "(c) SCAW:P1"+" SLP"
   Wslp1 = gsn_csm_contour_map(wks, SCAW_slp_rc1 ,resrc)
   Wslpcor1 = gsn_csm_contour(wks, SCAW_slp_cor1, rescor)
   Wslpline1 = gsn_csm_contour(wks, SCAW_slp_rc1, resrc2)
   overlay(Wslp1, Wslpline1)
   overlay(Wslp1, Wslpcor1)
   ; draw(Wslp1)
   ; frame(wks)
   resrc@gsnLeftString = "(c) SCAE:P1"+" SLP"
   Eslp1 = gsn_csm_contour_map(wks, SCAE_slp_rc1 ,resrc)
   Eslpcor1 = gsn_csm_contour(wks, SCAE_slp_cor1, rescor)
   Eslpline1 = gsn_csm_contour(wks, SCAE_slp_rc1, resrc2)
   overlay(Eslp1, Eslpline1)
   overlay(Eslp1, Eslpcor1)
   ; draw(Eslp1)
   ; frame(wks)

  ;Net radiation flux
   ;Net SWR
   resHeat@gsnLeftString = "SCAWI:P1"+" SWR"
   Wnsr1 = gsn_csm_contour_map(wks, SCAW_nswr_rc1, resHeat)
   Wnsrcor1 = gsn_csm_contour(wks, SCAW_nswr_cor1, rescor)
   overlay(Wnsr1, Wnsrcor1)
   ; draw(Wnsr1)
   ; frame(wks)
   resHeat@gsnLeftString = "SCAEI:P1"+" SWR"
   Ensr1 = gsn_csm_contour_map(wks, SCAE_nswr_rc1, resHeat)
   Ensrcor1 = gsn_csm_contour(wks, SCAE_nswr_cor1, rescor)
   overlay(Ensr1, Ensrcor1)

  ;Net LWR
   resHeat@gsnLeftString = "SCAWI:P1"+" LWR"
   Wnlr1 = gsn_csm_contour_map(wks, SCAW_nlwr_rc1, resHeat)
   Wnlrcor1 = gsn_csm_contour(wks, SCAW_nlwr_cor1, rescor)
   overlay(Wnlr1, Wnlrcor1)
   resHeat@gsnLeftString = "SCAEI:P1"+" LWR"
   Enlr1 = gsn_csm_contour_map(wks, SCAE_nlwr_rc1, resHeat)
   Enlrcor1 = gsn_csm_contour(wks, SCAE_nlwr_cor1, rescor)
   overlay(Enlr1, Enlrcor1)

  ;Latent HF
   resHeat@gsnLeftString = "SCAWI:P1"+" LHF"   
   Wlhf1 = gsn_csm_contour_map(wks, SCAW_lhf_rc1, resHeat)
   Wlhfcor1 = gsn_csm_contour(wks, SCAW_lhf_cor1, rescor)
   overlay(Wlhf1, Wlhfcor1)
   resHeat@gsnLeftString = "SCAEI:P1"+" LHF"
   Elhf1 = gsn_csm_contour_map(wks, SCAE_lhf_rc1, resHeat)
   Elhfcor1 = gsn_csm_contour(wks, SCAE_lhf_cor1, rescor)
   overlay(Elhf1, Elhfcor1)

  ;Sensible HF
   resHeat@gsnLeftString = "SCAWI:P1"+" SHF"   
   Wshf1 = gsn_csm_contour_map(wks, SCAW_shf_rc1, resHeat)
   Wshfcor1 = gsn_csm_contour(wks, SCAW_shf_cor1, rescor)
   overlay(Wshf1, Wshfcor1)
   resHeat@gsnLeftString = "SCAEI:P1"+" SHF"
   Eshf1 = gsn_csm_contour_map(wks, SCAE_shf_rc1, resHeat)
   Eshfcor1 = gsn_csm_contour(wks, SCAE_shf_cor1, rescor)
   overlay(Eshf1, Eshfcor1)

   resHeat@gsnLeftString = "SCAEI: P1 NHF"
   Enhf1 = gsn_csm_contour_map(wks, SCAE_nhf_rc1, resHeat)
   Enhfcor1 = gsn_csm_contour(wks, SCAE_nhf_cor1, rescor)
   overlay(Enhf1, Enhfcor1)

   ;TCC
   restcc@gsnLeftString = "SCAWI:P1"+" TCC"
   Wtcc1 = gsn_csm_contour_map(wks, SCAW_tcc_rc1, restcc)
   Wtcccor = gsn_csm_contour(wks, SCAW_tcc_cor1, rescor)
   overlay(Wtcc1, Wtcccor)
   ; draw(Wtcc1)
   ; frame(wks)
   restcc@gsnLeftString = "(a) SCAEI:P1"+" TCC"
   Etcc1 = gsn_csm_contour_map(wks, SCAE_tcc_rc1, restcc)
   Etcccor1 = gsn_csm_contour(wks, SCAE_tcc_cor1, rescor)
   overlay(Etcc1, Etcccor1)
   ; draw(Etcc1)
   ; frame(wks)

   ;Soil Moisture
   ressoil@cnMinLevelValF = -50.
   ressoil@cnMaxLevelValF = 50.
   ressoil@cnLevelSpacingF = 2.0
   ressoil@gsnLeftString = "SCAW:P1"+" Soil moisture"
   Wsoil1 = gsn_csm_contour_map(wks, SCAW_soilw_rc1, ressoil)
   Wsoilcor1 = gsn_csm_contour(wks, SCAW_soilw_cor1, rescor)
   overlay(Wsoil1, Wsoilcor1)
   draw(Wsoil1)
   frame(wks)
   ressoil@gsnLeftString = "SCAE:P1"+" Soil moisture"
   Esoil1 = gsn_csm_contour_map(wks, SCAE_soilw_rc1, ressoil)
   Esoilcor1 = gsn_csm_contour(wks, SCAE_soilw_cor1, rescor)
   overlay(Esoil1, Esoilcor1)
   draw(Esoil1)
   frame(wks)
   ; ressoil@gsnLeftString = "SCAC:P1"+" Soil moisture"
   ; Csoil1 = gsn_csm_contour_map(wks, SCAC_soilw_rc1, ressoil)
   ; Csoilcor1 = gsn_csm_contour(wks, SCAC_soilw_cor1, rescor)
   ; overlay(Csoil1, Csoilcor1)
   ; draw(Csoil1)
   ; frame(wks)

   ;Snow Cor
   ressnow@cnMinLevelValF = -16
   ressnow@cnMaxLevelValF = 16
   ressnow@cnLevelSpacingF = 1
   ressnow@gsnLeftString = "(a) SCAWI:P1"+" SCE"
   Wsce1 = gsn_csm_contour_map(wks, SCAW_sce_rc1, ressnow)
   Wscecor1 = gsn_csm_contour(wks, SCAW_sce_cor1, rescor)
   overlay(Wsce1, Wscecor1)
   ; draw(Wsce1)
   ; frame(wks)
   ressnow@gsnLeftString = "(a) SCAEI:P1"+" SCE"
   Esce1 = gsn_csm_contour_map(wks, SCAE_sce_rc1, ressnow)
   Escecor1 = gsn_csm_contour(wks, SCAE_sce_cor1, rescor)
   overlay(Esce1, Escecor1)
   ; draw(Esce1)
   ; frame(wks)

   ;SST 
   resSST@gsnLeftString = ""
   resSST@cnMinLevelValF = -0.5
   resSST@cnMaxLevelValF = 0.5
   resSST@cnLevelSpacingF = 0.1
   resSST@gsnCenterString = "SCAW:P1 SST"
   Wsst1 = gsn_csm_contour_map(wks, SCAW_sst_rc1, resSST)
   Wsstcor1  = gsn_csm_contour(wks, SCAW_sst_cor1, rescor)
   overlay(Wsst1, Wsstcor1)
   ; draw(Wsst1)
   ; frame(wks)
   resSST@gsnCenterString = "SCAE:P1 SST"
   Esst1 = gsn_csm_contour_map(wks, SCAE_sst_rc1, resSST)
   Esstcor1  = gsn_csm_contour(wks, SCAE_sst_cor1, rescor)
   overlay(Esst1, Esstcor1)
   ; draw(Esst1)
   ; frame(wks)
   ; resSST@gsnCenterString = "SCAC:P1 SST"
   ; Csst1 = gsn_csm_contour_map(wks, SCAC_sst_rc1, resSST)
   ; Csstcor1  = gsn_csm_contour(wks, SCAC_sst_cor1, rescor)
   ; overlay(Csst1, Csstcor1)
   ; draw(Csst1)
   ; frame(wks)

 ;P2  
 ;************************************************ 
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.

   rescor@cnLevels = (/-sig2,sig2/)
   print("P2:Sig = "+sig2)
   resrc@cnMinLevelValF = -2.
   resrc@cnMaxLevelValF = 2.
   resrc@cnLevelSpacingF = 0.1
   resrc@gsnLeftString = "(d) SCAWI:P2"+" SAT+Wind(850hPa)"
   Wsat2 = gsn_csm_contour_map(wks, SCAW_sat_rc2 ,resrc)
   Wwnd2 = gsn_csm_vector(wks, SCAW_u_rc2, SCAW_v_rc2, resV)
   Wsatcor2 = gsn_csm_contour(wks, SCAW_sat_cor2, rescor)
   overlay(Wsat2, Wwnd2)
   overlay(Wsat2, Wsatcor2)
   ; draw(Wsat2)
   ; frame(wks)
   resrc@gsnLeftString = "(b) SCAEI:P2"+" SAT+Wind(850hPa)"
   Esat2 = gsn_csm_contour_map(wks, SCAE_sat_rc2 ,resrc) ;Regression Map as based map
   Ewnd2 = gsn_csm_vector(wks, SCAE_u_rc2, SCAE_v_rc2, resV) 
   Esatcor2 = gsn_csm_contour(wks, SCAE_sat_cor2, rescor) ; Correlation overlay
   overlay(Esat2, Ewnd2)
   overlay(Esat2, Esatcor2)
   ; draw(Esat2)
   ; frame(wks)

   ;SLP-Wind
   resrc@cnMinLevelValF = -3.
   resrc@cnMaxLevelValF = 3.
   resrc@cnLevelSpacingF = 0.2
   resrc@gsnLeftString = "(d) SCAW:P2"+" SLP"
   Wslp2 = gsn_csm_contour_map(wks, SCAW_slp_rc2 ,resrc)
   Wslpcor2 = gsn_csm_contour(wks, SCAW_slp_cor2, rescor)
   Wslpline2 = gsn_csm_contour(wks, SCAW_slp_rc2, resrc2)
   overlay(Wslp2, Wslpline2)
   overlay(Wslp2, Wslpcor2)
   ; draw(Wslp2)
   ; frame(wks)
   resrc@gsnLeftString = "(d) SCAE:P2"+" SLP"
   Eslp2 = gsn_csm_contour_map(wks, SCAE_slp_rc2 ,resrc)
   Eslpcor2 = gsn_csm_contour(wks, SCAE_slp_cor2, rescor)
   Eslpline2 = gsn_csm_contour(wks, SCAE_slp_rc2, resrc2)
   overlay(Eslp2, Eslpline2)
   overlay(Eslp2, Eslpcor2)
   ; draw(Eslp2)
   ; frame(wks)

  ;Net radiation flux
   ;Net SWR
   resHeat@gsnLeftString = "SCAWI:P2"+" SWR"
   Wnsr2 = gsn_csm_contour_map(wks, SCAW_nswr_rc2, resHeat)
   Wnsrcor2 = gsn_csm_contour(wks, SCAW_nswr_cor2, rescor)
   overlay(Wnsr2, Wnsrcor2)
   ; draw(Wnsr2)
   ; frame(wks)
   resHeat@gsnLeftString = "SCAEI:P2"+" SWR"
   Ensr2 = gsn_csm_contour_map(wks, SCAE_nswr_rc2, resHeat)
   Ensrcor2 = gsn_csm_contour(wks, SCAE_nswr_cor2, rescor)
   overlay(Ensr2, Ensrcor2)

  ;Net LWR
   resHeat@gsnLeftString = "SCAWI:P2"+" LWR"
   Wnlr2 = gsn_csm_contour_map(wks, SCAW_nlwr_rc2, resHeat)
   Wnlrcor2 = gsn_csm_contour(wks, SCAW_nlwr_cor2, rescor)
   overlay(Wnlr2, Wnlrcor2)
   resHeat@gsnLeftString = "SCAEI:P2"+" LWR"
   Enlr2 = gsn_csm_contour_map(wks, SCAE_nlwr_rc2, resHeat)
   Enlrcor2 = gsn_csm_contour(wks, SCAE_nlwr_cor2, rescor)
   overlay(Enlr2, Enlrcor2)

  ;Latent HF
   resHeat@gsnLeftString = "SCAWI:P2"+" LHF"   
   Wlhf2 = gsn_csm_contour_map(wks, SCAW_lhf_rc2, resHeat)
   Wlhfcor2 = gsn_csm_contour(wks, SCAW_lhf_cor2, rescor)
   overlay(Wlhf2, Wlhfcor2)
   resHeat@gsnLeftString = "SCAEI:P2"+" LHF"
   Elhf2 = gsn_csm_contour_map(wks, SCAE_lhf_rc2, resHeat)
   Elhfcor2 = gsn_csm_contour(wks, SCAE_lhf_cor2, rescor)
   overlay(Elhf2, Elhfcor2)

  ;Sensible HF
   resHeat@gsnLeftString = "SCAWI:P2"+" SHF"   
   Wshf2 = gsn_csm_contour_map(wks, SCAW_shf_rc2, resHeat)
   Wshfcor2 = gsn_csm_contour(wks, SCAW_shf_cor2, rescor)
   overlay(Wshf2, Wshfcor2)
   resHeat@gsnLeftString = "SCAEI:P2"+" SHF"
   Eshf2 = gsn_csm_contour_map(wks, SCAE_shf_rc2, resHeat)
   Eshfcor2 = gsn_csm_contour(wks, SCAE_shf_cor2, rescor)
   overlay(Eshf2, Eshfcor2)

   resHeat@gsnLeftString = "SCAEI: P2 NHF"
   Enhf2 = gsn_csm_contour_map(wks, SCAE_nhf_rc2, resHeat)
   Enhfcor2 = gsn_csm_contour(wks, SCAE_nhf_cor2, rescor)
   overlay(Enhf2, Enhfcor2)

   ;TCC
   restcc@gsnLeftString = "(d) SCAWI:P2"+" TCC"
   Wtcc2 = gsn_csm_contour_map(wks, SCAW_tcc_rc2, restcc)
   Wtcccor = gsn_csm_contour(wks, SCAW_tcc_cor2, rescor)
   overlay(Wtcc2, Wtcccor)
   ; draw(Wtcc2)
   ; frame(wks)
   restcc@gsnLeftString = "(b) SCAEI:P2"+" TCC"
   Etcc2 = gsn_csm_contour_map(wks, SCAE_tcc_rc2, restcc)
   Etcccor2 = gsn_csm_contour(wks, SCAE_tcc_cor2, rescor)
   overlay(Etcc2, Etcccor2)
   ; draw(Etcc2)
   ; frame(wks)

   ;Soil Moisture
   ressoil@cnMinLevelValF = -50.
   ressoil@cnMaxLevelValF = 50.
   ressoil@cnLevelSpacingF = 2.0
   ressoil@gsnLeftString = "SCAW:P2"+" Soil moisture"
   Wsoil2 = gsn_csm_contour_map(wks, SCAW_soilw_rc2, ressoil)
   Wsoilcor2 = gsn_csm_contour(wks, SCAW_soilw_cor2, rescor)
   overlay(Wsoil2, Wsoilcor2)
   draw(Wsoil2)
   frame(wks)
   ressoil@gsnLeftString = "SCAE:P2"+" Soil moisture"
   Esoil2 = gsn_csm_contour_map(wks, SCAE_soilw_rc2, ressoil)
   Esoilcor2 = gsn_csm_contour(wks, SCAE_soilw_cor2, rescor)
   overlay(Esoil2, Esoilcor2)
   draw(Esoil2)
   frame(wks)

   ;Snow Cor
   ressnow@gsnLeftString = "(b) SCAWI:P2"+" SCE"
   Wsce2 = gsn_csm_contour_map(wks, SCAW_sce_rc2, ressnow)
   Wscecor2 = gsn_csm_contour(wks, SCAW_sce_cor2, rescor)
   overlay(Wsce2, Wscecor2)
   ; draw(Wsce2)
   ; frame(wks)
   ressnow@gsnLeftString = "(d) SCACI:P2"+" SCE"
   Csce2 = gsn_csm_contour_map(wks, SCAC_sce_cor2, ressnow)
   Cscecor2 = gsn_csm_contour(wks, SCAC_sce_cor2, rescor)
   overlay(Csce2, Cscecor2)
   ; draw(Csce2)
   ; frame(wks)
   ressnow@gsnLeftString = "(b) SCAEI:P2"+" SCE"
   Esce2 = gsn_csm_contour_map(wks, SCAE_sce_rc2, ressnow)
   Escecor2 = gsn_csm_contour(wks, SCAE_sce_cor2, rescor)
   overlay(Esce2, Escecor2)
   ; draw(Esce2)
   ; frame(wks)

   ;SST 
   resSST@gsnCenterString = "SCAW:P2 SST"
   Wsst2 = gsn_csm_contour_map(wks, SCAW_sst_rc2, resSST)
   Wsstcor2  = gsn_csm_contour(wks, SCAW_sst_cor2, rescor)
   overlay(Wsst2, Wsstcor2)
   ; draw(Wsst2)
   ; frame(wks)
   resSST@gsnCenterString = "SCAE:P2 SST"
   Esst2 = gsn_csm_contour_map(wks, SCAE_sst_rc2, resSST)
   Esstcor2  = gsn_csm_contour(wks, SCAE_sst_cor2, rescor)
   overlay(Esst2, Esstcor2)
   ; draw(Esst2)
   ; frame(wks)

  ;Panel plot
   resP@gsnPanelLabelBar = True

   slpW = new(2, "graphic")
   slpC = new(2, "graphic")
   slpE = new(2, "graphic")

   ; snowWCE = new(6, "graphic")
   ; snowWCE(0) = Wsce1
   ; snowWCE(1) = Wsce2
   ; snowWCE(2) = Csce1
   ; snowWCE(3) = Csce2
   ; snowWCE(4) = Esce1
   ; snowWCE(5) = Esce2
   ;gsn_panel(wks, snowWCE, (/3,2/), resP)

   sstW = new(2, "graphic")
   sstE = new(2, "graphic")
   sstW(0) = Wsst1
   sstW(1) = Wsst2
   sstE(0) = Esst1
   sstE(1) = Esst2
   gsn_panel(wks, sstW, (/1,2/), resP)
   gsn_panel(wks, sstE, (/1,2/), resP)

   resP@gsnPanelLabelBar = False
   satslpW = new(4, "graphic")
   satslpE = new(4, "graphic")
   satslpC = new(4, "graphic")
   satslpW(0) = Wsat1
   satslpW(1) = Wsat2
   satslpW(2) = Wslp1
   satslpW(3) = Wslp2
   gsn_panel(wks, satslpW, (/2,2/), resP)
   satslpE(0) = Esat1
   satslpE(1) = Esat2
   satslpE(2) = Eslp1
   satslpE(3) = Eslp2
   gsn_panel(wks, satslpE, (/2,2/), resP)

   snowsatW = new(4, "graphic")
   snowsatE = new(4, "graphic")
   snowsatW(0) = Wsce1
   snowsatW(1) = Wsce2
   snowsatW(2) = Wsat1
   snowsatW(3) = Wsat2
   gsn_panel(wks, snowsatW, (/2,2/), resP)
   snowsatE(0) = Esce1
   snowsatE(1) = Esce2
   snowsatE(2) = Esat1
   snowsatE(3) = Esat2
   gsn_panel(wks, snowsatE, (/2,2/), resP)

   resP@gsnPanelLabelBar = True
   resP@gsnPanelRowSpec = True
   ; E_nhf1 = new(5, "graphic")
   ; E_nhf1(0) = Enhf1
   ; E_nhf1(1) = Ensr1
   ; E_nhf1(2) = Enlr1
   ; E_nhf1(3) = Elhf1
   ; E_nhf1(4) = Eshf1
   ; gsn_panel(wks, E_nhf1, (/1,2,2/), resP)

   ; E_nhf2 = new(5, "graphic")
   ; E_nhf2(0) = Enhf2
   ; E_nhf2(1) = Ensr2
   ; E_nhf2(2) = Enlr2
   ; E_nhf2(3) = Elhf2
   ; E_nhf2(4) = Eshf2
   ; gsn_panel(wks, E_nhf2, (/1,2,2/), resP)

   tccnsrW = new(2, "graphic")
   tccnsrE = new(2, "graphic")
   tccnsrW(0) = Wtcc1
   tccnsrW(1) = Wtcc2
   gsn_panel(wks, tccnsrW, (/2,1/), resP)
   tccnsrE(0) = Etcc1
   tccnsrE(1) = Etcc2
   gsn_panel(wks, tccnsrE, (/2,1/), resP)

   E_nhf12 = new(10, "graphic")
   E_nhf12(0) = Enhf1
   E_nhf12(1) = Enhf2
   E_nhf12(2) = Ensr1
   E_nhf12(3) = Ensr2
   E_nhf12(4) = Enlr1
   E_nhf12(5) = Enlr2
   E_nhf12(6) = Eshf1
   E_nhf12(7) = Eshf2
   E_nhf12(8) = Elhf1
   E_nhf12(9) = Elhf2
   ;gsn_panel(wks, E_nhf12, (/1,4,1,4/), resP)

   resP@gsnPanelRowSpec = False
   resP@gsnMaximize = True
   resP@gsnPanelXWhiteSpacePercent = 5
   resP@gsnPanelFigureStrings = (/"a)","b)","c)","d)","e)","f)" \
                                 ,"g)","h)","i)","j)","k)","l)"/) 
   gsn_panel(wks, E_nhf12, (/5,2/), resP)

   printMinMax(SCAE_nhf_rc1, 0) 
   printMinMax(SCAE_nhf_rc2, 0)  


end
