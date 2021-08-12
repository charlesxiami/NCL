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

   sig = 0.285   ;95%, 48yeras
   ; sig1 = 0.497
   ; sig2 = 0.433
;*****************************************************
;I/O
;*****************************************************
   wks=gsn_open_wks("pdf", plotpath+"snow_rutger_2x2")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")

   snow_file = addfile(snowpath+"snow.rutger.2.0deg.neareststod.nc", "r")
   snow_file2 = addfile(snowpath+"RutgersSnow.mon.mean.nc", "r")
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

   YYYYMM3 = cd_calendar(sstdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt)
   iLast3  = ind(YYYYMM3.eq.yrlast)
   print(YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))

   snow_mon = snow_file->snowcover(iStrt:iLast,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   snow_mon2 = snow_file2->snowcover(iStrt:iLast,:,:) ; Original Rutger SCE
   snow_mon2@_FillValue = toshort(snow_mon2@missing_value)
   snow_mam2 = month_to_season(snow_mon2, "MAM")

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

   sst_mon = sstdata->sst(iStrt3:iLast3,{latS:latN},{lonL:lonR})
   sst_mam = month_to_season(sst_mon, "MAM")

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

   ;Time Series plot
   rts           = True
   rts@gsnMaximize = False
   rts@gsnDraw     = False
   rts@gsnFrame    = False
   rts@gsnScale  = False        ; force text scaling               
   rts@vpHeightF = 0.2        ; Changes the aspect ratio
   rts@vpWidthF  = 0.8
   rts@vpXF      = 0.10        ; change start locations
   rts@vpYF      = 0.75        ; the plot
   rts@gsnYRefLineDashPattern = 2
   rts@gsnXYBarChart         = True
   rts@gsnYRefLine           = 0.          
   rts@gsnAboveYRefLineColor = "red"       
   rts@gsnBelowYRefLineColor = "blue"   
   rts@gsnLeftStringFontHeightF = 0.03
   rts@trYMinF = -4.5
   rts@trYMaxF = 4.5

   rts@tmYUseLeft           = False   ; Make right axis independent of left
   rts@tmYLOn               = False   ; Turn off left tickmarks
   rts@tmYROn               = True    ; Turn on right tickmarks
   rts@tmXTOn               = False   ; Turn off top tickmarks
   rts@tmYLLabelsOn         = False   ; Turn off left labels
   rts@tmYRLabelsOn         = True    ; Turn on right labels
   rts@tmYRMinorOn          = False   ; Turn off minor ticks on Y axis
   rts@tmYRLabelFontHeightF = 0.015   ; Increase font height
   rts@tmYLLabelFontHeightF = 0.015
   rts@tmYRLabelDeltaF      = 2.0     ; Increase space b/w ticks and labels
   rts@tmYRLabelJust        = "CenterRight"   ; right-justify labels

   rts@xyLineThicknessF     = 1.0   ; Twice as thick
   rts@tiYAxisFontHeightF = 0.03

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
   resrc@mpCenterLonF = 90.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMinLatF = 20.
   resrc@mpMaxLatF = 80.
   resrc@cnLevelSelectionMode = "ManualLevels"
   ; resrc@cnMinLevelValF = 0
   ; resrc@cnMaxLevelValF = 100
   ; resrc@cnLevelSpacingF = 1

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
   resPolar@mpMinLatF = 20.
   resPolar@cnFillOn = True
   resPolar@cnLinesOn = False
   resPolar@lbLabelBarOn = False
   resPolar@gsnLeftString = " "
   resPolar@cnLevelSelectionMode = "ManualLevels"

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
   snow_mam_wgt= SqrtCosWeight(snow_mam)
   Wregion=snow_mam_wgt(:,{WlatS:WlatN},{WlonL:WlonR})
   Eregion=snow_mam_wgt(:,{ElatS:ElatN},{ElonL:ElonR})
   SCAW = wgt_areaave_Wrap(Wregion, 1.0, 1.0, 1)
   SCAE = wgt_areaave_Wrap(Eregion, 1.0, 1.0, 1)
   SCAW = dim_standardize_Wrap(SCAW, 0)
   SCAE = dim_standardize_Wrap(SCAE, 0)

   ;snow_mon = SqrtCosWeight(snow_mon)
   printVarSummary(snow_mon)
   snow_march = snow_mon(2:575:12,:,:)
   snow_april = snow_mon(3:575:12,:,:)
   snow_may   = snow_mon(4:575:12,:,:)

   dim_snow = dimsizes(snow_march)
   snow_345 = new((/3,dim_snow(0),dim_snow(1),dim_snow(2)/), "float")
   snow_345(0,:,:,:) = snow_march
   snow_345(1,:,:,:) = snow_april
   snow_345(2,:,:,:) = snow_may

   snow_23456 = new((/6,dim_snow(0),dim_snow(1),dim_snow(2)/), "float")
   snow_23456(0,:,:,:) = snow_mon(1:dim_snow(0)*12-1:12,:,:)   ;Feb
   snow_23456(1,:,:,:) = snow_mon(2:dim_snow(0)*12-1:12,:,:)
   snow_23456(2,:,:,:) = snow_mon(3:dim_snow(0)*12-1:12,:,:)
   snow_23456(3,:,:,:) = snow_mon(4:dim_snow(0)*12-1:12,:,:)
   snow_23456(4,:,:,:) = snow_mon(5:dim_snow(0)*12-1:12,:,:)   
   snow_23456(5,:,:,:) = snow_mon(6:dim_snow(0)*12-1:12,:,:)   ;July

   dim_ncep = dimsizes(air_mam)
   sat_345 = new((/3,dim_ncep(0),dim_ncep(1),dim_ncep(2)/), "float")
   sat_345(0,:,:,:) = air_mon(2:dim_ncep(0)*12-1:12,:,:)
   sat_345(1,:,:,:) = air_mon(3:dim_ncep(0)*12-1:12,:,:)
   sat_345(2,:,:,:) = air_mon(4:dim_ncep(0)*12-1:12,:,:)

   z850_345 = new((/3,dim_ncep(0),dim_ncep(1),dim_ncep(2)/), "float")
   z850_345(0,:,:,:) = z850_mon(2:dim_ncep(0)*12-1:12,:,:)
   z850_345(1,:,:,:) = z850_mon(3:dim_ncep(0)*12-1:12,:,:)
   z850_345(2,:,:,:) = z850_mon(4:dim_ncep(0)*12-1:12,:,:)

   z200_345 = new((/3,dim_ncep(0),dim_ncep(1),dim_ncep(2)/), "float")
   z200_345(0,:,:,:) = z200_mon(2:dim_ncep(0)*12-1:12,:,:)
   z200_345(1,:,:,:) = z200_mon(3:dim_ncep(0)*12-1:12,:,:)
   z200_345(2,:,:,:) = z200_mon(4:dim_ncep(0)*12-1:12,:,:)

   u850_345 = new((/3,dim_ncep(0),dim_ncep(1),dim_ncep(2)/), "float")
   u850_345(0,:,:,:) = u_mon(2:dim_ncep(0)*12-1:12,:,:)
   u850_345(1,:,:,:) = u_mon(3:dim_ncep(0)*12-1:12,:,:)
   u850_345(2,:,:,:) = u_mon(4:dim_ncep(0)*12-1:12,:,:)

   v850_345 = new((/3,dim_ncep(0),dim_ncep(1),dim_ncep(2)/), "float")
   v850_345(0,:,:,:) = v_mon(2:dim_ncep(0)*12-1:12,:,:)
   v850_345(1,:,:,:) = v_mon(3:dim_ncep(0)*12-1:12,:,:)
   v850_345(2,:,:,:) = v_mon(4:dim_ncep(0)*12-1:12,:,:)

   dim_sst = dimsizes(sst_mam)
   sst_345 = new((/3,dim_sst(0),dim_sst(1),dim_sst(2)/), "float")
   sst_345(0,:,:,:) = sst_mon(2:dim_sst(0)*12-1:12,:,:)
   sst_345(1,:,:,:) = sst_mon(3:dim_sst(0)*12-1:12,:,:)
   sst_345(2,:,:,:) = sst_mon(4:dim_sst(0)*12-1:12,:,:)

   ;each month of MAM
   wregion_march = snow_march(:,{WlatS:WlatN},{WlonL:WlonR})
   wregion_april = snow_april(:,{WlatS:WlatN},{WlonL:WlonR})
   wregion_may   = snow_may(:,{WlatS:WlatN},{WlonL:WlonR})
   eregion_march = snow_march(:,{ElatS:ElatN},{ElonL:ElonR})
   eregion_april = snow_april(:,{ElatS:ElatN},{ElonL:ElonR})
   eregion_may   = snow_may(:,{ElatS:ElatN},{ElonL:ElonR})

   SCAW_march = wgt_areaave_Wrap(wregion_march, 1.0, 1.0, 1)
   SCAW_april = wgt_areaave_Wrap(wregion_april, 1.0, 1.0, 1)
   SCAW_may   = wgt_areaave_Wrap(wregion_may, 1.0, 1.0, 1)
   SCAW_march  = -1*dim_standardize_Wrap(SCAW_march,0)
   SCAW_april  = -1*dim_standardize_Wrap(SCAW_april ,0)
   SCAW_may    = -1*dim_standardize_Wrap(SCAW_may ,0)

   SCAE_march = wgt_areaave_Wrap(eregion_march, 1.0, 1.0, 1)
   SCAE_april = wgt_areaave_Wrap(eregion_april, 1.0, 1.0, 1)
   SCAE_may   = wgt_areaave_Wrap(eregion_may, 1.0, 1.0, 1)
   SCAE_march  = -1*dim_standardize_Wrap(SCAE_march,0)
   SCAE_april  = -1*dim_standardize_Wrap(SCAE_april ,0)
   SCAE_may    = -1*dim_standardize_Wrap(SCAE_may ,0)

 ;**********************************************************
   rts_mtt = True
   rts_mtt@gsnDraw     = False
   rts_mtt@gsnFrame    = False
   rts_mtt@vpHeightF = 0.2
   rts_mtt@vpWidthF  = 0.8
   rts_mtt@vpXF      = 0.10
   rts_mtt@vpYF      = 0.75
   rts_mtt@trYMinF = 0.0
   rts_mtt@trYMaxF = 1.0
   rts_mtt@tmYRLabelFontHeightF = 0.015
   rts_mtt@tmYLLabelFontHeightF = 0.015

   x = ispan(yrstrt/100, yrlast/100, 1)

   rts@tiYAxisString = "MAM"
   w0 = gsn_csm_xy(wks, x,SCAW, rts)

   rts@tiYAxisString = "March"
   w1 = gsn_csm_xy(wks, x,SCAW_march, rts)

   rts@tiYAxisString = "April"
   w2 = gsn_csm_xy(wks, x,SCAW_april, rts)

   rts@tiYAxisString = "May"
   w3 = gsn_csm_xy(wks, x,SCAW_may, rts)

   rts1 = True
   rts2 = True
   rts1@gsnMaximize = False
   rts2@gsnAttachPlotsXAxis = True

   wplot = gsn_attach_plots(w0, (/w1,w2,w3/), rts1, rts2)   
   draw(w0)
   frame(wks)


   rts@tiYAxisString = "MAM"
   w00 = gsn_csm_xy(wks, x,SCAE, rts)

   rts@tiYAxisString = "March"
   w11 = gsn_csm_xy(wks, x, SCAE_march, rts)

   rts@tiYAxisString = "April"
   w22 = gsn_csm_xy(wks, x, SCAE_april, rts)

   rts@tiYAxisString = "May"
   w33 = gsn_csm_xy(wks, x, SCAE_may, rts)

   eplot = gsn_attach_plots(w00, (/w11,w22,w33/), rts1, rts2)   
   draw(w00)
   frame(wks)

   rts@tiYAxisString = " "

   sceI = new((/6,48/), "float")
   sceI(0,:) = SCAW_march
   sceI(2,:) = SCAW_april
   sceI(4,:) = SCAW_may
   sceI(1,:) = SCAE_march
   sceI(3,:) = SCAE_april
   sceI(5,:) = SCAE_may

   sceI = -1*sceI

   sciW = new((/3,48/), "float")
   sciW(0,:) = SCAW_march
   sciW(1,:) = SCAW_april
   sciW(2,:) = SCAW_may

   sciE = new((/3,48/), "float")
   sciE(0,:) = SCAE_march
   sciE(1,:) = SCAE_april
   sciE(2,:) = SCAE_may

   rtsP = True
   rtsP@lbLabelAutoStride = True 
   rtsP@gsnAttachBorderOn = False
   rtsP@tmXBLabelFontHeightF = 0.02
;*************************************************
;Moving T test
;*************************************************
   t_dim = dimsizes(sceI)
   wSize = 5
   n = t_dim(1)
   sceI_mtt = new((/6, n-(2*wSize-1)/), "float")
   
   ; do i = 0, 5
   ;    sceI_mtt(i,:) = moving_ttest(sceI(i,:), SCAW_may&time, wSize)
   ; end do
   ; printVarSummary(sceI_mtt)

   ; plot_mtt = new(6, "graphic")
   ; rtsP@gsnPanelMainString = wSize+"-Years  Moving T-test "
   ; do i = 0, 5
   ;    plot_mtt(i) = gsn_csm_xy(wks, sceI_mtt&time, sceI_mtt(i,:), rts_mtt)
   ; end do
   ; gsn_panel(wks, plot_mtt, (/3,2/), rtsP)
   ; delete(rtsP@gsnPanelMainString)

   ; print(SCAE_may)
   ; scae_may_mtt = moving_ttest(SCAE_may, SCAE_may&time, 5)
   ; printVarSummary(scae_may_mtt)
;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 7
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    pc1 = wgt_runave_Wrap(pc1_all, wgt, 0)
    ;snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
    sceI = wgt_runave_Wrap(sceI, wgt, 0)
    sciW = wgt_runave_Wrap(sciW, wgt, 0)
    sciE = wgt_runave_Wrap(sciE, wgt, 0)

    SCAE_march = wgt_runave_Wrap(SCAE_march, wgt, 0)
    SCAE_april = wgt_runave_Wrap(SCAE_april, wgt, 0)
    SCAE_may = wgt_runave_Wrap(SCAE_may, wgt, 0)

    sst_345 = wgt_runave_n_Wrap(sst_345, wgt, 0, 1)
;*************************************************
   plots = new(6, "graphic")
   do i = 0, 5
     plots(i) = gsn_csm_xy(wks, x, sceI(i,:), rts)
   end do
   gsn_panel(wks, plots, (/3,2/), rtsP)

;*************************************************
;Regression, Correlation
;*************************************************
   ; sat_rc = new((/6,d1,d2/), "float")
   ; sat_cor = new((/6,d1,d2/), "float")
   ; z850_rc = new((/6,d1,d2/), "float")
   ; z850_cor = new((/6,d1,d2/), "float")
   ; printVarSummary(z850_rc)

   ; snow_rc = new((/6,45,180/), "float")
   ; snow_cor = new((/6,45,180/), "float")

    sat_rc  = regCoef(sceI,air_mam(lat|:,lon|:,time|:))
    z850_rc = regCoef(sceI,z850_mam(lat|:,lon|:,time|:))
    snow_rc = regCoef(sceI,snow_mam(lat|:,lon|:,time|:))
    sat_cor  = escorc(sceI,air_mam(lat|:,lon|:,time|:))
    z850_cor = escorc(sceI,z850_mam(lat|:,lon|:,time|:))
    snow_cor = escorc(sceI,snow_mam(lat|:,lon|:,time|:))

    plotsat_rc = new(6, "graphic")
    plotsat_cor = new(6, "graphic")
    plotsnow_rc = new(6, "graphic")
    plotsnow_cor = new(6, "graphic")

   do i = 0, 5
      copy_VarCoords(air_mam(0,:,:), sat_rc(i,:,:))
      copy_VarCoords(z850_mam(0,:,:), z850_rc(i,:,:))
      copy_VarCoords(snow_mam(0,:,:), snow_rc(i,:,:))

      copy_VarCoords(air_mam(0,:,:), sat_cor(i,:,:))
      copy_VarCoords(z850_mam(0,:,:), z850_cor(i,:,:))
      copy_VarCoords(snow_mam(0,:,:), snow_cor(i,:,:))

      plotsat_rc(i) = gsn_csm_contour_map(wks, sat_rc(i,:,:), resrc)
      plotsat_cor(i) = gsn_csm_contour(wks, sat_cor(i,:,:), rescor)
      overlay(plotsat_rc(i), plotsat_cor(i))

      plotsnow_rc(i) = gsn_csm_contour_map(wks, snow_rc(i,:,:), resrc)
      plotsnow_cor(i) = gsn_csm_contour(wks, snow_cor(i,:,:), rescor)
      overlay(plotsnow_rc(i), plotsnow_cor(i))
   end do
   
   gsn_panel(wks, plotsat_rc, (/3,2/), resP)
   gsn_panel(wks, plotsnow_rc, (/3,2/), resP)

   ; plot_mam = new(12*12, "graphic")
   ; do i = 0, 12*12-1
   ;    plot_mam(i) = gsn_csm_contour_map_polar(wks, snow_mon(i+0*12,:,:), resPolar)
   ; end do
   ; resP@gsnPanelMainString = "Regridded SCE"
   ; gsn_panel(wks, plot_mam, (/12,12/), resP)

   ; lat2d = snow_file2->lat  
   ; lon2d = snow_file2->lon

   ; resPolar@sfXArray = lon2d
   ; resPolar@sfYArray = lat2d
   ; resPolar@gsnAddCyclic = False
   ; resPolar@trGridType = "TriangularMesh"
   ; resPolar@cnFillMode = "RasterFill"
   ; plot_mam2 = new(12*12, "graphic")
   ; do i = 0, 12*12-1
   ;    plot_mam2(i) = gsn_csm_contour_map_polar(wks, snow_mon2(i+0*12,:,:), resPolar)
   ; end do
   ; resP@gsnPanelMainString = "Original SCE"
   ; gsn_panel(wks, plot_mam2, (/12,12/), resP)

   Eplot_345_rc = new(9, "graphic" )
   Eplot_345_cor = new(9, "graphic" )

   ;Snow
   E_snow_rc345  = regCoef_n(sciE, snow_345, 1, 1)
   E_snow_cor345 = escorc_n(sciE, snow_345, 1, 1)
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(snow_345(0,0,:,:), E_snow_rc345(i,j,:,:))
         copy_VarCoords(snow_345(0,0,:,:), E_snow_cor345(i,j,:,:))

         Eplot_345_rc(k) = gsn_csm_contour_map(wks, E_snow_rc345(i,j,:,:), ressnow)
         Eplot_345_cor(k) = gsn_csm_contour(wks, E_snow_cor345(i,j,:,:), rescor)
         overlay(Eplot_345_rc(k), Eplot_345_cor(k))
         k=k+1
      end do
   end do
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly SCE"
   gsn_panel(wks, Eplot_345_rc, (/3,3/), resP)

   ;SAT
   E_sat_rc345 = regCoef_n(sciE, sat_345, 1, 1)
   E_sat_cor345 = escorc_n(sciE, sat_345, 1, 1)

   Eplot_345_vc = new(9, "graphic" )
   E_u850_rc345 = regCoef_n(sciE, u850_345, 1, 1)
   E_u850_cor345 = escorc_n(sciE, u850_345, 1, 1)
   E_v850_rc345 = regCoef_n(sciE, v850_345, 1, 1)
   E_v850_cor345 = escorc_n(sciE, v850_345, 1, 1)
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(sat_345(0,0,:,:), E_sat_rc345(i,j,:,:))
         copy_VarCoords(sat_345(0,0,:,:), E_sat_cor345(i,j,:,:))

         copy_VarCoords(u850_345(0,0,:,:), E_u850_rc345(i,j,:,:))
         copy_VarCoords(u850_345(0,0,:,:), E_u850_cor345(i,j,:,:))         
         copy_VarCoords(u850_345(0,0,:,:), E_v850_rc345(i,j,:,:))
         copy_VarCoords(u850_345(0,0,:,:), E_v850_cor345(i,j,:,:))

         Eplot_345_rc(k) = gsn_csm_contour_map(wks, E_sat_rc345(i,j,:,:), ressat)
         Eplot_345_cor(k) = gsn_csm_contour(wks, E_sat_cor345(i,j,:,:), rescor)
         Eplot_345_vc(k) = gsn_csm_vector(wks, E_u850_rc345(i,j,:,:), E_v850_rc345(i,j,:,:), resV)
         overlay(Eplot_345_rc(k), Eplot_345_vc(k))
         overlay(Eplot_345_rc(k), Eplot_345_cor(k))
         k=k+1
      end do
   end do
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly SAT "
   gsn_panel(wks, Eplot_345_rc, (/3,3/), resP)

   ;Z
   resZ@cnMinLevelValF = -40.
   resZ@cnMaxLevelValF = 40.
   resZ@cnLevelSpacingF = 2.
   E_z850_rc345 = regCoef_n(sciE, z850_345, 1, 1)
   E_z850_cor345 = escorc_n(sciE, z850_345, 1, 1)
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(z850_345(0,0,:,:), E_z850_rc345(i,j,:,:))
         copy_VarCoords(z850_345(0,0,:,:), E_z850_cor345(i,j,:,:))

         Eplot_345_rc(k) = gsn_csm_contour_map(wks, E_z850_rc345(i,j,:,:), resZ)
         Eplot_345_cor(k) = gsn_csm_contour(wks, E_z850_cor345(i,j,:,:), rescor)
         overlay(Eplot_345_rc(k), Eplot_345_cor(k))
         k=k+1
      end do
   end do
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly Z850 "
   gsn_panel(wks, Eplot_345_rc, (/3,3/), resP)


   ; resZ@cnMinLevelValF = -60.
   ; resZ@cnMaxLevelValF = 60.
   ; resZ@cnLevelSpacingF = 2.
   E_z200_rc345 = regCoef_n(sciE, z200_345, 1, 1)
   E_z200_cor345 = escorc_n(sciE, z200_345, 1, 1)
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(z200_345(0,0,:,:), E_z200_rc345(i,j,:,:))
         copy_VarCoords(z200_345(0,0,:,:), E_z200_cor345(i,j,:,:))

         Eplot_345_rc(k) = gsn_csm_contour_map(wks, E_z200_rc345(i,j,:,:), resZ)
         Eplot_345_cor(k) = gsn_csm_contour(wks, E_z200_cor345(i,j,:,:), rescor)
         overlay(Eplot_345_rc(k), Eplot_345_cor(k))
         k=k+1
      end do
   end do
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly Z200 "
   gsn_panel(wks, Eplot_345_rc, (/3,3/), resP)


   E_sst_rc345 = regCoef_n(sciE, sst_345, 1, 1)
   E_sst_cor345 = escorc_n(sciE, sst_345, 1, 1)
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(sst_345(0,0,:,:), E_sst_rc345(i,j,:,:))
         copy_VarCoords(sst_345(0,0,:,:), E_sst_cor345(i,j,:,:))

         Eplot_345_rc(k) = gsn_csm_contour_map(wks, E_sst_rc345(i,j,:,:), resSST)
         Eplot_345_cor(k) = gsn_csm_contour(wks, E_sst_cor345(i,j,:,:), rescor)
         overlay(Eplot_345_rc(k), Eplot_345_cor(k))
         k=k+1
      end do
   end do
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly SST "
   gsn_panel(wks, Eplot_345_rc, (/3,3/), resP)

   
   Eplot_23456_rc = new(6, "graphic" )
   Eplot_23456_cor = new(6, "graphic")

   E_snow_rc23456  = regCoef_n(SCAE_april, snow_23456, 0, 1)
   E_snow_cor23456 = escorc_n(SCAE_april, snow_23456, 0, 1)
   printVarSummary(E_snow_cor23456)
   k = 0
   do i = 0, 5
         copy_VarCoords(snow_23456(0,0,:,:), E_snow_rc23456(i,:,:))
         copy_VarCoords(snow_23456(0,0,:,:), E_snow_cor23456(i,:,:))

         Eplot_23456_rc(k) = gsn_csm_contour_map(wks, E_snow_rc23456(i,:,:), ressnow)
         Eplot_23456_cor(k) = gsn_csm_contour(wks, E_snow_cor23456(i,:,:), rescor)
         overlay(Eplot_23456_rc(k), Eplot_23456_cor(k))
         k=k+1
   end do
   resP@gsnPanelMainString = "SCAE(April) Lead-lag Reg monthly SCE"
   resP@gsnPanelFigureStrings = (/"Feb","Mar","April","May","Jun","July"/)
   gsn_panel(wks, Eplot_23456_rc, (/3,3/), resP)

   E_snow_rc23456  := regCoef_n(SCAE_may, snow_23456, 0, 1)
   E_snow_cor23456 := escorc_n(SCAE_may, snow_23456, 0, 1)
   printVarSummary(E_snow_cor23456)
   k = 0
   do i = 0, 5
         copy_VarCoords(snow_23456(0,0,:,:), E_snow_rc23456(i,:,:))
         copy_VarCoords(snow_23456(0,0,:,:), E_snow_cor23456(i,:,:))

         Eplot_23456_rc(k) = gsn_csm_contour_map(wks, E_snow_rc23456(i,:,:), ressnow)
         Eplot_23456_cor(k) = gsn_csm_contour(wks, E_snow_cor23456(i,:,:), rescor)
         overlay(Eplot_23456_rc(k), Eplot_23456_cor(k))
         k=k+1
   end do
   resP@gsnPanelMainString = "SCAE(May) Lead-lag Reg monthly SCE"
   gsn_panel(wks, Eplot_23456_rc, (/3,3/), resP)

;-----------------------------------------------------------------------------
;Polar 
   delete(resP@gsnPanelFigureStrings)
   ;Z
   resPolar@cnMinLevelValF = -30.
   resPolar@cnMaxLevelValF = 30.
   resPolar@cnLevelSpacingF = 2.
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(z850_345(0,0,:,:), E_z850_rc345(i,j,:,:))
         copy_VarCoords(z850_345(0,0,:,:), E_z850_cor345(i,j,:,:))

         Eplot_345_rc(k) = gsn_csm_contour_map(wks, E_z850_rc345(i,j,:,:), resPolar)
         Eplot_345_cor(k) = gsn_csm_contour(wks, E_z850_cor345(i,j,:,:), rescor)
         overlay(Eplot_345_rc(k), Eplot_345_cor(k))
         k=k+1
      end do
   end do
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly Z850 "
   gsn_panel(wks, Eplot_345_rc, (/3,3/), resP)


   resPolar@cnMinLevelValF = -40.
   resPolar@cnMaxLevelValF = 40.
   resPolar@cnLevelSpacingF = 2.
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(z200_345(0,0,:,:), E_z200_rc345(i,j,:,:))
         copy_VarCoords(z200_345(0,0,:,:), E_z200_cor345(i,j,:,:))

         Eplot_345_rc(k) = gsn_csm_contour_map(wks, E_z200_rc345(i,j,:,:), resPolar)
         Eplot_345_cor(k) = gsn_csm_contour(wks, E_z200_cor345(i,j,:,:), rescor)
         overlay(Eplot_345_rc(k), Eplot_345_cor(k))
         k=k+1
      end do
   end do
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly Z200 "
   gsn_panel(wks, Eplot_345_rc, (/3,3/), resP)

;--------------------------------------------------------------------
   plot_scecor_fill = new(4, "graphic")
   plot_sce_cor = new(4, "graphic")
   resrc@cnMinLevelValF = -1.0
   resrc@cnMaxLevelValF = 1.0
   resrc@cnLevelSpacingF = 0.01
   resrc@mpMaxLonF = 160.
   sce_cor_2mon = new((/4,dim_snow(1),dim_snow(2)/), "float")

   do i = 0, 3
      sce_cor_2mon(i,:,:) = escorc_n(snow_23456(i,:,:,:), snow_23456(i+1,:,:,:), 0, 0)
      copy_VarCoords(snow_mon(0,:,:), sce_cor_2mon(i,:,:))

      plot_scecor_fill(i) = gsn_csm_contour_map(wks, sce_cor_2mon(i,:,:), resrc)
      plot_sce_cor(i) = gsn_csm_contour(wks, sce_cor_2mon(i,:,:), rescor)
      overlay(plot_scecor_fill(i), plot_sce_cor(i))
   end do
   resP@gsnPanelMainString = "SCE Correlation between each 2 adjacent-month"
   resP@gsnPanelFigureStrings = (/"Feb-Mar","Mar-April","April-May","May-Jun"/)
   gsn_panel(wks, plot_scecor_fill, (/3,2/), resP)
   delete(resP@gsnPanelFigureStrings)

   do i = 0, 2
      sce_cor_2mon(i,:,:) = escorc_n(snow_23456(i,:,:,:), snow_23456(i+2,:,:,:), 0, 0)
      copy_VarCoords(snow_mon(0,:,:), sce_cor_2mon(i,:,:))

      plot_scecor_fill(i) = gsn_csm_contour_map(wks, sce_cor_2mon(i,:,:), resrc)
      plot_sce_cor(i) = gsn_csm_contour(wks, sce_cor_2mon(i,:,:), rescor)
      overlay(plot_scecor_fill(i), plot_sce_cor(i))
   end do
   resP@gsnPanelMainString = "SCE Correlation between each 2 gap-month"
   resP@gsnPanelFigureStrings = (/"Feb-April","Mar-May","April-Jun"/)
   gsn_panel(wks, plot_scecor_fill, (/1,3/), resP)
   ;delete(resP@gsnPanelFigureStrings)

;---------------------------------------------------------------
;climatic condition
   ressnow@cnFillPalette = "WhiteBlueGreenYellowRed"

   plotsnowclim = new(5, "graphic")
   snow_23456_clim = dim_avg_n_Wrap(snow_23456, 1)
   ressnow@cnMinLevelValF = 0
   ressnow@cnMaxLevelValF = 100
   do i = 0, 4
      plotsnowclim(i) = gsn_csm_contour_map(wks, snow_23456_clim(i,:,:), ressnow)
   end do
   resP@gsnPanelMainString = "SCE Monthly Clim-avg Feb-June"
   resP@gsnPanelFigureStrings := (/"Feb","March","April","May","Jun"/)
   gsn_panel(wks, plotsnowclim, (/2,3/), resP)
   ;delete(resP@gsnPanelFigureStrings)
   printMinMax(snow_23456_clim, 0)

   snow_23456_std = dim_stddev_n_Wrap(snow_23456, 1)
   ressnow@cnMinLevelValF = 0
   ressnow@cnMaxLevelValF = 40
   do i = 0, 4
      plotsnowclim(i) = gsn_csm_contour_map(wks, snow_23456_std(i,:,:), ressnow)
   end do
   resP@gsnPanelMainString = "SCE Monthly Std-dev Feb-June"
   resP@gsnPanelFigureStrings := (/"Feb","March","April","May","Jun"/)
   gsn_panel(wks, plotsnowclim, (/2,3/), resP)
   printMinMax(snow_23456_std, 0)


end