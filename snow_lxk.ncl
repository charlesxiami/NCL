load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/run_cor.ncl"
;***
  begin
;***
   yrstrt = 197901   ;P1+P2
   yrlast = 201712

   ; yrstrt = 196701   ;P1
   ; yrlast = 198812

   ; yrstrt = 198901  ;P2
   ; yrlast = 201912

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  year = ispan(yrstrt_snow/100, yrlast_snow/100, 1)
  year@units = "months since 0000-09-01 00:00:00 "

;---------------W,E-index Region
  SCI_WEU_N = 70
  SCI_WEU_S = 40
  SCI_WEU_L = 20
  SCI_WEU_R = 50

  SCI_EEU_N = 39
  SCI_EEU_S = 33
  SCI_EEU_L = 88
  SCI_EEU_R = 105

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
   wks=gsn_open_wks("pdf", plotpath+"snow_lxk")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.v5.nc", "r")

   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
   soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")
   ; snowdata = addfile(snowpath+"snow.rutger.2.0deg.nc","r")
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")

 ;*****************************************************************************************
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

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   ; snow_mon_wgt = SqrtCosWeight(snow_mon)

;************************************************
;Seasonal Mean
   ; snow_mam = month_to_season(snow_mon_hf, "MAM")
   snow_mam = month_to_season(snow_mon, "MAM")
   air_mam   = month_to_season(air_mon, "MAM")
   slp_mam   = month_to_season(slp_mon, "MAM")
   z500_mam = month_to_season(z500_mon, "MAM")
   z200_mam = month_to_season(z200_mon, "MAM")
   sst_mam   = month_to_season(sst_mon, "MAM")

   snow_apr = snow_mon(3::12,:,:)

   snow_apr_clim = dim_avg_n_Wrap(snow_mam, 0)

;************************************************
; Calculate Index
;************************************************
  EEU = snow_apr(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
  sci_eeu = dim_standardize_Wrap(wgt_areaave_Wrap(EEU, 1.0, 1.0, 1),0)

 ;*****************************************************************
   p = trend_manken(sci_eeu, False, 0)
  
   sci_eeu = dtrend(sci_eeu, False)
;******************************************************************
;regression
  sci_sce_rc = regCoef_n(sci_eeu, snow_apr, 0, 0)
  copy_VarCoords(snow_mam(0,:,:), sci_sce_rc)
  sci_sce_cor = escorc_n(sci_eeu, snow_apr, 0, 0)  
  copy_VarCoords(snow_mam(0,:,:), sci_sce_cor)
  ndim_snow = dimsizes(snow_mam)
  df_snow = sci_sce_cor
  df_snow = ndim_snow(0) - 2
  t_sce = sci_sce_cor*sqrt(df_snow/(1- sci_sce_cor^2 ))
  p_sce = student_t(t_sce, df_snow)
  copy_VarCoords(snow_mam(0,:,:), p_sce)

  ; print(sci_sce_cor({38.5},{91}))  ;38.5N, 91
   ; print(snow_apr(:,{36.5},{91}))
;*****************************************************************
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
   ; resrc@mpFillOn = False
   ; resrc@mpOutlineOn = True
   ; resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@lbBoxLinesOn = False
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@pmLabelBarHeightF = 0.05
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 360
   resrc@mpMaxLatF = 90
   resrc@mpMinLatF = 0

   res_snow = resrc
   res_snow@lbLabelBarOn = True
   res_snow@mpMinLonF = 60
   res_snow@mpMaxLonF = 110
   res_snow@mpMinLatF = 20
   res_snow@mpMaxLatF = 50
   ; res_snow@cnFillDrawOrder = "PostDraw"

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
   rescor@cnFillDrawOrder = "PostDraw"

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
;**********************************************************
;poly line
  Expts = (/SCI_EEU_L, SCI_EEU_L, SCI_EEU_R, SCI_EEU_R, SCI_EEU_L/)
  Eypts = (/SCI_EEU_S, SCI_EEU_N, SCI_EEU_N, SCI_EEU_S, SCI_EEU_S/)  
  dum1 = new(dimsizes(Expts)-1, graphic)
  dum2 = new(dimsizes(Expts)-1, graphic)
  dum3 = new(dimsizes(Expts)-1, graphic)
  plres = True
  plres@gsLineColor = "red"
  plres@gsLineThicknessF = 1.5
  plres@gsLineLabelString = ""  

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
  rts_bar@trYMaxF = -1*rts_bar@trYMinF
  rts_bar@gsnXYBarChartBarWidth = 0.35
  rts_bar@gsnAboveYRefLineColor = "red"
  rts_bar@gsnBelowYRefLineColor = "blue"

  rts_bar2 = rts_bar
  rts_bar2@gsnAboveYRefLineColor = "Transparent"
  rts_bar2@gsnBelowYRefLineColor = "Transparent"
  rts_bar2@gsnXYBarChartBarWidth = 0.65

  rts_line = rts   ; Line
  rts_line@xyDashPattern         = 1
  rts_line@xyLineThicknessF      = 4.
  rts_line@xyLineColor = "black"

  rtsP = True
  rtsP@lbLabelAutoStride = True

  ;Draw Bar chart
  rts_bar@gsnLeftStringFontHeightF = 0.02
  rts_bar@gsnLeftString = "b) Time series of SI"
  pbar = gsn_csm_xy(wks, year, sci_eeu, rts_bar)
  ; pbar2 = gsn_csm_xy(wks, year, sci_eeu, rts_bar2)
  ; pline = gsn_csm_xy(wks, year, sci_eeu_lf, rts_line)
  ; overlay(pbar, pbar2)
  ; overlay(pbar, pline)

  res_snow@gsnLeftString = "a) SCE"
  res_snow@gsnRightString = yrstrt/100+" - "+yrlast/100
     res_snow@cnMaxLevelValF = 1.0
   res_snow@cnMinLevelValF = -1*res_snow@cnMaxLevelValF
   res_snow@cnLevelSpacingF = 0.1
  ; snowplot = gsn_csm_contour_map(wks, sci_sce_rc, res_snow)
  snowplot = gsn_csm_contour_map(wks, sci_sce_cor, res_snow)
  snowdot = gsn_csm_contour(wks, p_sce, rescor)
  overlay(snowplot, snowdot)
   do i = 0, dimsizes(Expts)-2
       dum2(i) = gsn_add_polyline(wks, snowplot, Expts(i:i+1), \
                                  Eypts(i:i+1), plres)
   end do

   plots = new(2, graphic)
   plots(0) = snowplot
   plots(1) = pbar
   gsn_panel(wks, plots, (/2,1/), resP)

     res_snow@cnMaxLevelValF = 80
   res_snow@cnMinLevelValF = 0
   res_snow@cnLevelSpacingF = 5
   res_snow@cnFillPalette = "WhiteBlueGreenYellowRed"
   plot = gsn_csm_contour_map(wks, snow_apr_clim, res_snow)
   draw(plot)
   frame(wks)





end
