begin
; Load the data   
   ncep_ice = "/mnt/f/Data/Original/ncep/icec.mon.mean.nc"
   plotpath = "/mnt/f/Pic/work1/NCL_pic/"  
   Hadi = "/mnt/f/Data/Original/hadi/"+"HadISST_ice.nc" 

   yrstrt =197201
   yrlast =200912   

   latS     = -90.
   latN     = 90.
   lonL     = 0.
   lonR     = 360.   

   sicdata = addfile(Hadi, "r") 

   YYYYMM = cd_calendar(sicdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   sic_mon = sicdata->sic(iStrt:iLast,{latS:latN},:) 
   printVarSummary(sic_mon)

   pc_hf1 = asciiread(plotpath+"pc_hf1.txt", -1, "float")

   sic_mam = month_to_season(sic_mon, "MAM")
   sic_djf = month_to_season(sic_mon, "DJF")

   ;Winter sic(1971/72DJF-2008/09DJF) Regression on pc_hf1(hf:1972-2009)
   ;(latitude|:,longitude|:,time|:) Hadi coord name
   ;(lat|:,lon|:,time|:) NCEP coord name
   sic_reg_djf = regCoef(pc_hf1(2:39),sic_djf(latitude|:,longitude|:,time|:))
   sic_cor_djf = escorc(pc_hf1(2:39),sic_djf(latitude|:,longitude|:,time|:))
   copy_VarCoords(sic_djf(0,:,:), sic_reg_djf)
   copy_VarCoords(sic_djf(0,:,:), sic_cor_djf)
   printVarSummary(sic_reg_djf)   

   sic_reg_mam = regCoef(pc_hf1(2:39),sic_mam(latitude|:,longitude|:,time|:))
   sic_cor_mam = escorc(pc_hf1(2:39),sic_mam(latitude|:,longitude|:,time|:))
   copy_VarCoords(sic_mam(0,:,:), sic_reg_mam)
   copy_VarCoords(sic_mam(0,:,:), sic_cor_mam)

;Plot 
   wks=gsn_open_wks("pdf", plotpath+"sic_reg")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
 ;Resources Settings
   res = True
   res@gsnDraw = False
   res@gsnFrame = False   

   resrc = True    
   resrc@gsnDraw = False
   resrc@gsnFrame = False
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnFillPalette = "ViBlGrWhYeOrRe"
   ;resrc@cnInfoLabelString = " "
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = True
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMinLevelValF = -0.5
   resrc@cnMaxLevelValF = 0.5
   resrc@cnLevelSpacingF = 0.1
   ; resrc@mpGridAndLimbOn = True
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 360.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 60.
   resrc@mpFillOn = False
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)

   respolar = True
   respolar = res
   respolar@cnFillPalette = "ViBlGrWhYeOrRe"
   respolar@cnFillOn = True
   respolar@cnLinesOn = False
   respolar@gsnContourNegLineDashPattern = 5
   respolar@gsnContourZeroLineThicknessF = 0.
   ;respolar@cnInfoLabelString = "Dotted Area exceed 95% Sig Level"
   respolar@gsnPolar = "NH"
   respolar@mpFillOn = True
   respolar@mpOutlineOn = True
   respolar@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   respolar@mpMinLatF = 60.
   respolar@mpCenterLonF = 90.
   respolar@cnLevelSelectionMode = "ManualLevels"
   respolar@cnMinLevelValF = -0.5
   respolar@cnMaxLevelValF = 0.5
   respolar@cnLevelSpacingF = 0.1
   respolar@lbOrientation = "Vertical"

   rescor = True
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnLevels = (/-0.271,0.271/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False   

 ; Draw winter
   respolar@gsnLeftString = "PC1_hf - SIC:Early Winter(1971/72DJF)"
   sicdraw = gsn_csm_contour_map_polar(wks, sic_cor_djf, respolar)
   sicdot = gsn_csm_contour(wks, sic_cor_djf, rescor)   
   overlay(sicdraw, sicdot)
   draw(sicdraw)
   frame(wks)
 ; Draw spring
   respolar@gsnLeftString = "PC1_hf - SIC:Simultaneous Spring(1972MAM)"
   sicdraw = gsn_csm_contour_map_polar(wks, sic_cor_mam, respolar)
   sicdot = gsn_csm_contour(wks, sic_cor_mam, rescor)
   overlay(sicdraw, sicdot)
   draw(sicdraw)
   frame(wks)  

   resrc@gsnLeftString = "PC1_hf - SIC:Simultaneous Spring(1972MAM)"
   sicdraw = gsn_csm_contour_map(wks, sic_cor_mam, resrc)
   sicdot = gsn_csm_contour(wks, sic_cor_mam, rescor)
   overlay(sicdraw, sicdot)
   draw(sicdraw)
   frame(wks)  
end