load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
;***
   begin
;***
   ; yrstrt =197001
   ; yrlast =201412
   yrstrt =197201
   yrlast =200912

   latS     = -90.
   latN     = 90.
   lonL     = 0.
   lonR     = 360.

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

   t = ispan(yrstrt/100, yrlast/100, 1)
   ;year = ispan(1972, 2009, 1)
;*********************************************** 
   datapath = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"
   snowpath = "/public/home/charlesxiami/data/snow/"
;********************************************
   wks=gsn_open_wks("pdf", plotpath+"pc1_reg_1972-2009")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;************************************************
   airdata = addfile(datapath+"air.mon.mean.nc", "r")
   slpdata = addfile(datapath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(datapath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(datapath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(datapath+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(datapath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(datapath+"nlwrs.sfc.mon.mean.nc", "r")
   sstdata = addfile(datapath+"sst.mnmean.v4.nc", "r")
   soilwdata = addfile(datapath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(datapath+"tcdc.eatm.mon.mean.nc", "r")

   filesnow = "/public/home/charlesxiami/data/snow/snow.nc"
   snowdata = addfile(filesnow,"r")
   
   setfileoption("bin","ReadByteOrder","LittleEndian")
   binfilename = snowpath+"/swe/EASE_SWE/swe.mam.bin"
   swe_mam = fbindirread(binfilename, 0, (/29,721,721/), "float")

   pc1_all = asciiread(indexpath+"pc1_1972-2009.txt", -1, "float")
   pc1_all_45 = asciiread(indexpath+"pc1.txt", -1, "float")
   print("corre =  "+escorc(pc1_all_45(2:39), pc1_all))
   print("  pc1_38_years"+"    pc1_45_years")
   print("Avg= "+dim_avg(pc1_all)+"   "+dim_avg(pc1_all_45))
   print("Std= "+dim_stddev(pc1_all)+"   "+dim_stddev(pc1_all_45))
   print("Max= "+dim_max(pc1_all)+"   "+dim_max(pc1_all_45))
   print("Min= "+dim_min(pc1_all)+"   "+dim_min(pc1_all_45))

   setfileoption("bin","ReadByteOrder","LittleEndian")
   lat2d = fbindirread("$HOME/data/snow/swe/EASE-Grid/NLLATLSB", 0, (/721,721/), "integer")
   lon2d = fbindirread("$HOME/data/snow/swe/EASE-Grid/NLLONLSB", 0, (/721,721/), "integer")
   lat2d = lat2d/100000
   lon2d = lon2d/100000
   lat2d@_FillValue = 14316
   lon2d@_FillValue = 14316
   printMinMax(lat2d, False)
   printMinMax(lon2d, False)

   printVarSummary(swe_mam)

;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print(YYYYMM(iStrt)+"||"+YYYYMM(iLast))

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)
   print(YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))

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

   snow_mon = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   snow_mam_climate = 100*dim_avg_n_Wrap(snow_mam, 0)
   copy_VarCoords(snow_mam(0,:,:), snow_mam_climate)

   ; ndim = dimsizes(swe_mon(0,:,:))
   ; swe_mam = swe_mon(0:28,:,:)
   ; do i = 0, 28
   ;    do j = 0, ndim(0) -1
   ;      do k = 0, ndim(1) -1
   ;  swe_mam(i,j,k) = (swe_mon(2+2+i*12,j,k)+swe_mon(2+3+i*12,j,k)+swe_mon(2+4+i*12,j,k))/3.0
   ;      end do
   ;    end do
   ; end do  
   ; printVarSummary(swe_mam)

   sat_region = air_mam(:,{20:80},{80:140})
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
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    pc1 = wgt_runave_Wrap(pc1_all, wgt, 0)
    satindex_hf = wgt_runave_Wrap(satindex, wgt, 0)
    ;air_mam = wgt_runave_n_Wrap(air_mam, wgt, 0, 0)
    ;slp_mam = wgt_runave_n_Wrap(slp_mam, wgt, 0, 0)
    ;snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
    ;sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)

    ; low frequency
    ihp = 0  
    wts = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    pc1_lf = wgt_runave_Wrap(pc1_all, wts, 0)
    ;print(pc1_lf)

   ;********************************************
; Regression and Correlation
    pc1_sat_rc = regCoef(pc1(:),air_mam(lat|:,lon|:,time|:))
    pc1_sat_cor = escorc(pc1(:),air_mam(lat|:,lon|:,time|:))
    pc1_slp_rc = regCoef(pc1(:),slp_mam(lat|:,lon|:,time|:))
    pc1_slp_cor = escorc(pc1(:),slp_mam(lat|:,lon|:,time|:))
   pc1_z500_rc = regCoef(pc1(:),z500_mam(lat|:,lon|:,time|:))
   pc1_z500_cor = escorc(pc1(:),z500_mam(lat|:,lon|:,time|:))
   pc1_z200_rc = regCoef(pc1(:),z200_mam(lat|:,lon|:,time|:))
   pc1_z200_cor = escorc(pc1(:),z200_mam(lat|:,lon|:,time|:))
      pc1_u_rc = regCoef(pc1(:),u_mam(lat|:,lon|:,time|:))
      pc1_u_cor = escorc(pc1(:),u_mam(lat|:,lon|:,time|:))
      pc1_v_rc = regCoef(pc1(:),v_mam(lat|:,lon|:,time|:))
      pc1_v_cor = escorc(pc1(:),v_mam(lat|:,lon|:,time|:))
  ;SCE  only Correlation
    pc1_sce_rc = 100*regCoef(pc1(:),snow_mam(lat|:,lon|:,time|:))
    pc1_sce_cor = escorc(pc1(:),snow_mam(lat|:,lon|:,time|:))

    pc1_swe_cor = escorc_n(pc1(6:34), swe_mam, 0, 0)
    copy_VarCoords(swe_mam(0,:,:), pc1_swe_cor)
    pc1_swe_cor@lon2d = lon2d
    pc1_swe_cor@lat2d = lat2d
    printVarSummary(pc1_swe_cor)

    copy_VarCoords(air_mam(0,:,:), pc1_sat_rc(:,:))
    copy_VarCoords(air_mam(0,:,:), pc1_sat_cor(:,:))
    copy_VarCoords(slp_mam(0,:,:), pc1_slp_rc(:,:))
    copy_VarCoords(slp_mam(0,:,:), pc1_slp_cor(:,:))
    copy_VarCoords(z500_mam(0,:,:), pc1_z500_rc(:,:))
    copy_VarCoords(z500_mam(0,:,:), pc1_z500_cor(:,:))
    copy_VarCoords(z200_mam(0,:,:), pc1_z200_rc(:,:))
    copy_VarCoords(z200_mam(0,:,:), pc1_z200_cor(:,:))
    copy_VarCoords(u_mam(0,:,:), pc1_u_rc(:,:))
    copy_VarCoords(u_mam(0,:,:), pc1_v_rc(:,:))
    copy_VarCoords(snow_mam(0,:,:), pc1_sce_rc(:,:))
    copy_VarCoords(snow_mam(0,:,:), pc1_sce_cor(:,:))

    pc1_uv_rc = sqrt(pc1_u_rc^2+pc1_v_rc^2)
    copy_VarCoords(pc1_u_rc, pc1_uv_rc)
    printVarSummary(pc1_uv_rc)

;********************************************
;Time Series plot
;********************************************
     rts           = True
     rts@gsnDraw   = False       ; don't draw yet
     rts@gsnFrame  = False       ; don't advance frame yet
     rts@gsnScale  = True        ; force text scaling               
     rts@vpHeightF = 0.35        ; Changes the aspect ratio
     rts@vpWidthF  = 0.85
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
     rts1@tmXBValues = ispan(1975, 2005, 5)
     rts1@tmXBLabels = ispan(1975, 2005, 5)
     rts1@tmXBMinorValues = ispan(1972, 2009, 1)
     rts1@tmXTOn = False
     rts1@tmYROn = False
     rts1@tiXAxisString = "Time (Year)"
     rts1@tiYAxisString = " "
     rts1@tiXAxisFontHeightF = 0.02
     rts1@tiYAxisFontHeightF = 0.02
     rts1@trXMinF = 1973.5
     rts1@trXMaxF = 2007.5
     rts1@trYMinF = -2.0
     rts1@trYMaxF = 2.0

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
     rts1@gsnRightString = "Cor ="+ sprintf("%5.2f", escorc(pc1, satindex_hf))
     ts_pc1 = gsn_csm_xy(wks, t, pc1, rts1)

     delete(rts1@gsnAboveYRefLineColor)
     delete(rts1@gsnBelowYRefLineColor)

     rts1@gsnXYBarChartBarWidth = 0.66
     ts_sati = gsn_csm_xy(wks, t, satindex_hf, rts1)

     overlay(ts_pc1, ts_sati)
     draw(ts_pc1)
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
   resrc@pmLabelBarOrthogonalPosF = 0.10
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False
   resrc@cnMinLevelValF = -2.
   resrc@cnMaxLevelValF = 2.
   resrc@cnLevelSpacingF = 0.1
   resrc@mpFillOn = False
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@mpCenterLonF = 180.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.

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
   ressnow@mpMinLonF = 0
   ressnow@mpMaxLonF = 150
   ressnow@mpMaxLatF = 80
   ressnow@mpMinLatF = 20
   ressnow@mpCenterLonF = 180.
   ressnow@cnMinLevelValF = -1
   ressnow@cnMaxLevelValF = 1
   ressnow@cnLevelSpacingF = 0.1

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
   rescor@cnLevels = (/-0.320,0.320/)   ;95%

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
   resP@amJust = "TopLeft"
   resP@gsnPanelLabelBar = True
   resP@pmLabelBarWidthF = 0.6

;**************************************************
  ; Add Shapefile 
   lnres = True
   lnres@gsLineColor      = "gray12"
   lnres@gsLineThicknessF = 1.0

   dir = "/mnt/f/Programming/NCL/shp/"
   filename1 = "CHN_adm_shp/CHN_adm0.shp"
   filename2 = "TWN_adm_shp/TWN_adm0.shp"
   filename3 = "HKG_adm_shp/HKG_adm0.shp"

  ; Polyline Setting
   Wxpts = (/WlonL, WlonL, WlonR, WlonR, WlonL/)
   Wypts = (/WlatS, WlatN, WlatN, WlatS, WlatS/)

   Cxpts = (/ClonL, ClonL, ClonR, ClonR, ClonL/)
   Cypts = (/ClatS, ClatN, ClatN, ClatS, ClatS/)

   Expts = (/ElonL, ElonL, ElonR, ElonR, ElonL/)
   Eypts = (/ElatS, ElatN, ElatN, ElatS, ElatS/)

   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 2.0
   plres@gsLineLabelString = "sce"

   dum = new(dimsizes(Wxpts)-1, graphic)
   dum2 = new(dimsizes(Cxpts)-1, graphic)
   dum3 = new(dimsizes(Expts)-1, graphic)
   dum4 = new(dimsizes(Expts)-1, graphic)

;***********************************************
   ;Spring(MAM) SCE Correlation Map
   ressnow@gsnLeftStringFontHeightF = 0.02
   ressnow@lbLabelBarOn = False
   ressnow@gsnLeftString = "PC1: Correlation SCE"
   plotcn = gsn_csm_contour_map(wks, pc1_sce_cor,ressnow)
   plotsig = gsn_csm_contour(wks, pc1_sce_cor, rescor)
   overlay(plotcn, plotsig)
    ;add polyline 
    do i = 0, dimsizes(Wxpts)-2
        dum(i) = gsn_add_polyline(wks, plotcn, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    do i = 0, dimsizes(Expts)-2
        dum2(i) = gsn_add_polyline(wks, plotcn, Expts(i:i+1), Eypts(i:i+1), plres)
    end do
    draw(plotcn)
    frame(wks)

    ; ressnow@sfXArray     = lon2d
    ; ressnow@sfYArray     = lat2d
    ressnow@trGridType = "TriangularMesh"
    ressnow@cnFillMode = "RasterFill"
    ressnow@gsnLeftString = "PC1: Correlation SWE"
    rescor@trGridType = "TriangularMesh"
    plotswe = gsn_csm_contour_map(wks, pc1_swe_cor, ressnow)
    plotsig2 = gsn_csm_contour(wks, pc1_swe_cor, rescor)
    overlay(plotswe, plotsig2)
    do i = 0, dimsizes(Wxpts)-2
        dum3(i) = gsn_add_polyline(wks, plotswe, Wxpts(i:i+1), Wypts(i:i+1), plres)
    end do
    ; do i = 0, dimsizes(Expts)-2
    ;     dum2(i) = gsn_add_polyline(wks, plotcn, Cxpts(i:i+1), Cypts(i:i+1), plres)
    ; end do
    do i = 0, dimsizes(Expts)-2
        dum4(i) = gsn_add_polyline(wks, plotswe, Expts(i:i+1), Eypts(i:i+1), plres)
    end do

    ; ressnow@cnLevelSelectionMode = "AutomaticLevels"
    ; ressnow@gsnLeftString = "CPC Snow MAM Climate"
    ; plot_climate = gsn_csm_contour_map(wks, snow_mam_climate, ressnow)
    ; draw(plot_climate)
    ; frame(wks)

  ; pc1 regression(sat,slp,wind)
     resrc@gsnLeftString = "(a) PC1: SAT+Wind(850hpa)"
     airrc = gsn_csm_contour_map(wks, pc1_sat_rc, resrc)
     aircor = gsn_csm_contour(wks, pc1_sat_cor, rescor)
     windrc = gsn_csm_vector(wks, pc1_u_rc, pc1_v_rc, resV)
     ; slprc = gsn_csm_contour(wks, pc1_slp_rc(n,:,:), resrc2)
     ; slprc = ColorNegDashZeroPosContour(slprc,"blue","transparent","red")
     overlay(airrc, windrc)
     overlay(airrc, aircor)

     resrc@cnMinLevelValF = -4.0
     resrc@cnMaxLevelValF = 4.0
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

     panelsnow = new(2,"graphic")
     panelsnow(0) = plotcn
     panelsnow(1) = plotswe
     gsn_panel(wks, panelsnow, (/2,1/), resP)

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
     draw(airrc)
     frame(wks)


end
