 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

;***
  begin
;***
   yrstrt =197501
   yrlast =201412

   t = ispan(yrstrt/100, yrlast/100, 1)

   latS     = -90 
   latN     = 90
   lonL     = 0
   lonR     = 360

   eoflatS     = 40        
   eoflatN     = 70
   eoflonL     = 0
   eoflonR     = 140

   sig34 = 0.339
;**********************************************
;Calcute Snow Cover Index
;*********************************************
   datapath = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"
;************************************************
;Setting Plot
;************************************************
   wks=gsn_open_wks("pdf", plotpath+"eof_CSF")
   gsn_define_colormap(wks, "ViBlGrWhYeOrRe")
;***************************************
   filesnow = "/public/home/charlesxiami/data/snow/snow.nc"
   snowdata = addfile(filesnow,"r")
   airdata = addfile(datapath+"air.mon.mean.nc", "r")
   slpdata = addfile(datapath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(datapath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(datapath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(datapath+"vwnd.mon.mean.nc", "r")
   sstdata = addfile(datapath+"sst.mnmean.v4.nc", "r")
   soilwdata = addfile(datapath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(datapath+"tcdc.eatm.mon.mean.nc", "r")

   nswrdata = addfile(datapath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(datapath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata  = addfile(datapath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata  = addfile(datapath+"shtfl.sfc.mon.mean.nc", "r")
;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   year=ispan(1972, 2009, 1)

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)
   print(YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))
;********************************************
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
   uv_mam = sqrt(u_mam^2+v_mam^2)
   copy_VarCoords(u_mam, uv_mam)

   nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nswr_mam = month_to_season(nswr_mon, "MAM")

   nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nlwr_mam = month_to_season(nlwr_mon, "MAM")

   lhf_mon = lhfdata->lhtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   lhf_mam = month_to_season(lhf_mon, "MAM")

   shf_mon = shfdata->shtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   shf_mam = month_to_season(shf_mon, "MAM")

   soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})
   soilw_mam = month_to_season(soilw_mon, "MAM")

   snow_mon  = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   tcc_mon = tccdata->tcdc(iStrt:iLast,{latS:latN},{lonL:lonR})
   tcc_mam = month_to_season(tcc_mon, "MAM")

;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 9
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    air_mam = wgt_runave_n_Wrap(air_mam, wgt, 0, 0)

    shf_mam = wgt_runave_n_Wrap(shf_mam, wgt, 0, 0)
    lhf_mam = wgt_runave_n_Wrap(lhf_mam, wgt, 0, 0)
    nswr_mam = wgt_runave_n_Wrap(nswr_mam, wgt, 0, 0)
    nlwr_mam = wgt_runave_n_Wrap(nlwr_mam, wgt, 0, 0)

;********************************************
  rad  = 4.*atan(1.)/180.
  clat   = airdata->lat        
  clat   = sqrt( cos(rad*clat) ) 
  ;*** 
  air_mam_wgt = SqrtCosWeight(air_mam)
  x = air_mam_wgt(:,{eoflatS:eoflatN},{eoflonL:eoflonR})
 ;************************************************
 ;EOF 
 ;************************************************
   neof = 3
   optEOF = True
   optEOF@jopt = 0
   optETS = False
   eof    = eofunc_n_Wrap(x,neof,optEOF,0)
   eof_ts = eofunc_ts_n_Wrap(x,eof,optETS,0)
   eof_ts = dim_standardize_Wrap(eof_ts, 0)
   printVarSummary(eof_ts)
  ;*******************************************
  ; North significance test: Note any of the following could be used
  ;*******************************************
   dimp   = dimsizes(air_mam_wgt)
   ntim   = dimp(0)

   prinfo = True
   ;sig_ev  = eofunc_north(eof@eval, ntim, prinfo)

   sig_pcv = eofunc_north(eof@pcvar, ntim, prinfo)
   ;sig_evt = eofunc_north(eof@eval_transpose, ntim, prinfo)
   ;print(eof_ts)

;********************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   res@cnFillOn = True
   res@cnLinesOn = False
   res@lbLabelBarOn = False
   res@gsnAddCyclic = False
   res@mpFillOn             = False        ; turn off map fill
   res@mpMinLatF            = eoflatS         ; zoom in on map
   res@mpMaxLatF            = eoflatN
   res@mpMinLonF            = eoflonL
   res@mpMaxLonF            = eoflonR

   resP                 = True                 ; panel resources
   resP@txString        = "SAT:MAM:"+yrstrt/100+"-"+yrlast/100 ; add center string
   resP@gsnPanelLabelBar    = True            ; add common colorbar
   resP@lbLabelAutoStride   = True
   resP@gsnMaximize         = False
   ;resP@gsnPanelDebug = True      
   plot = new(neof, "graphic")
  do n = 0, neof-1
    res@gsnLeftString  = "EOF "+(n+1)
    res@gsnRightString = sprintf("%5.1f", eof@pcvar(n))+"%"
    plot(n) = gsn_csm_contour_map(wks, eof(n,:,:), res)
  end do
  gsn_panel(wks,plot,(/neof,1/),resP)

;********************************************
;Time Series plot
;********************************************
     rts           = True
     rts@gsnDraw   = False       ; don't draw yet
     rts@gsnFrame  = False       ; don't advance frame yet
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
     rts1@gsnLeftString = "(b) PC1"
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
     rts1@trXMinF = 1971.5
     rts1@trXMaxF = 2009.5
     rts1@gsnXYBarChartBarWidth = 0.3
     rts1@trYMaxF = 3.0
     rts1@trYMinF = -3.0

     rts2 = rts   ; Line 
     rts2@xyDashPattern         = 1
     rts2@xyLineThicknessF      = 4.
     rts2@xyLineColor = "black"

   rts@gsnYRefLine           = 0.              ; reference line   
   rts@gsnXYBarChart         = True            ; create bar chart 
   rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
   rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

    rtsP                     = True             ; modify the panel plot
    rtsP@gsnMaximize         = False             ; large format


  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,t,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)        ; draw all 'neof' as one plot

     ; ts_bar = gsn_csm_xy(wks, t, eof_ts(0,:),rts1)
     ; ts_line = gsn_csm_xy(wks,t,pc1_lf,rts2)
     ; overlay(ts_bar, ts_line)

;*********************************************************
   resrc = True
   resrc = res
   ;resrc@gsnAddCyclic = True
   resrc@vpHeightF = 0.8
   resrc@vpWidthF = 0.8
   resrc@cnFillPalette = "GMT_polar"
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@cnLineLabelFormat  =  "@^sg"
   resrc@gsnContourNegLineDashPattern = 5
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@pmLabelBarOrthogonalPosF = 0.12
   resrc@cnInfoLabelOn = False
   ;resrc@cnInfoLabelString = "Dotted Area exceed 99% Sig Level"
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False
   ;resrc@gsnLeftStringFontHeightF = 0.025
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 180
   resrc@mpMaxLatF = 70
   resrc@mpMinLatF = 40
   resrc@gsnStringFontHeightF = 0.02
   resrc@mpLabelFontHeightF = 0.02

   rescor = True
   rescor@gsnDraw = False
   rescor@gsnFrame = False
   rescor@cnFillOn = True
   rescor@cnLinesOn = False
   rescor@cnInfoLabelOn = False
   ;rescor@lgLabelsOn = False
   rescor@cnLineLabelsOn = False
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/-sig34,sig34/) 
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnFillColors = (/1,1,1/)
   rescor@lbLabelBarOn = False

   resP = True                
   resP@gsnMaximize = False
   ; resP@gsnPanelFigureStringsFontHeightF = 0.015
   ; resP@gsnPanelFigureStringsPerimOn = False
   ; strings = (/"a(-3)","b(-2)","c(-1)","d(0)","e(+1)","f(+2)"/)
   ; resP@gsnPanelFigureStrings = strings
   ;(/"-3","-2","-1","0","e","f","g"/)
   resP@amJust = "TopLeft"
   resP@gsnPanelLabelBar = True
   resP@gsnPanelRowSpec = True
   resP@gsnPolarLabelFontHeightF = 0.007
   resP@pmLabelBarWidthF = 0.5
   resP@gsnPanelLabelBar = True
   resP@gsnPanelRowSpec = True

;**************************************************************
   xpts = (/lonL, lonL, lonR, lonR, lonL/)
   ypts = (/latS, latN, latN, latS, latS/)
   dum = new(dimsizes(xpts)-1, graphic)
   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 2.8
   ;plres@gsLineLabelString = "sce"
  
   pc1 = -1*eof_ts(0,:)
   pc2 = eof_ts(1,:)

   resrc@cnMinLevelValF = -1.2
   resrc@cnMaxLevelValF = 1.2
   resrc@cnLevelSpacingF = 0.2
   pc1_air_rc = regCoef_n(pc1, air_mam, 0, 0)
   pc1_air_cor = escorc_n(pc1, air_mam, 0, 0)
   copy_VarCoords(air_mam(0,:,:), pc1_air_rc)
   copy_VarCoords(air_mam(0,:,:), pc1_air_cor)

   pc2_air_rc = regCoef_n(pc2, air_mam, 0, 0)
   pc2_air_cor = escorc_n(pc2, air_mam, 0, 0)
   copy_VarCoords(air_mam(0,:,:), pc2_air_rc)
   copy_VarCoords(air_mam(0,:,:), pc2_air_cor)

   resrc@gsnRightString  = " "
   resrc@gsnLeftString  = "EOF1"
   plot1 = gsn_csm_contour_map(wks, pc1_air_rc, resrc)
   plot2 = gsn_csm_contour(wks, pc1_air_cor, rescor)
   overlay(plot1, plot2)
   draw(plot1)
   frame(wks)

   resrc@gsnLeftString  = "EOF2"
   plot1 = gsn_csm_contour_map(wks, pc2_air_rc, resrc)
   plot2 = gsn_csm_contour(wks, pc2_air_cor, rescor)
   overlay(plot1, plot2)
   draw(plot1)
   frame(wks)
   
   pc1 = -1*pc1
   pc2 = -1*pc2
   pc1_shf_rc = regCoef_n(pc1, shf_mam, 0, 0)
   pc1_lhf_rc = regCoef_n(pc1, lhf_mam, 0, 0)
   pc1_swr_rc = regCoef_n(pc1, nswr_mam, 0, 0)
   pc1_lwr_rc = regCoef_n(pc1, nlwr_mam, 0, 0)
   pc1_shf_cor = escorc_n(pc1, shf_mam, 0, 0)
   pc1_lhf_cor = escorc_n(pc1, lhf_mam, 0, 0)
   pc1_swr_cor = escorc_n(pc1, nswr_mam, 0, 0)
   pc1_lwr_cor = escorc_n(pc1, nlwr_mam, 0, 0)
   copy_VarCoords(shf_mam(0,:,:), pc1_shf_rc)
   copy_VarCoords(shf_mam(0,:,:), pc1_shf_cor)
   copy_VarCoords(shf_mam(0,:,:), pc1_lhf_rc)
   copy_VarCoords(shf_mam(0,:,:), pc1_lhf_cor)
   copy_VarCoords(shf_mam(0,:,:), pc1_swr_rc)
   copy_VarCoords(shf_mam(0,:,:), pc1_swr_cor)
   copy_VarCoords(shf_mam(0,:,:), pc1_lwr_rc)
   copy_VarCoords(shf_mam(0,:,:), pc1_lwr_cor)

   pc2_shf_rc = regCoef_n(pc2, shf_mam, 0, 0)
   pc2_lhf_rc = regCoef_n(pc2, lhf_mam, 0, 0)
   pc2_swr_rc = regCoef_n(pc2, nswr_mam, 0, 0)
   pc2_lwr_rc = regCoef_n(pc2, nlwr_mam, 0, 0)
   pc2_shf_cor = escorc_n(pc2, shf_mam, 0, 0)
   pc2_lhf_cor = escorc_n(pc2, lhf_mam, 0, 0)
   pc2_swr_cor = escorc_n(pc2, nswr_mam, 0, 0)
   pc2_lwr_cor = escorc_n(pc2, nlwr_mam, 0, 0)
   copy_VarCoords(shf_mam(0,:,:), pc2_shf_rc)
   copy_VarCoords(shf_mam(0,:,:), pc2_shf_cor)
   copy_VarCoords(shf_mam(0,:,:), pc2_lhf_rc)
   copy_VarCoords(shf_mam(0,:,:), pc2_lhf_cor)
   copy_VarCoords(shf_mam(0,:,:), pc2_swr_rc)
   copy_VarCoords(shf_mam(0,:,:), pc2_swr_cor)
   copy_VarCoords(shf_mam(0,:,:), pc2_lwr_rc)
   copy_VarCoords(shf_mam(0,:,:), pc2_lwr_cor)

   delete(plot1)
   delete(plot2)
   resrc@lbLabelBarOn = False
   resrc@cnMinLevelValF = -4.5
   resrc@cnMaxLevelValF = 4.5
   resrc@cnLevelSpacingF = 0.5
   resrc@gsnLeftString = " "
   resrc@gsnRightString = "shf"
   plot1 = gsn_csm_contour_map(wks, pc1_shf_rc, resrc)
   plot11 = gsn_csm_contour(wks, pc1_shf_cor, rescor)
   overlay(plot1, plot11)

   resrc@gsnRightString = "lhf"
   plot2 = gsn_csm_contour_map(wks, pc1_lhf_rc, resrc)
   plot22 = gsn_csm_contour(wks, pc1_lhf_cor, rescor)
   overlay(plot2, plot22)

   resrc@gsnRightString = "swr"
   plot3 = gsn_csm_contour_map(wks, pc1_swr_rc, resrc)
   plot33 = gsn_csm_contour(wks, pc1_swr_cor, rescor)
   overlay(plot3, plot33)

   resrc@gsnRightString = "lwr"
   plot4 = gsn_csm_contour_map(wks, pc1_lwr_rc, resrc)
   plot44 = gsn_csm_contour(wks, pc1_lwr_cor, rescor)
   overlay(plot4, plot44)

   plotpanel = new(4, "graphic")
   plotpanel(0) = plot1
   plotpanel(1) = plot2
   plotpanel(2) = plot3
   plotpanel(3) = plot4
   resP@txString = "PC1 Heat Flux"
   gsn_panel(wks, plotpanel, (/2,2/), resP)

   resrc@gsnRightString = "shf"
   plot1 = gsn_csm_contour_map(wks, pc2_shf_rc, resrc)
   plot11 = gsn_csm_contour(wks, pc2_shf_cor, rescor)
   overlay(plot1, plot11)

   resrc@gsnRightString = "lhf"
   plot2 = gsn_csm_contour_map(wks, pc2_lhf_rc, resrc)
   plot22 = gsn_csm_contour(wks, pc2_lhf_cor, rescor)
   overlay(plot2, plot22)

   resrc@gsnRightString = "swr"
   plot3 = gsn_csm_contour_map(wks, pc2_swr_rc, resrc)
   plot33 = gsn_csm_contour(wks, pc2_swr_cor, rescor)
   overlay(plot3, plot33)

   resrc@gsnRightString = "lwr"
   plot4 = gsn_csm_contour_map(wks, pc2_lwr_rc, resrc)
   plot44 = gsn_csm_contour(wks, pc2_lwr_cor, rescor)
   overlay(plot4, plot44)

   plotpanel = new(4, "graphic")
   plotpanel(0) = plot1
   plotpanel(1) = plot2
   plotpanel(2) = plot3
   plotpanel(3) = plot4
   resP@txString = "PC2 Heat Flux"
   gsn_panel(wks, plotpanel, (/2,2/), resP)

end
