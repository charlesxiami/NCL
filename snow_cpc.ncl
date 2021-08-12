load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
  yrstrt = 197201
  yrlast = 200912
;---------------W,E-index Region
  WlatS = 48
  WlatN = 58
  WlonL = 25
  WlonR = 50

  ClatS = 50
  ClatN = 60
  ClonL = 55
  ClonR = 85
  
  ElatS = 60
  ElatN = 70
  ElonL = 100
  ElonR = 125

  latS     = -90               
  latN     = 90
  lonL     = 0
  lonR     = 360

  year=ispan(yrstrt/100, yrlast/100, 1)
  nyr = dimsizes(year)

  cd = "/public/home/charlesxiami/data/ncep/"
  plotpath = "/public/home/charlesxiami/output/"
  indexpath = "/public/home/charlesxiami/data/index/"

   wks=gsn_open_wks("pdf", plotpath+"snow_cpc")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;***********************************************
;************************************************
   filesnow = "/public/home/charlesxiami/data/snow/snow.nc"
   snowdata = addfile(filesnow,"r")
   airdata = addfile(cd+"air.mon.mean.nc", "r")
   slpdata = addfile(cd+"slp.mon.mean.nc", "r")
   hgtdata = addfile(cd+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(cd+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(cd+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(cd+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(cd+"nlwrs.sfc.mon.mean.nc", "r")
   sstdata = addfile(cd+"sst.mnmean.v4.nc", "r")
   soilwdata = addfile(cd+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(cd+"tcdc.eatm.mon.mean.nc", "r")

   pc1_all = asciiread(indexpath+"pc1.txt", -1, "float")
   tele_index = asciiread(indexpath+"tele_index.nh.txt", -1, "string")
;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)
   print(YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))
;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   air_mam = month_to_season(air_mon, "MAM")
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR})
   slp_mam = month_to_season(slp_mon, "MAM")
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 
   z500_mam = month_to_season(z500_mon, "MAM")

   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   z200_mam = month_to_season(z200_mon, "MAM")

   z850_mon = hgtdata->hgt(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   z850_mam = month_to_season(z500_mon, "MAM")

   u_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   u_mam = month_to_season(u_mon, "MAM")
   v_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   v_mam = month_to_season(v_mon, "MAM")
   uv_mam = sqrt(u_mam^2+v_mam^2)
   copy_VarCoords(u_mam, uv_mam)

   snow_mon  = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

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
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@mpFillOn = False
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = False
   resrc@mpCenterLonF = 90.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMinLatF = 20.
   resrc@mpMaxLatF = 80.

   ressat = resrc
   ressat@cnMinLevelValF = -1.8
   ressat@cnMaxLevelValF = 1.8
   ressat@cnLevelSpacingF = 0.1

   resZ = resrc
   resZ@cnMinLevelValF = -40.
   resZ@cnMaxLevelValF = 40.
   resZ@cnLevelSpacingF = 2.

   ressnow = resrc
   ressnow@cnMinLevelValF = -20
   ressnow@cnMaxLevelValF = 20
   ressnow@cnLevelSpacingF = 1
   ;ressnow@gsnRightString = "%"
   ressnow@mpMinLonF = 20.
   ressnow@mpMaxLonF = 160.
   ressnow@mpMinLatF = 20.
   ressnow@mpMaxLatF = 80.

   ;For Line
   resrc2 = True
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
   resrc2@cnLineLabelFontHeightF = 0.015
   ;resrc2@cnLineLabelFontColor = 0
   resrc2@cnLineLabelFontThicknessF = 1.0
   resrc2@gsnAddCyclic = True

   ;Correlation res (with dots.)
   rescor = True
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/-0.320,0.320/)  ;95%
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False

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
   ;resP@gsnPanelFigureStrings = (/"a)","b)","c)","d)","e)","f)"/)
   resP@gsnPanelFigureStringsFontHeightF = 0.012
   resP@gsnPanelFigureStringsPerimOn = False
   resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   resP@amJust = "TopLeft"
   resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   resP@amParallelPosF = -0.50    ;X-axis
   resP@pmLabelBarOrthogonalPosF = -0.015
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

   ;MAM average
   snow_mon = SqrtCosWeight(snow_mon)
   printVarSummary(snow_mon)
   snow_march = snow_mon(2:455:12,:,:)
   snow_april = snow_mon(3:455:12,:,:)
   snow_may   = snow_mon(4:455:12,:,:)
   printVarSummary(snow_may)

   dim_snow = dimsizes(snow_march)
   snow_345 = new((/3,dim_snow(0),dim_snow(1),dim_snow(2)/), "float")
   snow_345(0,:,:,:) = snow_march
   snow_345(1,:,:,:) = snow_april
   snow_345(2,:,:,:) = snow_may

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

   rts@xyLineThicknessF     = 2.0   ; Twice as thick

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

   rtsP = True
   rtsP@lbLabelAutoStride = True

   sciW = new((/3,nyr/), "float")
   sciW(0,:) = SCAW_march
   sciW(1,:) = SCAW_april
   sciW(2,:) = SCAW_may

   sciE = new((/3,nyr/), "float")
   sciE(0,:) = SCAE_march
   sciE(1,:) = SCAE_april
   sciE(2,:) = SCAE_may

   sciW = -1*sciW
   sciE = -1*sciE
;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    pc1 = wgt_runave_Wrap(pc1_all , wgt, 0)

    ;snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
    ;sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)
    sciW = wgt_runave_Wrap(sciW, wgt, 0)
    sciE = wgt_runave_Wrap(sciE, wgt, 0)

 ;**********************************************************
 ;    ;SCAW draw
 ;    resrc@mpMinLonF = 0.
 ;    ;resrc@mpMaxLonF = 240.
 ;    resrc@cnMinLevelValF = -2.
 ;    resrc@cnMaxLevelValF = 2.
 ;    resrc@cnLevelSpacingF = 0.1
 ;    resrc@gsnLeftString = "(a) SCAW: SAT+Wind(850hpa)"
 ;    ;resrc@cnInfoLabelString = "Dotted Wrea exceed 95% Sig Level"
 ;    satW = gsn_csm_contour_map(wks, SCAW_sat_rc ,resrc)
 ;    Wwnd = gsn_csm_vector(wks, SCAW_u_rc, SCAW_v_rc, resV)
 ;    Wdot = gsn_csm_contour(wks, SCAW_sat_cor, rescor)
 ;    overlay(satW, Wwnd)
 ;    overlay(satW, Wdot)

 ;   ;SCAE draw
 ;   resrc@gsnLeftString = "(b) SCAEI: SAT+Wind(850hpa)"
 ;   satE = gsn_csm_contour_map(wks, SCAE_sat_rc ,resrc) ;Regression Map as based map
 ;   Ewnd = gsn_csm_vector(wks, SCAE_u_rc, SCAE_v_rc, resV) ; Wind overlay
 ;   Edot = gsn_csm_contour(wks, SCAE_sat_cor, rescor) ; Correlation overlay
 ;   overlay(satE, Ewnd)
 ;   overlay(satE, Edot)


 ;   ;SLP
 ;   resrc@cnMinLevelValF = -2.5
 ;   resrc@cnMaxLevelValF = 2.5
 ;   resrc@cnLevelSpacingF = 0.1
 ;   resrc@gsnLeftString = "SCAW: "+"SLP"
 ;   Wslp = gsn_csm_contour_map(wks, SCAW_slp_rc, resrc)
 ;   slpcor = gsn_csm_contour(wks, SCAW_slp_cor, rescor)
 ;   line = gsn_csm_contour(wks, SCAW_slp_rc, resrc2)
 ;   overlay(Wslp, line)
 ;   overlay(Wslp, slpcor)

 ;   resrc@gsnLeftString = "SCAE: "+"SLP"
 ;   Eslp = gsn_csm_contour_map(wks, SCAE_slp_rc, resrc)
 ;   slpcor = gsn_csm_contour(wks, SCAE_slp_cor, rescor)
 ;   line = gsn_csm_contour(wks, SCAE_slp_rc, resrc2)
 ;   overlay(Eslp, line)
 ;   overlay(Eslp, slpcor)

 ;   ;
 ;   resrc@cnMinLevelValF = -30.
 ;   resrc@cnMaxLevelValF = 30.
 ;   resrc@cnLevelSpacingF = 1.
 ;   resrc@gsnLeftString = "(c) SCAW: Z500"
 ;   Whgt = gsn_csm_contour_map(wks, SCAW_z500_rc, resrc)
 ;   Whgtcor = gsn_csm_contour(wks, SCAW_z500_cor, rescor)
 ;   line = gsn_csm_contour(wks, SCAW_z500_rc, resrc2)
 ;   overlay(Whgt, line)
 ;   overlay(Whgt, Whgtcor)

 ;   resrc@gsnLeftString = "(d) SCAE: Z500"
 ;   Ehgt = gsn_csm_contour_map(wks, SCAE_z500_rc, resrc)
 ;   Ehgtcor = gsn_csm_contour(wks, SCAE_z500_cor, rescor)
 ;   line = gsn_csm_contour(wks, SCAE_z500_rc, resrc2)
 ;   overlay(Ehgt, line)
 ;   overlay(Ehgt, Ehgtcor)

 ; ;**********************************************************
 ; ;Snow Correlation
 ;   ;SCAW
 ;   resrc@mpMinLatF = 0.
 ;   resrc@mpMaxLonF = 180.
 ;   resrc@cnMinLevelValF = -1.
 ;   resrc@cnMaxLevelValF = 1.
 ;   resrc@cnLevelSpacingF = 0.1
 ;   resrc@gsnLeftString = "SCAW: SCE correlation map"
 ;   snowplot = gsn_csm_contour_map(wks, SCAW_snow_cor, resrc)
 ;   snowdot = gsn_csm_contour(wks, SCAW_snow_cor, rescor)

 ;    draw(snowplot)
 ;    frame(wks)

 ;   resrc@gsnLeftString = "SCAE: SCE correlation map"
 ;   delete(snowplot)
 ;   delete(snowdot)
 ;   snowplot = gsn_csm_contour_map(wks, SCAE_snow_cor, resrc)
 ;   snowdot = gsn_csm_contour(wks, SCAE_snow_cor, rescor)
 ;    draw(snowplot)
 ;    frame(wks)


 ;    satWE = new(2,"graphic")
 ;    satWE(0) = satW
 ;    satWE(1) = satE
 ;    gsn_panel(wks, satWE, (/1,2/), rtsP)

   Eplot_345_rc = new(9, "graphic" )
   Eplot_345_cor = new(9, "graphic" )

   ;Snow
   E_snow_rc345  = 100*regCoef_n(sciE, snow_345, 1, 1)
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




end
