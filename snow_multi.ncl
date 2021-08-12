begin
  load "/public/home/charlesxiami/nclscript/undef_function/shapefile_utils.ncl"
   snowpath  = "/public/home/charlesxiami/data/snow/"
   plotpath  = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"
   shppath = "/public/home/charlesxiami/data/shapefile/"

  latS   =  20.
  latN   =  80.
  lonL   =  20.
  lonR   =  150.

  latS_TP = 24.98
  latN_TP = 46.13
  lonW_TP = 61.27
  lonE_TP = 105.24

  WlatS = 48
  WlatN = 58
  WlonL = 25
  WlonR = 50
  
  ElatS = 60
  ElatN = 70
  ElonL = 100
  ElonR = 125

   yrstrt =197301
   yrlast =200912

   sig = 0.320   ;95%
   ; sig1 = 0.497
   ; sig2 = 0.433
;*****************************************************
;I/O
;*****************************************************
   wks=gsn_open_wks("pdf", plotpath+"snow_multi")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")    ;cmp_b2r
;*************************************************
;Res
;*************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   resmap = True
   resmap@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)

   rts           = True
   rts@gsnDraw   = False      
   rts@gsnFrame  = False      
   rts@gsnScale  = True                
   rts@vpHeightF = 0.35       
   rts@vpWidthF  = 0.85
   rts@vpXF      = 0.10       
   rts@vpYF      = 0.75        
   rts@tiYAxisString = ""      
   rts@gsnLeftStringFontHeightF = 0.025
   rts@gsnYRefLine = 0.
   rts@tmYLLabelFontHeightF = 0.015
   rts@tmYLLabelFontHeightF = 0.015

   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = False
   resrc@pmLabelBarOrthogonalPosF = 0.5
   ;resrc@lbOrientation = "Vertical"
   resrc@cnInfoLabelOn = False
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = False
   resrc@mpMinLonF = lonL
   resrc@mpMaxLonF = lonR
   resrc@mpMinLatF = latS
   resrc@mpMaxLatF = latN
   resrc@gsnAddCyclic = False
   ;resrc@trGridType = "TriangularMesh"
   ;resrc@gsnPolar = "NH"
   ;resrc@mpMinLatF = 35
   ;resrc@cnFillMode = "RasterFill"
   resrc@cnLevelSelectionMode = "ManualLevels"


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
   rescor@cnLevels = (/-sig, sig/)

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

   plres = True
   plres@gsLineColor = "Blue"
   plres@gsLineThicknessF = 1.0

;-------------------------------------------------------------------
;Data read and process
   snow_rutger = addfile(snowpath+"RutgersSnow.mon.mean.nc", "r")
   snow_rutgerRegrid = addfile(snowpath+"snow.rutger.2.0deg.neareststod.nc", "r")
   snow_cpc  = addfile(snowpath+"snow.nc", "r")
   prec_zc = asciiread(indexpath+"precp_pc1_1973_2009_zhangchao.txt", -1, "float")
   tpfile = addfile(shppath+"TP_boundary/tp.shp", "r")
   ;print_shapefile_info(shppath+"TP_boundary/tp.shp")

   YYYYMM = cd_calendar(snow_rutger->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print(YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   snow_mon = snow_rutger->snowcover(iStrt:iLast,:,:)
   snow_mon@_FillValue = -999
   delete(snow_mon@missing_value)
   snow_mam = month_to_season(snow_mon, "MAM")
   
   snow_mon2 = snow_rutgerRegrid->snowcover(iStrt:iLast,:,:)
   snow_mam2 = month_to_season(snow_mon2, "MAM")

   YYYYMM2 = snow_cpc->time
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)
   print(YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))
   snow_mon3 = snow_cpc->Snow(iStrt2:iLast2,:,:)
   snow_mam3 = month_to_season(snow_mon3, "MAM")

   dim2 = dimsizes(snow_mon2)
   snow_march = snow_mon2(2:dim2(0)-1:12,:,:)
   snow_april = snow_mon2(3:dim2(0)-1:12,:,:)
   snow_may   = snow_mon2(4:dim2(0)-1:12,:,:)
   snow_am = snow_mam2
   snow_am = (snow_april+snow_may)/2.0
   snow_am@long_name = "AM SCE Rate"


;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1          ; 0=low pass, 1=high pass, 2=band-pass
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 7
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    ;pc1 = wgt_runave_Wrap(pc1_all, wgt, 0)
    ;snow_mam2  = wgt_runave_n_Wrap(snow_mam2, wgt, 0, 0)

;*************************************************
;Dtrend
    ; snow_mam2 = dtrend_leftdim(snow_mam2, False)
    ; snow_am = dtrend_leftdim(snow_am, False)
;*************************************************
   ;Bar Chart
   rts@gsnXYBarChart         = True
   rts@gsnAboveYRefLineColor = "red"
   rts@gsnBelowYRefLineColor = "blue"
   rts@gsnLeftString = "Precp PC1 ZC  " + yrstrt/100 +" - "+ yrlast/100
   rts@trYMaxF = 4.0
   rts@trYMinF = -4.0

   year = ispan(yrstrt/100, yrlast/100, 1)
   pc1 = gsn_csm_xy(wks, year, prec_zc, rts)
   draw(pc1)
   frame(wks)
;--------------------------------------------------------
   ;Ruger Regridded
   prec_zc = dim_standardize_Wrap(prec_zc, 0)

   prec_pc1_rutgerNew_rc  = regCoef_n(prec_zc, snow_mam2, 0, 0)
   prec_pc1_rutgerNew_cor = escorc_n(prec_zc, snow_mam2, 0, 0)
   copy_VarCoords(snow_mam2(0,:,:), prec_pc1_rutgerNew_rc)
   copy_VarCoords(snow_mam2(0,:,:), prec_pc1_rutgerNew_cor)

   ;CPC
   prec_pc1_cpc_rc  = 100.0*regCoef_n(prec_zc, snow_mam3, 0, 0)
   prec_pc1_cpc_cor = escorc_n(prec_zc, snow_mam3, 0, 0)
   copy_VarCoords(snow_mam3(0,:,:), prec_pc1_cpc_rc)
   copy_VarCoords(snow_mam3(0,:,:), prec_pc1_cpc_cor)

;--------------------------------------------------------
   resrc@cnMaxLevelValF = 10.
   resrc@cnMinLevelValF = -10.
   resrc@cnLevelSpacingF = 0.1

   resrc@gsnLeftString = "Reg PC1-SCE Rutger Regridded"
   plot_rutgerNew_rc  = gsn_csm_contour_map(wks, prec_pc1_rutgerNew_rc, resrc)
   plot_rutgerNew_cor = gsn_csm_contour(wks, prec_pc1_rutgerNew_cor, rescor)
   overlay(plot_rutgerNew_rc, plot_rutgerNew_cor)
   ; draw(plot_rutgerNew_rc)
   ; frame(wks)

   resrc@gsnLeftString = "Reg PC1-SCE CPC"
   plot_cpc_rc  = gsn_csm_contour_map(wks, prec_pc1_cpc_rc, resrc)
   plot_cpc_cor = gsn_csm_contour(wks, prec_pc1_cpc_cor, rescor)
   overlay(plot_cpc_rc, plot_cpc_cor)

   polytp0 = gsn_add_shapefile_polylines(wks, plot_rutgerNew_rc, shppath+"TP_boundary/tp.shp", plres)
   polytp1 = gsn_add_shapefile_polylines(wks, plot_cpc_rc, shppath+"TP_boundary/tp.shp", plres)

   panel1 = new(2, "graphic")
   panel1(0) = plot_rutgerNew_rc
   panel1(1) = plot_cpc_rc

   gsn_panel(wks, panel1, (/2,1/), resP)

;---------------------------------------------------------------------------------
   resrc@mpMinLonF = lonW_TP
   resrc@mpMaxLonF = lonE_TP
   resrc@mpMinLatF = latS_TP
   resrc@mpMaxLatF = latN_TP

; rutg_rc = shapefile_mask_data(prec_pc1_rutgerNew_rc,shppath+"TP_boundary/tp.shp",True)
; rutg_cor = shapefile_mask_data(prec_pc1_rutgerNew_cor,shppath+"TP_boundary/tp.shp",True)
;    resrc@gsnLeftString = "Reg PC1-SCE Rutger Regridded"
;    plot_rutg_rc_tp = gsn_csm_contour_map(wks, rutg_rc, resrc)
;    plot_rutg_cor_tp = gsn_csm_contour(wks, rutg_cor, rescor)
;    overlay(plot_rutg_rc_tp, plot_rutg_cor_tp)
;    draw(plot_rutg_rc_tp)
;    frame(wks)

; cpc_rc = shapefile_mask_data(prec_pc1_cpc_rc,shppath+"TP_boundary/tp.shp",True)
; cpc_cor = shapefile_mask_data(prec_pc1_cpc_cor,shppath+"TP_boundary/tp.shp",True)
;    resrc@gsnLeftString = "Reg PC1-SCE Rutger Regridded"
;    plot_cpc_rc_tp = gsn_csm_contour_map(wks, cpc_rc, resrc)
;    plot_cpc_cor_tp = gsn_csm_contour(wks, cpc_cor, rescor)
;    overlay(plot_cpc_rc_tp, plot_cpc_cor_tp)
;    draw(plot_cpc_rc_tp)
;    frame(wks)

   ; polytp2 = gsn_add_shapefile_polylines(wks, plot_rutg_rc_tp, shppath+"TP_boundary/tp.shp", plres)
   ; polytp3 = gsn_add_shapefile_polylines(wks, plot_cpc_cor_tp, shppath+"TP_boundary/tp.shp", plres)


   resrc@gsnLeftString = "Reg PC1-SCE Rutger Regridded Tibetan Plateau"
   plot_rutgerNew_rc  = gsn_csm_contour_map(wks, prec_pc1_rutgerNew_rc, resrc)
   plot_rutgerNew_cor = gsn_csm_contour(wks, prec_pc1_rutgerNew_cor, rescor)
   overlay(plot_rutgerNew_rc, plot_rutgerNew_cor)

   resrc@gsnLeftString = "Reg PC1-SCE CPC Tibetan Plateau"
   plot_cpc_rc  = gsn_csm_contour_map(wks, prec_pc1_cpc_rc, resrc)
   plot_cpc_cor = gsn_csm_contour(wks, prec_pc1_cpc_cor, rescor)
   overlay(plot_cpc_rc, plot_cpc_cor)

   polytp2 = gsn_add_shapefile_polylines(wks, plot_rutgerNew_rc, shppath+"TP_boundary/tp.shp", plres)
   polytp3 = gsn_add_shapefile_polylines(wks, plot_cpc_rc, shppath+"TP_boundary/tp.shp", plres)

   panel2 = new(2, "graphic")
   panel2(0) = plot_rutgerNew_rc
   panel2(1) = plot_cpc_rc
   
   gsn_panel(wks, panel2, (/2,1/), resP)
   

end