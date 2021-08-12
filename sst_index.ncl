load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
   yrstrt =197201
   yrlast =200912

   latS     = -90
   latN     = 90
   lonL     = 0
   lonR     = 360

   SlatS = 30
   SlatN = 70
   SlonL = 330
   SlonR = 360
   cd = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"

   snowdata = addfile("/public/home/charlesxiami/data/snow/snow.nc","r")
   airdata  = addfile(cd+"air.mon.mean.nc", "r")
   slpdata  = addfile(cd+"slp.mon.mean.nc", "r")
   hgtdata  = addfile(cd+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(cd+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(cd+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(cd+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(cd+"nlwrs.sfc.mon.mean.nc", "r")
   sstdata  = addfile(cd+"sst.mnmean.v4.nc", "r")
   
   ; Ai_hf = asciiread(plotpath+"Ai_hf_re.txt", -1, "float")
   ; Bi_hf = asciiread(plotpath+"Bi_hf_re.txt", -1, "float")
   ; pc_hf = asciiread(plotpath+"pc_hf1.txt", -1, "float")
   ;printVarSummary(Bi_hf)

   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)

   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   air_mam = month_to_season(air_mon, "MAM")
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   slp_mam = month_to_season(slp_mon, "MAM")

   u_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   u_mam = month_to_season(u_mon, "MAM")
   v_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   v_mam = month_to_season(v_mon, "MAM")

   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 
   z500_mam = month_to_season(z500_mon, "MAM")

   snow_mon = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   sst_mam = month_to_season(sst_mon, "MAM")
   
   sst_mam_region = sst_mam(:,{SlatS:SlatN},{SlonL:SlonR})
   sst_mam_region = SqrtCosWeight(sst_mam_region)
   printVarSummary(sst_mam_region)

   sst_ind = wgt_areaave_Wrap(sst_mam_region, 1.0, 1.0, 1)
   sst_ind = dim_standardize_Wrap(sst_ind, 0)
   ;asciiwrite(plotpath+"SSTi.txt", sst_ind)

   ihp = 1
   fca = 1.0/10.0
   fcb= -999
   nsigma = 1.
   nwt= 5
   wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
   sst_ind_hf = wgt_runave_Wrap(sst_ind, wgt, 0)

   ; print("Cor_hf:sst_ind-Ai_hf = "+ escorc(sst_ind_hf, Ai_hf))
   ; print("Cor_hf:sst_ind-Bi_hf = "+ escorc(sst_ind_hf, Bi_hf))
   ; print("Cor_hf:sst_ind-PC_hf = "+ escorc(sst_ind_hf, pc_hf(2:39)))

   ; print("Cor_hf-P1:sst-Ai = "+ escorc(sst_ind_hf(0:15), Ai_hf(0:15)))
   ; print("Cor_hf-P2:sst-Ai = "+ escorc(sst_ind_hf(17:37), Ai_hf(17:37)))

   ; print("Cor_hf-P1:sst-Bi = "+ escorc(sst_ind_hf(0:15), Bi_hf(0:15)))
   ; print("Cor_hf-P2:sst-Bi = "+ escorc(sst_ind_hf(17:37), Bi_hf(17:37)))

   ; print("Cor_hf-P1:sst-pc1 = "+ escorc(sst_ind_hf(0:15), pc_hf(2:17)))
   ; print("Cor_hf-P2:sst-pc1 = "+ escorc(sst_ind_hf(17:37), pc_hf(19:39)))
   ;**********************************************************
   ssti_snow_rc  = regCoef(sst_ind_hf,snow_mam(lat|:,lon|:,time|:))
   ssti_snow_cor = escorc(sst_ind_hf,snow_mam(lat|:,lon|:,time|:))
   copy_VarCoords(snow_mam(0,:,:), ssti_snow_rc)
   copy_VarCoords(snow_mam(0,:,:), ssti_snow_cor)

   ssti_air_rc  = regCoef(sst_ind_hf,air_mam(lat|:,lon|:,time|:))
   ssti_air_cor = escorc(sst_ind_hf,air_mam(lat|:,lon|:,time|:))
   copy_VarCoords(air_mam(0,:,:), ssti_air_rc)
   copy_VarCoords(air_mam(0,:,:), ssti_air_cor)

   ssti_slp_rc  = regCoef(sst_ind_hf,slp_mam(lat|:,lon|:,time|:))
   ssti_slp_cor = escorc(sst_ind_hf,slp_mam(lat|:,lon|:,time|:))
   copy_VarCoords(slp_mam(0,:,:), ssti_slp_rc)
   copy_VarCoords(slp_mam(0,:,:), ssti_slp_cor)

   ssti_u_rc  = regCoef(sst_ind_hf,u_mam(lat|:,lon|:,time|:))
   ssti_v_rc  = regCoef(sst_ind_hf,v_mam(lat|:,lon|:,time|:))
   copy_VarCoords(u_mam(0,:,:), ssti_u_rc)
   copy_VarCoords(v_mam(0,:,:), ssti_v_rc)

   ssti_z500_rc  = regCoef(sst_ind_hf,z500_mam(lat|:,lon|:,time|:))
   ssti_z500_cor = escorc (sst_ind_hf,z500_mam(lat|:,lon|:,time|:))
   copy_VarCoords(z500_mam(0,:,:), ssti_z500_rc)
   copy_VarCoords(z500_mam(0,:,:), ssti_z500_cor)

   ssti_sst_rc  = regCoef(sst_ind_hf,sst_mam(lat|:,lon|:,time|:))
   ssti_sst_cor = escorc(sst_ind_hf,sst_mam(lat|:,lon|:,time|:))
   copy_VarCoords(sst_mam(0,:,:), ssti_sst_rc)
   copy_VarCoords(sst_mam(0,:,:), ssti_sst_cor)

   ;**********************************************************
   output = plotpath
   wks=gsn_open_wks("pdf", output+"sst_index")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
   ;**********************************************************
   ;Resources Setting
   ;**********************************************************
   ;Time Series plot
   rts           = True
   rts@gsnDraw   = False       ; don't draw yet
   rts@gsnFrame  = False       ; don't advance frame yet
   rts@gsnScale  = False        ; force text scaling               

   rts@vpHeightF = 0.40        ; Changes the aspect ratio
   rts@vpWidthF  = 0.80
   rts@vpXF      = 0.10        ; change start locations
   rts@vpYF      = 0.75        ; the plot
   rts@tiYAxisString = ""                    ; y-axis label
   rts@gsnYRefLine           = 0.              ; reference line
   rts@gsnYRefLineDashPattern = 2
   rts@gsnXYBarChart         = True            ; create bar chart
   rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
   rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue 
   rts@tmXBMode = "Manual"
   rts@tmXBTickStartF = 1970
   rts@tmXBTickEndF = 2010
   rts@tmXBTickSpacingF = 5
   rts@tmXBLabelFontHeightF = 0.02
   rts@tmYLLabelFontHeightF = 0.02
   rts@gsnLeftStringFontHeightF = 0.025

   ;Draw hf
   rts2 = True
   rts2 = rts
   rts2@gsnXYBarChart = False
   rts2@xyDashPattern         = 5
   rts2@xyLineThicknessF      = 3.
   rts2@xyLineColor = "black"
   rts2@gsnLeftString = ""
   rts2@gsnRightString = ""
   delete(rts2@gsnAboveYRefLineColor)
   delete(rts2@gsnBelowYRefLineColor)

   ;Time Series of SST Index
   rts@gsnLeftString = "SST Index"
   t = ispan(yrstrt/100, yrlast/100, 1)
   plot = gsn_csm_xy(wks, t, sst_ind, rts)
   ssthf = gsn_csm_xy(wks, t, sst_ind_hf, rts2)
   overlay(plot, ssthf)
   draw(plot)
   frame(wks)

   ;*****************************

   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   ;For Fills
   resrc = True    
   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnInfoLabelString = " "
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = True
   
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   ; resrc@mpGridAndLimbOn = True
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 360.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.
   resrc@mpFillOn = False
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@gsnLeftStringFontHeightF = 0.025
   resrc@pmLabelBarOrthogonalPosF = 0.20

   ;For Line
   resrc2 = True
   resrc2 = res
   resrc2@cnFillOn = False
   resrc2@cnLinesOn = True
   resrc2@cnLabelMasking = True
   resrc2@cnInfoLabelOn = False
   resrc2@gsnContourNegLineDashPattern = 5
   resrc2@gsnContourZeroLineThicknessF = 0.
   resrc2@cnLineThicknessF = 2.0
   ;resrc2@cnLineColor = "black"
   resrc2@cnLineLabelsOn = True
   resrc2@cnLineLabelPerimOn = False
   resrc2@cnLineLabelBackgroundColor = 2
   resrc2@cnLineLabelPlacementMode = "Constant"
   resrc2@cnLineLabelInterval = 1
   resrc2@cnLineLabelFontHeightF = 0.006
   ;resrc2@cnLineLabelFontColor = 0
   resrc2@cnLineLabelFontThicknessF = 1.6


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
   rescor@cnInfoLabelOn = False

   rescor2 = True
   rescor2 = res
   rescor2@cnLinesOn = False
   rescor2@cnFillOn = True
   rescor2@cnLevelSelectionMode = "ExplicitLevels"
   rescor2@cnLevels = (/-0.320,-0.271,0.271,0.320/)  ;95%,99%
   rescor2@cnFillColors = (/20,40,120,220,240/)
   rescor2@cnLineLabelsOn = False
   rescor2@cnInfoLabelOn = False
   rescor2@lbLabelBarOn = False
   rescor2@mpFillOn = False
   ;rescor2@mpCenterLonF = 180.
   rescor2@mpMinLonF = -180.
   rescor2@mpMaxLonF = 180.
   rescor2@mpMaxLatF = 90.
   rescor2@mpMinLatF = 0.

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
   resV@vcRefAnnoOrthogonalPosF = -0.7
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.0               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   ;Air+Wind
   resrc@cnMinLevelValF = -1.6
   resrc@cnMaxLevelValF = 1.6
   resrc@cnLevelSpacingF = 0.1
   resrc@gsnLeftString = "SST_hf: SAT+Wind"
   plot = gsn_csm_contour_map(wks, ssti_air_rc, resrc)
   plot2 = gsn_csm_contour(wks, ssti_air_cor, rescor)
   plot3 = gsn_csm_vector(wks, ssti_u_rc, ssti_v_rc, resV)
   overlay(plot, plot2)
   overlay(plot, plot3)
   draw(plot)
   frame(wks)

   ;SLP
   rescor2@gsnLeftString = "SST_hf: SLP"
   plot  =  gsn_csm_contour_map(wks, ssti_slp_cor, rescor2)
   plot2 = gsn_csm_contour(wks, ssti_slp_rc, resrc2)
   overlay(plot, plot2)
   draw(plot)
   frame(wks)

   ;SST
   resrc@gsnLeftString = "SST_hf: SST"
   resrc@cnMinLevelValF = -0.8
   resrc@cnMaxLevelValF = 0.8
   resrc@cnLevelSpacingF = 0.1
   plot = gsn_csm_contour_map(wks, ssti_sst_rc, resrc)
   plot2 = gsn_csm_contour(wks, ssti_sst_cor, rescor)
   plot3 = gsn_csm_vector(wks, ssti_u_rc, ssti_v_rc, resV)
   overlay(plot, plot2)
   overlay(plot, plot3)
   draw(plot)
   frame(wks)

   ;Snow Regression
   resrc@cnMinLevelValF = -1.
   resrc@cnMaxLevelValF = 1.
   resrc@cnLevelSpacingF = 0.1
   resrc@mpMaxLonF = 180.
   resrc@gsnLeftString = "SST_hf: SCE"
   plot = gsn_csm_contour_map(wks, ssti_snow_cor, resrc)
   plot2 = gsn_csm_contour(wks, ssti_snow_cor, rescor)
   overlay(plot, plot2)
   draw(plot)
   frame(wks)


end 