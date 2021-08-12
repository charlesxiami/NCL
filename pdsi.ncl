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

   wks = gsn_open_wks(wks_type, plotpath+"pdsi")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")

;************************************************
   sstdata = addfile(nceppath+"sst.mnmean.nc", "r")

   ; pdo_table = readAsciiTable(indexpath+"PDO.latest.txt", 13, "float", (/34,20/))
   ; pdo_table2 = pdo_table(0:117,1:12)
   ; pdo = ndtooned(pdo_table2)
   ; pdo!0 = "time"
   ; pdo = dim_standardize_Wrap(pdo, 0)
   ; pdo_son = month_to_season(pdo, "SON")
   ; printVarSummary(pdo_son)

   pdsi_table = readAsciiTable(indexpath+"pdsipm_ob.txt", 520, "float", (/0,0/))
   pdsi_table!0 = "time"
   pdsi_table!1 = "station"

   ; pdsi_time = yyyymmdd_time(1962, 2013, "float")
   ; pdsi_time!0 = "time"
   ; pdsi_time@long_name = "time"
   ; pdsi_time@units = "month"

   ; pdsi_table&time = pdsi_time

   printVarSummary(pdsi_table)
   
   pdsi_station = asciiread(indexpath+"pdsi_china_station.txt", -1, "float")

   cn_station_table = asciiread(indexpath+"station.csv", -1, "string")
   cn_part = str_get_field(cn_station_table, 4, ",")
   ndim = dimsizes(cn_part)
   cn_lon = stringtofloat(cn_part(1:ndim-1))
   cn_part = str_get_field(cn_station_table, 5, ",")
   cn_lat = stringtofloat(cn_part(1:ndim-1))
  
   north_ind = ind(cn_lon.le.cn_northR.and.cn_lon.ge.cn_northL.and.cn_lat.le. \
                      cn_northN.and.cn_lat.ge.cn_northS)
   north_lon = cn_lon(north_ind)
   north_lat = cn_lat(north_ind)

   printMinMax(north_lon, 0)
   printMinMax(north_lat, 0)

   pdsi_north = pdsi_table(:,north_ind)

   ntime = dimsizes(pdsi_north(:,0))
   pdsi_north_son = new((/ntime/12,dimsizes(north_ind)/), "float")
   do i = 0, ntime/12 - 1
      pdsi_north_son(i,:) = dim_avg_n_Wrap(pdsi_north(i*12+8:i*12+10,:), 0)
   end do
   pdsi_north_son!0 = "time"
   printVarSummary(pdsi_north_son)


   pdsi_north_son_avg = dim_avg_n_Wrap(pdsi_north_son, 1)
   pdsi_north_son_avg_ano = dim_rmvmean_Wrap(pdsi_north_son_avg)
   ; pdsi_north_son_avg = dim_standardize_Wrap(pdsi_north_son_avg, 1)
   
   time_pdsi = ispan(1962, 2013, 1)
   pdo_pos = (/1980,1981,1982,1986,1991/)
   pdo_neg = (/1965,1966,1972,1997,1998,1999,2000,2001,2002,2006,2009/)

   pdsi_drought_year = (/1965,1966,1972,1997,1980,1981,1982,1986,1991, 1998, \
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

   pdsi_pdo_pos = pdsi_north_son(pdo_pos_ind,:)
   pdsi_pdo_neg = pdsi_north_son(pdo_neg_ind,:)
   pdsi_drought = pdsi_north_son(pdsi_drought_ind,:)

   pdsi_pdo_pos_avg = dim_avg_n_Wrap(pdsi_pdo_pos, 0)
   pdsi_pdo_neg_avg = dim_avg_n_Wrap(pdsi_pdo_neg, 0)
   pdsi_drought_avg = dim_avg_n_Wrap(pdsi_drought, 0)

   pdsi_pdo_pos_ano = pdsi_pdo_pos_avg - pdsi_drought_avg
   pdsi_pdo_neg_ano = pdsi_pdo_neg_avg - pdsi_drought_avg

   aveX = dim_avg_n_Wrap(pdsi_pdo_pos, 0)
   aveY = dim_avg_n_Wrap(pdsi_drought, 0)
   varX = dim_variance_n_Wrap(pdsi_pdo_pos, 0)
   varY = dim_variance_n_Wrap(pdsi_drought, 0)
   sX   = dimsizes(pdsi_pdo_pos(:,0))
   sY   = dimsizes(pdsi_drought(:,0))
   iflag   = True
   tval_opt= False
   prob_pos = ttest(aveX,varX,sX, aveY,varY,sY, iflag, tval_opt)
   printMinMax(prob_pos, 0)

   aveX = dim_avg_n_Wrap(pdsi_pdo_neg, 0)
   aveY = dim_avg_n_Wrap(pdsi_drought, 0)
   varX = dim_variance_n_Wrap(pdsi_pdo_neg, 0)
   varY = dim_variance_n_Wrap(pdsi_drought, 0)
   sX   = dimsizes(pdsi_pdo_neg(:,0))
   sY   = dimsizes(pdsi_drought(:,0))
   iflag   = True
   tval_opt= False
   prob_neg = ttest(aveX,varX,sX, aveY,varY,sY, iflag, tval_opt)
   printMinMax(prob_neg, 0)

   glon = ispan(110, 120, 1)
   glon!0 = "lon"
   glon@long_name = "longitude"
   glon@units = "degrees_east"

   glat = ispan(35, 42, 1)
   glat!0 = "lat"
   glat@long_name = "latitude"
   glat@units = "degrees_north"

   rscan = (/5,3,1/)
   option = False
   pdsi_pdo_pos_ano1 = obj_anal_ic_Wrap(north_lon, north_lat, pdsi_pdo_pos_ano, \
                                        glon, glat, rscan, option)
   pdsi_pdo_pos_ano1&lon = glon
   pdsi_pdo_pos_ano1&lat = glat
   prob_pos1 = obj_anal_ic_Wrap(north_lon, north_lat, prob_pos, \
                                        glon, glat, rscan, option)
   copy_VarCoords(pdsi_pdo_pos_ano1, prob_pos1)

   pdsi_pdo_neg_ano1 = obj_anal_ic_Wrap(north_lon, north_lat, pdsi_pdo_neg_ano, \
                                        glon, glat, rscan, option)
   pdsi_pdo_neg_ano1&lon = glon
   pdsi_pdo_neg_ano1&lat = glat
   prob_neg1 = obj_anal_ic_Wrap(north_lon, north_lat, prob_neg, \
                                        glon, glat, rscan, option)
   copy_VarCoords(pdsi_pdo_neg_ano1, prob_neg1)

;***************************************
   YYYYMM = cd_calendar(sstdata->time, 1)
   ; printMinMax(YYYYMM, 0)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print(YYYYMM(iStrt)+"---"+YYYYMM(iLast))

;********************************************
   
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

;********************************************
; Regression and Correlation
   ; pdo_sst_cor = escorc_n(pdo, sst_mon, 0, 0)
   ; copy_VarCoords(sst_mon(0,:,:), pdo_sst_cor)
   ; printVarSummary(pdo_sst_cor)
   
   ; df = nsize - 2
   ; r = pdo_sst_cor
   ; t    := r*sqrt((nsize-2)/(1-r^2))      
   ; p    = student_t(t, df)
   ; copy_VarCoords(sst_mon(0,:,:), p)
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
   resrc@pmLabelBarOrthogonalPosF = 0.50
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False
   
   ;map_projection = (/"Orthographic", "Stereographic","LambertEqualArea","Gnomonic"/)
   ; resrc@mpProjection = "Satellite "
   ; resrc@mpLimitMode = "Angles"
   resrc@mpPerimOn = False
   resrc@mpFillOn = True  
   resrc@mpOutlineOn = True
   ;resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@mpCenterLonF = (cn_northL + cn_northR)/2
   ; resrc@mpCenterLatF = -10
   resrc@mpMinLonF = cn_northL
   resrc@mpMaxLonF = cn_northR
   resrc@mpMaxLatF = cn_northN
   resrc@mpMinLatF = cn_northS

   resrc@cnMinLevelValF = -2
   resrc@cnMaxLevelValF = 2
   resrc@cnLevelSpacingF = 0.2

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
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/-1,17,-1/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False
   rescor@cnLevels = (/-0.05,0.05/)   ;95%

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
     
     ts_bar = gsn_csm_xy(wks, time_pdsi, pdsi_north_son_avg_ano, rts1)
     ; ts_line = gsn_csm_xy(wks, time_pdsi, pdo_son_lf, rts2)
     ; overlay(ts_bar, ts_line)
     draw(ts_bar)
     frame(wks)

     ; rts2@gsnXRefLine = (/1945, 1977, 2002/)
     ; ts_line2 = gsn_csm_xy(wks, time_pdsi, pdo_son_runave, rts2)
     ; draw(ts_line2)
     ; frame(wks)   

     ; ts_bar2 = gsn_csm_xy(wks, time_pdsi, pdo_son_runave, rts1)
     ; draw(ts_bar2)
     ; frame(wks)

;***********************************************
;Plot

   plot = gsn_csm_contour_map(wks, pdsi_pdo_pos_ano1, resrc)
   psig = gsn_csm_contour(wks, prob_pos1, rescor)
   overlay(plot, psig)
   draw(plot)
   frame(wks)

   plot = gsn_csm_contour_map(wks, pdsi_pdo_neg_ano1, resrc)
   psig = gsn_csm_contour(wks, prob_neg1, rescor)
   overlay(plot, psig)
   draw(plot)
   frame(wks)


   
end
