load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
  yrstrt =197201
  yrlast =200912

  year=ispan(1972, 2009, 1)
  ;t = ispan(1970, 2014, 1)
;---------------W,E-index Region
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

  latS     = -90               
  latN     = 90
  lonL     =   0
  lonR     = 360

  cd = "/public/home/charlesxiami/data/ncep/"
  plotpath = "/public/home/charlesxiami/output/"
  indexpath = "/public/home/charlesxiami/data/index/"

   wks=gsn_open_wks("pdf", plotpath+"snow_reg")
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
   nswrdata = addfile(cd+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(cd+"nlwrs.sfc.mon.mean.nc", "r")
   sstdata = addfile(cd+"sst.mnmean.v4.nc", "r")
   soilwdata = addfile(cd+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(cd+"tcdc.eatm.mon.mean.nc", "r")

   pc1 = asciiread(indexpath+"pc1.txt", -1, "float")
   tele_index = asciiread(indexpath+"tele_index.nh.txt", -1, "string")
;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

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

   snow_mon  = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nswr_mam = month_to_season(nswr_mon, "MAM")

   nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nlwr_mam = month_to_season(nlwr_mon, "MAM")

   soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})
   soilw_mam = month_to_season(soilw_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   sst_mam = month_to_season(sst_mon, "MAM")
;************************************************
; Calculate W,E Index
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
   ;Reserve WI and EI 
    SCAW_hf = -1*SCAW_hf
    SCAC_hf = -1*SCAC_hf
    SCAE_hf = -1*SCAE_hf

    snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
    sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)

    ;Low frequency
    ihp = 0
    wgt2 = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    SCAW_lf = wgt_runave_Wrap(SCAW, wgt2, 0)
    SCAE_lf = wgt_runave_Wrap(SCAE, wgt2, 0)

  ;Calculate Correlations
   pcai1 = escorc(pc1_hf(2:17), SCAW_hf(0:15))
   pcai2 = escorc(pc1_hf(19:39), SCAW_hf(17:37))
   pcbi1 = escorc(pc1_hf(2:17), SCAE_hf(0:15))
   pcbi2 = escorc(pc1_hf(19:39), SCAE_hf(17:37))
   print("Cor PC1_hf-SCAW_hf:Entire= "+escorc(pc1_hf(2:39), SCAW_hf))
   print("Cor PC1_hf-SCAW_hf:P1= "+pcai1)
   print("Cor PC1_hf-SCAW_hf:P2= "+pcai2)
   print("Cor PC1_hf-SCAE_hf:Entire= "+escorc(pc1_hf(2:39), SCAE_hf))
   print("Cor PC1_hf-SCAE_hf:P1= "+pcbi1)
   print("Cor PC1_hf-SCAE_hf:P2= "+pcbi2)
   print("Cor PC1_hf-SCAC_hf:Entire= "+escorc(pc1_hf(2:39), SCAC_hf))
   print("Cor PC1_hf-SCAC_hf:P1= "+escorc(pc1_hf(2:17), SCAC_hf(0:15)))
   print("Cor PC1_hf-SCAC_hf:P2= "+escorc(pc1_hf(19:39), SCAC_hf(17:37)))

   cc0 = escorc(SCAW_hf, SCAE_hf)
   cc = escorc(SCAW_hf(0:15), SCAE_hf(0:15))
   cc2 = escorc(SCAW_hf(17:37), SCAE_hf(17:37))
   print("Cor SCAW-SCAE:Entire = "+cc0)
   print("Cor SCAW-SCAE:P1 = "+cc)
   print("Cor SCAW-SCAE:P2 = "+cc2)

  ;Partial Correlation and linear Regression
   xp = new((/34,2/), typeof(SCAW_hf))
   xp(:,0) = SCAW_hf(2:35)
   xp(:,1) = SCAE_hf(2:35)
   optMLR = True
   optMLR@print_data = False
   optMLR@print_anova = False
   ;yy = pc1_hf(0,2:39)
   b = reg_multlin_stats(pc1_hf(4:37), xp, optMLR)
   print("Partial Cor:Entire pc1-SCAW="+b(1))
   print("Partial Cor:Entire pc1-SCAE="+b(2))

   xp1 = new((/14,2/), typeof(SCAW_hf))
   xp1(:,0) = SCAW_hf(2:15)
   xp1(:,1) = SCAE_hf(2:15)
   b1 = reg_multlin_stats(pc1_hf(4:17), xp1, optMLR)
   print("Partial Cor:P1 pc1-SCAW="+b1(1))
   print("Partial Cor:P1 pc1-SCAE="+b1(2))

   xp2 = new((/19,2/), typeof(SCAW_hf))
   xp2(:,0) = SCAW_hf(17:35)
   xp2(:,1) = SCAE_hf(17:35)
   b2 = reg_multlin_stats(pc1_hf(19:37), xp2, optMLR)
   print("Partial Cor:P2 pc1-SCAW="+b2(1))
   print("Partial Cor:P2 pc1-SCAE="+b2(2))
 ;**********************************************************
 ;Regression
 ;**********************************************************
   SCAW_sat_rc  = regCoef(SCAW_hf,air_mam(lat|:,lon|:,time|:))
   SCAW_slp_rc  = regCoef(SCAW_hf,slp_mam(lat|:,lon|:,time|:)) 
   SCAW_z500_rc = regCoef(SCAW_hf,z500_mam(lat|:,lon|:,time|:))
   SCAW_z200_rc = regCoef(SCAW_hf,z200_mam(lat|:,lon|:,time|:)) 
   SCAW_u_rc    = regCoef(SCAW_hf,u_mam(lat|:,lon|:,time|:))
   SCAW_v_rc    = regCoef(SCAW_hf,v_mam(lat|:,lon|:,time|:))
   SCAW_nswr_rc = regCoef(SCAW_hf,nswr_mam(lat|:,lon|:,time|:))
   SCAW_nlwr_rc = regCoef(SCAW_hf,nlwr_mam(lat|:,lon|:,time|:))
   SCAW_soilw_rc = regCoef(SCAW_hf,soilw_mam(lat|:,lon|:,time|:))

   SCAW_sat_cor  = escorc(SCAW_hf,air_mam(lat|:,lon|:,time|:)) 
   SCAW_slp_cor  = escorc(SCAW_hf,slp_mam(lat|:,lon|:,time|:)) 
   SCAW_z500_cor = escorc(SCAW_hf,z500_mam(lat|:,lon|:,time|:)) 
   SCAW_z200_cor = escorc(SCAW_hf,z200_mam(lat|:,lon|:,time|:)) 
   SCAW_u_cor    = escorc(SCAW_hf,u_mam(lat|:,lon|:,time|:))
   SCAW_v_cor    = escorc(SCAW_hf,v_mam(lat|:,lon|:,time|:))
   SCAW_uv_cor   = escorc(SCAW_hf,uv_mam(lat|:,lon|:,time|:))
   SCAW_nswr_cor = escorc(SCAW_hf,nswr_mam(lat|:,lon|:,time|:))
   SCAW_nlwr_cor = escorc(SCAW_hf,nlwr_mam(lat|:,lon|:,time|:))
   SCAW_soilw_cor = escorc(SCAW_hf,soilw_mam(lat|:,lon|:,time|:))

   SCAW_sst_rc_mam  = regCoef(SCAW_hf,sst_mam(lat|:,lon|:,time|:))
   SCAW_sst_cor_mam  = escorc(SCAW_hf,sst_mam(lat|:,lon|:,time|:))

   SCAW_snow_rc = regCoef(SCAW_hf,snow_mam(lat|:,lon|:,time|:))
   SCAW_snow_cor = escorc(SCAW_hf,snow_mam(lat|:,lon|:,time|:))

   SCAE_sat_rc  = regCoef(SCAE_hf,air_mam(lat|:,lon|:,time|:)) 
   SCAE_slp_rc  = regCoef(SCAE_hf,slp_mam(lat|:,lon|:,time|:)) 
   SCAE_z500_rc = regCoef(SCAE_hf,z500_mam(lat|:,lon|:,time|:)) 
   SCAE_z200_rc = regCoef(SCAE_hf,z200_mam(lat|:,lon|:,time|:))
   SCAE_u_rc    = regCoef(SCAE_hf,u_mam(lat|:,lon|:,time|:))
   SCAE_v_rc    = regCoef(SCAE_hf,v_mam(lat|:,lon|:,time|:))
   SCAE_nswr_rc = regCoef(SCAE_hf,nswr_mam(lat|:,lon|:,time|:))
   SCAE_nlwr_rc = regCoef(SCAE_hf,nlwr_mam(lat|:,lon|:,time|:))
   SCAE_soilw_rc = regCoef(SCAE_hf,soilw_mam(lat|:,lon|:,time|:))

   SCAE_sat_cor  = escorc(SCAE_hf,air_mam(lat|:,lon|:,time|:)) 
   SCAE_slp_cor  = escorc(SCAE_hf,slp_mam(lat|:,lon|:,time|:)) 
   SCAE_z500_cor = escorc(SCAE_hf,z500_mam(lat|:,lon|:,time|:)) 
   SCAE_z200_cor = escorc(SCAE_hf,z200_mam(lat|:,lon|:,time|:)) 
   SCAE_u_cor    = escorc(SCAE_hf,u_mam(lat|:,lon|:,time|:))
   SCAE_v_cor    = escorc(SCAE_hf,v_mam(lat|:,lon|:,time|:))
   SCAE_uv_cor   = escorc(SCAE_hf,uv_mam(lat|:,lon|:,time|:))
   SCAE_nswr_cor = escorc(SCAE_hf,nswr_mam(lat|:,lon|:,time|:))
   SCAE_nlwr_cor = escorc(SCAE_hf,nlwr_mam(lat|:,lon|:,time|:))
   SCAE_soilw_cor = escorc(SCAE_hf,soilw_mam(lat|:,lon|:,time|:))

   SCAE_sst_rc_mam  = regCoef(SCAE_hf,sst_mam(lat|:,lon|:,time|:))
   SCAE_sst_cor_mam  = escorc(SCAE_hf,sst_mam(lat|:,lon|:,time|:))

   SCAE_snow_rc = regCoef(SCAE_hf,snow_mam(lat|:,lon|:,time|:))
   SCAE_snow_cor = escorc(SCAE_hf,snow_mam(lat|:,lon|:,time|:))

  ;********************************
   SCAC_sat_rc  = regCoef(SCAC_hf,air_mam(lat|:,lon|:,time|:))
   SCAC_slp_rc  = regCoef(SCAC_hf,slp_mam(lat|:,lon|:,time|:)) 
   SCAC_z500_rc = regCoef(SCAC_hf,z500_mam(lat|:,lon|:,time|:))
   SCAC_z200_rc = regCoef(SCAC_hf,z200_mam(lat|:,lon|:,time|:)) 
   SCAC_u_rc    = regCoef(SCAC_hf,u_mam(lat|:,lon|:,time|:))
   SCAC_v_rc    = regCoef(SCAC_hf,v_mam(lat|:,lon|:,time|:))
   SCAC_sat_cor  = escorc(SCAC_hf,air_mam(lat|:,lon|:,time|:)) 
   SCAC_slp_cor  = escorc(SCAC_hf,slp_mam(lat|:,lon|:,time|:)) 
   SCAC_z500_cor = escorc(SCAC_hf,z500_mam(lat|:,lon|:,time|:)) 
   SCAC_z200_cor = escorc(SCAC_hf,z200_mam(lat|:,lon|:,time|:)) 
   SCAC_u_cor    = escorc(SCAC_hf,u_mam(lat|:,lon|:,time|:))
   SCAC_v_cor    = escorc(SCAC_hf,v_mam(lat|:,lon|:,time|:))
   SCAC_uv_cor   = escorc(SCAC_hf,uv_mam(lat|:,lon|:,time|:))

   ;Copy Varcoords
   copy_VarCoords(air_mam(0, :, :), SCAW_sat_rc)
   copy_VarCoords(air_mam(0, :, :), SCAW_slp_rc)
   copy_VarCoords(air_mam(0, :, :), SCAW_z500_rc)
   copy_VarCoords(air_mam(0, :, :), SCAW_z200_rc)
   copy_VarCoords(air_mam(0, :, :), SCAW_u_rc)
   copy_VarCoords(air_mam(0, :, :), SCAW_v_rc)
   copy_VarCoords(nswr_mam(0, :, :), SCAW_nswr_rc)
   copy_VarCoords(nlwr_mam(0, :, :), SCAW_nlwr_rc)
   copy_VarCoords(soilw_mam(0, :, :), SCAW_soilw_rc)

   copy_VarCoords(air_mam(0, :, :), SCAW_sat_cor)
   copy_VarCoords(air_mam(0, :, :), SCAW_slp_cor)
   copy_VarCoords(air_mam(0, :, :), SCAW_z500_cor)
   copy_VarCoords(air_mam(0, :, :), SCAW_z200_cor)
   copy_VarCoords(air_mam(0, :, :), SCAW_uv_cor)
   copy_VarCoords(nswr_mam(0, :, :), SCAW_nswr_cor) 
   copy_VarCoords(nlwr_mam(0, :, :), SCAW_nlwr_cor) 
   copy_VarCoords(soilw_mam(0, :, :), SCAW_soilw_cor)

   copy_VarCoords(sst_mam(0, :, :), SCAW_sst_rc_mam)
   copy_VarCoords(sst_mam(0, :, :), SCAW_sst_cor_mam)

   copy_VarCoords(snow_mam(0, :, :), SCAW_snow_rc)
   copy_VarCoords(snow_mam(0, :, :), SCAW_snow_cor)
   copy_VarCoords(snow_mam(0, :, :), SCAE_snow_rc)
   copy_VarCoords(snow_mam(0, :, :), SCAE_snow_cor)

   copy_VarCoords(air_mam(0, :, :), SCAE_sat_rc)
   copy_VarCoords(air_mam(0, :, :), SCAE_slp_rc)
   copy_VarCoords(air_mam(0, :, :), SCAE_z500_rc)
   copy_VarCoords(air_mam(0, :, :), SCAE_z200_rc)
   copy_VarCoords(air_mam(0, :, :), SCAE_u_rc)
   copy_VarCoords(air_mam(0, :, :), SCAE_v_rc)
   copy_VarCoords(nswr_mam(0, :, :), SCAE_nswr_rc)
   copy_VarCoords(nlwr_mam(0, :, :), SCAE_nlwr_rc)  
   copy_VarCoords(soilw_mam(0, :, :), SCAE_soilw_rc)

   copy_VarCoords(air_mam(0, :, :), SCAE_sat_cor)
   copy_VarCoords(air_mam(0, :, :), SCAE_slp_cor)
   copy_VarCoords(air_mam(0, :, :), SCAE_z500_cor)
   copy_VarCoords(air_mam(0, :, :), SCAE_z200_cor)
   copy_VarCoords(air_mam(0, :, :), SCAE_uv_cor) 
   copy_VarCoords(nswr_mam(0, :, :), SCAE_nswr_cor)
   copy_VarCoords(nlwr_mam(0, :, :), SCAE_nlwr_cor)

   copy_VarCoords(sst_mam(0, :, :), SCAE_sst_rc_mam)
   copy_VarCoords(sst_mam(0, :, :), SCAE_sst_cor_mam)

   copy_VarCoords(soilw_mam(0, :, :), SCAE_soilw_cor)

   ;
   copy_VarCoords(air_mam(0, :, :), SCAC_sat_rc)
   copy_VarCoords(air_mam(0, :, :), SCAC_slp_rc)
   copy_VarCoords(air_mam(0, :, :), SCAC_z500_rc)
   copy_VarCoords(air_mam(0, :, :), SCAC_z200_rc)
   copy_VarCoords(air_mam(0, :, :), SCAC_u_rc)
   copy_VarCoords(air_mam(0, :, :), SCAC_v_rc)
   copy_VarCoords(air_mam(0, :, :), SCAC_sat_cor)
   copy_VarCoords(air_mam(0, :, :), SCAC_slp_cor)
   copy_VarCoords(air_mam(0, :, :), SCAC_z500_cor)
   copy_VarCoords(air_mam(0, :, :), SCAC_z200_cor)
   copy_VarCoords(air_mam(0, :, :), SCAC_uv_cor)
   ;printVarSummary(SCAW_u_rc)

 ;**********************************************************
 ;Time Series plot
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
     rts1@gsnYRefLine = 0.
     ;rts1@gsnLeftString = "(b) PC1"
     ;rts1@tmXUseBottom = True
     rts1@tmXBMode = "Explicit"
     rts1@tmXBValues = ispan(1975, 2005, 5)
     rts1@tmXBLabels = ispan(1975, 2005, 5)
     rts1@tmXBMinorValues = ispan(1972, 2009, 1)
     rts1@tmXTOn = False
     rts1@tmYROn = False
     rts1@tiXAxisString = "Time (Year)"
     rts1@tiYAxisString = " "
     rts1@tiXAxisFontHeightF = 0.02
     rts1@tiYAxisFontHeightF = 0.02
     rts1@trXMinF = 1971.5
     rts1@trXMaxF = 2009.5
     rts1@trYMinF = -3.0
     rts1@trYMaxF = 3.0

     rts2 = rts   ; Line
     rts2@xyDashPattern         = 1
     rts2@xyLineThicknessF      = 4.
     rts2@xyLineColor = "black"

   ;Draw Earchart(SCAW)
   rts1@gsnXYBarChartBarWidth = 0.66
   rts1@gsnLeftString = "(a) SCAWI"
   indexW = gsn_csm_xy(wks, year, SCAW, rts1)
   rts1@gsnLeftString = "(b) SCAEI"
   indexE = gsn_csm_xy(wks, year, SCAE, rts1)
   rts1@gsnLeftString = "SCAC"
   indexC = gsn_csm_xy(wks, year, SCAC, rts1)

   rts1@gsnLeftString = ""
   rts1@gsnRightString = ""
   rts1@gsnXYBarChartBarWidth = 0.3
     rts1@gsnAboveYRefLineColor = "red"
     rts1@gsnBelowYRefLineColor = "blue"
   Whf = gsn_csm_xy(wks, year, -1*SCAW_hf, rts1)
   Ehf = gsn_csm_xy(wks, year, -1*SCAE_hf, rts1)
   Chf = gsn_csm_xy(wks, year, -1*SCAC_hf, rts1)
  
   overlay(indexW, Whf)
   overlay(indexC, Chf)
   overlay(indexE, Ehf)

   Wrunave = runave_n_Wrap(SCAW, 11, 0, 0)
   Erunave = runave_n_Wrap(SCAE, 11, 0, 0)

   Wlf = gsn_csm_xy(wks, year, SCAW_lf, rts2)
   Elf = gsn_csm_xy(wks, year, SCAE_lf, rts2)

   Wrave = gsn_csm_xy(wks, year, Wrunave, rts2)
   Erave = gsn_csm_xy(wks, year, Erunave, rts2)

   overlay(indexW, Wrave)
   overlay(indexE, Erave)

   rtsP = True
   rtsP@lbLabelAutoStride = True

   indices = new(2,"graphic")
   indices(0) = indexW
   ;indices(1) = indexC
   indices(1) = indexE
   gsn_panel(wks, indices, (/2,1/), rtsP)


   ;Draw Regline (trend)
   trdW = regline(year, SCAW)
   yW = trdW*year + trdW@yintercept
   trdE = regline(year, SCAE)
   yE = trdE*year + trdE@yintercept
   trdC = regline(year, SCAC)
   yC = trdW*year + trdC@yintercept
   
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
   ; resrc@mpGridWndLimbOn = True
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.
   resrc@mpFillOn = False
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15

   ;For Line
   resrc2 = True
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

   ;Correlation res (with dots.)
   rescor = True
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/-0.320,0.320/)  ;95%
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False

   resSST = resrc
   resSST@mpMaxLonF = 20.
   resSST@mpMinLonF = -90.
   resSST@mpMaxLatF = 80.
   resSST@mpMinLatF = -10.
   resSST@mpCenterLonF = 0.

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
   resV@vcRefAnnoOrthogonalPosF = -0.13
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.0               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   lnres = True
   lnres@gsLineColor      = "gray12"
   lnres@gsLineThicknessF = 1.0

   dir = "/mnt/f/Programming/NCL/shp/"
   filename1 = "CHN_adm_shp/CHN_adm0.shp"
   filename2 = "HKG_adm_shp/HKG_adm0.shp"
   filename3 = "TWN_adm_shp/TWN_adm0.shp"
   

   ;Polyline Setting
   Wxpts = (/WlonL, WlonL, WlonR, WlonR, WlonL/)
   Wypts = (/WlatS, WlatN, WlatN, WlatS, WlatS/)

   Expts = (/ElonL, ElonL, ElonR, ElonR, ElonL/)
   Eypts = (/ElatS, ElatN, ElatN, ElatS, ElatS/)

   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 2.0
   plres@gsLineLabelString = "sce"

   dum = new(dimsizes(Wxpts)-1, graphic)
   dum2 = new(dimsizes(Expts)-1, graphic)

 ;**********************************************************
 ;
    ;SCAW draw
    resrc@mpMinLonF = 0.
    ;resrc@mpMaxLonF = 240.
    resrc@cnMinLevelValF = -2.
    resrc@cnMaxLevelValF = 2.
    resrc@cnLevelSpacingF = 0.1
    resrc@gsnLeftString = "(a) SCAWI: SAT+Wind(850hpa)"
    ;resrc@cnInfoLabelString = "Dotted Wrea exceed 95% Sig Level"
    satW = gsn_csm_contour_map(wks, SCAW_sat_rc ,resrc)
    Wwnd = gsn_csm_vector(wks, SCAW_u_rc, SCAW_v_rc, resV)
    Wdot = gsn_csm_contour(wks, SCAW_sat_cor, rescor)
    overlay(satW, Wwnd)
    overlay(satW, Wdot)

   ;SCAE draw
   resrc@gsnLeftString = "(b) SCAEI: SAT+Wind(850hpa)"
   satE = gsn_csm_contour_map(wks, SCAE_sat_rc ,resrc) ;Regression Map as based map
   Ewnd = gsn_csm_vector(wks, SCAE_u_rc, SCAE_v_rc, resV) ; Wind overlay
   Edot = gsn_csm_contour(wks, SCAE_sat_cor, rescor) ; Correlation overlay
   overlay(satE, Ewnd)
   overlay(satE, Edot)


   resrc@gsnLeftString = "SCAC: "+"SAT+Wind(850hpa)"
   SCACrc = gsn_csm_contour_map(wks, SCAC_sat_rc ,resrc) ;Regression Map as based map
   Cwnd = gsn_csm_vector(wks, SCAC_u_rc, SCAC_v_rc, resV) ; Wind overlay
   Cdot = gsn_csm_contour(wks, SCAC_sat_cor, rescor) ; Correlation overlay
   overlay(SCACrc, Cwnd)
   overlay(SCACrc, Cdot)
   draw(SCACrc)
   frame(wks)

   ;SLP
   resrc@cnMinLevelValF = -2.5
   resrc@cnMaxLevelValF = 2.5
   resrc@cnLevelSpacingF = 0.1
   resrc@gsnLeftString = "SCAW: "+"SLP"
   Wslp = gsn_csm_contour_map(wks, SCAW_slp_rc, resrc)
   slpcor = gsn_csm_contour(wks, SCAW_slp_cor, rescor)
   line = gsn_csm_contour(wks, SCAW_slp_rc, resrc2)
   overlay(Wslp, line)
   overlay(Wslp, slpcor)

   resrc@gsnLeftString = "SCAE: "+"SLP"
   Eslp = gsn_csm_contour_map(wks, SCAE_slp_rc, resrc)
   slpcor = gsn_csm_contour(wks, SCAE_slp_cor, rescor)
   line = gsn_csm_contour(wks, SCAE_slp_rc, resrc2)
   overlay(Eslp, line)
   overlay(Eslp, slpcor)

   resrc@gsnLeftString = "SCAC: "+"SLP"
   Cslp = gsn_csm_contour_map(wks, SCAC_slp_rc, resrc)
   slpcor = gsn_csm_contour(wks, SCAC_slp_cor, rescor)
   line = gsn_csm_contour(wks, SCAC_slp_rc, resrc2)
   overlay(Cslp, line)
   overlay(Cslp, slpcor)
   draw(Cslp)
   frame(wks) 

   ;
   resrc@cnMinLevelValF = -30.
   resrc@cnMaxLevelValF = 30.
   resrc@cnLevelSpacingF = 1.
   resrc@gsnLeftString = "(c) SCAW: Z500"
   Whgt = gsn_csm_contour_map(wks, SCAW_z500_rc, resrc)
   Whgtcor = gsn_csm_contour(wks, SCAW_z500_cor, rescor)
   line = gsn_csm_contour(wks, SCAW_z500_rc, resrc2)
   overlay(Whgt, line)
   overlay(Whgt, Whgtcor)

   resrc@gsnLeftString = "(d) SCAE: Z500"
   Ehgt = gsn_csm_contour_map(wks, SCAE_z500_rc, resrc)
   Ehgtcor = gsn_csm_contour(wks, SCAE_z500_cor, rescor)
   line = gsn_csm_contour(wks, SCAE_z500_rc, resrc2)
   overlay(Ehgt, line)
   overlay(Ehgt, Ehgtcor)
 ;**********************************************************
 ;Net Radiation
    resrc@cnMinLevelValF = -6.
    resrc@cnMaxLevelValF = 6.
    resrc@cnLevelSpacingF = 0.2
    resrc@mpMinLonF = 0.
    resrc@mpMaxLonF = 180.
    resrc@mpMaxLatF = 90.
    resrc@mpMinLatF = 0.
    ;
    resrc@gsnLeftString = "SCAW: "+"nswr flux"
    Wnswrrc = gsn_csm_contour_map(wks, SCAW_nswr_rc ,resrc)
    Wnswrcor = gsn_csm_contour(wks, SCAW_nswr_cor, rescor)
    overlay(Wnswrrc, Wnswrcor)
        ;add polyline 
    do i = 0, dimsizes(Wxpts)-2
        dum(i) = gsn_add_polyline(wks, Wnswrrc, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    do i = 0, dimsizes(Expts)-2
        dum2(i) = gsn_add_polyline(wks, Wnswrrc, Expts(i:i+1), Eypts(i:i+1), plres)
    end do
    draw(Wnswrrc)
    frame(wks)

    resrc@gsnLeftString = "SCAE: "+"nswr flux"
    Wnswrrc = gsn_csm_contour_map(wks, SCAE_nswr_rc ,resrc)
    Wnswrcor = gsn_csm_contour(wks, SCAE_nswr_cor, rescor)
    overlay(Wnswrrc, Wnswrcor)
            ;add polyline 
    do i = 0, dimsizes(Wxpts)-2
        dum(i) = gsn_add_polyline(wks, Wnswrrc, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    do i = 0, dimsizes(Expts)-2
        dum2(i) = gsn_add_polyline(wks, Wnswrrc, Expts(i:i+1), Eypts(i:i+1), plres)
    end do
    draw(Wnswrrc)
    frame(wks)

    resrc@gsnLeftString = "SCAW: "+"nlwr flux"
    Wnswrrc = gsn_csm_contour_map(wks, SCAW_nlwr_rc ,resrc)
    Wnswrcor = gsn_csm_contour(wks, SCAW_nlwr_cor, rescor)
    overlay(Wnswrrc, Wnswrcor)
            ;add polyline 
    do i = 0, dimsizes(Wxpts)-2
        dum(i) = gsn_add_polyline(wks, Wnswrrc, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    do i = 0, dimsizes(Expts)-2
        dum2(i) = gsn_add_polyline(wks, Wnswrrc, Expts(i:i+1), Eypts(i:i+1), plres)
    end do
    draw(Wnswrrc)
    frame(wks)

    resrc@gsnLeftString = "SCAE: "+"nlwr flux"
    Wnswrrc = gsn_csm_contour_map(wks, SCAE_nlwr_rc ,resrc)
    Wnswrcor = gsn_csm_contour(wks, SCAE_nlwr_cor, rescor)
    overlay(Wnswrrc, Wnswrcor)
            ;add polyline 
    do i = 0, dimsizes(Wxpts)-2
        dum(i) = gsn_add_polyline(wks, Wnswrrc, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    do i = 0, dimsizes(Expts)-2
        dum2(i) = gsn_add_polyline(wks, Wnswrrc, Expts(i:i+1), Eypts(i:i+1), plres)
    end do
    draw(Wnswrrc)
    frame(wks)

    ;Soil Moisture
    resrc@cnMinLevelValF = -30.
    resrc@cnMaxLevelValF = 30.
    resrc@cnLevelSpacingF = 2.
    resrc@gsnLeftString = "SCAW: "+"soil moisture"
    Wswrc = gsn_csm_contour_map(wks, SCAW_soilw_rc ,resrc)
    Wswcor = gsn_csm_contour(wks, SCAW_soilw_cor, rescor)
    overlay(Wswrc, Wswcor)
            ;add polyline 
    do i = 0, dimsizes(Wxpts)-2
        dum(i) = gsn_add_polyline(wks, Wswrc, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    do i = 0, dimsizes(Expts)-2
        dum2(i) = gsn_add_polyline(wks, Wswrc, Expts(i:i+1), Eypts(i:i+1), plres)
    end do
    draw(Wswrc)
    frame(wks)

    resrc@gsnLeftString = "SCAE: "+"soil moisture"
    Wswrc = gsn_csm_contour_map(wks, SCAE_soilw_rc ,resrc)
    Wswcor = gsn_csm_contour(wks, SCAE_soilw_cor, rescor)
    overlay(Wswrc, Wswcor)
            ;add polyline 
    do i = 0, dimsizes(Wxpts)-2
        dum(i) = gsn_add_polyline(wks, Wswrc, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    do i = 0, dimsizes(Expts)-2
        dum2(i) = gsn_add_polyline(wks, Wswrc, Expts(i:i+1), Eypts(i:i+1), plres)
    end do
    draw(Wswrc)
    frame(wks)

 ;**********************************************************
 ;SST draw
   resSST@cnMinLevelValF = -0.5
   resSST@cnMaxLevelValF = 0.5
   resSST@cnLevelSpacingF = 0.1

   ;MAM
   resSST@gsnLeftString = "SCAW: SST_MAM"
   sstrc1 = gsn_csm_contour_map(wks, SCAW_sst_rc_mam, resSST)
   sstcor1 = gsn_csm_contour(wks, SCAW_sst_cor_mam, rescor)
   overlay(sstrc1, sstcor1)
   draw(sstrc1)
   frame(wks)

   resSST@gsnLeftString = "SCAE: SST_MAM"
   sstrc2 = gsn_csm_contour_map(wks, SCAE_sst_rc_mam, resSST)
   sstcor2 = gsn_csm_contour(wks, SCAE_sst_cor_mam, rescor)
   overlay(sstrc2, sstcor2)
   draw(sstrc2)
   frame(wks)

 ;**********************************************************
 ;Snow Correlation
   ;SCAW
   resrc@mpMinLatF = 0.
   resrc@mpMaxLonF = 180.
   resrc@cnMinLevelValF = -1.
   resrc@cnMaxLevelValF = 1.
   resrc@cnLevelSpacingF = 0.1
   resrc@gsnLeftString = "SCAW: SCE correlation map"
   snowplot = gsn_csm_contour_map(wks, SCAW_snow_cor, resrc)
   snowdot = gsn_csm_contour(wks, SCAW_snow_cor, rescor)
   overlay(snowplot, snowdot)
       do i = 0, dimsizes(Wxpts)-2
        dum(i) = gsn_add_polyline(wks, snowplot, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    do i = 0, dimsizes(Expts)-2
        dum2(i) = gsn_add_polyline(wks, snowplot, Expts(i:i+1), Eypts(i:i+1), plres)
    end do
    draw(snowplot)
    frame(wks)

   resrc@gsnLeftString = "SCAE: SCE correlation map"
   delete(snowplot)
   delete(snowdot)
   snowplot = gsn_csm_contour_map(wks, SCAE_snow_cor, resrc)
   snowdot = gsn_csm_contour(wks, SCAE_snow_cor, rescor)
   overlay(snowplot, snowdot)
       do i = 0, dimsizes(Wxpts)-2
        dum(i) = gsn_add_polyline(wks, snowplot, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    do i = 0, dimsizes(Expts)-2
        dum2(i) = gsn_add_polyline(wks, snowplot, Expts(i:i+1), Eypts(i:i+1), plres)
    end do
    draw(snowplot)
    frame(wks)

    ; satWCE = new(2,"graphic")
    ; satWCE(0) = Wslp
    ; satWCE(1) = Eslp
    ; gsn_panel(wks, satWCE, (/1,2/), rtsP)

    satslpP = new(4,"graphic")
    satslpP(0) = satW
    satslpP(1) = satE
    satslpP(2) = Whgt
    satslpP(3) = Ehgt
    gsn_panel(wks, satslpP, (/2,2/), rtsP)

    satWE = new(2,"graphic")
    satWE(0) = satW
    satWE(1) = satE
    rtsP@gsnPanelLabelBar = True
    rtsP@pmLabelBarWidthF = 0.6
    gsn_panel(wks, satWE, (/2,1/), rtsP)



end
