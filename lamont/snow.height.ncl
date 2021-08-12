load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   ;P1 = 1972-1995, P2 = 1996-2019, each length = 24 yrs.

   yrstrt = 197201
   yrlast = 199512

   ; yrstrt = 199601
   ; yrlast = 201912

   ; yrstrt = 197201
   ; yrlast = 201912

   nyrs = yrlast/100-yrstrt/100+1
   print("years= "+nyrs)

   ; yrstrt_sst = yrstrt
   ; yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  year=ispan(yrstrt_snow/100, yrlast_snow/100, 1)
  ;t = ispan(1970, 2014, 1)
;---------------W,E-index Region
  SCI_EEU_N = 70
  SCI_EEU_S = 40
  SCI_EEU_L = 80
  SCI_EEU_R = 140
  
  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

  pv_latS = 65
  pv_latN = 90
  pv_lonL = -60
  pv_lonR = 10

   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", "snow.height")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   ; sstdata = addfile(nceppath+"sst.mnmean.nc", "r")

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
   nao_index3 = nao_index2(0:dimsizes(nao_index2)-1-2)

   month_time = yyyymm_time(1950, 2020, "integer")
   month_time!0 = "time"
   month_time@long_name = "time"
   month_time@units = "month"
   nao_index3!0 = "time"
   nao_index3&time = month_time

 ;***************************************
   YYYYMM = cd_calendar(hgtdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))
 ;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})

   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR})

   z70_mon = hgtdata->hgt(iStrt:iLast,{70},{latS:latN},{lonL:lonR})

   z50_mon = hgtdata->hgt(iStrt:iLast,{50},{latS:latN},{lonL:lonR})

   zmulti_mon0 = hgtdata->hgt(iStrt:iLast,:,{latS:latN},{lonL:lonR})
   zmulti_mon0 = lonFlip(zmulti_mon0)
   ; printVarSummary(zmulti_mon0)
   zmulti_mon1 = dim_avg_n_Wrap(zmulti_mon0(:,:,:,:), 3)  ; zonal mean
   zmulti_mon2 = dim_avg_n_Wrap(zmulti_mon0(:,:,{pv_latS:pv_latN},:), 2)   ;meridian mean
   zmulti_mon3 = dim_avg_n_Wrap(zmulti_mon1(:,:,{pv_latS:pv_latN}), 2) ;height x time
   ; xx = zmulti_mon0(:,:,:,{pv_lonL:pv_lonR})
   ; printVarSummary(zmulti_mon3)

   u_mon = uwnddata->uwnd(iStrt:iLast,:,{latS:latN},{lonL:lonR})
   u_mon1 = dim_avg_n_Wrap(u_mon, 3) ;Zonal Mean
   u_mon2 = dim_avg_n_Wrap(u_mon(:,:,{60:90},:), 2);meridian mean

   u850_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR})
   v850_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 

   u200_mon = uwnddata->uwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})
   v200_mon = vwnddata->vwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})

;************************************************
;Seasonal Mean
   ; season = "DJF"
   ; print("season:  " + season)
   ; zmulti_mam1 = month_to_season(zmulti_mon1, season)
   ; zmulti_mam2 = month_to_season(zmulti_mon2, season)
   ; ; printVarSummary(zmulti_mam2)

   ; zmulti_djf = month_to_season(zmulti_mon0, season)
   ; zmulti_djf1 = zmulti_djf(1:,:,:,:)
   ; ; printVarSummary(zmulti_djf1)

   ; u_mam1 = month_to_season(u_mon1, season)
   ; u_mam2 = month_to_season(u_mon2, season)

  ; print("-------------------------------------------------------")
  ;**********************************************
  ;Maunal calculate
   zdim = dimsizes(zmulti_mon3)
   nmonth = 6
   zmulti_mam3 = new((/nmonth, nyrs-1, zdim(1)/), float)
   do i = 0, nyrs - 2   
       do k = 0, nmonth - 1
           zmulti_mam3(k,i,:) = zmulti_mon3(k+8+i*12,:)
       end do
       ; copy_VarCoords(zmulti_mon3(0:nyrs-2,:), zmulti_mam3(k,:,:))
   end do
   ; printVarSummary(zmulti_mam3)

   ; zdim0 = dimsizes(zmulti_mon0)
   ; zmulti_sea = new((/nmonth, nyrs-1, zdim0(1), zdim0(2), zdim0(3)/), float)
   ; do k = 0, nmonth - 1
   ;    do i = 0, nyrs -2
   ;     zmulti_sea(k,i,:,:,:) = (zmulti_mon0(k+7+i*12,:,:,:)+zmulti_mon0(k+8+i*12,:,:,:)+ \
   ;                              zmulti_mon0(k+9+i*12,:,:,:))/3.0
   ;    end do
   ;    copy_VarCoords(zmulti_mon0(0:nyrs-2,:,:,:), zmulti_sea(k,:,:,:,:))
   ; end do
   ; printVarSummary(zmulti_sea)
  ; print("-------------------------------------------------------")
 ;*****************************************************************
   snow_son_pc = asciiread(indexpath+"snow_pc1dt_1972-2019SON.txt", -1, "float")
   ; snow_son_pc = asciiread(indexpath+"snow_pc2dt_1972-2019SON.txt", -1, "float")

   pc_p1 = snow_son_pc(0:22)     ;1972-1994 SON for PC_P1
   pc_p2 = snow_son_pc(24:46)    ;1996-2018 SON for PC_P2

  ;Define index
   snow_index = pc_p1
   ; snow_index = pc_p2

   ; pc1_p1 = snow_son_pc1(0:imidyr)
   ; pc1_p2 = snow_son_pc1(imidyr+1:)

   ; pc2_p1 = snow_son_pc2(0:imidyr)
   ; pc2_p2 = snow_son_pc2(imidyr+1:)
   ; printVarSummary(pc1_p2)

;**********************************************************
;3-D Data analysis
;**********************************************************
 ;Reg and Cor
  ; ndim_multi = dimsizes(zmulti_mam1)

  ; sci_zmulti_rc1 = regCoef_n(snow_index, zmulti_mam1, 0, 0)
  ; copy_VarCoords(zmulti_mam1(0,:,:), sci_zmulti_rc1)
  ; sci_zmulti_cor = escorc_n(snow_index, zmulti_mam1, 0, 0)
  ; df_ncep_multi = sci_zmulti_cor
  ; df_ncep_multi = ndim_multi(0) - 2
  ; p_zmulti = student_t(sci_zmulti_cor*sqrt(df_ncep_multi/(1- sci_zmulti_cor^2)), df_ncep_multi)
  ; copy_VarCoords(zmulti_mam1(0,:,:), p_zmulti)

  ; sci_zmulti_rc2 = regCoef_n(snow_index, zmulti_mam2, 0, 0)
  ; copy_VarCoords(zmulti_mam2(0,:,:), sci_zmulti_rc2)
  ; sci_zmulti_cor2 = escorc_n(snow_index, zmulti_mam2, 0, 0)
  ; df_ncep_multi2 = sci_zmulti_cor2
  ; df_ncep_multi2 = ndim_multi(0) - 2
  ; p_zmulti2 = student_t(sci_zmulti_cor2*sqrt(df_ncep_multi2/(1- sci_zmulti_cor2^2)), df_ncep_multi2)
  ; copy_VarCoords(zmulti_mam2(0,:,:), p_zmulti2)

; printVarSummary(snow_index)
; printVarSummary(zmulti_mam3)

  sci_zmulti_rc3 = regCoef_n(snow_index, zmulti_mam3, 0, 1)
  copy_VarCoords(zmulti_mam3(:,0,:), sci_zmulti_rc3)
  sci_zmulti_cor3 = escorc_n(snow_index, zmulti_mam3, 0, 1)
  df_ncep_multi3 = sci_zmulti_cor3
  df_ncep_multi3 = nyrs - 2 - 1
  p_zmulti3 = student_t(sci_zmulti_cor3*sqrt(df_ncep_multi3/(1- sci_zmulti_cor3^2)), df_ncep_multi3)
  copy_VarCoords(zmulti_mam3(:,0,:), p_zmulti3)
  sci_zmulti_rc3!0 = "time"
  ; sci_zmulti_rc3&time = ispan(1, nmonth, 1)
  p_zmulti3!0 = "time"

  ; sci_zmulti_rc0 = regCoef_n(snow_index, zmulti_djf1, 0, 0)
  ; copy_VarCoords(zmulti_djf1(0,:,:,:), sci_zmulti_rc0)
  ; sci_zmulti_cor0 = escorc_n(snow_index, zmulti_djf1, 0, 0)
  ; df_ncep_multi0 = sci_zmulti_cor0
  ; df_ncep_multi0 = nyrs - 2 - 1
  ; p_zmulti0 = student_t(sci_zmulti_cor0*sqrt(df_ncep_multi0/(1- sci_zmulti_cor0^2)), df_ncep_multi0)
  ; copy_VarCoords(zmulti_djf1(0,:,:,:), p_zmulti0)
  ; printVarSummary(sci_zmulti_rc0)
  ; printVarSummary(p_zmulti0)

  ; sci_zmulti_rc0 = regCoef_n(snow_index, zmulti_sea, 0, 1)
  ; copy_VarCoords(zmulti_sea(:,0,:,:,:), sci_zmulti_rc0)
  ; sci_zmulti_cor0 = escorc_n(snow_index, zmulti_sea, 0, 1)
  ; df_ncep_multi0 = sci_zmulti_cor0
  ; df_ncep_multi0 = nyrs - 2 - 1
  ; p_zmulti0 = student_t(sci_zmulti_cor0*sqrt(df_ncep_multi0/(1- sci_zmulti_cor0^2)), df_ncep_multi0)
  ; copy_VarCoords(zmulti_sea(:,0,:,:,:), p_zmulti0)
  ; sci_zmulti_rc0!0 = "time"
  ; p_zmulti0!0 = "time"

  ; sci_u_rc1 = regCoef_n(snow_index, u_mam1, 0, 0)
  ; copy_VarCoords(u_mam1(0,:,:), sci_u_rc1)
  ; sci_u_cor = escorc_n(snow_index, u_mam1, 0, 0)
  ; df_ncep_multi = sci_u_cor
  ; df_ncep_multi = ndim_multi(0) - 2
  ; p_u1 = student_t(sci_u_cor*sqrt(df_ncep_multi/(1- sci_u_cor^2)), df_ncep_multi)
  ; copy_VarCoords(u_mam1(0,:,:), p_u1)

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
   resrc@pmLabelBarHeightF = 0.1
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15

   res_circ = resrc
   res_circ@gsnLeftStringFontHeightF = 0.015
   res_circ@gsnRightStringFontHeightF = 0.015


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
   rescor@cnLevels = (/0.1/) 
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
   rescor@cnFillScaleF = 2
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
;pressure vs lat/lon
   res_circ@pmLabelBarOrthogonalPosF = 0.04
   ; res_circ@vpWidthF = 0.75
   ; res_circ@vpHeightF = 0.3
   ; res_circ@gsnLeftString = "Height x time HGT regressed on PC1"
   res_circ@gsnRightString = " "   
   res_circ@cnMaxLevelValF = 60
   res_circ@cnMinLevelValF = -1*res_circ@cnMaxLevelValF
   res_circ@cnLevelSpacingF = 5
   ; res_circ@tmXBLabels = new(nmonth, "string")

   ; res_circ@gsnLeftString = "Zonal (60W-20E mean) HGT regressed on PC1"
   ; zmultiplot = gsn_csm_pres_hgt(wks, sci_zmulti_rc1, res_circ)
   ; zmultidot = gsn_csm_contour(wks, p_zmulti, rescor)
   ; overlay(zmultiplot, zmultidot)
   ; ; draw(zmultiplot)
   ; ; frame(wks)

   ; res_circ@gsnLeftString = "Meridian (60-90N mean) HGT regressed on PC1"
   ; zmultiplot2 = gsn_csm_pres_hgt(wks, sci_zmulti_rc2, res_circ)
   ; zmultidot2 = gsn_csm_contour(wks, p_zmulti2, rescor)
   ; overlay(zmultiplot2, zmultidot2)
   ; ; draw(zmultiplot2)
   ; ; frame(wks)
   ; do i = 0, n
   ;   ; write loop content
   ; end do

   res_circ@gsnLeftString = "a) 1972-1995"
   ; res_circ@gsnLeftString = "b) 1996-2019"
   res_circ@tmXBOn = False
   res_circ@tmXBLabelsOn = False
   ; res_circ@tmXBMode = "Manual"
   ; res_circ@tmXBTickStartF = 1
   ; res_circ@tmXBTickEndF = 6
   ; res_circ@tmXBValues = ispan(1, 6, 1)
   ; res_circ@tmXBLabels = (/"J","A","S","O","N","D","J","F","M"/)
   ; res_circ@tmXBLabels = (/"S","O","N","D","J","F"/)
  
   ; dim_time = sci_zmulti_rc3&time
   ; dim_time@actual_range = ispan(1, 6, 1)
   ; sci_zmulti_rc3&time = dim_time
   printMinMax(p_zmulti3, 0)
   zmultiplot = gsn_csm_pres_hgt(wks, sci_zmulti_rc3(level|:, time|:), res_circ)
   zmultidot = gsn_csm_contour(wks, p_zmulti3(level|:, time|:), rescor)
   overlay(zmultiplot, zmultidot)
   draw(zmultiplot)
   frame(wks)
   ; printVarSummary(sci_zmulti_rc3&time)

   ; sci_zlat = dim_avg_n_Wrap(sci_zmulti_rc0, 2)
   ; p_zlat = dim_avg_n_Wrap(p_zmulti0, 2)
   ; sci_zlon = dim_avg_n_Wrap(sci_zmulti_rc0(:,{60:},:), 1)
   ; p_zlon = dim_avg_n_Wrap(p_zmulti0(:,{60:},:), 1)

   ; plot_zlat = gsn_csm_pres_hgt(wks, sci_zlat, res_circ)
   ; plot_p = gsn_csm_contour(wks, p_zlat, rescor)
   ; overlay(plot_zlat, plot_p)
   ; draw(plot_zlat)
   ; frame(wks)

   ; printVarSummary(sci_zmulti_rc3)

   ; rc01 = dim_avg_n_Wrap(sci_zmulti_rc0(:,:,{pv_latS:pv_latN},{pv_lonL:pv_lonR}), 2)
   ; rc02 = dim_avg_n_Wrap(rc01, 2)
   ; cor01 = dim_avg_n_Wrap(p_zmulti0(:,:,{pv_latS:pv_latN},{pv_lonL:pv_lonR}), 2)
   ; cor02 = dim_avg_n_Wrap(cor01, 2)

   ; zmultiplot = gsn_csm_pres_hgt(wks, rc02(level|:, time|:), res_circ)
   ; zmultidot = gsn_csm_contour(wks, cor02(level|:, time|:), rescor)
   ; overlay(zmultiplot, zmultidot)
   ; draw(zmultiplot)
   ; frame(wks)

   ; ;Zonal Mean Wind
   ; res_circ@cnFillPalette = "MPL_PRGn"
   ; res_circ@cnMaxLevelValF = 4
   ; res_circ@cnMinLevelValF = -1*res_circ@cnMaxLevelValF
   ; res_circ@cnLevelSpacingF := 0.2
   ; res_circ@gsnLeftString = "Zonal Mean U regressed on snow_PC1"
   ; uplot1 = gsn_csm_pres_hgt(wks, sci_u_rc1, res_circ)
   ; udot1 = gsn_csm_contour(wks, p_u1, rescor)
   ; overlay(uplot1, udot1)
   ; ; draw(uplot1)
   ; ; frame(wks)


end
