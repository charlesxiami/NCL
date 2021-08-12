begin
   snowpath  = "/public/home/charlesxiami/data/snow/"
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

   yrstrt =197201
   yrlast =200912
  
   sig = 0.320   ;95%
   sig1 = 0.497
   sig2 = 0.433
;*****************************************************
;I/O
;*****************************************************
   wks=gsn_open_wks("pdf", plotpath+"snow_rutger")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")

   snowdata = addfile(snowpath+"RutgersSnow.mon.mean.nc", "r") 
   ;snowdata_noaa = addfile(snowpath+"nhsce_v01r01_19661004_20170403.nc", "r")
   ;snowdata actual:196611-201603   ;integer:196701-201512 !!!
   pc1_all = asciiread(indexpath+"pc1.txt", -1, "float")

   YYYYMM = cd_calendar(snowdata->time, 1)
   print(YYYYMM(dimsizes(YYYYMM)-12:dimsizes(YYYYMM)-1))
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print(YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   snow_mon = snowdata->snowcover(iStrt:iLast,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")
   snow_mam@lon2d = snowdata->lon
   snow_mam@lat2d = snowdata->lat
   printVarSummary(snow_mam)
   print(max(snow_mam@lat2d)+"_"+min(snow_mam@lat2d))
   print(max(snow_mam@lon2d)+"_"+min(snow_mam@lon2d))

   snow_mam_avg = dim_avg_n_Wrap(snow_mam, 0)
   snow_mam_avg@lon2d = snowdata->lon
   snow_mam_avg@lat2d = snowdata->lat
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
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   resrc@pmLabelBarOrthogonalPosF = 0.5
   ;resrc@lbOrientation = "Vertical"
   resrc@cnInfoLabelOn = False
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = False
   resrc@mpCenterLonF = 90
   resrc@mpMinLonF = 20
   resrc@mpMaxLonF = 150
   resrc@mpMinLatF = 40
   resrc@mpMaxLatF = 80
   resrc@trGridType = "TriangularMesh"
   ; resrc@gsnPolar   = "NH"

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
;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    pc1 = wgt_runave_Wrap(pc1_all, wgt, 0)
    snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)

    snow_mam_transf = snow_mam
    ; snow_mam_transf!1 = "Lat"
    ; snow_mam_transf!2 = "Lon"
    snow_mam_transf@lon2d = snowdata->lon
    snow_mam_transf@lat2d = snowdata->lat
    printVarSummary(snow_mam_transf)

    ; index = new((/38,9999/), "float")
    ; index = 0
    ; p = 0 
    ; do k =0,37
    ; do i=0,88
    ;   do j=0,88
    ;     if (snow_mam_transf@lon2d.ge.ElonL.and.snow_mam_transf@lon2d.le.ElonR) then
    ;       if (snow_mam_transf@lat2d.ge.ElatS.and.snow_mam_transf@lat2d.le.ElatN) then
    ;         index = index + snow_mam_transf(k,i,j)
    ;       end if
    ;     end if
    ;     end do
    ;             end do
    ;                     end do


;*************************************************
;Regression, Correlation
;*************************************************    
  ;all
    pc1_snow_reg = regCoef_n(pc1(2:39), snow_mam(0:37,:,:), 0, 0)
    pc1_snow_cor = escorc_n(pc1(2:39), snow_mam(0:37,:,:), 0, 0)
    copy_VarCoords(snow_mam(0,:,:), pc1_snow_reg)
    copy_VarCoords(snow_mam(0,:,:), pc1_snow_cor)
    pc1_snow_reg@lon2d = snowdata->lon
    pc1_snow_reg@lat2d = snowdata->lat
    pc1_snow_cor@lon2d = snowdata->lon
    pc1_snow_cor@lat2d = snowdata->lat
  ;P1
    pc1_snow_reg1 = regCoef_n(pc1(2:17), snow_mam(0:15,:,:), 0, 0)
    pc1_snow_cor1 = escorc_n(pc1(2:17), snow_mam(0:15,:,:), 0, 0)
    copy_VarCoords(snow_mam(0,:,:), pc1_snow_reg1)
    copy_VarCoords(snow_mam(0,:,:), pc1_snow_cor1)
    pc1_snow_reg1@lon2d = snowdata->lon
    pc1_snow_reg1@lat2d = snowdata->lat
    pc1_snow_cor1@lon2d = snowdata->lon
    pc1_snow_cor1@lat2d = snowdata->lat 
  ;P2
    pc1_snow_reg2 = regCoef_n(pc1(19:39), snow_mam(17:37,:,:), 0, 0)
    pc1_snow_cor2 = escorc_n(pc1(19:39), snow_mam(17:37,:,:), 0, 0)
    copy_VarCoords(snow_mam(0,:,:), pc1_snow_reg2)
    copy_VarCoords(snow_mam(0,:,:), pc1_snow_cor2)
    pc1_snow_reg2@lon2d = snowdata->lon
    pc1_snow_reg2@lat2d = snowdata->lat
    pc1_snow_cor2@lon2d = snowdata->lon
    pc1_snow_cor2@lat2d = snowdata->lat
;*************************************************
;Plot
;*************************************************
    resrc@cnLevelSelectionMode = "ManualLevels"
    resrc@cnMinLevelValF = 0
    resrc@cnMaxLevelValF = 100
    resrc@cnLevelSpacingF = 10
    resrc@gsnLeftString = "RutgersSnow MAM Cliamte"
    plot_climate = gsn_csm_contour_map(wks, snow_mam_avg, resrc)
    draw(plot_climate)
    frame(wks)

    resrc@cnLevelSelectionMode = "ManualLevels"
    resrc@cnMinLevelValF = -12
    resrc@cnMaxLevelValF = 12
    resrc@cnLevelSpacingF = 1
    rescor@cnLevels = (/-sig,sig/)
    resrc@gsnRightString = snow_mam@units
    resrc@gsnLeftString = "PC1 regression RutgersSnow MAM Entire"
    plot = gsn_csm_contour_map(wks, pc1_snow_reg, resrc)
    plotcor = gsn_csm_contour(wks, pc1_snow_cor, rescor)
    overlay(plot, plotcor)
    draw(plot)
    frame(wks)

    rescor@cnLevels = (/-sig1,sig1/)
    resrc@gsnLeftString = "PC1 regression RutgersSnow MAM P1"
    plot1 = gsn_csm_contour_map(wks, pc1_snow_reg1, resrc)
    plotcor1 = gsn_csm_contour(wks, pc1_snow_cor1, rescor)
    overlay(plot1, plotcor1)
    draw(plot1)
    frame(wks)

    rescor@cnLevels = (/-sig2,sig2/)
    resrc@gsnLeftString = "PC1 regression RutgersSnow MAM P2"
    plot2 = gsn_csm_contour_map(wks, pc1_snow_reg2, resrc)
    plotcor2 = gsn_csm_contour(wks, pc1_snow_cor2, rescor)
    overlay(plot2, plotcor2)
    draw(plot2)
    frame(wks)



end