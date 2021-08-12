begin
   yrstrt = 196701
   yrlast = 201912

   ; yrstrt = 198901
   ; yrlast = 201912

   yrstrt_ice = yrstrt
   yrlast_ice = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

   SCI_EEU_N = 70
   SCI_EEU_S = 40
   SCI_EEU_L = 80
   SCI_EEU_R = 140

;************************************************************
   nceppath = "$HOME/data/ncep/"
   ncep2path = "$HOME/data/ncep2/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"
   hadleypath = "$HOME/data/hadley/"

   plotpath = "$HOME/output/"
;************************************************************
   wks=gsn_open_wks("pdf", plotpath+"sea_ice")
   gsn_define_colormap(wks, "MPL_RdBu")
;************************************************************
   ; snowdata  = addfile(snowpath+"snow.rutger.2.0deg.nc","r")
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")
   sicdata = addfile(hadleypath+"HadISST_ice.nc", "r")

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))

   YYYYMM4 = cd_calendar(sicdata->time, 1)
   iStrt4  = ind(YYYYMM4.eq.yrstrt_ice)
   iLast4  = ind(YYYYMM4.eq.yrlast_ice)
   print("Sea Ice time: "+YYYYMM4(iStrt4)+"--"+YYYYMM4(iLast4))
;************************************************************
   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   sic_mon = sicdata->sic(iStrt4:iLast4,:,:)

   snow_sea = month_to_season(snow_mon, "MAM")

   season_string = "MAM"
   sic_sea = month_to_season(sic_mon, season_string)
   print("Season:  "+ season_string)
;************************************************************
   sic_sea_clim = dim_avg_n_Wrap(sic_sea, 0)

   sic_sea_std = dim_stddev_n_Wrap(sic_sea, 0)
;************************************************************   
   EEU = snow_sea(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
   sci_eeu = dim_standardize_Wrap(wgt_areaave_Wrap(EEU, 1.0, 1.0, 1),0)
   sci_eeu = dtrend(sci_eeu, False)
;************************************************************
   snow_index = sci_eeu
   ; snow_index = sci_eeu(0:21)
   ; snow_index = sci_eeu(22:)

  ;snow data
   sci_sce_rc = regCoef_n(sci_eeu, snow_sea, 0, 0)
   copy_VarCoords(snow_sea(0,:,:), sci_sce_rc)
   sci_sce_cor = escorc_n(sci_eeu, snow_sea, 0, 0)  
   ndim_snow = dimsizes(snow_sea)
   df_snow = sci_sce_cor
   df_snow = ndim_snow(0) - 2
   t_sce = sci_sce_cor*sqrt(df_snow/(1- sci_sce_cor^2 ))
   p_sce = student_t(t_sce, df_snow)
   copy_VarCoords(snow_sea(0,:,:), p_sce)

   sci_sic_rc = regCoef_n(snow_index, sic_sea, 0, 0)
   copy_VarCoords(sic_sea(0,:,:), sci_sic_rc)
   sci_sic_cor = escorc_n(snow_index, sic_sea, 0, 0)  
   ndim_sic = dimsizes(sic_sea)
   df_sic = sci_sic_cor
   df_sic = ndim_sic(0) - 2
   t_sic = sci_sic_cor*sqrt(df_sic/(1- sci_sic_cor^2 ))
   p_sic = student_t(t_sic, df_sic)
   copy_VarCoords(sic_sea(0,:,:), p_sic)

;************************************************************
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
   resrc@mpGridAndLimbOn = True
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   ; resrc@mpOutlineOn = True
   ; resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = True
   ; resrc@mpMinLonF = -180
   ; resrc@mpMaxLonF = 180
   ; resrc@mpMaxLatF = 90
   ; resrc@mpMinLatF = 0
   resrc@mpCenterLonF = 0
   resrc@mpAreaMaskingOn = True
   resrc@mpOceanFillColor = "Transparent"
   resrc@mpLandFillColor = "Transparent"
   ; resrc@mpMaskAreaSpecifiers =(/"China","Taiwan"/)

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
   rescor@cnFillScaleF = 0.8
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillOpacityF = 1.0
   rescor@cnFillDrawOrder = "PreDraw"
;************************************************************
   resrc@cnFillPalette = "WhiteBlueGreenYellowRed"
   resrc@gsnPolar = "NH"
   resrc@mpMinLatF = 60
   ; resrc@cnMinLevelValF = 0.0
   ; resrc@cnMaxLevelValF = 1.0
   ; resrc@cnLevelSpacingF = 0.05
   resrc@gsnRightString = " "
   resrc@gsnLeftString = season_string + "  Climatic Mean"
   resrc@gsnStringFontHeightF = 0.03

   plot_sic = gsn_csm_contour_map_polar(wks, sic_sea_clim, resrc)
   ; draw(plot_sic)
   ; frame(wks)

   ; resrc@gsnLeftString = season_string + "  Standard deviation"
   ; resrc@cnMinLevelValF = 0.04
   ; resrc@cnMaxLevelValF = 0.4
   ; plot_sic := gsn_csm_contour_map_polar(wks, sic_sea_std, resrc)
   ; draw(plot_sic)
   ; frame(wks)
  
   resrc@cnFillPalette = "MPL_RdBu"
   resrc@cnMinLevelValF = -0.12
   resrc@cnMaxLevelValF = 0.12
   resrc@cnLevelSpacingF = 0.02
   resrc@gsnLeftString = season_string + " SIC Reg"
   resrc@gsnRightString = yrstrt/100 + "-" + yrlast/100
   plot_sic := gsn_csm_contour_map_polar(wks, sci_sic_rc, resrc)
   plot_dot = gsn_csm_contour(wks, p_sic, rescor)
   overlay(plot_sic, plot_dot)
   draw(plot_sic)
   frame(wks)



end