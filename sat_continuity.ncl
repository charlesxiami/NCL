load "/public/home/charlesxiami/nclscript/undef_function/moving_ttest.ncl"
;***********************************************

begin
   snowpath  = "/public/home/charlesxiami/data/snow/"
   nceppath  = "/public/home/charlesxiami/data/ncep/"
   plotpath  = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"

   latS  = -90
   latN  = 90
   lonL  = 0
   lonR  = 360

   WlatS = 48
   WlatN = 58
   WlonL = 25
   WlonR = 50
  
   ElatS = 60
   ElatN = 70
   ElonL = 100
   ElonR = 125

   yrstrt =196701
   yrlast =201412

   sig = 0.285   ;95%, 48yeras   99%=0.368
   ; sig1 = 0.497
   ; sig2 = 0.433
;*****************************************************
;I/O
;*****************************************************
   wks=gsn_open_wks("pdf", plotpath+"sat_continuity")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")

   snow_file = addfile(snowpath+"snow.rutger.2.0deg.neareststod.nc", "r")
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.v4.nc", "r")
   pc1_all = asciiread(indexpath+"pc1.txt", -1, "float")
   ;print(snow_file->lon)

   YYYYMM = cd_calendar(snow_file->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print(YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM2 = cd_calendar(airdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)
   print(YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))

   snow_mon = snow_file->snowcover(iStrt:iLast,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   air_mon = airdata->air(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   air_mam = month_to_season(air_mon, "MAM")
   
   slp_mon = slpdata->slp(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   slp_mam = month_to_season(slp_mon, "MAM")
   
   z500_mon = hgtdata->hgt(iStrt2:iLast2,{500},{latS:latN},{lonL:lonR}) 
   z500_mam = month_to_season(z500_mon, "MAM")

   z200_mon = hgtdata->hgt(iStrt2:iLast2,{200},{latS:latN},{lonL:lonR}) 
   z200_mam = month_to_season(z200_mon, "MAM")

   z850_mon = hgtdata->hgt(iStrt2:iLast2,{850},{latS:latN},{lonL:lonR}) 
   z850_mam = month_to_season(z500_mon, "MAM")

   u_mon = uwnddata->uwnd(iStrt2:iLast2,{850},{latS:latN},{lonL:lonR}) 
   u_mam = month_to_season(u_mon, "MAM")
   v_mon = vwnddata->vwnd(iStrt2:iLast2,{850},{latS:latN},{lonL:lonR}) 
   v_mam = month_to_season(v_mon, "MAM")
   uv_mam = sqrt(u_mam^2+v_mam^2)
   copy_VarCoords(u_mam, uv_mam)

;*************************************************
;Res
;*************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   resmap = res
   resmap@mpFillOn = False  
   resmap@mpOutlineOn = True
   resmap@mpCenterLonF = 90.
   resmap@mpMinLonF = 20.
   resmap@mpMaxLonF = 180.
   resmap@mpMaxLatF = 90.
   resmap@mpMinLatF = 0.
   resmap@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)

   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   ;resrc@lbBoxSeparatorLinesOn = False
   resrc@pmLabelBarOrthogonalPosF = 0.5
   ;resrc@lbOrientation = "Vertical"
   resrc@cnInfoLabelOn = False
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = False
   resrc@mpCenterLonF = 180.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 180.
   resrc@mpMinLatF = 0.
   resrc@mpMaxLatF = 90.
   resrc@cnLevelSelectionMode = "ManualLevels"

   ressat = resrc
   ressat@cnMinLevelValF = -1.8
   ressat@cnMaxLevelValF = 1.8
   ressat@cnLevelSpacingF = 0.1

   resZ = resrc

   ressnow = resrc
   ressnow@cnMinLevelValF = -20
   ressnow@cnMaxLevelValF = 20
   ressnow@cnLevelSpacingF = 1
   ;ressnow@gsnRightString = "%"
   ressnow@mpMinLonF = 20.
   ressnow@mpMaxLonF = 160.
   ressnow@mpMinLatF = 20.
   ressnow@mpMaxLatF = 80.

   resSST = resrc
   resSST@mpCenterLonF = 180.
   resSST@mpMinLonF = 0.
   resSST@mpMaxLonF = 360.
   resSST@mpMinLatF = -20.
   resSST@mpMaxLatF = 80.
   resSST@cnMinLevelValF = -0.5
   resSST@cnMaxLevelValF = 0.5
   resSST@cnLevelSpacingF = 0.01

   rescor = True
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnMonoFillPattern = False
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnLevels = (/-sig,sig/)

   resPolar = res
   resPolar@gsnPolar = "NH"
   resPolar@mpMinLatF = 30.
   resPolar@cnFillOn = True
   resPolar@cnLinesOn = False
   resPolar@lbLabelBarOn = False
   resPolar@gsnLeftString = " "
   resPolar@cnLevelSelectionMode = "ManualLevels"
   resPolar@cnMaxLevelValF = 100.
   resPolar@cnMinLevelValF = 0.
   resPolar@cnLevelSpacingF = 10.

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
   resV@vcRefAnnoOrthogonalPosF = -0.58
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.0               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True
   resP@gsnMaximize = False
   resP@gsnPanelLabelBar = True
   resP@gsnPanelFigureStringsFontHeightF = 0.012
   resP@gsnPanelFigureStringsPerimOn = True
   resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   resP@amJust = "TopLeft"
   resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   resP@amParallelPosF = -0.50    ;X-axis
   resP@pmLabelBarOrthogonalPosF = -0.015
   resP@lbBoxSeparatorLinesOn = False

;************************************************
; Calculate 
;************************************************
   dim_ncep = dimsizes(air_mam)
   sat_23456 = new((/5,dim_ncep(0),dim_ncep(1),dim_ncep(2)/), "float")
   sat_23456(0,:,:,:) = air_mon(1:dim_ncep(0)*12-1:12,:,:)   ;Feb
   sat_23456(1,:,:,:) = air_mon(2:dim_ncep(0)*12-1:12,:,:)
   sat_23456(2,:,:,:) = air_mon(3:dim_ncep(0)*12-1:12,:,:)
   sat_23456(3,:,:,:) = air_mon(4:dim_ncep(0)*12-1:12,:,:)
   sat_23456(4,:,:,:) = air_mon(5:dim_ncep(0)*12-1:12,:,:)   ;June

   sat_cor_2mon = new((/4,dim_ncep(1),dim_ncep(2)/), "float")

;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 7
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    ;pc1 = wgt_runave_Wrap(pc1_all, wgt, 0)
    ;snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)

;*************************************************
;
;*************************************************
   sat_23456_avg = dim_avg_n_Wrap(sat_23456, 1)

   resrc@cnMinLevelValF = -24.
   resrc@cnMaxLevelValF = 24.
   resrc@cnLevelSpacingF = 1.0
   plot_sat_clim = new(5, "graphic")
   do i = 0, 4
      plot_sat_clim(i) = gsn_csm_contour_map(wks, sat_23456_avg(i,:,:), resrc)
   end do
   resP@gsnPanelMainString = "SAT Clim Month Mean "
   resP@gsnPanelFigureStrings = (/"Feb","Mar","April","May","Jun"/)
   gsn_panel(wks, plot_sat_clim, (/3,3/), resP)
   delete(resP@gsnPanelFigureStrings)


   plot_satcor_fill = new(4, "graphic")
   plot_sat_cor = new(4, "graphic")
   resrc@cnMinLevelValF = -1.0
   resrc@cnMaxLevelValF = 1.0
   resrc@cnLevelSpacingF = 0.01
   do i = 0, 3
      sat_cor_2mon(i,:,:) = escorc_n(sat_23456(i,:,:,:), sat_23456(i+1,:,:,:), 0, 0)
      copy_VarCoords(air_mon(0,:,:), sat_cor_2mon(i,:,:))

      plot_satcor_fill(i) = gsn_csm_contour_map(wks, sat_cor_2mon(i,:,:), resrc)
      plot_sat_cor(i) = gsn_csm_contour(wks, sat_cor_2mon(i,:,:), rescor)
      overlay(plot_satcor_fill(i), plot_sat_cor(i))
   end do
   resP@gsnPanelMainString = "SAT Correlation between each 2 adjacent-month"
   resP@gsnPanelFigureStrings = (/"Feb-Mar","Mar-April","April-May","May-Jun"/)
   gsn_panel(wks, plot_satcor_fill, (/3,2/), resP)
   delete(resP@gsnPanelFigureStrings)

   do i = 0, 2
      sat_cor_2mon(i,:,:) = escorc_n(sat_23456(i,:,:,:), sat_23456(i+2,:,:,:), 0, 0)
      copy_VarCoords(air_mon(0,:,:), sat_cor_2mon(i,:,:))

      plot_satcor_fill(i) = gsn_csm_contour_map(wks, sat_cor_2mon(i,:,:), resrc)
      plot_sat_cor(i) = gsn_csm_contour(wks, sat_cor_2mon(i,:,:), rescor)
      overlay(plot_satcor_fill(i), plot_sat_cor(i))
   end do
   resP@gsnPanelMainString = "SAT Correlation between each 2 gap-month"
   resP@gsnPanelFigureStrings = (/"Feb-April","Mar-May","April-Jun"/)
   gsn_panel(wks, plot_satcor_fill, (/1,3/), resP)



end