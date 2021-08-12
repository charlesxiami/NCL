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

   sig45 = 0.294

   t = ispan(yrstrt/100, yrlast/100, 1)
   ;year = ispan(1972, 2009, 1)
;*********************************************** 
   datapath = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"
;********************************************
   wks=gsn_open_wks("pdf", plotpath+"pc_long_sst")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;************************************************
   filesnow = "/public/home/charlesxiami/data/snow/snow.nc"
   snowdata = addfile(filesnow,"r")

   airdata = addfile(datapath+"air.mon.mean.nc", "r")

   sstdata = addfile(datapath+"sst.mnmean.nc", "r")
   
   pc1_all = asciiread(indexpath+"pc1_1948-2017.txt", -1, "float")
;**********************************************************
;Res
;**********************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   rts = res
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
   rts1 = rts  ; Bar Chart
   rts1@gsnXYBarChart         = True                  ; reference line
   rts1@gsnAboveYRefLineColor = "red"           
   rts1@gsnBelowYRefLineColor = "blue"   
   rts1@gsnLeftString = "PC1" 
   rts2 = rts   ; Line 
   rts2@xyDashPattern         = 1
   rts2@xyLineThicknessF      = 4.
   rts2@xyLineColor = "black"

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
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False
   resrc@cnMinLevelValF = -0.5
   resrc@cnMaxLevelValF = 0.5
   resrc@cnLevelSpacingF = 0.01
   resrc@mpFillOn = False
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@mpCenterLonF = 90.
   resrc@mpMinLonF = -90.
   resrc@mpMaxLonF = 270.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = -30.
   resrc@lbBoxSeparatorLinesOn = False

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
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False
   rescor@cnLevels = (/-sig45,sig45/)

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
   resP@gsnPanelLabelBar = True
   resP@gsnPanelFigureStringsFontHeightF = 0.012
   resP@gsnPanelFigureStringsPerimOn = True
   resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   resP@amJust = "TopLeft"
   resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   resP@amParallelPosF = -0.50    ;X-axis
   resP@pmLabelBarOrthogonalPosF = -0.015
   resP@lbBoxSeparatorLinesOn = False

;********************************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt_sst)
   iLast2  = ind(YYYYMM2.eq.yrlast_sst)
   print("sst  time: "+YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))

;****************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR})
   air_mam = month_to_season(air_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   sst_mam = month_to_season(sst_mon, "MAM")

   dim_sst = dimsizes(sst_mam)
   sst_jfmam = new((/5,dim_sst(0),dim_sst(1),dim_sst(2)/), "float")
   sst_jfmam(0,:,:,:) = sst_mon(0:dim_sst(0)*12-1:12,:,:)
   sst_jfmam(1,:,:,:) = sst_mon(1:dim_sst(0)*12-1:12,:,:)
   sst_jfmam(2,:,:,:) = sst_mon(2:dim_sst(0)*12-1:12,:,:)
   sst_jfmam(3,:,:,:) = sst_mon(3:dim_sst(0)*12-1:12,:,:)
   sst_jfmam(4,:,:,:) = sst_mon(4:dim_sst(0)*12-1:12,:,:)

   sst_9mon = new((/9,dim_sst(0)-1,dim_sst(1),dim_sst(2)/), "float")
   do i = 0, 8
    do j = 0, dim_sst(0) -2
    sst_9mon(i,j,:,:) = dim_avg_n_Wrap(sst_mon(i+7+(j*12):i+9+(j*12),:,:), 0)
     end do
   end do
   printVarSummary(sst_9mon)

;********************************************
; Filter 
;********************************************
   ; high frequence component 
    ihp = 1
    fca = 1.0/10.0
    fcb= -999.
    nsigma = 1.
    nwt= 7
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    pc1_hf = wgt_runave_Wrap(pc1_all, wgt, 0)
    ;air_mam = wgt_runave_n_Wrap(air_mam, wgt, 0, 0)
    sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)
    sst_jfmam = wgt_runave_n_Wrap(sst_jfmam, wgt, 0, 1)
    sst_9mon_hf = wgt_runave_n_Wrap(sst_9mon, wgt, 0, 1)

    ; low frequency
    ihp = 0  
    wts = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    pc1_lf = wgt_runave_Wrap(pc1_all, wts, 0)

   ;********************************************
; Regression and Correlation
    pc1_sat_rc = regCoef(pc1_all(:),air_mam(lat|:,lon|:,time|:))
    pc1_sat_cor = escorc(pc1_all(:),air_mam(lat|:,lon|:,time|:))
    copy_VarCoords(air_mam(0,:,:), pc1_sat_rc(:,:))
    copy_VarCoords(air_mam(0,:,:), pc1_sat_cor(:,:))

    ; pc1_sst_rc = regCoef_n(pc1_hf,sst_mam,0,0)
    ; pc1_sst_cor = escorc_n(pc1_hf,sst_mam,0,0)
    ; copy_VarCoords(sst_mam(0,:,:), pc1_sst_rc)
    ; copy_VarCoords(sst_mam(0,:,:), pc1_sst_cor)

    ; pc1_sst_jfmam_rc = regCoef_n(pc1_hf, sst_jfmam, 0, 1)
    ; pc1_sst_jfmam_cor = escorc_n(pc1_hf, sst_jfmam, 0, 1)
    pc1_sst9mon_rc = regCoef_n(pc1_hf, sst_9mon_hf, 0, 1)
    pc1_sst9mon_cor = escorc_n(pc1_hf, sst_9mon_hf, 0, 1)

;***********************************************
    plot_sstrc = new(9, "graphic")
    plot_sstcor = new(9, "graphic")
    do i = 0, 8
      copy_VarCoords(sst_mon(0,:,:), pc1_sst9mon_rc(i,:,:))
      copy_VarCoords(sst_mon(0,:,:), pc1_sst9mon_cor(i,:,:))
      plot_sstrc(i) = gsn_csm_contour_map(wks, pc1_sst9mon_rc(i,:,:), resrc)
      plot_sstcor(i) = gsn_csm_contour(wks, pc1_sst9mon_cor(i,:,:), rescor)
      overlay(plot_sstrc(i), plot_sstcor(i))
    end do
    gsn_panel(wks, plot_sstrc, (/3,3/), resP)

;Sub-period   1970-1987, 1989-2014
   ;  pc1_sst_jfmam_rc_p1 = regCoef_n(pc1_hf(0:17), sst_jfmam(:,0:17,:,:), 0, 1)
   ;  pc1_sst_jfmam_cor_p1 = escorc_n(pc1_hf(0:17), sst_jfmam(:,0:17,:,:), 0, 1)
   ;   do i = 0, 4
   ;     copy_VarCoords(sst_mon(0,:,:), pc1_sst_jfmam_rc_p1(i,:,:))
   ;     copy_VarCoords(sst_mon(0,:,:), pc1_sst_jfmam_cor_p1(i,:,:))

   ;     plot_sstrc(i) = gsn_csm_contour_map(wks, pc1_sst_jfmam_rc_p1(i,:,:), resrc)
   ;     plot_sstcor(i) = gsn_csm_contour(wks, pc1_sst_jfmam_cor_p1(i,:,:), rescor)
   ;     overlay(plot_sstrc(i), plot_sstcor(i))
   ;   end do
   ; resP@gsnPanelMainString := "PC1 SST Lead-Lag Reg P1"
   ; resP@gsnPanelFigureStrings := (/"Jan","Feb","March","April","May"/)
   ; gsn_panel(wks, plot_sstrc, (/2,3/), resP)

   ;  pc1_sst_jfmam_rc_p2 = regCoef_n(pc1_hf(19:44), sst_jfmam(:,19:44,:,:), 0, 1)
   ;  pc1_sst_jfmam_cor_p2 = escorc_n(pc1_hf(19:44), sst_jfmam(:,19:44,:,:), 0, 1)
   ;   do i = 0, 4
   ;     copy_VarCoords(sst_mon(0,:,:), pc1_sst_jfmam_rc_p2(i,:,:))
   ;     copy_VarCoords(sst_mon(0,:,:), pc1_sst_jfmam_cor_p2(i,:,:))
       
   ;     plot_sstrc(i) = gsn_csm_contour_map(wks, pc1_sst_jfmam_rc_p2(i,:,:), resrc)
   ;     plot_sstcor(i) = gsn_csm_contour(wks, pc1_sst_jfmam_cor_p2(i,:,:), rescor)
   ;     overlay(plot_sstrc(i), plot_sstcor(i))
   ;   end do
   ; resP@gsnPanelMainString := "PC1 SST Lead-Lag Reg P2"
   ; resP@gsnPanelFigureStrings := (/"Jan","Feb","March","April","May"/)
   ; gsn_panel(wks, plot_sstrc, (/2,3/), resP)

end
