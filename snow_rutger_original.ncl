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
   wks=gsn_open_wks("pdf", plotpath+"snow.rutger.89x89")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")

   snow_file = addfile(snowpath+"RutgersSnow.mon.mean.nc", "r")
   ;snow_file2 = addfile(snowpath+"RutgersSnow.mon.mean.nc", "r")
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
   resrc@mpCenterLonF = 180.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMinLatF = 0.
   resrc@mpMaxLatF = 90.
   resrc@cnLevelSelectionMode = "ManualLevels"

   ressat = resrc
   ressat@cnMinLevelValF = -1.8
   ressat@cnMaxLevelValF = 1.8
   ressat@cnLevelSpacingF = 0.1
   ;ressat@gsnRightString = "degC"

   resZ = resrc
   resZ@cnMinLevelValF = -40
   resZ@cnMaxLevelValF = 40
   resZ@cnLevelSpacingF = 2

   ressnow = resrc
   ;ressnow@cnFillMode = "RasterFill"
   ressnow@trGridType = "TriangularMesh"
   ressnow@cnMinLevelValF = -20
   ressnow@cnMaxLevelValF = 20
   ressnow@cnLevelSpacingF = 1
   ;ressnow@gsnRightString = "%"
   ressnow@mpMinLonF = 20.
   ressnow@mpMaxLonF = 160.
   ressnow@mpMinLatF = 20.
   ressnow@mpMaxLatF = 80.

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
   resPolar@cnLevelSelectionMode = "AutomaticLevels"
   resPolar@cnMaxLevelValF = 100.
   resPolar@cnMinLevelValF = 0.
   resPolar@cnLevelSpacingF = 10.
   ; resPolar@sfXArray = lon2d
   ; resPolar@sfYArray = lat2d
   resPolar@gsnAddCyclic = False
   resPolar@trGridType = "TriangularMesh"
   resPolar@cnFillMode = "RasterFill"

   resP = True
   resP@gsnMaximize = False
   resP@gsnPanelLabelBar = True
   ;resP@lblabel
   ;resP@gsnPanelFigureStrings = (/"a)","b)","c)","d)","e)","f)"/)
   resP@gsnPanelFigureStringsFontHeightF = 0.012
   resP@gsnPanelFigureStringsPerimOn = False
   resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   resP@amJust = "TopLeft"
   resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   resP@amParallelPosF = -0.50    ;X-axis
   resP@lbAutoManage = False
   resP@pmLabelBarWidthF = 0.5
   resP@pmLabelBarHeightF = 0.05
   resP@lbLabelFontHeightF = 0.012
   resP@lbTitleOn = False
   resP@lbTitlePosition = "Right"
   resP@lbTitleFontHeightF = 0.01
   resP@lbPerimOn = False

;************************************************
; Calculate 
;************************************************
   lat2d = snow_file->lat
   lon2d = snow_file->lon
   printMinMax(lat2d, 0)
   printMinMax(lon2d, 0)

 ;Cosine weighted
   dim3d = dimsizes(snow_mam)
   ; do k = 0, dim3d(0)-1
   ;    do i = 0, dim3d(2)-1
   ;       do j = 0, dim3d(1)-1
   ;          ; write loop content
   ;       end do
   ;    end do
   ; end do

   rad = get_d2r("float")
   clat = snow_file->lat
   clat = sqrt(cos(rad*clat))

   snow_mam_wgt = snow_mam
   snow_mam_wgt = snow_mam*conform(snow_mam, clat, (/1,2/))
   snow_mam_wgt@long_name = "Wgt: "+snow_mam_wgt@long_name

   snow_mon_wgt = snow_mon
   snow_mon_wgt = snow_mon*conform(snow_mon, clat, (/1,2/))
   snow_mon_wgt@long_name = "Wgt: "+snow_mon_wgt@long_name

   Elat = (/ElatS,ElatN/)
   Elon = (/ElonL,ElonR/)

   nm = getind_latlon2d(lat2d, lon2d, Elat, Elon)
  do k=0,dimsizes(Elat)-1
     n = nm(k,0)
     m = nm(k,1)
     print(lat2d(n,m)+"   "+lon2d(n,m))
  end do
   jStrtE = nm(0,0)
   jLastE = nm(1,0)
   iStrtE = nm(0,1)
   iLastE = nm(1,1)
   lat2d_E = lat2d(jStrtE:jLastE,iStrtE:iLastE)
   lon2d_E = lon2d(jStrtE:jLastE,iStrtE:iLastE)
   Eregion=snow_mam_wgt(:,jStrtE:jLastE,iStrtE:iLastE)
   printVarSummary(Eregion)

   delete(nm)
   Wlat = (/WlatS,WlatN/)
   Wlon = (/WlonL,WlonR/)
   nm = getind_latlon2d(lat2d, lon2d, Wlat, Wlon)
  do k=0,dimsizes(Wlat)-1
     n = nm(k,0)
     m = nm(k,1)
     print(lat2d(n,m)+"   "+lon2d(n,m))
  end do
   jStrtW = nm(0,0)
   jLastW = nm(1,0)
   iStrtW = nm(0,1)
   iLastW = nm(1,1)
   lat2d_W = lat2d(jStrtW:jLastW,iStrtW:iLastW)
   lon2d_W = lon2d(jStrtW:jLastW,iStrtW:iLastW)
   Wregion=snow_mam_wgt(:,jStrtW:jLastW,iStrtW:iLastW)
   printVarSummary(Wregion)
   ;Wregion=snow_mam_wgt(:,{WlatS:WlatN},{WlonL:WlonR})

   SCAW = wgt_areaave_Wrap(Wregion, 1.0, 1.0, 1)
   SCAE = wgt_areaave_Wrap(Eregion, 1.0, 1.0, 1)
   SCAW = dim_standardize_Wrap(SCAW, 0)
   SCAE = dim_standardize_Wrap(SCAE, 0)

   snow_march = snow_mon(2:575:12,:,:)
   snow_april = snow_mon(3:575:12,:,:)
   snow_may   = snow_mon(4:575:12,:,:)

   dsnow = dimsizes(snow_march)
   d0 = dsnow(0)
   d1 = dsnow(1)
   d2 = dsnow(2)

   snow_345 = new((/3,d0,d1,d2/), "float")
   snow_345(0,:,:,:) = snow_march
   snow_345(1,:,:,:) = snow_april
   snow_345(2,:,:,:) = snow_may
   printVarSummary(snow_345)

   sat_345 = new((/3,48,73,144/), "float")
   sat_345(0,:,:,:) = air_mon(2:575:12,:,:)
   sat_345(1,:,:,:) = air_mon(3:575:12,:,:)
   sat_345(2,:,:,:) = air_mon(4:575:12,:,:)

   z850_345 = new((/3,48,73,144/), "float")
   z850_345(0,:,:,:) = z850_mon(2:575:12,:,:)
   z850_345(1,:,:,:) = z850_mon(3:575:12,:,:)
   z850_345(2,:,:,:) = z850_mon(4:575:12,:,:)

   z200_345 = new((/3,48,73,144/), "float")
   z200_345(0,:,:,:) = z200_mon(2:575:12,:,:)
   z200_345(1,:,:,:) = z200_mon(3:575:12,:,:)
   z200_345(2,:,:,:) = z200_mon(4:575:12,:,:)

   ;Region of monthly MAM
   wregion_march = snow_march(:,jStrtW:jLastW,iStrtW:iLastW)
   wregion_april = snow_april(:,jStrtW:jLastW,iStrtW:iLastW)
   wregion_may   = snow_may  (:,jStrtW:jLastW,iStrtW:iLastW)
   eregion_march = snow_march(:,jStrtE:jLastE,iStrtE:iLastE)
   eregion_april = snow_april(:,jStrtE:jLastE,iStrtE:iLastE)
   eregion_may   = snow_may  (:,jStrtE:jLastE,iStrtE:iLastE)

   ;Snow index monthly
   SCAW_march = wgt_areaave_Wrap(wregion_march, 1.0, 1.0, 1)
   SCAW_april = wgt_areaave_Wrap(wregion_april, 1.0, 1.0, 1)
   SCAW_may   = wgt_areaave_Wrap(wregion_may, 1.0, 1.0, 1)
   SCAW_march  = dim_standardize_Wrap(SCAW_march,0)
   SCAW_april  = dim_standardize_Wrap(SCAW_april ,0)
   SCAW_may    = dim_standardize_Wrap(SCAW_may ,0)

   SCAE_march = wgt_areaave_Wrap(eregion_march, 1.0, 1.0, 1)
   SCAE_april = wgt_areaave_Wrap(eregion_april, 1.0, 1.0, 1)
   SCAE_may   = wgt_areaave_Wrap(eregion_may, 1.0, 1.0, 1)
   SCAE_march  = dim_standardize_Wrap(SCAE_march,0)
   SCAE_april  = dim_standardize_Wrap(SCAE_april ,0)
   SCAE_may    = dim_standardize_Wrap(SCAE_may ,0)

 ;**********************************************************
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
   rts@trYMinF = -2.0
   rts@trYMaxF = 3.0

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

   sciW = new((/3,48/), "float")
   sciW(0,:) = SCAW_march
   sciW(1,:) = SCAW_april
   sciW(2,:) = SCAW_may

   sciE = new((/3,48/), "float")
   sciE(0,:) = SCAE_march
   sciE(1,:) = SCAE_april
   sciE(2,:) = SCAE_may

   sciW = -1*sciW
   sciE = -1*sciE
   printVarSummary(sciW)
   
   rtsP = True
   rtsP@lbLabelAutoStride = True 
   resP@gsnAttachBorderOn = False

   rts@tmXBLabelFontHeightF = 0.02
;*************************************************
;Moving T test
;*************************************************
   t_dim = dimsizes(sciW)
   wSize = 5
   n = t_dim(1)
   sciW_mtt = new((/3, n-(2*wSize-1)/), "float")
   sciE_mtt = new((/3, n-(2*wSize-1)/), "float")
   
   ; do i = 0, 5
   ;    sciW_mtt(i,:) = moving_ttest(sciW(i,:), SCAW_may&time, wSize)
   ; end do
   ; printVarSummary(sciW_mtt)

   ; plot_mtt = new(6, "graphic")
   ; rtsP@gsnPanelMainString = wSize+"-Years  Moving T-test "
   ; do i = 0, 5
   ;    plot_mtt(i) = gsn_csm_xy(wks, sciW_mtt&time, sciW_mtt(i,:), rts_mtt)
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
    sciW = wgt_runave_Wrap(sciW, wgt, 0)
    sciE = wgt_runave_Wrap(sciE, wgt, 0)
;*************************************************
   plotsW = new(3, "graphic")
   plotsE = new(3, "graphic")
   ;rtsP@gsnPanelMainString = "Hihg-pass SCAW index"
   do i = 0, 2
     plotsW(i) = gsn_csm_xy(wks, x, sciW(i,:), rts)
     plotsE(i) = gsn_csm_xy(wks, x, sciE(i,:), rts)
   end do
   gsn_panel(wks, plotsW, (/3,1/), rtsP)
   gsn_panel(wks, plotsE, (/3,1/), rtsP)

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

    W_sat_rc  = regCoef(sciW,air_mam(lat|:,lon|:,time|:))
    W_sat_cor  = escorc(sciW,air_mam(lat|:,lon|:,time|:))
    W_z850_rc = regCoef(sciW,z850_mam(lat|:,lon|:,time|:))
    W_z850_cor = escorc(sciW,z850_mam(lat|:,lon|:,time|:))
    
    E_sat_rc  = regCoef(sciE,air_mam(lat|:,lon|:,time|:))
    E_sat_cor  = escorc(sciE,air_mam(lat|:,lon|:,time|:))
    E_z850_rc = regCoef(sciE,z850_mam(lat|:,lon|:,time|:))
    E_z850_cor = escorc(sciE,z850_mam(lat|:,lon|:,time|:))

    plotsat_rc_W = new(3, "graphic")
    plotsat_cor_W = new(3, "graphic")
    plotsnow_rc_W = new(3, "graphic")
    plotsnow_cor_W = new(3, "graphic")

     plotsat_rc_E = new(3, "graphic")
    plotsat_cor_E = new(3, "graphic")
    plotsnow_rc_E = new(3, "graphic")
   plotsnow_cor_E = new(3, "graphic") 

   do i = 0, 2
      copy_VarCoords(air_mam(0,:,:), W_sat_rc(i,:,:))
      copy_VarCoords(air_mam(0,:,:), W_sat_cor(i,:,:))
      copy_VarCoords(z850_mam(0,:,:), W_z850_rc(i,:,:))
      copy_VarCoords(z850_mam(0,:,:), W_z850_cor(i,:,:))
      plotsat_rc_W(i) = gsn_csm_contour_map(wks, W_sat_rc(i,:,:), ressat)
      plotsat_cor_W(i) = gsn_csm_contour(wks, W_sat_cor(i,:,:), rescor)
      overlay(plotsat_rc_W(i), plotsat_cor_W(i))

      copy_VarCoords(air_mam(0,:,:), E_sat_rc(i,:,:))
      copy_VarCoords(air_mam(0,:,:), E_sat_cor(i,:,:))
      copy_VarCoords(z850_mam(0,:,:), E_z850_rc(i,:,:))
      copy_VarCoords(z850_mam(0,:,:), E_z850_cor(i,:,:))
      plotsat_rc_E(i) = gsn_csm_contour_map(wks, E_sat_rc(i,:,:), ressat)
      plotsat_cor_E(i) = gsn_csm_contour(wks, E_sat_cor(i,:,:), rescor)
      overlay(plotsat_rc_E(i), plotsat_cor_E(i))      
   end do
   printVarSummary(W_sat_rc)

    W_snow_rc = regCoef(sciW,snow_mam(y|:,x|:,time|:))
    W_snow_cor = escorc(sciW,snow_mam(y|:,x|:,time|:))
    W_snow_rc@lat2d = snow_file->lat
    W_snow_rc@lon2d = snow_file->lon
    W_snow_cor@lat2d = snow_file->lat
    W_snow_cor@lon2d = snow_file->lon   

    E_snow_rc = regCoef(sciE,snow_mam(y|:,x|:,time|:))
    E_snow_cor = escorc(sciE,snow_mam(y|:,x|:,time|:))
      E_snow_rc@lat2d = snow_file->lat
      E_snow_rc@lon2d = snow_file->lon
      E_snow_cor@lat2d = snow_file->lat
      E_snow_cor@lon2d = snow_file->lon

   do i = 0, 2
      copy_VarCoords(snow_mam(0,:,:), W_snow_rc(i,:,:))
      copy_VarCoords(snow_mam(0,:,:), W_snow_cor(i,:,:))
 
      plotsnow_rc_W(i) = gsn_csm_contour_map(wks, W_snow_rc(i,:,:), ressnow)
      plotsnow_cor_W(i) = gsn_csm_contour(wks, W_snow_cor(i,:,:), rescor)
      overlay(plotsnow_rc_W(i), plotsnow_cor_W(i))

      copy_VarCoords(snow_mam(0,:,:), E_snow_rc(i,:,:))
      copy_VarCoords(snow_mam(0,:,:), E_snow_cor(i,:,:))

      plotsnow_rc_E(i) = gsn_csm_contour_map(wks, E_snow_rc(i,:,:), ressnow)
      plotsnow_cor_E(i) = gsn_csm_contour(wks, E_snow_cor(i,:,:), rescor)
      overlay(plotsnow_rc_E(i), plotsnow_cor_E(i))  
   end do
   ;printVarSummary(W_snow_rc)
   
   resP@lbTitleString = "degC"
   gsn_panel(wks, plotsat_rc_W, (/3,1/), resP)
   gsn_panel(wks, plotsat_rc_E, (/3,1/), resP)

   resP@lbTitleString = "%"
   gsn_panel(wks, plotsnow_rc_W, (/3,1/), resP)
   gsn_panel(wks, plotsnow_rc_E, (/3,1/), resP)

;--------------------------------------------------------------------------
;Lead and lag snow analysis
   E_snow_rc345 = regCoef_n(sciE, snow_345, 1, 1)
   E_snow_cor345 = escorc_n(sciE, snow_345, 1, 1)
   E_snow_rc345@lat2d = snow_file->lat
   E_snow_rc345@lon2d = snow_file->lon
   E_snow_cor345@lat2d = snow_file->lat
   E_snow_cor345@lon2d = snow_file->lon

   Eplot_rc345_345 = new(9, "graphic" )
   Eplot_cor345_345 = new(9, "graphic" )
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(snow_345(0,0,:,:), E_snow_rc345(i,j,:,:))
         copy_VarCoords(snow_345(0,0,:,:), E_snow_cor345(i,j,:,:))

         Eplot_rc345_345(k) = gsn_csm_contour_map(wks, E_snow_rc345(i,j,:,:), ressnow)
         Eplot_cor345_345(k) = gsn_csm_contour(wks, E_snow_cor345(i,j,:,:), rescor)
         overlay(Eplot_rc345_345(k), Eplot_cor345_345(k))
         k=k+1
      end do
   end do
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly SCE "
   ;resP@gsnRightString = "%"
   gsn_panel(wks, Eplot_rc345_345, (/3,3/), resP)


   E_sat_rc345 = regCoef_n(sciE, sat_345, 1, 1)
   E_sat_cor345 = escorc_n(sciE, sat_345, 1, 1)
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(sat_345(0,0,:,:), E_sat_rc345(i,j,:,:))
         copy_VarCoords(sat_345(0,0,:,:), E_sat_cor345(i,j,:,:))

         Eplot_rc345_345(k) = gsn_csm_contour_map(wks, E_sat_rc345(i,j,:,:), ressat)
         Eplot_cor345_345(k) = gsn_csm_contour(wks, E_sat_cor345(i,j,:,:), rescor)
         overlay(Eplot_rc345_345(k), Eplot_cor345_345(k))
         k=k+1
      end do
   end do
   print(k)
   printVarSummary(E_sat_rc345)
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly SAT "
   ;resP@gsnRightString = "degC"
   gsn_panel(wks, Eplot_rc345_345, (/3,3/), resP)


   E_z850_rc345 = regCoef_n(sciE, z850_345, 1, 1)
   E_z850_cor345 = escorc_n(sciE, z850_345, 1, 1)
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(z850_345(0,0,:,:), E_z850_rc345(i,j,:,:))
         copy_VarCoords(z850_345(0,0,:,:), E_z850_cor345(i,j,:,:))

         Eplot_rc345_345(k) = gsn_csm_contour_map(wks, E_z850_rc345(i,j,:,:), resZ)
         Eplot_cor345_345(k) = gsn_csm_contour(wks, E_z850_cor345(i,j,:,:), rescor)
         overlay(Eplot_rc345_345(k), Eplot_cor345_345(k))
         k=k+1
      end do
   end do
   print(k)
   printVarSummary(E_z850_rc345)
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly Z850 "
   gsn_panel(wks, Eplot_rc345_345, (/3,3/), resP)


   resZ@cnMinLevelValF = -60
   resZ@cnMaxLevelValF = 60
   E_z200_rc345 = regCoef_n(sciE, z200_345, 1, 1)
   E_z200_cor345 = escorc_n(sciE, z200_345, 1, 1)
   k = 0
   do i = 0, 2
      do j = 0, 2
         copy_VarCoords(z200_345(0,0,:,:), E_z200_rc345(i,j,:,:))
         copy_VarCoords(z200_345(0,0,:,:), E_z200_cor345(i,j,:,:))

         Eplot_rc345_345(k) = gsn_csm_contour_map(wks, E_z200_rc345(i,j,:,:), resZ)
         Eplot_cor345_345(k) = gsn_csm_contour(wks, E_z200_cor345(i,j,:,:), rescor)
         overlay(Eplot_rc345_345(k), Eplot_cor345_345(k))
         k=k+1
      end do
   end do
   print(k)
   printVarSummary(E_z200_rc345)
   resP@gsnPanelMainString = "SCAE Lead-lag Reg monthly Z200 "
   gsn_panel(wks, Eplot_rc345_345, (/3,3/), resP)

   ; E_snow_rc4_345 = regCoef_n(SCAE_march*-1, snow_345, 0, 1)
   ; E_snow_cor4_345 = escorc_n(SCAE_march*-1, snow_345, 0, 1)
   ; E_snow_rc4_345@lat2d = snow_file->lat
   ; E_snow_rc4_345@lon2d = snow_file->lon
   ; E_snow_cor4_345@lat2d = snow_file->lat
   ; E_snow_cor4_345@lon2d = snow_file->lon

   ; Eplot_rc4_345 = new(3, "graphic" )
   ; Eplot_cor4_345 = new(3, "graphic" )
   ; do i = 0, 2
   ;    copy_VarCoords(snow_345(0,0,:,:), E_snow_rc4_345(i,:,:))
   ;    copy_VarCoords(snow_345(0,0,:,:), E_snow_cor4_345(i,:,:))

   ;    Eplot_rc4_345(i) = gsn_csm_contour_map(wks, E_snow_rc4_345(i,:,:), ressnow)
   ;    Eplot_cor4_345(i) = gsn_csm_contour(wks, E_snow_cor4_345(i,:,:), rescor)
   ;    overlay(Eplot_rc4_345(i), Eplot_cor4_345(i))
   ; end do
   ; gsn_panel(wks, Eplot_rc4_345, (/1,3/), resP)



end
