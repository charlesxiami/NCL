begin
;
  yrstrt =197201
  yrlast =200912
  latS  = -90
  latN  = 90
  lonL  = 0
  lonR  = 360
  sig1 = 0.497   ; %95
  sig2 = 0.433   ; %95
  cd = "/public/home/charlesxiami/data/ncep/"
  plotpath = "/public/home/charlesxiami/output/"
  wks=gsn_open_wks("pdf", plotpath+"NAO")
  gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;************************************************
;Data read
;************************************************
   filesnow = "/public/home/charlesxiami/data/snow/snow.nc"
   snowdata = addfile(filesnow,"r")
   airdata = addfile(cd+"air.mon.mean.nc", "r")
   slpdata = addfile(cd+"slp.mon.mean.nc", "r")
   hgtdata = addfile(cd+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(cd+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(cd+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(cd+"nswrs.sfc.mon.mean.nc", "r")
   sstdata = addfile(cd+"sst.mnmean.v4.nc", "r")
;********************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)
   print(YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))
;********************************************
   air_mon =  airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR})
   air_mam =  month_to_season(air_mon, "MAM")

   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR})
   slp_mam = month_to_season(slp_mon, "MAM")

   u_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   u_mam = month_to_season(u_mon, "MAM")
   v_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   v_mam = month_to_season(v_mon, "MAM")

   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})
   z500_mam = month_to_season(z500_mon, "MAM")
   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   z200_mam = month_to_season(z200_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   sst_mam = month_to_season(sst_mon, "MAM")

   snow_mon  = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")
   
   ;Read NAO index
   indexpath = "/public/home/charlesxiami/data/index/"
   tele_index = asciiread(indexpath+"tele_index.nh.txt", -1, "string")
   nfields = str_fields_count(tele_index(19), " ")
   nao_index = stringtofloat(str_get_field(tele_index(19::), 3, " "))
   printVarSummary(nao_index)

   nao_mam_all = new((/67/), float)    ; 1950mam-2016mam
   nao_djf_all = new((/67/), "float")  ; 1950/51djf-2016/17djf
   do i = 0, 66
     nao_mam_all(i) = dim_avg(nao_index(i*12+2:i*12+4))
     nao_djf_all(i) = dim_avg(nao_index(i*12+11:i*12+13))
   end do
   printVarSummary(nao_mam_all)
   print(slp_mon@units)
;*************************************************
;Filter High-Frequency Pass
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    nao_mam = wgt_runave_Wrap(nao_mam_all, wgt, 0)
    nao_djf = wgt_runave_Wrap(nao_djf_all, wgt, 0)
    ; air_mam = wgt_runave_n_Wrap(air_mam, wgt, 0, 0)
    ; slp_mam = wgt_runave_n_Wrap(slp_mam, wgt, 0, 0)
    snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
;*************************************************
   snow_mam1 = snow_mam(0:15,:,:)
   air_mam1  = air_mam(0:15,:,:)
   slp_mam1  = slp_mam(0:15,:,:)
   u_mam1    = u_mam(0:15,:,:)
   v_mam1    = v_mam(0:15,:,:)
   z500_mam1 = z500_mam(0:15,:,:)
   z200_mam1 = z200_mam(0:15,:,:)
   sst_mam1  = sst_mam(0:15,:,:)
   ; nswr_mam1 = nswr_mam(0:15,:,:)
   ; nlwr_mam1 = nlwr_mam(0:15,:,:)
   ; tcc_mam1  = tcc_mam(0:15,:,:)

   snow_mam2 = snow_mam(17:37,:,:)
   air_mam2  = air_mam(17:37,:,:)
   slp_mam2  = slp_mam(17:37,:,:)
   u_mam2    = u_mam(17:37,:,:)
   v_mam2    = v_mam(17:37,:,:)
   z500_mam2 = z500_mam(17:37,:,:)
   z200_mam2 = z200_mam(17:37,:,:)
   sst_mam2  = sst_mam(17:37,:,:)
   ; nswr_mam2 = nswr_mam(17:37,:,:)
   ; nlwr_mam2 = nlwr_mam(17:37,:,:)
   ; tcc_mam2  = tcc_mam(17:37,:,:)
;*******************************************
   ; nao_mam_all = nao_djf_all    ; Replace with winter nao 
   ; nao_mam = nao_djf

   nao_sat_rc1 = regCoef_n(nao_mam(22:37), air_mam1, 0, 0)
   nao_sat_cor1 = escorc_n(nao_mam(22:37), air_mam1, 0, 0)
   nao_sat_rc2 = regCoef_n(nao_mam(39:59), air_mam2, 0, 0)
   nao_sat_cor2 = escorc_n(nao_mam(39:59), air_mam2, 0, 0)
   copy_VarCoords(air_mam1(0,:,:), nao_sat_rc1)
   copy_VarCoords(air_mam1(0,:,:), nao_sat_cor1)
   copy_VarCoords(air_mam2(0,:,:), nao_sat_rc2)
   copy_VarCoords(air_mam2(0,:,:), nao_sat_cor2)

   nao_slp_rc1 = regCoef_n(nao_mam(22:37), slp_mam1, 0, 0)
   nao_slp_cor1 = escorc_n(nao_mam(22:37), slp_mam1, 0, 0)
   nao_slp_rc2 = regCoef_n(nao_mam(39:59), slp_mam2, 0, 0)
   nao_slp_cor2 = escorc_n(nao_mam(39:59), slp_mam2, 0, 0)
   copy_VarCoords(slp_mam1(0,:,:), nao_slp_rc1)
   copy_VarCoords(slp_mam1(0,:,:), nao_slp_cor1)
   copy_VarCoords(slp_mam2(0,:,:), nao_slp_rc2)
   copy_VarCoords(slp_mam2(0,:,:), nao_slp_cor2)

   nao_u_rc1 = regCoef_n(nao_mam(22:37), u_mam1, 0, 0)
   nao_u_cor1 = escorc_n(nao_mam(22:37), u_mam1, 0, 0)
   nao_u_rc2 = regCoef_n(nao_mam(39:59), u_mam2, 0, 0)
   nao_u_cor2 = escorc_n(nao_mam(39:59), u_mam2, 0, 0)
   copy_VarCoords(u_mam1(0,:,:), nao_u_rc1)
   copy_VarCoords(u_mam1(0,:,:), nao_u_cor1)
   copy_VarCoords(u_mam2(0,:,:), nao_u_rc2)
   copy_VarCoords(u_mam2(0,:,:), nao_u_cor2)

   nao_v_rc1 = regCoef_n(nao_mam(22:37), v_mam1, 0, 0)
   nao_v_cor1 = escorc_n(nao_mam(22:37), v_mam1, 0, 0)
   nao_v_rc2 = regCoef_n(nao_mam(39:59), v_mam2, 0, 0)
   nao_v_cor2 = escorc_n(nao_mam(39:59), v_mam2, 0, 0)
   copy_VarCoords(v_mam1(0,:,:), nao_v_rc1)
   copy_VarCoords(v_mam1(0,:,:), nao_v_cor1)
   copy_VarCoords(v_mam2(0,:,:), nao_v_rc2)
   copy_VarCoords(v_mam2(0,:,:), nao_v_cor2)

   nao_z500_rc1 = regCoef_n(nao_mam(22:37), z500_mam1, 0, 0)
   nao_z500_cor1 = escorc_n(nao_mam(22:37), z500_mam1, 0, 0)
   nao_z500_rc2 = regCoef_n(nao_mam(39:59), z500_mam2, 0, 0)
   nao_z500_cor2 = escorc_n(nao_mam(39:59), z500_mam2, 0, 0)
   copy_VarCoords(z500_mam1(0,:,:), nao_z500_rc1)
   copy_VarCoords(z500_mam1(0,:,:), nao_z500_cor1)
   copy_VarCoords(z500_mam2(0,:,:), nao_z500_rc2)
   copy_VarCoords(z500_mam2(0,:,:), nao_z500_cor2)

   nao_z200_rc1 = regCoef_n(nao_mam(22:37), z200_mam1, 0, 0)
   nao_z200_cor1 = escorc_n(nao_mam(22:37), z200_mam1, 0, 0)
   nao_z200_rc2 = regCoef_n(nao_mam(39:59), z200_mam2, 0, 0)
   nao_z200_cor2 = escorc_n(nao_mam(39:59), z200_mam2, 0, 0)
   copy_VarCoords(z200_mam1(0,:,:), nao_z200_rc1)
   copy_VarCoords(z200_mam1(0,:,:), nao_z200_cor1)
   copy_VarCoords(z200_mam2(0,:,:), nao_z200_rc2)
   copy_VarCoords(z200_mam2(0,:,:), nao_z200_cor2)

   nao_snow_rc1 = 100*regCoef_n(nao_mam(22:37), snow_mam1, 0, 0)
   nao_snow_cor1 = escorc_n(nao_mam(22:37), snow_mam1, 0, 0)
   nao_snow_rc2 = 100*regCoef_n(nao_mam(39:59), snow_mam2, 0, 0)
   nao_snow_cor2 = escorc_n(nao_mam(39:59), snow_mam2, 0, 0)
   copy_VarCoords(snow_mam1(0,:,:), nao_snow_rc1)
   copy_VarCoords(snow_mam1(0,:,:), nao_snow_cor1)
   copy_VarCoords(snow_mam2(0,:,:), nao_snow_rc2)
   copy_VarCoords(snow_mam2(0,:,:), nao_snow_cor2)
;*******************************************
; Draw XY plot
    rts           = True
    rts@gsnDraw   = False       ; don't draw yet
    rts@gsnFrame  = False       ; don't advance frame yet
    rts@gsnScale  = True        ; force text scaling               
    rts@vpHeightF = 0.35        ; Changes the aspect ratio
    rts@vpWidthF  = 0.85
    rts@vpXF      = 0.10        ; change start locations
    rts@vpYF      = 0.75        ; the plot 
    rts@tiYAxisString = ""                    ; y-axis label
    rts@gsnLeftStringFontHeightF = 0.025
    rts@gsnYRefLine = 0.
    rts@tmYLLabelFontHeightF = 0.015
    rts@tmYLLabelFontHeightF = 0.015
   ;Bar Chart
    rts1 = rts  
    rts1@gsnXYBarChart         = True
    rts1@gsnAboveYRefLineColor = "red"           
    rts1@gsnBelowYRefLineColor = "blue"
   ;Line
    rts2 = rts   
    rts2@xyDashPattern         = 1
    rts2@xyLineThicknessF      = 3.
    rts2@xyLineColor = "black"

   ;Draw nao index from cpc
    ;MAM
    year = ispan(1950,2016,1)
    rts1@gsnLeftString = "NAO MAM"
    plot = gsn_csm_xy(wks, year, nao_mam_all, rts1)
    plot2 = gsn_csm_xy(wks, year, nao_mam, rts2)
    overlay(plot, plot2)
    draw(plot)
    frame(wks)
     ;DJF
    ; rts1@gsnLeftString = "NAO DJF"
    ; plot = gsn_csm_xy(wks, year, nao_djf, rts1)
    ; plot2 = gsn_csm_xy(wks, year, nao_djf_hf, rts2)
    ; overlay(plot, plot2)
    ; draw(plot)
    ; frame(wks)
;************************************************
; Res Settings
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
  ;Correlation res (with dots.)
   rescor = True
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False

  ;For SAT
   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   resrc@lbBoxEndCapStyle = "TriangleBothEnds"
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@mpFillOn = False
   resrc@mpCenterLonF = 0.
   resrc@mpMinLonF = -90.
   resrc@mpMaxLonF = 180.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.
   resrc@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMaxLevelValF = 2.4
   resrc@cnMinLevelValF = -2.4
   resrc@cnLevelSpacingF = 0.2

   resSLP = resrc
   resSLP@gsnRightString = slp_mon@units
   resSLP@cnMaxLevelValF = 6.
   resSLP@cnMinLevelValF = -6.
   resSLP@cnLevelSpacingF = 0.5

   resZ = resrc
   resZ@gsnRightString = z500_mon@units
   resZ@cnMaxLevelValF = 60.
   resZ@cnMinLevelValF = -60.
   resZ@cnLevelSpacingF = 5.

   ressnow = resrc
   ;ressnow@cnLevelSelectionMode = "AutomaticLevels"
   ressnow@gsnRightString = "%"
   ressnow@mpMinLatF = 30.
   ressnow@mpMaxLatF = 80.
   ressnow@mpMinLonF = 10.
   ressnow@mpMaxLonF = 150.
   ressnow@mpCenterLonF = 80.
   ressnow@cnMaxLevelValF = 20.0
   ressnow@cnMinLevelValF = -20.0
   ressnow@cnLevelSpacingF = 2.

   resSST = resrc
   resSST@mpMaxLonF = 10.
   resSST@mpMinLonF = -80.
   resSST@mpMaxLatF = 80.
   resSST@mpMinLatF = -10.
   resSST@mpCenterLonF = 0.

   ;For contour lines
   resrc2 = res
   resrc2@cnFillOn = False
   resrc2@cnLinesOn = True
   resrc2@cnInfoLabelOn = False
   resrc2@gsnContourNegLineDashPattern = 5
   resrc2@gsnContourZeroLineThicknessF = 0.
   resrc2@cnLineThicknessF = 2.0
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

   ;Wind Resources
   resV = True
   resV@gsnDraw = False
   resV@gsnFrame = False
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.5               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02
   resV@vcRefMagnitudeF = 3.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = False
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.30

   respolar = True
   respolar@gsnDraw = False
   respolar@gsnFrame = False
   respolar@gsnPolar = "NH"
   respolar@cnFillOn = True
   respolar@cnLinesOn = False
   respolar@lbLabelBarOn = False
   respolar@cnLevelSelectionMode = "ManualLevels"
   respolar@cnMinLevelValF = -0.030
   respolar@cnMaxLevelValF = 0.030
   respolar@cnLevelSpacingF = 0.005

   resP = True
   resP@gsnMaximize = False
   resP@gsnPanelLabelBar = False
   resP@lbLabelAutoStride = True
   resP@gsnPanelFigureStrings = (/"a)","b)","c)","d)","e)","f)"/)
   resP@gsnPanelFigureStringsFontHeightF = 0.012
   resP@gsnPanelFigureStringsPerimOn = True
   resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   resP@amJust = "TopLeft"
   resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   resP@amParallelPosF = -0.50    ;X-axis
;************************************************
;Plots
   ;P1
   rescor@cnLevels = (/-sig1,sig1/)
   print("P1:Sig = "+sig1)
   resrc@gsnRightString = air_mon@units
   resrc@gsnLeftString = "NAO-SAT P1"
   satreg1 = gsn_csm_contour_map(wks, nao_sat_rc1, resrc)
   satcor1 = gsn_csm_contour(wks, nao_sat_cor1, rescor)
   satwnd1 = gsn_csm_vector(wks, nao_u_rc1, nao_v_rc1, resV)
   overlay(satreg1, satwnd1)
   overlay(satreg1, satcor1)
   
   resSLP@gsnLeftString = "NAO-SLP P1"
   slpreg1 = gsn_csm_contour_map(wks, nao_slp_rc1, resSLP)
   slpcont1 = gsn_csm_contour(wks, nao_slp_rc1, resrc2)
   slpcor1 = gsn_csm_contour(wks, nao_slp_cor1, rescor)
   overlay(slpreg1, slpcont1)
   overlay(slpreg1, slpcor1)

   resZ@gsnLeftString = "NAO-Z500 P1"
   z500reg1 = gsn_csm_contour_map(wks, nao_z500_rc1, resZ)
   z500cont1 = gsn_csm_contour(wks, nao_z500_rc1, resrc2)
   z500cor1 = gsn_csm_contour(wks, nao_z500_cor1, rescor)
   overlay(z500reg1, z500cont1)
   overlay(z500reg1, z500cor1)

   ; resZ@cnMaxLevelValF = 60.
   ; resZ@cnMinLevelValF = -60.
   ; resZ@cnLevelSpacingF = 5.
   resZ@gsnLeftString = "NAO-Z200 P1"
   z200reg1 = gsn_csm_contour_map(wks, nao_z200_rc1, resZ)
   z200cont1 = gsn_csm_contour(wks, nao_z200_rc1, resrc2)
   z200cor1 = gsn_csm_contour(wks, nao_z200_cor1, rescor)
   overlay(z200reg1, z200cont1)
   overlay(z200reg1, z200cor1)

   ressnow@gsnLeftString = "NAO-Snow P1"
   snowreg1 = gsn_csm_contour_map(wks, nao_snow_rc1, ressnow)
   snowcor1 = gsn_csm_contour(wks, nao_snow_cor1, rescor)
   overlay(snowreg1, snowcor1)

   ;P2
   rescor@cnLevels = (/-sig2,sig2/)
   print("P2:Sig = "+sig2)
   resrc@gsnLeftString = "NAO-SAT P2"
   satreg2 = gsn_csm_contour_map(wks, nao_sat_rc2, resrc)
   satcor2 = gsn_csm_contour(wks, nao_sat_cor2, rescor)
   satwnd2 = gsn_csm_vector(wks, nao_u_rc2, nao_v_rc2, resV)
   overlay(satreg2, satwnd2)
   overlay(satreg2, satcor2)

   resSLP@gsnLeftString = "NAO-SLP P2"
   slpreg2 = gsn_csm_contour_map(wks, nao_slp_rc2, resSLP)
   slpcont2 = gsn_csm_contour(wks, nao_slp_rc2, resrc2)
   slpcor2 = gsn_csm_contour(wks, nao_slp_cor2, rescor)
   overlay(slpreg2, slpcont2)
   overlay(slpreg2, slpcor2)

   ; resZ@cnMaxLevelValF = 40.
   ; resZ@cnMinLevelValF = -40.
   ; resZ@cnLevelSpacingF = 5.
   resZ@gsnLeftString = "NAO-Z500 P2"
   z500reg2 = gsn_csm_contour_map(wks, nao_z500_rc2, resZ)
   z500cont2 = gsn_csm_contour(wks, nao_z500_rc2, resrc2)
   z500cor2 = gsn_csm_contour(wks, nao_z500_cor2, rescor)
   overlay(z500reg2, z500cont2)
   overlay(z500reg2, z500cor2)

   ; resZ@cnMaxLevelValF = 50.
   ; resZ@cnMinLevelValF = -50.
   ; resZ@cnLevelSpacingF = 5.
   resZ@gsnLeftString = "NAO-Z200 P2"
   z200reg2 = gsn_csm_contour_map(wks, nao_z200_rc2, resZ)
   z200cont2 = gsn_csm_contour(wks, nao_z200_rc2, resrc2)
   z200cor2 = gsn_csm_contour(wks, nao_z200_cor2, rescor)
   overlay(z200reg2, z200cont2)
   overlay(z200reg2, z200cor2)

   ressnow@gsnLeftString = "NAO-Snow P2"
   snowreg2 = gsn_csm_contour_map(wks, nao_snow_rc2, ressnow)
   snowcor2 = gsn_csm_contour(wks, nao_snow_cor2, rescor)
   overlay(snowreg2, snowcor2)   
;************************************************   
;Panel plots
   satslp = new(4, "graphic")
   satslp(0) = satreg1
   satslp(1) = satreg2
   satslp(2) = slpreg1
   satslp(3) = slpreg2
   gsn_panel(wks, satslp, (/2,2/), resP)

   z52 = new(4, "graphic")
   z52(0) = z500reg1
   z52(1) = z500reg2
   z52(2) = z200reg1
   z52(3) = z200reg2
   gsn_panel(wks, z52, (/2,2/), resP)

   snowplot = new(2, "graphic")
   snowplot(0) = snowreg1
   snowplot(1) = snowreg2
   gsn_panel(wks, snowplot, (/2,2/), resP)


end
