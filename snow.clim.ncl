load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; begin

   yrstrt = 197201
   yrlast = 201912
;**************************************************
   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"
   wks=gsn_open_wks("pdf", "snow.clim")
   gsn_define_colormap(wks, "WhiteBlueGreenYellowRed")
;**************************************************
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")
   ; swedata = addfile(snowpath+"/swe/GlobSnow_SWE_L3B_monthly_197909_v2.0.nc", status)

   YYYYMM = cd_calendar(snowdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   snow_mon = snowdata->snowcover(iStrt:iLast,:,:)
   ; snow_mon = SqrtCosWeight(snow_mon_org)

   snow_mam = month_to_season(snow_mon, "MAM")
   snow_jja = month_to_season(snow_mon, "JJA")
   snow_son = month_to_season(snow_mon, "SON")
   snow_djf = month_to_season(snow_mon, "DJF")

   snow_mam_clim = dim_avg_n_Wrap(snow_mam, 0)
   snow_jja_clim = dim_avg_n_Wrap(snow_jja, 0)
   snow_son_clim = dim_avg_n_Wrap(snow_son, 0)
   snow_djf_clim = dim_avg_n_Wrap(snow_djf, 0)

   snow_mam_var = dim_stddev_n_Wrap(snow_mam, 0)
   snow_jja_var = dim_stddev_n_Wrap(snow_jja, 0)
   snow_son_var = dim_stddev_n_Wrap(snow_son, 0)
   snow_djf_var = dim_stddev_n_Wrap(snow_djf, 0)

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
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@mpGridAndLimbOn = False
   resrc@mpOutlineOn = True
   ; resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = True
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 180
   resrc@mpMaxLatF = 80
   resrc@mpMinLatF = 20
   resrc@mpCenterLonF = (resrc@mpMinLonF+resrc@mpMaxLonF)/2.
   resrc@mpAreaMaskingOn = True
   resrc@mpOceanFillColor = "white"
   resrc@mpLandFillColor = "Transparent"
   ; resrc@mpMaskAreaSpecifiers =(/"China","Taiwan"/)
   resrc@gsnLeftString = " "
   resrc@gsnRightString = " "

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.015
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsBackgroundFillColor = "white"
   resP@gsnPanelFigureStringsFontColor = "black"
   resP@gsnPanelYWhiteSpacePercent = 5
   ; resP@lbLabelBarOn = True
   resP@gsnPanelLabelBar = True
   resP@gsnPanelFigureStrings = (/"(a)MAM","(b)JJA","(c)SON","(d)DJF"/)
;************************************************************************
   resrc@cnMaxLevelValF = 100
   resrc@cnMinLevelValF = 0
   resrc@cnLevelSpacingF = 5
   resrc@cnFillPalette = "WhiteBlue"

   plots = new(4, graphic)
   plots(0) = gsn_csm_contour_map(wks, snow_mam_clim, resrc)
   plots(1) = gsn_csm_contour_map(wks, snow_jja_clim, resrc)
   plots(2) = gsn_csm_contour_map(wks, snow_son_clim, resrc)
   plots(3) = gsn_csm_contour_map(wks, snow_djf_clim, resrc)
   gsn_panel(wks, plots, (/4,1/), resP)


   resrc@cnMaxLevelValF = 20
   resrc@cnMinLevelValF = 0
   resrc@cnLevelSpacingF = 2

   plots1 = new(4, graphic)
   plots1(0) = gsn_csm_contour_map(wks, snow_mam_var, resrc)
   plots1(1) = gsn_csm_contour_map(wks, snow_jja_var, resrc)
   plots1(2) = gsn_csm_contour_map(wks, snow_son_var, resrc)
   plots1(3) = gsn_csm_contour_map(wks, snow_djf_var, resrc)
   gsn_panel(wks, plots1, (/4,1/), resP)
