load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/run_cor.ncl"
;***
  begin
;***
   yrstrt = 196701
   yrlast = 201412

   yrstrt_sst = 196701
   yrlast_sst = 201412

   yrstrt_snow = 196701
   yrlast_snow = 201412

  year=ispan(yrstrt_snow/100, yrlast_snow/100, 1)
  ;t = ispan(1970, 2014, 1)
;---------------W,E-index Region

  SCI_EEU_N = 70
  SCI_EEU_S = 40
  SCI_EEU_L = 80
  SCI_EEU_R = 150
  
  SCI_NA_N = 70
  SCI_NA_S = 40
  SCI_NA_L = -120
  SCI_NA_R = -60

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   nceppath = "/public/home/charlesxiami/data/ncep/"
   snowpath = "/public/home/charlesxiami/data/snow/"
   indexpath = "/public/home/charlesxiami/data/index/"

   plotpath = "/public/home/charlesxiami/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"sci_analy")
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
   printMinMax((cd_calendar(shfdata&time, -1)), False)
   snowdata = addfile(snowpath+"snow.rutger.2.0deg.nc","r")

   pc1 = asciiread(indexpath+"pc1_1948-2017.txt", -1, "float")
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
   air_mam = month_to_season(air_mon, "MAM")
   time = cd_calendar(air_mam&time, -1)/100
   time!0 = "time"
   time@units = "year"

   air_mon2 = airdata->air
   ndim2 = dimsizes(air_mon2)
   air_mam2 = month_to_season(air_mon2(0:ndim2(0)-7,:,:), "MAM")
   time_long = cd_calendar(air_mam2&time, -1)/100
   ;time_long!0 = "time"
   time_long@units = "year"
   
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
   
   shf_mon = shfdata->shtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   shf_mam = month_to_season(shf_mon, "MAM")
   
   lhf_mon = lhfdata->lhtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   lhf_mam = month_to_season(lhf_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   sst_mam = month_to_season(sst_mon, "MAM")

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")
;************************************************
; Calculate Snow Index
;************************************************
  snow_mam_wgt= SqrtCosWeight(snow_mam)

  EEU = snow_mam_wgt(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
  NA  = snow_mam_wgt(:,{SCI_NA_S:SCI_NA_N},{SCI_NA_L:SCI_NA_R})

  sci_eeu = -1*dim_standardize_Wrap(wgt_areaave_Wrap(EEU, 1.0, 1.0, 1),0)
  sci_na = -1*dim_standardize_Wrap(wgt_areaave_Wrap(NA, 1.0, 1.0, 1),0)

  snow_mam_dif = snow_mam
  snow_mam_dif = snow_mam - snow_mam_wgt
  snow_mam_dif_avg = dim_avg_n_Wrap(snow_mam_dif, 0)

  air_mam_wgt2 = SqrtCosWeight(air_mam2)
  sat_EEU = air_mam_wgt2(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
  sat_NA = air_mam_wgt2(:,{SCI_NA_S:SCI_NA_N},{SCI_NA_L+360:SCI_NA_R+360})
  sati_eeu = dim_standardize_Wrap(wgt_areaave_Wrap(sat_EEU, 1.0, 1.0, 1), 0)
  sati_na = dim_standardize_Wrap(wgt_areaave_Wrap(sat_NA, 1.0, 1.0, 1), 0)
  ;printVarSummary(sati_eeu)
;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    sci_eeu_hf   = wgt_runave_Wrap(sci_eeu,  wgt, 0)
    sci_na_hf    = wgt_runave_Wrap(sci_na,   wgt, 0)
    pc1_hf       = wgt_runave_Wrap(pc1,      wgt, 0)
    sati_eeu_hf  = wgt_runave_Wrap(sati_eeu, wgt, 0)
    sati_na_hf   = wgt_runave_Wrap(sati_na,  wgt, 0)

    ; snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
    ; sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)

    ;Low frequency
    ihp = 0
    wgt2 = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
;**********************************************************
;Index Correlation
    print("cor SAT between EEU and NA   = " + \
          escorc(sati_eeu(:), sati_na(:)))
    print("cor SCE between EEU and NA   = " + escorc(sci_eeu, sci_na))
    print("cor EEU between SAT and SCE  = " + escorc(sati_eeu(19:66), sci_eeu))
    print("cor NA between SAT and SCE   = " + escorc(sati_na(19:66), sci_na))
    print("cor SAT(EEU) and SCE(NA)  = " + escorc(sati_eeu(19:66), sci_na))
    print("cor SAT(NA) and SCE(EEU)   = " + escorc(sati_na(19:66), sci_eeu))

    print("cor SAT between EEU and NA (HF)  = " + \
          escorc(sati_eeu_hf(:), sati_na_hf(:)))
    print("cor SCE between EEU and NA   = " + escorc(sci_eeu_hf, sci_na_hf))
    print("cor EEU between SAT and SCE  = " + escorc(sati_eeu_hf(19:66), sci_eeu_hf))
    print("cor NA between SAT and SCE   = " + escorc(sati_na_hf(19:66), sci_na_hf))
    print("cor SAT(EEU) and SCE(NA)  = "    + escorc(sati_eeu_hf(19:66), sci_na_hf))
    print("cor SAT(NA) and SCE(EEU)   = "   + escorc(sati_na_hf(19:66), sci_eeu_hf))
    ;Run cor
    wSize = 15
    rcor_sat = run_cor(sati_eeu, sati_na,        time_long, wSize)
    rcor_sce = run_cor(sci_eeu, sci_na,          time, wSize)
    rcor_ss1 = run_cor(sati_eeu(19:66), sci_eeu, time, wSize)
    rcor_ss2 = run_cor(sati_na(19:66), sci_na,   time, wSize)
    rcor_css1 = run_cor(sati_eeu(19:66), sci_na, time, wSize)
    rcor_css2 = run_cor(sati_na(19:66), sci_eeu, time, wSize)
;**********************************************************
;3-D Data analysis
;**********************************************************
 ;Reg and Cor
  snow_index = sati_eeu_hf(19:66)
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

  sci_u_rc = regCoef_n(snow_index, u_mam, 0, 0)
  copy_VarCoords(u_mam(0,:,:), sci_u_rc)
  sci_v_rc = regCoef_n(snow_index, v_mam, 0, 0)
  copy_VarCoords(v_mam(0,:,:), sci_v_rc)
  ; df_sce = onedtond(weu_sce_rc@nptxy,dimsizes(weu_sce_rc))- 2
  ; tval_sce = onedtond(weu_sce_rc@tval, dimsizes(weu_sce_rc))
  ; b = tval_sce
  ; b = 0.5
  ; prob_sce = betainc(df_sce/(df_sce+tval_sce^2), df_sce/2.0, b)
  ; copy_VarCoords(snow_mam(0,:,:), weu_sce_rc)
  ; copy_VarCoords(snow_mam(0,:,:), prob_sce)
  ; printVarSummary(prob_sce)
  ; printMinMax(prob_sce, False)
  snow_mam_stv = dim_stddev_n_Wrap(snow_mam, 0)
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
   resrc@mpMinLatF = 20.

   res_snow = resrc
   res_snow@lbLabelBarOn = True
   res_snow@cnMaxLevelValF = 10.
   res_snow@cnMinLevelValF = -10.
   res_snow@cnLevelSpacingF = 1.
   res_snow@gsnAddCyclic = True
   res_snow@mpMinLatF = 20.
   res_snow@pmLabelBarOrthogonalPosF = 0.25

   res_htfl = resrc
   res_htfl@cnMaxLevelValF = 8.
   res_htfl@cnMinLevelValF = -8.
   res_htfl@cnLevelSpacingF = 1.

   resSST = resrc
   resSST@mpMaxLonF = 20.
   resSST@mpMinLonF = -90.
   resSST@mpMaxLatF = 80.
   resSST@mpMinLatF = -10.
   resSST@mpCenterLonF = 0.

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
   rescor@cnLevels = (/-0.05,0.05/)  ;95%
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/-1,17,-1/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnFillColor = "black"
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False

   ;Wind Resources
   resV = True
   resV@gsnDraw = False
   resV@gsnFrame = False
   resV@vcRefMagnitudeF = 2.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"  
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.50
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.2               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"

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
  rts_line@xyDashPatterns = (/1, 5/)
  rts_line@xyLineThicknessF = 2.0
  rts_line@xyLineColors = (/"red","blue"/)
  rts_line@tiYAxisString = ""
  rts_line@lgTitleOn = True
  rts_line@lgLabelsOn = True
  ;rts_line@pmLegendDisplayMode = "Always"
  rts_line@pmLegendWidthF = 0.3
  rts_line@gsnYRefLine = (/-0.514, 0.514/)
  rts_line@gsnYRefLineColors = (/"black","black"/)
  rts_line@gsnYRefLineDashPatterns = (/2, 8/)
  rts_line@gsnLeftStringFontHeightF = 0.015
  ;rts_line@xyExplicitLegendLabels = (/"EEU","NA"/)
  ; rts_line@trYMinF = -1.0
  ; rts_line@trYMaxF = 1.0

  rtsP = True
  rtsP@lbLabelAutoStride = True

;****************************************************************
;Polyline
   Expts = (/SCI_EEU_L, SCI_EEU_L, SCI_EEU_R, SCI_EEU_R, SCI_EEU_L/)
   Eypts = (/SCI_EEU_S, SCI_EEU_N, SCI_EEU_N, SCI_EEU_S, SCI_EEU_S/)

   NAxpts = (/SCI_NA_L, SCI_NA_L, SCI_NA_R, SCI_NA_R, SCI_NA_L/)
   NAypts = (/SCI_NA_S, SCI_NA_N, SCI_NA_N, SCI_NA_S, SCI_NA_S/)

   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 1.5
   plres@gsLineLabelString = ""

   dum2 = new(dimsizes(Expts)-1, graphic)
   dum1 = new(dimsizes(NAypts)-1, graphic)
;**********************************************************
;Draw contour

  ;res_snow@gsnLeftString = "SCE_WEU: Reg SCE MAM"
  snowplot = gsn_csm_contour_map(wks, sci_sce_rc, res_snow)
  snowdot = gsn_csm_contour(wks, p_sce, rescor)
  overlay(snowplot, snowdot)
  do i = 0, dimsizes(NAypts)-2
    dum1(i) = gsn_add_polyline(wks, snowplot, NAxpts(i:i+1), \
                                 NAypts(i:i+1), plres)
  end do
   ; do i = 0, dimsizes(Expts)-2
   ;     dum2(i) = gsn_add_polyline(wks, snowplot, Expts(i:i+1), \
   ;                                Eypts(i:i+1), plres)
   ; end do
   ; do i = 0, dimsizes(Expts)-2
   ;     dum2(i) = gsn_add_polyline(wks, snowplot, NAxpts(i:i+1), \
   ;                                NAypts(i:i+1), plres)
   ; end do

   resrc@lbLabelBarOn = True   
   resrc@cnMaxLevelValF = 2.0
   resrc@cnMinLevelValF = -2.0
   resrc@cnLevelSpacingF = 0.1
   satplot = gsn_csm_contour_map(wks, sci_sat_rc, resrc)
   satdot = gsn_csm_contour(wks, p_sat, rescor)
   overlay(satplot, satdot)
   wnd = gsn_csm_vector(wks, sci_u_rc, sci_v_rc, resV)
   overlay(satplot, wnd)
   ; do i = 0, dimsizes(Wxpts)-2
   ;   dum1(i) = gsn_add_polyline(wks, satplot, Wxpts(i:i+1), \
   ;                                Wypts(i:i+1), plres)
   ; end do

   resrc@cnMaxLevelValF = 3.0
   resrc@cnMinLevelValF = -3.0
   resrc@cnLevelSpacingF = 0.5
   slpplot = gsn_csm_contour_map(wks, sci_slp_rc, resrc)
   slpdot = gsn_csm_contour(wks, p_slp, rescor)
   overlay(slpplot, slpdot)

   resrc@cnMaxLevelValF = 30.
   resrc@cnMinLevelValF = -30.
   resrc@cnLevelSpacingF = 5.
   z500plot = gsn_csm_contour_map(wks, sci_z500_rc, resrc)
   z500dot = gsn_csm_contour(wks, p_z500, rescor)
   overlay(z500plot, z500dot)

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

  ;Panel Draw
   plot_panel = new(4,graphic)
   plot_panel(0) = snowplot
   plot_panel(1) = satplot
   plot_panel(2) = slpplot
   plot_panel(3) = z500plot
   resP@gsnPanelFigureStrings = (/"SCE","SAT","SLP","Z500"/)
   gsn_panel(wks, plot_panel, (/4,1/), resP)

   htfl_panel = new(4,graphic)
   htfl_panel(0) = swrplot
   htfl_panel(1) = lwrplot
   htfl_panel(2) = shfplot
   htfl_panel(3) = lhfplot
   resP@gsnPanelLabelBar = True
   resP@gsnPanelFigureStrings = (/"SWR","LWR","SHF","LHF"/)
   gsn_panel(wks, htfl_panel, (/4,1/), resP)

    ; satWE = new(2,"graphic")
    ; satWE(0) = satW
    ; satWE(1) = satE
    ; rtsP@gsnPanelLabelBar = True
    ; rtsP@pmLabelBarWidthF = 0.6
    ; gsn_panel(wks, satWE, (/2,1/), rtsP)

  res_snow@cnFillPalette = "WhiteBlueGreenYellowRed"
  res_snow@cnMaxLevelValF = 50.
  res_snow@cnMinLevelValF = 0.
  plot = gsn_csm_contour_map(wks, snow_mam_dif_avg, res_snow)
  draw(plot)
  frame(wks)
  
  res_snow@cnMaxLevelValF = 30.
  ;res_snow@cnMinLevelValF = -30.
  res_snow@gsnLeftString = ""
  plot = gsn_csm_contour_map(wks, snow_mam_stv, res_snow)
  draw(plot)
  frame(wks)

  ;res_snow@cnMaxLevelValF = 20.
  res_snow@mpMinLonF = 230.
  res_snow@mpMaxLonF = 300.
  res_snow@pmLabelBarOrthogonalPosF = 0.05
  plot = gsn_csm_contour_map(wks, snow_mam_stv, res_snow)
  draw(plot)
  frame(wks)

  sati2 = new((/2,dimsizes(sati_eeu)/), "float")
  sati2(0,:) = sati_eeu
  sati2(1,:) = sati_na

  sci2 = new((/2,dimsizes(sci_eeu)/), "float")
  sci2(0,:) = sci_eeu
  sci2(1,:) = sci_na

  rts_line@lgTitleString = "SAT"
  pline = gsn_csm_xy(wks, time_long, sati2, rts_line)
  draw(pline)
  frame(wks)
  rts_line@lgTitleString = "Snow"
  pline = gsn_csm_xy(wks, time, sci2, rts_line)
  draw(pline)
  frame(wks)
   
  rts_line@xyLineColors = (/"black","black"/)
  rts_line@lgTitleString = "run cor SAT"
  rts_line@gsnLeftString = "Cor between SAT_EEU and SAT_NA"
  pline = gsn_csm_xy(wks, time_long(wSize/2:dimsizes(time_long)-1-wSize/2), rcor_sat, rts_line)
  rts_line@gsnLeftString = "Cor between SCE_EEU and SCE_NA"
  pline2 = gsn_csm_xy(wks, time(wSize/2:dimsizes(time)-1-wSize/2), rcor_sce, rts_line)

  tplot = new(2, graphic)
  tplot(0) = pline
  tplot(1) = pline2
  gsn_panel(wks, tplot, (/2,1/), rtsP)

  rts_line@gsnLeftString = "Cor between SAT_EEU and SCE_EEU"
  pline = gsn_csm_xy(wks, time(wSize/2:dimsizes(time)-1-wSize/2), rcor_ss1, rts_line)
  rts_line@gsnLeftString = "Cor between SAT_NA and SCE_NA"  
  pline2 = gsn_csm_xy(wks, time(wSize/2:dimsizes(time)-1-wSize/2), rcor_ss2, rts_line)
  tplot(0) = pline
  tplot(1) = pline2
  gsn_panel(wks, tplot, (/2,1/), rtsP)

  rts_line@gsnLeftString = "Cor between SAT_EEU and SCE_NA"
  pline = gsn_csm_xy(wks, time(wSize/2:dimsizes(time)-1-wSize/2), rcor_css1, rts_line)
  rts_line@gsnLeftString = "Cor between SCE_EEU and SAT_NA"
  pline2 = gsn_csm_xy(wks, time(wSize/2:dimsizes(time)-1-wSize/2), rcor_css2, rts_line)
  tplot(0) = pline
  tplot(1) = pline2
  gsn_panel(wks, tplot, (/2,1/), rtsP)  


end
