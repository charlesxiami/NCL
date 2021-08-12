begin

   yrstrt = 196701   ;P1
   yrlast = 201412

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  latS   =  40
  latN   =  75
  lonL   =  65
  lonR   =  150

  WlatS = 48
  WlatN = 58
  WlonL = 25
  WlonR = 50
  
  ElatS = 60
  ElatN = 70
  ElonL = 100
  ElonR = 125

   latS_eof = 20
   latN_eof = 80
   lonW_eof = 0
   lonE_eof = 150

   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"snow_check")
   gsn_define_colormap(wks, "WhiteBlueGreenYellowRed")
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
   snowdata = addfile(snowpath+"snow.rutger.2.0deg.nc","r")
   precipdata = addfile(precpath+"precip.mon.anom.nc", "r")

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
;-------------------------------------------------------------------
;Data read and process
   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)

   snow_son = month_to_season(snow_mon_wgt, "OND")
   snow_djf = month_to_season(snow_mon_wgt, "DJF")
   snow_mam = month_to_season(snow_mon_wgt, "MAM")
   snow_jja = month_to_season(snow_mon_wgt, "JJA")
  
   ndim = dimsizes(snow_mam)
   snow_avg = new((/4,ndim(1),ndim(2)/), typeof(snow_mam))
      snow_avg(0,:,:) = dim_avg_n_Wrap(snow_son, 0)
      snow_avg(1,:,:) = dim_avg_n_Wrap(snow_djf, 0)
      snow_avg(2,:,:) = dim_avg_n_Wrap(snow_mam, 0)
      snow_avg(3,:,:) = dim_avg_n_Wrap(snow_jja, 0)
      ; snow_avg = dtrend_n(snow_avg, False, 1)
        copy_VarCoords(snow_mam(0,:,:), snow_avg(0,:,:))
        copy_VarCoords(snow_mam(0,:,:), snow_avg(1,:,:))
        copy_VarCoords(snow_mam(0,:,:), snow_avg(2,:,:))
        copy_VarCoords(snow_mam(0,:,:), snow_avg(3,:,:))

   snow_std = new((/4,ndim(1),ndim(2)/), typeof(snow_mam))
      snow_std(0,:,:) = dim_stddev_n_Wrap(snow_son, 0)
      snow_std(1,:,:) = dim_stddev_n_Wrap(snow_djf, 0)
      snow_std(2,:,:) = dim_stddev_n_Wrap(snow_mam, 0)
      snow_std(3,:,:) = dim_stddev_n_Wrap(snow_jja, 0)
      ; snow_std = dtrend_n(snow_std, False, 1)
        copy_VarCoords(snow_mam(0,:,:), snow_std(0,:,:))
        copy_VarCoords(snow_mam(0,:,:), snow_std(1,:,:))
        copy_VarCoords(snow_mam(0,:,:), snow_std(2,:,:))
        copy_VarCoords(snow_mam(0,:,:), snow_std(3,:,:))
;*************************************************
;Regression, Correlation
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
   resmap@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)

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
   resrc@gsnAddCyclic = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMaxLevelValF = 0.08
   resrc@cnMinLevelValF = -0.08
   resrc@cnLevelSpacingF = 0.02
   resrc@trGridType = "TriangularMesh"
   ;resrc@gsnPolar = "NH"
   ;resrc@mpMinLatF = 35
   ;resrc@cnFillMode = "RasterFill"

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

   resP = True
   resP@gsnMaximize = False
   resP@gsnPanelLabelBar = True
   resP@lbOrientation = "Vertical"
   resP@gsnPanelFigureStringsFontHeightF = 0.012
   resP@gsnPanelFigureStringsPerimOn = False
   resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   resP@amJust = "TopLeft"
   ; resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   ; resP@amParallelPosF = -0.50    ;X-axis

   resrc@cnMaxLevelValF = 80.0
   resrc@cnMinLevelValF = 0.0
   resrc@cnLevelSpacingF = 2.0
   resrc@gsnLeftString = " "

   plots = new(4, graphic)

   resP@gsnPanelFigureStrings = (/"SON","DJF","MAM","JJA"/)
   do i = 0,3
     plots(i) = gsn_csm_contour_map(wks, snow_avg(i,:,:), resrc)
   end do
   gsn_panel(wks, plots, (/4,1/), resP)

   resrc@cnMaxLevelValF = 30.0
   resrc@cnMinLevelValF = 0.0
   resrc@cnLevelSpacingF = 1.0
   resP@gsnPanelFigureStrings = (/"SON","DJF","MAM","JJA"/)
   do i = 0,3
     plots(i) = gsn_csm_contour_map(wks, snow_std(i,:,:), resrc)
   end do
   gsn_panel(wks, plots, (/4,1/), resP)

end