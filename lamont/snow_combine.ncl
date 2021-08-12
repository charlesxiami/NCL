
begin

   yrstrt1 = 195901
   yrlast1 = 197112

   yrstrt2 = 197201
   yrlast2 = 201412

;**************************************************************************
   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"
   plotpath = "$HOME/output/"

   wks = gsn_open_wks("pdf", plotpath+"snow_combine")
   gsn_define_colormap(wks, "MPL_YlGnBu")

   snowdata1 = addfile(snowpath+"snow.fsu.monthly.nc","r")
   snowdata2 = addfile(snowpath+"snow.rutger.2.0deg.nc","r")

   yyyymm1 = cd_calendar(snowdata1&time, 1)
   iyear1 = ind(yyyymm1.ge.yrstrt1.and.yyyymm1.le.yrlast1)

   yyyymm2 = cd_calendar(snowdata2&time, 1)
   iyear2 = ind(yyyymm2.ge.yrstrt2.and.yyyymm2.le.yrlast2)

   snow_fsu = snowdata1->snow(iyear1,:,:)
   snow_rtg = snowdata2->snowcover(iyear2,:,:)
 
   snow_combine = new((/672, 45,180/), float)
   do i = 0, 155
       snow_combine(i,:,:) = snow_fsu(i,:,:)
   end do
   do i = 0, 515
       snow_combine(i+156,:,:) = snow_rtg(i,:,:)
   end do
   do i = 0, 671
       copy_VarCoords(snow_rtg(0,:,:), snow_combine(i,:,:))
   end do

   printVarSummary(snow_combine)

;**************************************************************************
   season = "SON"
   snow_fsu_son = month_to_season(snow_fsu, season)
   snow_rtg_son = month_to_season(snow_rtg, season)
   ; printVarSummary(snow_fsu_son)
   snow_fsu_son = SqrtCosWeight(snow_fsu_son)

   snow_fsu_son_EUavg = wgt_areaave_Wrap(snow_fsu_son(:,{40:75},{0:180}), 1.0, 1.0, 0)
   snow_rtg_son_EUavg = wgt_areaave_Wrap(snow_rtg_son(:,{40:75},{0:180}), 1.0, 1.0, 0)
   ; printVarSummary(snow_rtg_son_EUavg)

   sc_fsu_index = dim_standardize_Wrap(snow_fsu_son_EUavg, 0)
   sc_rtg_index = dim_standardize_Wrap(snow_rtg_son_EUavg, 0)

;**************************************************************************
;Res
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
   ; resrc@cnFillPalette = "cmocean_dense"  
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@gsnLeftString = " "
   resrc@gsnRightString = " "
   resrc@cnLevelSelectionMode = "ManualLevels"
   ; resrc@mpGridAndLimbOn = False
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpOutlineOn = True
   ; resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = True
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 180
   resrc@mpMaxLatF = 90
   resrc@mpMinLatF = 10
   resrc@mpCenterLonF = (resrc@mpMinLonF+resrc@mpMaxLonF)/2.
   resrc@mpAreaMaskingOn = True
   resrc@mpOceanFillColor = "white"
   resrc@mpLandFillColor = "Transparent"
   ; resrc@mpMaskAreaSpecifiers =(/"China","Taiwan"/)

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.015
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsBackgroundFillColor = "black"
   resP@gsnPanelFigureStringsFontColor = "white"
   resP@gsnPanelLabelBar = True

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
;*****************************************************************************
;Plot
   resrc@cnMaxLevelValF = 90
   resrc@cnMinLevelValF = 10
   resrc@cnLevelSpacingF = 5
   ; plot = gsn_csm_contour_map(wks, snow_grid_avg, resrc)
   ; draw(plot)
   ; frame(wks)

   plots = new(24, graphic)
   plots2 = new(24, graphic)
   do i = 0, 12
      plots(i) = gsn_csm_contour_map(wks, snow_fsu_son(i,:,:), resrc)
      ; plots(i) = gsn_csm_contour_map(wks, snow_fsu(9+i*12,:,:), resrc)
      plots2(i) = gsn_csm_contour_map(wks, snow_rtg_son(i,:,:), resrc)
   end do
   gsn_panel(wks, plots, (/5,5/), resP)
   ; gsn_panel(wks, plots2, (/5,5/), resP)

   ; year = ispan(1972, 1995, 1)

   ; rts@xyLineColor = "red"
   ; plotline = gsn_csm_xy(wks, year, sc_fsu_index, rts)

   ; rts@xyLineColor = "blue"
   ; plotline2 = gsn_csm_xy(wks, year, sc_rtg_index, rts)

   ; overlay(plotline, plotline2)

   ; draw(plotline)
   ; frame(wks)

;********************************************************************
   fname = "snow.comb.monthly.nc"
   system("/bin/rm -f "+ snowpath+fname )
   ncdf = addfile(snowpath+fname ,"c")
   ; ncdf2 = addfile(snowpath"snow.fsu.daily.nc" ,"c")

       fAtt               = True            ; assign file attributes
       ; fAtt@process  = "Processed by Min Wang"
       ; fAtt@source   =  "Historical Soviet Daily Snow Depth (HSDSD), Version 2"
       fAtt@title    = "Snow Cover: FSU (1959-1971) + Rutger (1972-2014)"
       ; fAtt@creation_date = systemfunc ("date")
       fileattdef( ncdf, fAtt )            ; copy file attributes
       ; fileattdef( ncdf2, fAtt )            ; copy file attributes

   ncdf->snow = snow_combine

end