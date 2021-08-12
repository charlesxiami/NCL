load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
;***
   begin
;***
   yrstrt = 194801
   yrlast = 201712

   yrstrt_sst = 194701
   yrlast_sst = 201712

   yrstrt_snow = 196701
   yrlast_snow = 201412

   latS     = -90.
   latN     = 90.
   lonL     = 0.
   lonR     = 360.

   t = ispan(yrstrt/100, yrlast/100, 1)
   ;year = ispan(1972, 2009, 1)
;*********************************************** 
   nceppath = "/public/home/charlesxiami/data/ncep/"
   snowpath = "/public/home/charlesxiami/data/snow/"
   indexpath = "/public/home/charlesxiami/data/index/"

   plotpath = "/public/home/charlesxiami/output/"
;********************************************
   wks=gsn_open_wks("pdf", plotpath+"pc1_reg_1948-2017")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;************************************************
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.nc", "r")

   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")   
   soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")

   snowdata = addfile(snowpath+"snow.rutger.2.0deg.nc","r")
   
   pc1_all = asciiread(indexpath+"pc1_1948-2017.txt", -1, "float")
   ;pc2_all = asciiread(indexpath+"pc2_1948-2017.txt", -1, "float")
   npc1 = dimsizes(pc1_all)
   ;pc1 = pc1_all

   ;Nao 195001-201806
   nao_index = asciiread(indexpath+"norm.nao.monthly.b5001.current.ascii.txt", -1, "string")
   nao_mon = stringtofloat(str_get_field(nao_index, 3, " "))
   nao_djf = new((/67/), float)  ; nao_djf: 1950DJF-2016DJF
   nao_mam = new((/67/), float)  ; nao_mam: 1950MAM-2016MAM
   do i = 0,66
    nao_djf(i) = dim_avg_Wrap(nao_mon(i*12+11:i*12+13))   ;NAO DJF 1951/52 - 2016/17 
   end do 
   do i = 0,66
    nao_mam(i) = dim_avg_Wrap(nao_mon(i*12+2+12:i*12+4+12))  ; NAO MAM 1951 - 2017
   end do

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

;****************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR})
   air_mam = month_to_season(air_mon, "MAM")

   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   slp_mam = month_to_season(slp_mon, "MAM")
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 
   z500_mam = month_to_season(z500_mon, "MAM")

   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   z200_mam = month_to_season(z200_mon, "MAM")

   u_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   u_mam = month_to_season(u_mon, "MAM")
   v_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   v_mam = month_to_season(v_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   sst_jfm = month_to_season(sst_mon, "JFM")
   sst_ond = month_to_season(sst_mon, "OND")
   ndim_sst = dimsizes(sst_jfm)

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   sat_region = air_mam(:,{10:80},{80:150})
   sat_region = SqrtCosWeight(sat_region)
   satindex = wgt_areaave_Wrap(sat_region, 1.0, 1.0, 1)
   satindex = dim_standardize_Wrap(satindex, 0)

;********************************************
; Filter 
;********************************************
   ; high frequence component 
    ihp = 1
    fca = 1.0/10.0
    fcb= -999.
    nsigma = 1.
    nwt= 7
    wgt_high = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    pc1 = wgt_runave_Wrap(pc1_all, wgt_high, 0)
    ; satindex_hf = wgt_runave_Wrap(satindex, wgt, 0)
    ; ;air_mam = wgt_runave_n_Wrap(air_mam, wgt, 0, 0)
    ; ;slp_mam = wgt_runave_n_Wrap(slp_mam, wgt, 0, 0)
    ; ;snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
    sst_ond = wgt_runave_n_Wrap(sst_ond, wgt_high, 0, 0)

    nao_djf_hf = wgt_runave_Wrap(nao_djf, wgt_high, 0)
    nao_mam_hf = wgt_runave_Wrap(nao_mam, wgt_high, 0)

   ; low frequency
    ihp = 0  
    wgt_low = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    pc1_lf = wgt_runave_Wrap(pc1_all, wgt_low, 0)
    ; ;print(pc1_lf)

    print("Pecentage of HF/AF: " + variance(pc1)/variance(dtrend(pc1_all,False)))
;********************************************
; Spectrum 
;********************************************
  d = 1
  sm = 7
  pct = 0.10

  spec_pc1 = specx_anal(pc1_all, d, sm, pct)
  splt_pc1 = specx_ci(spec_pc1, 0.05, 0.95)

  spec_nao_djf = specx_anal(nao_djf, d, sm, pct)
  splt_nao_djf = specx_ci(spec_nao_djf, 0.05, 0.95)

  spec_nao_mam = specx_anal(nao_mam, d, sm, pct)
  splt_nao_mam = specx_ci(spec_nao_mam, 0.05, 0.95)

;************************
  nnao = dimsizes(nao_djf)
  print("AF: PC1-NAO(DJF) = "+ escorc(pc1_all(3:npc1-1), nao_djf))
  print("AF: PC1-NAO(MAM) = "+ escorc(pc1_all(3:npc1-1), nao_mam))

  print("HF: PC1-NAO(DJF) = "+ escorc(pc1(3:npc1-1), nao_djf_hf(0:nnao-1)))
  print("HF: PC1-NAO(MAM) = "+ escorc(pc1(3:npc1-1), nao_mam_hf(0:nnao-1)))

print("HF P1: PC1-NAO(DJF) = "+ escorc(pc1(3+3:npc1-30), nao_djf_hf(3:nnao-30)))
print("HF P1: PC1-NAO(MAM) = "+ escorc(pc1(3+3:npc1-30), nao_mam_hf(3:nnao-30)))

print("HF P2: PC1-NAO(DJF) = "+ escorc(pc1(3+38:npc1-4), nao_djf_hf(38:nnao-4)))
print("HF P2: PC1-NAO(MAM) = "+ escorc(pc1(3+38:npc1-4), nao_mam_hf(38:nnao-4)))
  ;********************************************
; Regression and Correlation
    pc1_sat_rc = regCoef_n(pc1(:),air_mam, 0, 0)
    pc1_sat_cor = escorc_n(pc1(:),air_mam, 0, 0)
    pc1_slp_rc = regCoef_n(pc1(:),slp_mam, 0, 0)
    pc1_slp_cor = escorc_n(pc1(:),slp_mam, 0, 0)
   pc1_z500_rc = regCoef_n(pc1(:),z500_mam, 0 ,0)
   pc1_z500_cor = escorc_n(pc1(:),z500_mam, 0 ,0)
   pc1_z200_rc = regCoef_n(pc1(:),z200_mam, 0 ,0)
   pc1_z200_cor = escorc_n(pc1(:),z200_mam, 0 ,0)
      pc1_u_rc = regCoef_n(pc1(:),u_mam, 0, 0)
      pc1_u_cor = escorc_n(pc1(:),u_mam, 0, 0)
      pc1_v_rc = regCoef_n(pc1(:),v_mam, 0, 0)
      pc1_v_cor = escorc_n(pc1(:),v_mam, 0, 0)

    copy_VarCoords(air_mam(0,:,:), pc1_sat_rc)
    copy_VarCoords(air_mam(0,:,:), pc1_sat_cor)
    copy_VarCoords(slp_mam(0,:,:), pc1_slp_rc)
    copy_VarCoords(slp_mam(0,:,:), pc1_slp_cor)
    copy_VarCoords(z500_mam(0,:,:), pc1_z500_rc)
    copy_VarCoords(z500_mam(0,:,:), pc1_z500_cor)
    copy_VarCoords(z200_mam(0,:,:), pc1_z200_rc)
    copy_VarCoords(z200_mam(0,:,:), pc1_z200_cor)
    copy_VarCoords(u_mam(0,:,:), pc1_u_rc)
    copy_VarCoords(u_mam(0,:,:), pc1_v_rc)

    pc1_uv_rc = sqrt(pc1_u_rc^2+pc1_v_rc^2)
    copy_VarCoords(pc1_u_rc, pc1_uv_rc)

    pc1_sst_rc = regCoef_n(pc1(0+3:npc1-1-3),sst_ond(0+3:ndim_sst(0)-2-3,:,:),0,0)
    pc1_sst_cor = escorc_n(pc1(0+3:npc1-1-3),sst_ond(0+3:ndim_sst(0)-2-3,:,:),0,0)
    copy_VarCoords(sst_ond(0,:,:), pc1_sst_rc)
    copy_VarCoords(sst_ond(0,:,:), pc1_sst_cor)

    pc1_sce_rc = regCoef_n(pc1(19:66),snow_mam, 0, 0)
    pc1_sce_cor = escorc_n(pc1(19:66),snow_mam, 0, 0)
    copy_VarCoords(snow_mam(0,:,:), pc1_sce_rc(:,:))
    copy_VarCoords(snow_mam(0,:,:), pc1_sce_cor(:,:))

;********************************************
;Time Series plot
;********************************************
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

     rts1 = rts  ; Bar Chart
     rts1@gsnXYBarChart         = True
     rts1@gsnYRefLine = 0.
     rts1@gsnAboveYRefLineColor = "red"
     rts1@gsnBelowYRefLineColor = "blue"
     ;rts1@gsnLeftString = "(b) PC1"
     ;rts1@tmXUseBottom = True
     rts1@tmXBMode = "Explicit"
     ; rts1@tmXBValues = ispan(1975, 2005, 5)
     ; rts1@tmXBLabels = ispan(1975, 2005, 5)
     ; rts1@tmXBMinorValues = ispan(1972, 2009, 1)
     rts1@tmXTOn = False
     rts1@tmYROn = False
     rts1@tiXAxisString = "Time (Year)"
     rts1@tiYAxisString = " "
     rts1@tiXAxisFontHeightF = 0.02
     rts1@tiYAxisFontHeightF = 0.02
     ; rts1@trXMinF = 1973.5
     ; rts1@trXMaxF = 2007.5
     rts1@trYMinF = -3.0
     rts1@trYMaxF = 3.0

     rts2 = rts   ; Line 
     rts2@xyDashPattern         = 1
     rts2@xyLineThicknessF      = 4.
     rts2@xyLineColor = "black"
     
     ts = gsn_csm_xy(wks,t,pc1_all,rts1)
     ts2 = gsn_csm_xy(wks, t, pc1_lf,rts2)
     overlay(ts, ts2)
     draw(ts)
     frame(wks)

     rts1@gsnXYBarChartBarWidth = 0.2
     ts_pc1 = gsn_csm_xy(wks, t, pc1, rts1)

     delete(rts1@gsnAboveYRefLineColor)
     delete(rts1@gsnBelowYRefLineColor)

     rts1@gsnXYBarChartBarWidth = 0.66
     ts_pc1_all = gsn_csm_xy(wks, t, pc1_all, rts1)

     overlay(ts_pc1, ts_pc1_all)
     draw(ts_pc1)
     frame(wks)

     rts2@xyLineThicknessF = 0.6
     rts2@tiXAxisString = "Frequency (cycle/year)"
     rts2@tiYAxisString = "Variance"
     rts2@xyDashPatterns := (/0,0,1,1/)
     rts2@xyLineColors := (/"black", "green", "blue", "red"/)

     plot_spec = gsn_csm_xy(wks, spec_pc1@frq, splt_pc1, rts2)
     draw(plot_spec)
     frame(wks)

     plot_spec = gsn_csm_xy(wks, spec_nao_djf@frq, splt_nao_djf, rts2)
     draw(plot_spec)
     frame(wks)

     plot_spec = gsn_csm_xy(wks, spec_nao_mam@frq, splt_nao_mam, rts2)
     draw(plot_spec)
     frame(wks)
;**********************************************************
;Draw 
;**********************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   resrc = True
   resrc@gsnDraw = False
   resrc@gsnFrame = False
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.20
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False

   resrc@mpFillOn = False
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@mpCenterLonF = 180.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 360.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.

   ressst = resrc
   ressst@mpMinLonF = 0.
   ressst@mpMaxLonF = 360.
   ressst@mpMaxLatF = 90.
   ressst@mpMinLatF = -20.

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

   ressnow = resrc
   ressnow@mpMinLonF = 0.
   ressnow@mpMaxLonF = 360.
   ressnow@mpMinLatF = 0.
   ressnow@mpMaxLatF = 90.
   ressnow@mpCenterLonF = 180.
   ressnow@cnMinLevelValF = -12
   ressnow@cnMaxLevelValF = 12
   ressnow@cnLevelSpacingF = 1

   ;Correlation res setting
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
   rescor@cnLevels = (/-0.290,0.290/)   ;95%

   ;Vector res setting
   resV = res
   resV@vcRefMagnitudeF = 1.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.53
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.0               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.01

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopRight"

;**************************************************
  ; Add Shapefile 
   lnres = True
   lnres@gsLineColor      = "gray12"
   lnres@gsLineThicknessF = 1.0

   ; dir = "/mnt/f/Programming/NCL/shp/"
   ; filename1 = "CHN_adm_shp/CHN_adm0.shp"
   ; filename2 = "TWN_adm_shp/TWN_adm0.shp"
   ; filename3 = "HKG_adm_shp/HKG_adm0.shp"

  ; Polyline Setting
   ; Wxpts = (/WlonL, WlonL, WlonR, WlonR, WlonL/)
   ; Wypts = (/WlatS, WlatN, WlatN, WlatS, WlatS/)

   ; Cxpts = (/ClonL, ClonL, ClonR, ClonR, ClonL/)
   ; Cypts = (/ClatS, ClatN, ClatN, ClatS, ClatS/)

   ; Expts = (/ElonL, ElonL, ElonR, ElonR, ElonL/)
   ; Eypts = (/ElatS, ElatN, ElatN, ElatS, ElatS/)

   ; plres = True
   ; plres@gsLineColor = "red"
   ; plres@gsLineThicknessF = 2.0
   ; plres@gsLineLabelString = "sce"

   ; dum = new(dimsizes(Wxpts)-1, graphic)
   ; dum2 = new(dimsizes(Cxpts)-1, graphic)
   ; dum3 = new(dimsizes(Expts)-1, graphic)

;***********************************************
; pc1 regression(sat,slp,wind)
     resrc@cnMinLevelValF = -2.
     resrc@cnMaxLevelValF = 2.
     resrc@cnLevelSpacingF = 0.1

     pc1_u_rc = mask(pc1_u_rc, pc1_uv_rc.gt.0.2, True)
     pc1_v_rc = mask(pc1_v_rc, pc1_uv_rc.gt.0.2, True)
     resrc@gsnLeftString = "(a) PC1: SAT+Wind(850hpa)"
     airrc = gsn_csm_contour_map(wks, pc1_sat_rc, resrc)
     aircor = gsn_csm_contour(wks, pc1_sat_cor, rescor)
     windrc = gsn_csm_vector(wks, pc1_u_rc, pc1_v_rc, resV)
     ; slprc = gsn_csm_contour(wks, pc1_slp_rc(n,:,:), resrc2)
     ; slprc = ColorNegDashZeroPosContour(slprc,"blue","transparent","red")
     overlay(airrc, windrc)
     overlay(airrc, aircor)

     resrc@cnMinLevelValF = -3.6
     resrc@cnMaxLevelValF = 3.6
     resrc@cnLevelSpacingF = 0.2
     resrc@gsnLeftString = "PC1: SLP"
     slprc = gsn_csm_contour_map(wks, pc1_slp_rc, resrc)
     slpcor = gsn_csm_contour(wks, pc1_slp_cor, rescor)
     line = gsn_csm_contour(wks, pc1_slp_rc, resrc2)
     overlay(slprc, line)
     overlay(slprc, slpcor)
     draw(slprc)
     frame(wks)

     resrc@cnMinLevelValF = -36.
     resrc@cnMaxLevelValF = 36.
     resrc@cnLevelSpacingF = 2
     resrc@gsnLeftString = "(b) PC1: Z500"
     zrc = gsn_csm_contour_map(wks, pc1_z500_rc, resrc)
     zcor = gsn_csm_contour(wks, pc1_z500_cor, rescor)
     line = gsn_csm_contour(wks, pc1_z500_rc, resrc2)
     overlay(zrc, line)
     overlay(zrc, zcor)

     plotnew = new(2,"graphic")
     plotnew(0) = airrc
     plotnew(1) = zrc
     gsn_panel(wks, plotnew, (/2,1/), resP)


    ; pc1_u_rc = mask(pc1_u_rc, pc1_uv_rc.gt.0.3, True)
    ; pc1_v_rc = mask(pc1_v_rc, pc1_uv_rc.gt.0.3, True)
    ;  resrc@gsnLeftString = "(a) PC1: SAT+Wind(850hpa)"
    ;  airrc = gsn_csm_contour_map(wks, pc1_sat_rc, resrc)
    ;  aircor = gsn_csm_contour(wks, pc1_sat_cor, rescor)
    ;  windrc = gsn_csm_vector(wks, pc1_u_rc, pc1_v_rc, resV)
    ;  ; slprc = gsn_csm_contour(wks, pc1_slp_rc(n,:,:), resrc2)
    ;  ; slprc = ColorNegDashZeroPosContour(slprc,"blue","transparent","red")
    ;  overlay(airrc, windrc)
    ;  overlay(airrc, aircor)
    ;  draw(airrc)
    ;  frame(wks)

     ressst@cnMinLevelValF = -0.5
     ressst@cnMaxLevelValF = 0.5
     ressst@cnLevelSpacingF = 0.05
     ressst@gsnLeftString = "PC1: SST OND"
     sstrc = gsn_csm_contour_map(wks, pc1_sst_rc, ressst)
     sstcor = gsn_csm_contour(wks, pc1_sst_cor, rescor)
     draw(sstrc)
     frame(wks)

   ;Spring(MAM) SCE Correlation Map
   ressnow@gsnLeftStringFontHeightF = 0.02
   ressnow@gsnLeftString = "PC1: SCE MAM"
   snowrc = gsn_csm_contour_map(wks, pc1_sce_rc,ressnow)
   snowcor = gsn_csm_contour(wks, pc1_sce_cor, rescor) 
   overlay(snowrc, snowcor)
   draw(snowrc)
   frame(wks)


end
