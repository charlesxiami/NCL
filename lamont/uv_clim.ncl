begin

   yrstrt = 197201
   yrlast = 201912

   ; yrstrt = 199601
   ; yrlast = 201912

   nyrs = yrlast/100 - yrstrt/100 + 1

   ; year_ind = ispan(yrstrt/100, yrlast/100, 1)

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  latS   =  40
  latN   =  75
  lonL   =  65
  lonR   =  150

   latS_eof = 40
   latN_eof = 70
   lonW_eof = 20
   lonE_eof = 140

   ; sig = 0.320   ;95%
   ; sig1 = 0.497
   ; sig2 = 0.433

   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"

   plotpath = "$HOME/output/"
;**************************************************
   wks = gsn_open_wks("pdf", "uv_clim")
   gsn_define_colormap(wks, "cmp_b2r")
;**************************************************
;Read Data
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
 ;***************************************
   YYYYMM = cd_calendar(hgtdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))
;-------------------------------------------------------------------
;Data read and process
   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)

   sc_season  = month_to_season(snow_mon_wgt, "SON")
   sc_season_eu = sc_season(:,{latS_eof:latN_eof},{lonW_eof:lonE_eof})

   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{20:90},:)
   z500_season = month_to_season(z500_mon, "DJF")

   u_mon = uwnddata->uwnd(iStrt:iLast,:,:,:)
   u_season = month_to_season(u_mon, "DJF")
   ulevel_season = u_season(:,{200},:,:)

   umulti = dim_avg_n_Wrap(u_season, 3) 
   ; printVarSummary(umulti)
;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1          ; 0=low pass, 1=high pass, 2=band-pass
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 7
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    ;pc1 = wgt_runave_Wrap(pc1_all, wgt, 0)
    ;snow_mam2  = wgt_runave_n_Wrap(snow_mam2, wgt, 0, 0)
;*************************************************
;Dtrend
   ; x = dtrend_n(z500_season, False, 0)
   ; copy_VarCoords(z500_season, x)

   ; x = dtrend_n(u200_season, False, 0)
   ; copy_VarCoords(u200_season, x)
;*************************************************
   iyr = 23

   ulevel_1 = ulevel_season(:iyr,:,:)
   ulevel_2 = ulevel_season(iyr+1:,:,:)

   ulevel_clim1 = dim_avg_n_Wrap(ulevel_1, 0)
   ulevel_clim2 = dim_avg_n_Wrap(ulevel_2, 0)

   ulevel_dif = ulevel_clim1
   ulevel_dif = ulevel_clim2 - ulevel_clim1

   ;Calculate the significance frwom u-distribution
   x1 = ulevel_clim1
   x2 = ulevel_clim2
   var1 = dim_variance_n_Wrap(ulevel_1, 0)
   var2 = dim_variance_n_Wrap(ulevel_2, 0)
   n1 = iyr+1
   n2 = (yrlast/100 - yrstrt/100)+1-n1
   ulevel_dif_sig = ulevel_dif
   ulevel_dif_sig = (x2 - x1)/sqrt(var2/n2+var1/n1)

   tval = ulevel_dif_sig
   df = ulevel_dif
   df = n1+n2-2
   b = ulevel_dif
   b = 0.5
   ulevel_prob = betainc(df/(df+tval^2),df/2.0,b)
   copy_VarCoords(ulevel_dif, ulevel_prob)

   umulti_1 = umulti(:iyr,:,:)
   umulti_2 = umulti(iyr+1:,:,:)

   umulti_clim1 = dim_avg_n_Wrap(umulti_1, 0)
   umulti_clim2 = dim_avg_n_Wrap(umulti_2, 0)
   umulti_dif = umulti_clim2
   umulti_dif = umulti_clim2 - umulti_clim1
   printVarSummary(umulti_dif)

   x1 := umulti_clim1
   x2 := umulti_clim2
   var1 := dim_variance_n_Wrap(umulti_1, 0)
   var2 := dim_variance_n_Wrap(umulti_2, 0)
   tval := umulti_dif
   tval = (x2 - x1)/sqrt(var2/n2+var1/n1)

   df := umulti_dif
   df = n1+n2-2
   b := umulti_dif
   b = 0.5
   umulti_prob = betainc(df/(df+tval^2),df/2.0,b)
   copy_VarCoords(umulti_dif, umulti_prob)
   printVarSummary(umulti_prob)
;*************************************************
;Res
;*************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   resmap = True
   resmap@mpFillOn = False
   resmap@mpCenterLonF = 180.
   resmap@mpMinLonF = 0.
   resmap@mpMaxLonF = 240.
   resmap@mpMaxLatF = 90.
   resmap@mpMinLatF = 0.
   ; resmap@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)

   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   resrc@pmLabelBarOrthogonalPosF = 0.5
   ;resrc@lbOrientation = "Vertical"
   resrc@cnInfoLabelOn = False
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = False
   ;resrc@mpCenterLonF = 0
   ; resrc@mpMinLonF = lonW_eof
   ; resrc@mpMaxLonF = lonE_eof
   ; resrc@mpMinLatF = latS_eof
   ; resrc@mpMaxLatF = latN_eof
   resrc@mpMinLatF = latS_eof
   resrc@mpMaxLatF = latN_eof
   resrc@mpMinLonF = lonW_eof
   resrc@mpMaxLonF = lonE_eof

   resrc@mpMinLatF = 20
   resrc@mpMaxLatF = 90
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 360
   resrc@mpCenterLonF = 180

   resrc@gsnAddCyclic = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMaxLevelValF = 0.08
   resrc@cnMinLevelValF = -0.08
   resrc@cnLevelSpacingF = 0.01
   ; resrc@trGridType = "TriangularMesh"
   ;resrc@gsnPolar = "NH"
   ;resrc@mpMinLatF = 35
   ;resrc@cnFillMode = "RasterFill"

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
   ; rescor@cnFillDrawOrder = "PreDraw"

   resP = True
   resP@gsnMaximize = False
   resP@gsnPanelLabelBar = True
   resP@pmLabelBarWidthF = 0.5
   resP@gsnPanelYWhiteSpacePercent = 6
   ; ;resP@gsnPanelFigureStrings = (/"a)","b)","c)","d)","e)","f)"/)
   ; resP@gsnPanelFigureStringsFontHeightF = 0.012
   ; resP@gsnPanelFigureStringsPerimOn = False
   ; resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   ; resP@amJust = "TopLeft"
   ; resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   ; resP@amParallelPosF = -0.50    ;X-axis
;*******************************************
; plot
;*******************************************
  resrc@cnMaxLevelValF = 10.
  resrc@cnMinLevelValF = -1*resrc@cnMaxLevelValF
  resrc@cnLevelSpacingF = 1.
  resrc@cnFillPalette = "BlueWhiteOrangeRed"

  resrc@lbLabelBarOn = False
  resrc@mpMinLatF = -30

  resrc@gsnLeftString = " "
  resrc@gsnRightString = " "
  
  plots = new(3, graphic)
  plots(0) = gsn_csm_contour_map(wks, ulevel_clim1, resrc)
  plots(1) = gsn_csm_contour_map(wks, ulevel_clim2, resrc)
  plots(2) = gsn_csm_contour_map(wks, ulevel_dif, resrc)
  plot := gsn_csm_contour(wks, ulevel_prob, rescor)
  overlay(plots(2), plot)
  gsn_panel(wks, plots, (/3,1/), resP)

  plots_hgt = new(3, graphic)
  plots_hgt(0) = gsn_csm_pres_hgt(wks, umulti_clim1, resrc)
  plots_hgt(1) = gsn_csm_pres_hgt(wks, umulti_clim2, resrc)
  plots_hgt(2) = gsn_csm_pres_hgt(wks, umulti_dif, resrc)
  plot := gsn_csm_pres_hgt(wks, umulti_prob, rescor)
  overlay(plots_hgt(2), plot)
  gsn_panel(wks, plots_hgt, (/1,3/), resP)


end