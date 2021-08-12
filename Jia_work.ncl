;***********************************************
begin
   snowpath  = "/public/home/charlesxiami/data/snow/"
   nceppath  = "/public/home/charlesxiami/data/ncep/"
   plotpath  = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"

   latS  = -90
   latN  = 90
   lonL  = 0
   lonR  = 360

   WlatS = 48
   WlatN = 58
   WlonL = 25
   WlonR = 50
  
   ElatS = 60
   ElatN = 70
   ElonL = 100
   ElonR = 125

   yrstrt =196401
   yrlast =200912

   sig = 0.285   ;95%, 48yeras   99%=0.368
   tsig = 2.02

   year = ispan(yrstrt/100, yrlast/100, 1)
   year_pos = (/1980,1981,1982,1986,1991/)
   year_neg = (/1965,1966,1972,1997,1998,1999,2000,2001,2002,2006,2009/)
   ind_year_pos = get1Dindex(year,year_pos)
   ind_year_neg = get1Dindex(year,year_neg)
;*****************************************************
;I/O
;*****************************************************
   wks=gsn_open_wks("pdf", plotpath+"Jia_work")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")

   snow_file = addfile(snowpath+"snow.rutger.2.0deg.neareststod.nc", "r")
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.v4.nc", "r")
   pc1_all = asciiread(indexpath+"pc1.txt", -1, "float")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")

   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print(YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR})
   air_mam = month_to_season(air_mon, "MAM")

   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 
   z500_son = month_to_season(z500_mon, "SON")

   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR})
   slp_mam = month_to_season(slp_mon, "MAM")
   slp_son = month_to_season(slp_mon, "SON")
   slp_son_pos = slp_son(ind_year_pos,:,:)
   slp_son_neg = slp_son(ind_year_neg,:,:)

   u300_mon = uwnddata->uwnd(iStrt:iLast,{300},{latS:latN},{lonL:lonR})
   u300_mam = month_to_season(u300_mon, "MAM")

   v300_mon = vwnddata->vwnd(iStrt:iLast,{300},{latS:latN},{lonL:lonR})
   uv300_mam = sqrt(u300_mon^2+v300_mon^2)
   copy_VarCoords(u300_mon, uv300_mam)

   ;YYYYMM2 = cd_calendar(tccdata->time, option)
   tcc_mon = tccdata->tcdc(iStrt:iLast,{latS:latN},{lonL:lonR})
   tcc_son = month_to_season(tcc_mon, "SON")
   tcc_son_pos = tcc_son(ind_year_pos,:,:)
   tcc_son_neg = tcc_son(ind_year_neg,:,:)

;*************************************************
;Res
;*************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   resmap = res
   resmap@mpFillOn = False  
   resmap@mpOutlineOn = True
   resmap@mpCenterLonF = 90.
   resmap@mpMinLonF = 20.
   resmap@mpMaxLonF = 180.
   resmap@mpMaxLatF = 90.
   resmap@mpMinLatF = 0.
   resmap@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)

   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   resrc@lbBoxSeparatorLinesOn = False
   resrc@pmLabelBarOrthogonalPosF = 0.5
   ;resrc@lbOrientation = "Vertical"
   resrc@cnInfoLabelOn = False
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = False
   resrc@mpCenterLonF = 60.
   resrc@mpMinLonF = -30.
   resrc@mpMaxLonF = 150.
   resrc@mpMinLatF = 10.
   resrc@mpMaxLatF = 60.
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnSmoothingOn = True
   resrc@cnSmoothingDistanceF = 0.001

   ressat = resrc
   ressat@cnMinLevelValF = -1.8
   ressat@cnMaxLevelValF = 1.8
   ressat@cnLevelSpacingF = 0.1

   resslp = resrc
   resslp@mpCenterLonF = 180.
   resslp@mpMinLonF = 80.
   resslp@mpMaxLonF = 240.
   resslp@mpMinLatF = 0.
   resslp@mpMaxLatF = 60.

   restcc = resrc
   restcc@mpCenterLonF = 180.
   restcc@mpMinLonF = 109.
   restcc@mpMaxLonF = 122.
   restcc@mpMinLatF = 32.
   restcc@mpMaxLatF = 45.

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
   rescor@cnFillPatterns = (/17,-1/)
   rescor@cnLevels = (/0.05/)

   resPolar = res
   resPolar@gsnPolar = "NH"
   resPolar@mpMinLatF = 30.
   resPolar@cnFillOn = True
   resPolar@cnLinesOn = False
   resPolar@lbLabelBarOn = False
   resPolar@gsnLeftString = " "
   resPolar@cnLevelSelectionMode = "ManualLevels"
   resPolar@cnMaxLevelValF = 100.
   resPolar@cnMinLevelValF = 0.
   resPolar@cnLevelSpacingF = 10.

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
   resV@vcRefAnnoOrthogonalPosF = -0.58
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.0               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

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

;************************************************
; Calculate 
;************************************************
   dim_ncep = dimsizes(u300_mon)
   ;u300_march = new((/5,dim_ncep(0),dim_ncep(1),dim_ncep(2)/), "float")
   u300_april = u300_mon(3:dim_ncep(0)-1:12,:,:)
   u300_may = u300_mon(4:dim_ncep(0)-1:12,:,:)
   u300_34 = u300_mam
   u300_34 = (u300_april+u300_may)/2.0
   u300_34@long_name = "April and May: Monthly mean u wind"

   u300_34_p1 = u300_34(0:20,:,:)
   u300_34_p2 = u300_34(22:40,:,:)
   dimarray1 = dimsizes(u300_34_p1)
   dimarray2 = dimsizes(u300_34_p2)

   u300_34_p1_avg = dim_avg_n_Wrap(u300_34_p1, 0)
   u300_34_p2_avg = dim_avg_n_Wrap(u300_34_p2, 0)
   u300_34_dif = u300_34_p1_avg
   u300_34_dif = u300_34_p2_avg-u300_34_p1_avg
   printMinMax(u300_34_dif, 0)

   slp_son_avg = dim_avg_n_Wrap(slp_son, 0)
   slp_son_pos_avg = dim_avg_n_Wrap(slp_son_pos, 0)
   slp_son_neg_avg = dim_avg_n_Wrap(slp_son_neg, 0)
   slp_son_pos_dif = slp_son_avg
   slp_son_neg_dif = slp_son_avg
   slp_son_pos_dif = slp_son_pos_avg - slp_son_avg
   slp_son_neg_dif = slp_son_neg_avg - slp_son_avg

   tcc_son_avg = dim_avg_n_Wrap(tcc_son, 0)
   tcc_son_pos_avg = dim_avg_n_Wrap(tcc_son_pos, 0)
   tcc_son_neg_avg = dim_avg_n_Wrap(tcc_son_neg, 0)
   tcc_son_pos_dif = tcc_son_avg
   tcc_son_neg_dif = tcc_son_avg
   tcc_son_pos_dif = tcc_son_pos_avg - tcc_son_avg
   tcc_son_neg_dif = tcc_son_neg_avg - tcc_son_avg

   ; z500_son_dif = z500_son
   ; z500_son_dif = z500_son - dim_avg_n_Wrap(z500_son, 0)   
   ; printVarSummary(z500_son_dif)
;*************************************************
;T test
;*************************************************
   iflag = False
   tval_opt = False

   ave1 = dim_avg_n_Wrap(u300_34_p1, 0)
   var1 = dim_variance_n_Wrap(u300_34_p1, 0)
   s1 = dimarray1(0)
   ave2 = dim_avg_n_Wrap(u300_34_p2, 0)
   var2 = dim_variance_n_Wrap(u300_34_p2, 0)
   s2 = dimarray2(0)

   probt = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
   copy_VarCoords(u300_mon(0,:,:), probt)

   ;Second T-test
   ;---------------------------------------------------------------------
   dim_slp = dimsizes(slp_son)
   dim_slp_pos = dimsizes(slp_son_pos)
   dim_slp_neg = dimsizes(slp_son_neg)

   ave1 = slp_son_avg
   var1 = dim_variance_n_Wrap(slp_son, 0)
   s1 = dim_slp(0)

   ;pos
   ave2 = slp_son_pos_avg
   var2 = dim_variance_n_Wrap(slp_son_pos, 0)
   s2 = dim_slp_pos(0)
   probt_slp_pos = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
   copy_VarCoords(slp_son(0,:,:), probt_slp_pos)

   ;neg
   ave2 = slp_son_neg_avg
   var2 = dim_variance_n_Wrap(slp_son_neg, 0)
   s2 = dim_slp_neg(0)
   probt_slp_neg = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
   copy_VarCoords(slp_son(0,:,:), probt_slp_neg)

   ;Third T-test
   ;--------------------------------------------------------------
   dim_tcc = dimsizes(tcc_son)
   dim_tcc_pos = dimsizes(tcc_son_pos)
   dim_tcc_neg = dimsizes(tcc_son_neg)

   ave1 := tcc_son_avg
   var1 := dim_variance_n_Wrap(tcc_son, 0)
   s1 = dim_tcc(0)

   ;pos
   ave2 := tcc_son_pos_avg
   var2 := dim_variance_n_Wrap(tcc_son_pos, 0)
   s2 = dim_tcc_pos(0)
   probt_tcc_pos := ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
   copy_VarCoords(tcc_son(0,:,:), probt_tcc_pos)

   ;neg
   ave2 := tcc_son_neg_avg
   var2 := dim_variance_n_Wrap(tcc_son_neg, 0)
   s2 = dim_tcc_neg(0)
   probt_tcc_neg := ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
   copy_VarCoords(tcc_son(0,:,:), probt_tcc_neg)
   printVarSummary(probt_tcc_neg)

;*************************************************
;
;*************************************************
   resrc@cnMinLevelValF = -30.
   resrc@cnMaxLevelValF = 30.
   resrc@cnLevelSpacingF = 1.0

   plot_panel = new(2, "graphic")
   resrc@gsnLeftString = "P1 1964-1984"
   plot1 = gsn_csm_contour_map(wks, u300_34_p1_avg , resrc)
   resrc@gsnLeftString = "P2 1986-2004"
   plot2 = gsn_csm_contour_map(wks, u300_34_p2_avg , resrc)
   plot_panel(0) = plot1
   plot_panel(1) = plot2
   resP@gsnPanelMainString  = "April-May Mean u wind"
   gsn_panel(wks, plot_panel, (/1,2/), resP)

   resrc@cnMinLevelValF = -5.
   resrc@cnMaxLevelValF = 5.
   resrc@cnLevelSpacingF = 0.1
   resrc@lbLabelBarOn = True
   resrc@gsnLeftString = "P2-P1 Dif"
   plot_dif = gsn_csm_contour_map(wks, u300_34_dif , resrc)
   plot_sig = gsn_csm_contour(wks, probt, rescor)
   overlay(plot_dif, plot_sig)
   draw(plot_dif)
   frame(wks)

   ;-----------------------------------------------------------
   ;Draw GQX
   resP@gsnPanelMainString  = " "
   ;SLP
   resslp@cnMinLevelValF = -3.0
   resslp@cnMaxLevelValF = 3.0
   resslp@cnLevelSpacingF = 0.1

   plot_pos_rc = gsn_csm_contour_map(wks, slp_son_pos_dif, resslp)
   plot_pos_cor = gsn_csm_contour(wks, probt_slp_pos, rescor)
   overlay(plot_pos_rc, plot_pos_cor)

   plot_neg_rc = gsn_csm_contour_map(wks, slp_son_neg_dif, resslp)
   plot_neg_cor = gsn_csm_contour(wks, probt_slp_neg, rescor)
   overlay(plot_neg_rc, plot_neg_cor)
   
   plot_panel(0) = plot_pos_rc
   plot_panel(1) = plot_neg_rc
   gsn_panel(wks, plot_panel, (/2,1/), resP)

   ;TCC
   restcc@cnMinLevelValF = -5.0
   restcc@cnMaxLevelValF = 5.0
   restcc@cnLevelSpacingF = 0.5

   plot_pos_rc = gsn_csm_contour_map(wks, tcc_son_pos_dif, restcc)
   plot_pos_cor = gsn_csm_contour(wks, probt_tcc_pos, rescor)
   overlay(plot_pos_rc, plot_pos_cor)

   plot_neg_rc = gsn_csm_contour_map(wks, tcc_son_neg_dif, restcc)
   plot_neg_cor = gsn_csm_contour(wks, probt_tcc_neg, rescor)
   overlay(plot_neg_rc, plot_neg_cor)
   
   plot_panel(0) = plot_pos_rc
   plot_panel(1) = plot_neg_rc
   gsn_panel(wks, plot_panel, (/2,1/), resP)



end