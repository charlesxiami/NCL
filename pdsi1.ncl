;***
   begin
;***
   yrstrt = 187001
   yrlast = 201712

   latS = -90
   latN = 90
   lonL = 0
   lonR = 360

   cn_northN = 42
   cn_northS = 35
   cn_northL = 110
   cn_northR = 120

   t = ispan(yrstrt/100, yrlast/100, 1)

;*********************************************** 
   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/sce/"
   indexpath = "$HOME/data/index/"
   plotpath = "$HOME/output/"
   precpath = "$HOME/data/precip/PREC/"
;********************************************
   wks_type          = "pdf"
   ;wks_type@wkOrientation = "landscape"
   ; wks_type@wkPaperHeightF = 11
   ; wks_type@wkPaperWidthF  = 8.5
   wks_type@wkPaperSize = "A4"

   ; wks_type          = "png"
   ; wks_type@wkWidth  =  2500
   ; wks_type@wkHeight =  2500

   wks = gsn_open_wks(wks_type, plotpath+"pdsi1")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
   gsn_reverse_colormap(wks)
;************************************************
   sstdata = addfile(nceppath+"sst.mnmean.nc", "r")
   pdsifile = addfile("$HOME/data/pdsi/pdsi.mon.nc", "r")
   pdsi_latlon = pdsifile->pdsi

   ; pdsi_table = readAsciiTable(indexpath+"pdsipm_ob.txt", 520, "float", (/0,0/))
   ; pdsi_table!0 = "time"
   ; pdsi_table!1 = "station"

   ; ; pdsi_time = yyyymmdd_time(1962, 2013, "float")
   ; ; pdsi_time!0 = "time"
   ; ; pdsi_time@long_name = "time"
   ; ; pdsi_time@units = "month"
   ; ; pdsi_table&time = pdsi_time
   
   ; ; pdsi_station = asciiread(indexpath+"pdsi_china_station.txt", -1, "float")

   ; cn_station_table = asciiread(indexpath+"station.csv", -1, "string")
   ; cn_part = str_get_field(cn_station_table, 4, ",")
   ; ndim = dimsizes(cn_part)
   ; cn_lon = stringtofloat(cn_part(1:ndim-1))
   ; cn_part = str_get_field(cn_station_table, 5, ",")
   ; cn_lat = stringtofloat(cn_part(1:ndim-1))
  
   ; glon = ispan(tointeger(min(cn_lon)), tointeger(max(cn_lon))+1, 1)
   ; glon!0 = "lon"
   ; glon@long_name = "longitude"
   ; glon@units = "degrees_east"

   ; glat = ispan(tointeger(min(cn_lat)), tointeger(max(cn_lat))+1, 1)
   ; glat!0 = "lat"
   ; glat@long_name = "latitude"
   ; glat@units = "degrees_north"

   ; rscan = (/10,5,3/)
   ; option = False
   ; pdsi_latlon = obj_anal_ic_Wrap(cn_lon, cn_lat, pdsi_table, \
   ;                                      glon, glat, rscan, option)

   ; month_time = yyyymm_time(1962, 2013, "integer")
   ; month_time!0 = "time"
   ; month_time@long_name = "time"
   ; month_time@units = "month"
   ; pdsi_latlon&time = month_time
   pdsi_son = month_to_season(pdsi_latlon, "SON")

   pdsi_nc_son = pdsi_son(:,{cn_northS:cn_northN},{cn_northL:cn_northR})
   pdsi_nci = wgt_areaave_Wrap(pdsi_nc_son, 1.0, 1.0, 1)
   pdsi_nci = dim_rmvmean_Wrap(pdsi_nci)
   pdsi_nci = -1.0*pdsi_nci
   pdsi_nci = dim_standardize_Wrap(pdsi_nci, 1)
   
   time_pdsi = ispan(1962, 2013, 1)

   neg_ind = ind(pdsi_nci.le.-1.0)
   ; print(time_pdsi(neg_ind))
   ; pdsi_nci_drought = pdsi_nci(neg_ind)

   ; pdo_pos = (/1980,1981,1982,1986,1991/)
   ; pdo_neg = (/1965,1966,1972,1997,1998,1999,2000,2001,2002,2006,2009/)

   pdo_pos = ispan(1976, 2001, 1)
   pdo_neg = new(dimsizes(time_pdsi) - dimsizes(pdo_pos)-1, "float")
   pdo_neg(0:13) = ispan(1962, 1975, 1)
   pdo_neg(14:24) = ispan(2003, 2013, 1)

   ; pdo_pos = (/1979,1980,1981,1982,1983,1984,1986,1987,1989,1991, \
   ;            1992,1993,1997,1998,1999,2000,2001/)
   ; pdo_neg = (/1962,1965,1966,1968,1970,1971,1972,1975,2005,2006,2009/)

   pdsi_drought_year = (/1965,1966,1972,1980,1981,1982,1986,1991,1997,1998, \
                       1999,2000,2001,2002,2006,2009/)

   pdo_pos_ind = new(dimsizes(pdo_pos), "integer")
   do i = 0, dimsizes(pdo_pos) - 1
      ; do j = 0, dimsizes(time_pdsi)
        pdo_pos_ind(i) = ind(time_pdsi.eq.pdo_pos(i))
   end do

   pdo_neg_ind = new(dimsizes(pdo_neg), "integer")
   do i = 0, dimsizes(pdo_neg) - 1
      ; do j = 0, dimsizes(time_pdsi)
        pdo_neg_ind(i) = ind(time_pdsi.eq.pdo_neg(i))
   end do

   pdsi_drought_ind = new(dimsizes(pdsi_drought_year), "integer")
   do i = 0, dimsizes(pdsi_drought_year) - 1
        pdsi_drought_ind(i) = ind(time_pdsi.eq.pdsi_drought_year(i))
   end do

   pdsi_pdo_pos = pdsi_son(pdo_pos_ind,:,:)
   pdsi_pdo_neg = pdsi_son(pdo_neg_ind,:,:)
   pdsi_drought = pdsi_son(pdsi_drought_ind,:,:)

   pdsi_nci_pos = pdsi_nci(pdo_pos_ind)
   pdsi_nci_neg = pdsi_nci(pdo_neg_ind)

   ; print(time_pdsi(pdo_pos_ind))
   ; print(time_pdsi(pdo_neg_ind))

   ; printVarSummary(pdsi_nci_pos)
   ; printVarSummary(pdsi_nci_neg)
;**************************************************************
;Composite Analysis
;**************************************************************
   ; pdsi_pdo_pos_avg = dim_avg_n_Wrap(pdsi_pdo_pos, 0)
   ; pdsi_pdo_neg_avg = dim_avg_n_Wrap(pdsi_pdo_neg, 0)
   ; pdsi_drought_avg = dim_avg_n_Wrap(pdsi_drought, 0)
   ; pdsi_son_avg = dim_avg_n_Wrap(pdsi_son, 0)

   ; pdsi_pdo_pos_ano = pdsi_pdo_pos_avg - pdsi_son_avg
   ; pdsi_pdo_neg_ano = pdsi_pdo_neg_avg - pdsi_son_avg
   ; pdsi_drought_ano = pdsi_drought_avg - pdsi_son_avg
   ; copy_VarCoords(pdsi_pdo_pos(0,:,:), pdsi_pdo_pos_ano)
   ; copy_VarCoords(pdsi_pdo_pos(0,:,:), pdsi_pdo_neg_ano)
   ; copy_VarCoords(pdsi_drought(0,:,:), pdsi_drought_ano)

   ; aveX = dim_avg_n_Wrap(pdsi_pdo_pos, 0)
   ; aveY = dim_avg_n_Wrap(pdsi_son, 0)
   ; varX = dim_variance_n_Wrap(pdsi_pdo_pos, 0)
   ; varY = dim_variance_n_Wrap(pdsi_son, 0)
   ; sX   = dimsizes(pdsi_pdo_pos(:,0,0))
   ; sY   = dimsizes(pdsi_son(:,0,0))
   ; iflag   = True
   ; tval_opt= False
   ; prob_pos = ttest(aveX,varX,sX, aveY,varY,sY, iflag, tval_opt)
   ; copy_VarCoords(pdsi_pdo_pos(0,:,:), prob_pos)

   ; aveX = dim_avg_n_Wrap(pdsi_pdo_neg, 0)
   ; aveY = dim_avg_n_Wrap(pdsi_son, 0)
   ; varX = dim_variance_n_Wrap(pdsi_pdo_neg, 0)
   ; varY = dim_variance_n_Wrap(pdsi_son, 0)
   ; sX   = dimsizes(pdsi_pdo_neg(:,0,0))
   ; sY   = dimsizes(pdsi_son(:,0,0))
   ; iflag   = True
   ; tval_opt= False
   ; prob_neg = ttest(aveX,varX,sX, aveY,varY,sY, iflag, tval_opt)
   ; copy_VarCoords(pdsi_pdo_neg(0,:,:), prob_neg)

   ; ; printMinMax(prob_pos, 0)
   ; ; printMinMax(prob_neg, 0)

   ; aveX := dim_avg_n_Wrap(pdsi_drought, 0)
   ; aveY := dim_avg_n_Wrap(pdsi_son, 0)
   ; varX := dim_variance_n_Wrap(pdsi_drought, 0)
   ; varY := dim_variance_n_Wrap(pdsi_son, 0)
   ; sX   := dimsizes(pdsi_drought(:,0,0))
   ; sY   := dimsizes(pdsi_son(:,0,0))
   ; prob_drought = ttest(aveX,varX,sX, aveY,varY,sY, iflag, tval_opt)
   ; copy_VarCoords(pdsi_drought(0,:,:), prob_drought)
   ; printMinMax(prob_drought({cn_northS:cn_northN},{cn_northL:cn_northR}), 0)
;****************************************************
   YYYYMM = cd_calendar(sstdata->time, 1)
   ; printMinMax(YYYYMM, 0)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   ; print(YYYYMM(iStrt)+"---"+YYYYMM(iLast))

;*****************************************************
;*****************************************************
; Filter 
;*****************************************************
   ; high frequence component 
    ihp = 1
    fca = 1.0/10.0
    fcb= -999.
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
   ;  pc1 = wgt_runave_Wrap(pc1_all, wgt, 0)
   ;  satindex_hf = wgt_runave_Wrap(satindex, wgt, 0)
   ;  ;air_mam = wgt_runave_n_Wrap(air_mam, wgt, 0, 0)
   ;  ;slp_mam = wgt_runave_n_Wrap(slp_mam, wgt, 0, 0)
   ;  ;snow_mam = wgt_runave_n_Wrap(snow_mam, wgt, 0, 0)
   ;  ;sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)

    ; low frequency
    ihp = 0  
    wts_lf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    ; pc1_lf = wgt_runave_Wrap(pc1_all, wts, 0)
    ; pdo_son_lf = wgt_runave_Wrap(pdo_son, wts_lf, 0)

    ; pdo_son_runave = runave_Wrap(pdo_son, 11, 0)

;*******************************************************
; Regression and Correlation
;*******************************************************
  ;Pos
   pdsi_pos_reg = regCoef_n(pdsi_nci_pos, pdsi_pdo_pos, 0, 0)
   pdsi_pos_cor = escorc_n(pdsi_nci_pos, pdsi_pdo_pos, 0, 0)
   copy_VarCoords(pdsi_pdo_pos(0,:,:), pdsi_pos_reg)
   copy_VarCoords(pdsi_pdo_pos(0,:,:), pdsi_pos_cor)

   df   = onedtond(pdsi_pos_reg@nptxy, dimsizes(pdsi_pos_reg))  - 2
   tval = onedtond(pdsi_pos_reg@tval, dimsizes(pdsi_pos_reg))
   b    = tval
   b    = 0.5
   prob_reg_pos = betainc(df/(df+tval^2),df/2.0,b)
   copy_VarCoords(pdsi_pdo_pos(0,:,:), prob_reg_pos)

   ; df = nsize - 2
   ; r = pdo_sst_cor
   ; t    := r*sqrt((nsize-2)/(1-r^2))
   ; p    = student_t(t, df)
   ; copy_VarCoords(sst_mon(0,:,:), p)
  
  ;Neg
   pdsi_neg_reg = regCoef_n(pdsi_nci_neg, pdsi_pdo_neg, 0, 0)
   pdsi_neg_cor = escorc_n(pdsi_nci_neg, pdsi_pdo_neg, 0, 0)
   copy_VarCoords(pdsi_pdo_neg(0,:,:), pdsi_neg_reg)
   copy_VarCoords(pdsi_pdo_neg(0,:,:), pdsi_neg_cor)

   df   := onedtond(pdsi_neg_reg@nptxy, dimsizes(pdsi_neg_reg))  - 2
   tval := onedtond(pdsi_neg_reg@tval, dimsizes(pdsi_neg_reg))
   b    := tval
   b    = 0.5
   prob_reg_neg = betainc(df/(df+tval^2),df/2.0,b)
   copy_VarCoords(pdsi_pdo_neg(0,:,:), prob_reg_neg)

   ; printMinMax(prob_reg_pos, 0)
   ; printMinMax(prob_reg_neg, 0) 
;**********************************************************
;Res
;**********************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   ; res@vpHeightF = 3.0
   ; res@vpWidthF  = 0.8

   resrc = res
   resrc@gsnAddCyclic = False
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   ; resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.20
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False
   
   ;map_projection = (/"Orthographic", "Stereographic","LambertEqualArea","Gnomonic"/)
   ; resrc@mpProjection = "Satellite "
   ; resrc@mpLimitMode = "Angles"
   resrc@mpPerimOn = False
   resrc@mpOutlineOn = True
   resrc@mpDataBaseVersion = "MediumRes"
   resrc@mpDataSetName = "Earth..4"
   ; resrc@mpDataResolution = "Medium"
   resrc@mpOutlineSpecifiers = (/"China:states","Taiwan"/)
   ; resrc@mpCenterLonF = (cn_northL + cn_northR)/2
   ; ; resrc@mpCenterLatF = -10
   resrc@mpFillDrawOrder = "PostDraw"
   resrc@mpFillOn = True
   ; resrc@mpFillAreaSpecifiers        = (/"Land" ,"Water"/)
   ; resrc@mpSpecifiedFillColors       = (/"Transparent", "white"/)  
   resrc@mpAreaMaskingOn = True
   resrc@mpMaskAreaSpecifiers =(/"china:states","Taiwan"/)
   ; resrc@mpInlandWaterFillColor = "white"
   resrc@mpOceanFillColor = "white"
   resrc@mpLandFillColor="white"
   resrc@mpMinLonF = cn_northL-2
   resrc@mpMaxLonF = cn_northR+2
   resrc@mpMaxLatF = cn_northN+2
   resrc@mpMinLatF = cn_northS-2

   resrc@cnMinLevelValF = -2.4
   resrc@cnMaxLevelValF = 2.4
   resrc@cnLevelSpacingF = 0.1

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

   ;Correlation res setting
   rescor = True
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False
   rescor@cnMonoFillPattern = False
   rescor@cnMonoFillScale = True
   rescor@cnFillScaleF = 2.0
   rescor@cnFillDotSizeF = 0.004
   rescor@cnFillPatterns = (/17,-1/)
   rescor@cnLevels = (/0.05/)
   rescor@cnFillColors = (/1,1/)
   rescor@cnFillOpacityF = 0.3

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
   resP@gsnFrame = False
   resP@gsnMaximize = False
   resP@gsnPanelLabelBar = True
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@gsnPanelFigureStringsFontHeightF = 0.012
   resP@gsnPanelFigureStringsPerimOn = False
   resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   resP@amJust = "TopLeft"
   resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   resP@amParallelPosF = -0.50    ;X-axis
   resP@gsnPanelYWhiteSpacePercent = 5
   resP@gsnPanelXWhiteSpacePercent = 5

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
     rts1@gsnYRefLine = 0
     rts1@gsnAboveYRefLineColor = "blue"
     rts1@gsnBelowYRefLineColor = "red"
     ;rts1@gsnLeftString = "(b) PC1"
     ;rts1@tmXUseBottom = True
     rts1@tmXBMode = "Explicit"
     rts1@tmXTOn = False
     rts1@tmYROn = False
     rts1@tiXAxisString = "Time (Year)"
     rts1@tiYAxisString = " "
     rts1@tiXAxisFontHeightF = 0.02
     rts1@tiYAxisFontHeightF = 0.02
     rts1@trYMinF = -3.0
     rts1@trYMaxF = 6.0

     rts2 = rts   ; Line 
     rts2@xyDashPattern         = 1
     rts2@xyLineThicknessF      = 4.
     rts2@xyLineColor = "black"
     rts2@gsnYRefLine = 0.
     rts2@trYMinF = -2.0
     rts2@trYMaxF = 2.0
     rts2@gsnXRefLine = (/1977, 2002/)
     ; rts2@gsnYRefLine = dim_stddev(pdsi_nci)

     xpts = (/1962, 2013/)
     ypts = (/-1, -1/)
     plres = True
     plres@gsLineColor = "black"
     plres@gsLineDashPattern = 1

     dum = new(dimsizes(xpts), graphic)

     ts_bar = gsn_csm_xy(wks, time_pdsi, pdsi_nci, rts1)
     do i = 0, dimsizes(xpts) - 1
        dum(i) = gsn_add_polyline(wks, ts_bar, xpts, ypts, plres)
     end do
     draw(ts_bar)
     frame(wks)
     ; print(nci_std)

;***********************************************
;Plot

   ; plot = gsn_csm_contour_map(wks, pdsi_drought_ano, resrc)
   ; psig = gsn_csm_contour(wks, prob_drought, rescor)
   ; overlay(plot, psig)
   ; draw(plot)
   ; frame(wks)

   ; plot_panel = new(2, "graphic")

   ; resrc@gsnLeftString = "Drought PDO Pos"
   ; plot := gsn_csm_contour_map(wks, pdsi_pdo_pos_ano, resrc)
   ; psig := gsn_csm_contour(wks, prob_pos, rescor)
   ; overlay(plot, psig)
   ; plot_panel(0) = plot

   ; resrc@gsnLeftString = "Drought PDO Neg"
   ; plot := gsn_csm_contour_map(wks, pdsi_pdo_neg_ano, resrc)
   ; psig := gsn_csm_contour(wks, prob_neg, rescor)
   ; overlay(plot, psig)
   ; plot_panel(1) = plot

   ; gsn_panel(wks, plot_panel, (/1,2/), resP)
   ; frame(wks)


   resrc@gsnLeftString = "PDSI Reg PDO Pos"
   plot_pos = gsn_csm_contour_map(wks, pdsi_pos_reg, resrc)
   plot_cor = gsn_csm_contour(wks, prob_reg_pos, rescor)
   overlay(plot_pos, plot_cor)
   
   resrc@gsnLeftString = "PDSI Reg PDO Neg"
   plot_neg = gsn_csm_contour_map(wks, pdsi_neg_reg, resrc)
   plot_cor = gsn_csm_contour(wks, prob_reg_neg, rescor)
   overlay(plot_neg, plot_cor)

   plot_panel    = new(2, "graphic")
   plot_panel(0) = plot_pos
   plot_panel(1) = plot_neg
   gsn_panel(wks, plot_panel, (/1,2/), resP)




   system("date")

end
