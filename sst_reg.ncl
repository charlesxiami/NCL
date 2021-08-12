begin
; Load the data   
   cd = "/mnt/f/Data/Original/ncep/"
   plotpath = "/mnt/f/Pic/work1/NCL_pic/"

   yrstrt =197001
   yrlast =200912 

   latS     = -90.
   latN     = 90.
   lonL     = 0.
   lonR     = 360.   

   sstdata = addfile(cd+"sst.mnmean.v4.nc", "r")

   YYYYMM = cd_calendar(sstdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   sst_mon = sstdata->sst(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   ;printVarSummary(sst_mon)

   pc_hf1 = asciiread(plotpath+"pc1.txt", -1, "float")

;Manual Calculate DJF and MAM
   nlat = dimsizes(sst_mon&lat)
   nlon = dimsizes(sst_mon&lon)
   ;sst_run = new((/38,nlat,nlon/), "float")
   ;sst_mam = new((/38,nlat,nlon/), "float")
   sst_run = sst_mon(0:37,:,:)
   sst_run = 0.
   sst_mam = sst_mon(0:37,:,:)
   sst_mam = 0.
   printVarSummary(sst_run)
   ;print(dim_max_n_Wrap(sst_run, 1))

 ;Data Analysis
   ; sst_mam = month_to_season(sst_mon, "MAM")
   ; sst_djf = month_to_season(sst_mon, "DJF")

  ;Winter SST(1971/72DJF-2008/09DJF) Regression on pc_hf1(hf:1972-2009)
   ; sst_reg_djf = regCoef(pc_hf1(2:39),sst_djf(lat|:,lon|:,time|:))
   ; sst_cor_djf = escorc(pc_hf1(2:39),sst_djf(lat|:,lon|:,time|:))
   ; copy_VarCoords(sst_mon(0,:,:), sst_reg_djf)
   ; copy_VarCoords(sst_mon(0,:,:), sst_cor_djf)
   ; printVarSummary(sst_reg_djf) 

;Plot 
   wks=gsn_open_wks("pdf", plotpath+"sst_reg_panel(pc_not_hf)")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
 ;Resources Settings
   res = True
   res@gsnDraw = False
   res@gsnFrame = False   

   resrc = True
   resrc = res
   ;resrc@cnFillPalette = "BlueWhiteOrangeRed"
   resrc@gsnDraw = False
   resrc@gsnFrame = False
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = False
   ; resrc@lbLabelsOn = True
   resrc@cnInfoLabelOn = False
   resrc@mpFillOn = False
   resrc@mpCenterLonF = 180.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 360.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = -30. 

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
   ;rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False   

 ;Draw Panel
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMinLevelValF = -0.6
   resrc@cnMaxLevelValF = 0.6
   resrc@cnLevelSpacingF = 0.1
   plot = new(16,graphic)
   do k = 0, 15
      do i = 0, 37
              sst_run(i,:,:) = (sst_mon(i*12+11+k,:,:)+sst_mon(i*12+11+k+1,:,:)+ \
              sst_mon(i*12+11+k+2,:,:))/3.
          end do
   ;copy_VarCoords(sst_mon(0:37,:,:), sst_run)
   sst_run_rc = regCoef(pc_hf1(2:39),sst_run(lat|:,lon|:,time|:))
   sst_run_cor = escorc(pc_hf1(2:39),sst_run(lat|:,lon|:,time|:))
   copy_VarCoords(sst_mon(0,:,:), sst_run_rc)
   copy_VarCoords(sst_mon(0,:,:), sst_run_cor)
   ;resrc@gsnLeftString = k-15
   plot(k) = gsn_csm_contour_map_overlay(wks, sst_run_rc, sst_run_cor, resrc, rescor)
   delete(sst_run_rc)
   delete(sst_run_cor)
   end do
   
   resP            = True                         ; modify the panel plot
   resP@txString   = "PC1_hf vs SST-Lag Regression"
   resP@gsnPanelFigureStrings= ispan(-15, 0, 1) ; add strings to panel
   resP@amJust  = "TopRight"
   resP@gsnPanelFigureStringsPerimOn = False
   resP@gsnPanelFigureStringsBackgroundFillColor = 0
   resP@gsnPanelLabelBar = True
   resP@lbOrientation = "Vertical"
   ; resP@gsnPanelYWhiteSpacePercent = 5
   ; resP@gsnPanelXWhiteSpacePercent = 5
   gsn_panel(wks,plot,(/8,2/),resP)               ; now draw as one plot


 ;Draw spring
      do i = 0, 37
              sst_mam(i,:,:) = (sst_mon(i*12+26,:,:)+sst_mon(i*12+26+1,:,:)+ \
              sst_mon(i*12+26+2,:,:))/3.
      end do
   ;copy_VarCoords(sst_mon(0:37,:,:), sst_mam)
   sst_reg_mam = regCoef(pc_hf1(2:39),sst_mam(lat|:,lon|:,time|:))
   sst_cor_mam =  escorc(pc_hf1(2:39),sst_mam(lat|:,lon|:,time|:))
   copy_VarCoords(sst_mon(0,:,:), sst_reg_mam)
   copy_VarCoords(sst_mon(0,:,:), sst_cor_mam)
   ; resrc@cnLevelSelectionMode = "ManualLevels"
   ; resrc@cnMinLevelValF = -1.
   ; resrc@cnMaxLevelValF = 1.
   ; resrc@cnLevelSpacingF = 0.2
   resrc@gsnLeftString = "PC1_hf - Simultaneous Spring(1972MAM)"
   rescor@lbLabelBarOn = False
   sstdraw = gsn_csm_contour_map(wks, sst_reg_mam, resrc)
   sstdot = gsn_csm_contour(wks, sst_cor_mam, rescor)
   overlay(sstdraw, sstdot)
   draw(sstdraw)
   frame(wks) 

   ; sstdraw2 = plot(15)
   ; draw(sstdraw2)
   ; frame(wks)

end