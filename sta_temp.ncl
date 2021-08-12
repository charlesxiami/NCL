begin   
   cd = "/mnt/f/Data/Original/ncep/"
   stacd = "/mnt/f/Data/Original/China160station/temperature/"
   plotpath = "/mnt/f/Pic/work1/NCL_pic/"

   yrstrt =197801
   yrlast =199812 

   latS     = -90.
   latN     = 90.
   lonL     = 0.
   lonR     = 360. 

   sstdata = addfile(cd+"sst.mnmean.v3.nc", "r")

   YYYYMM = cd_calendar(sstdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   sst_mon = sstdata->sst(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   sst_mam = month_to_season(sst_mon, "MAM")
   sst_jja = month_to_season(sst_mon, "JJA")
   printVarSummary(sst_jja)
   
   temp_jja = new((/66,15,3/), "float")
   do i = 0, 2
      data = asciiread(stacd+"t160"+(i+6)+".txt", (/66,160/), "float")
      print("t160"+(i+6)+".txt")
      ;printVarSummary(data)
      stasub = data(:,0:15)
      fftn = data(:,0:14)
      fftn(:,2:14) = stasub(:,3:15)   ;stations num.1-16 ,except num.3
   
      temp_jja(:,:,i) = fftn
   
      delete(data)
      delete(stasub)
      delete(fftn)
   end do
   printVarSummary(temp_jja)
   temp_jja2 = dim_avg_n(temp_jja, 2)
   temp_jja3 = dim_avg_n(temp_jja2, 1)

   temp_jja4 = temp_jja3(0:57)  ; Final use 

   tempsst_mam_rc = regCoef(temp_jja4(27:47),sst_mam(lat|:,lon|:,time|:))
   tempsst_mam_cor = escorc(temp_jja4(27:47),sst_mam(lat|:,lon|:,time|:))

   tempsst_jja_rc = regCoef(temp_jja4(27:47),sst_jja(lat|:,lon|:,time|:))
   tempsst_jja_cor = escorc(temp_jja4(27:47),sst_jja(lat|:,lon|:,time|:))

   copy_VarCoords(sst_mam(0,:,:), tempsst_mam_rc)
   copy_VarCoords(sst_mam(0,:,:), tempsst_mam_cor)
   copy_VarCoords(sst_jja(0,:,:), tempsst_jja_rc)
   copy_VarCoords(sst_jja(0,:,:), tempsst_jja_cor)
   printVarSummary(tempsst_mam_rc)

   tempsst_mam_rc_mask = mask(tempsst_mam_rc, abs(tempsst_mam_cor).gt.0.369, True)
   copy_VarCoords(tempsst_mam_rc, tempsst_mam_rc_mask)

   tempsst_jja_rc_mask = mask(tempsst_jja_rc, abs(tempsst_jja_cor).gt.0.369, True)
   copy_VarCoords(tempsst_jja_rc, tempsst_jja_rc_mask)
; 
   wks=gsn_open_wks("pdf", plotpath+"wuRG_test")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
   
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   
   resrc = True
   resrc = res
   resrc@cnFillOn = False
   resrc@cnLinesOn = True
   resrc@gsnContourNegLineDashPattern = 5
   resrc@gsnContourZeroLineThicknessF = 0.
   resrc@cnInfoLabelOn = False
   resrc@cnLineLabelFontHeightF = 0.007
   ; resrc@cnLevelSelectionMode = "ManualLevels"
   ; resrc@cnMaxLevelValF = 0.4
   ; resrc@cnMinLevelValF = -0.2
   ; resrc@cnLevelSpacingF = 0.1

   rescor = True
   rescor = res
   rescor@cnFillOn = True
   rescor@cnLinesOn = False
   rescor@mpFillOn = False
   rescor@mpCenterLonF = 180.
   rescor@mpMinLonF = 40.
   rescor@mpMaxLonF = 360.
   rescor@mpMaxLatF = 65.
   rescor@mpMinLatF = -25. 
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/-0.433,0.433/)
   rescor@cnFillColors = (/40,0,210/)
   ; rescor@cnMaxLevelValF = 0.12
   ; rescor@cnMinLevelValF = -0.12
   ; rescor@cnLevelSpacingF = 0.02
   rescor@cnInfoLabelOn = False
   rescor@lbLabelBarOn = False

   rescor@gsnLeftString = "15stationJJA_temp - SST:MAM"
   sstfill = gsn_csm_contour_map(wks, tempsst_mam_cor, rescor)
   sstline = gsn_csm_contour(wks, tempsst_mam_rc, resrc)
   overlay(sstfill, sstline)
   draw(sstfill)
   frame(wks)

   rescor@gsnLeftString = "15stationJJA_temp - SST:JJA"
   sstfill2 = gsn_csm_contour_map(wks, tempsst_jja_cor, rescor)
   sstline2 = gsn_csm_contour(wks, tempsst_jja_rc, resrc)
   overlay(sstfill2, sstline2)
   draw(sstfill2)
   frame(wks)

end