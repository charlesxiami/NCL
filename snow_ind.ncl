load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/run_cor.ncl"
;***
  begin
;***
   yrstrt = 197201   ;P1+P2
   yrlast = 201912

   ; yrstrt = 196701   ;P1
   ; yrlast = 198812

   ; yrstrt = 198901  ;P2
   ; yrlast = 201912

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  year = ispan(yrstrt_snow/100, yrlast_snow/100, 1)
  year@units = "months since 0000-09-01 00:00:00 "

;---------------W,E-index Region
  SC_EU_N = 70
  SC_EU_S = 40
  SC_EU_L = 20
  SC_EU_R = 140

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", "snow_ind")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.v5.nc", "r")

   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
   soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")

 ;*****************************************************************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt_sst)
   iLast2  = ind(YYYYMM2.eq.yrlast_sst)
   print("sst  time: "+YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))
 ;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})

   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   
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
   
   shf_mon = shfdata->shtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   shf_mam = month_to_season(shf_mon, "MAM")
   
   lhf_mon = lhfdata->lhtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   lhf_mam = month_to_season(lhf_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   ; snow_mon_wgt = SqrtCosWeight(snow_mon)

;*************************************************
;Filter High-Frequency Pass
;*************************************************
   ihp = 1
   fca = 1.0/120.
   fcb= -999
   nsigma = 1.
   nwt= 21
   wgt_hf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

   snow_mon_hf = wgt_runave_n_Wrap(snow_mon, wgt_hf, 0, 0)

;************************************************
; Calculate Index
;************************************************
  sc_eu = snow_mon(:,{SC_EU_S:SC_EU_N},{SC_EU_L:SC_EU_R})

  sc_eu_ind = wgt_areaave_Wrap(sc_eu, 1.0, 1.0, 1)
  sci_eu = dim_standardize_Wrap(sc_eu_ind,0)

  nyrs = dimsizes(sci_eu)/12
  sci_eu_reshp = onedtond(sc_eu_ind, (/nyrs,12/))
  sci_eu_mon = dim_avg_n_Wrap(sci_eu_reshp, 0)
  ; printMinMax(sci_eu_mon, 1)

  sc_dim = dimsizes(sc_eu)

  ;-------------------------------------------
  ;Area linear trend
  dim_snow = dimsizes(snow_mon)
  sc_eu_reshp = reshape(snow_mon, (/dim_snow(0)/12, 12, dim_snow(1), dim_snow(2)/))
  sc_eu_trend = trend_manken(sc_eu_reshp, True, 0)

  sc_eu_trend_mam = dim_avg_n_Wrap(sc_eu_trend(:,2:4,:,:), 1)
  sc_eu_trend_jja = dim_avg_n_Wrap(sc_eu_trend(:,5:7,:,:), 1)
  sc_eu_trend_son = dim_avg_n_Wrap(sc_eu_trend(:,8:10,:,:), 1)
  sc_eu_trend_djf = (dim_avg_n_Wrap(sc_eu_trend(:,0:1,:,:), 1)+sc_eu_trend(:,11,:,:))/2.0

  do i = 0, 1
      copy_VarCoords(snow_mon(0,:,:), sc_eu_trend_mam(i,:,:))
      copy_VarCoords(snow_mon(0,:,:), sc_eu_trend_jja(i,:,:))
      copy_VarCoords(snow_mon(0,:,:), sc_eu_trend_son(i,:,:))
      copy_VarCoords(snow_mon(0,:,:), sc_eu_trend_djf(i,:,:))
  end do

  sc_eu_trend_annual = sc_eu_trend_djf
  sc_eu_trend_annual = (sc_eu_trend_mam+sc_eu_trend_jja+sc_eu_trend_son+sc_eu_trend_djf)/4.
;************************************************
;Seasonal Mean
  sc_eu_mam = month_to_season(sc_eu, "MAM")
  sci_eu_mam = dim_standardize_Wrap(wgt_areaave_Wrap(sc_eu_mam, 1.0, 1.0, 1),0)
  sci_eu_mam = runave(sci_eu_mam, 11, 1)

  sc_eu_jja = month_to_season(sc_eu, "JJA")
  sci_eu_jja = dim_standardize_Wrap(wgt_areaave_Wrap(sc_eu_jja, 1.0, 1.0, 1),0)
  sci_eu_jja = runave(sci_eu_jja, 11, 1)

  sc_eu_son = month_to_season(sc_eu, "SON")
  sci_eu_son = dim_standardize_Wrap(wgt_areaave_Wrap(sc_eu_son, 1.0, 1.0, 1),0)
  sci_eu_son = runave(sci_eu_son, 11, 1)

  sc_eu_djf = month_to_season(sc_eu, "DJF")
  sci_eu_djf = dim_standardize_Wrap(wgt_areaave_Wrap(sc_eu_djf, 1.0, 1.0, 1),0)
  sci_eu_djf = runave(sci_eu_djf, 11, 1)

  sci_eu_annual = sci_eu_djf
  sci_eu_annual = (sci_eu_mam+sci_eu_jja+sci_eu_son+sci_eu_djf)/4.
  ; sci_eu_annual = dim_avg_n_Wrap(sci_eu_reshp, 1)
  sci_eu_annual = dim_standardize_Wrap(sci_eu_annual, 0)
;*****************************************************************
  dim_season = dimsizes(sci_eu_mam)
  data_ind = new((/5,dim_season/), float )
  data_ind(0,:) = sci_eu_annual
  data_ind(1,:) = sci_eu_mam
  data_ind(2,:) = sci_eu_jja
  data_ind(3,:) = sci_eu_son
  data_ind(4,:) = sci_eu_djf

;*****************************************************************
   p = trend_manken(sci_eu_mam, False, 0)

   sci_eu_mam_dtrend = dtrend(sci_eu_mam, False)

   fcb= -999
   nsigma = 1.
   ihp = 0
   fca = 1.0/10
   nwt= 7
   wgt_lf := filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

;******************************************************************
;Spectral 
   iopt = 0
   jave = 7
   pct = 0.10
   spec_sce = specx_anal(sci_eu, iopt, jave, pct)
   red_noise = specx_ci(spec_sce, 0.05, 0.95)
   ; printMinMax(spec_sce@spcx, 0)
;*****************************************************************
;Resources Setting
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   ;For Fills
   resrc = True    
   resrc@gsnDraw = False
   resrc@gsnFrame = False
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnInfoLabelString = " "
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = False
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@mpGridAndLimbOn = False
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpFillOn = False
   resrc@mpOutlineOn = True
   ; resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@lbBoxLinesOn = False
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@pmLabelBarHeight = 0.05
   resrc@gsnAddCyclic = False
   resrc@mpFillOn = False
   resrc@mpMinLonF =   0
   resrc@mpMaxLonF =   180
   resrc@mpMinLatF =   20  
   resrc@mpMaxLatF =   80
   ; resrc@mpCenterLonF = (resrc@mpMinLonF+resrc@mpMaxLonF)/2

   res_snow = resrc
   res_snow@lbLabelBarOn = True
   res_snow@cnMaxLevelValF = 10
   res_snow@cnMinLevelValF = -1*res_snow@cnMaxLevelValF
   res_snow@cnLevelSpacingF = 1.
   res_snow@mpMinLonF = 0
   res_snow@mpMaxLonF = 180
   res_snow@mpMinLatF = 0
   res_snow@mpMaxLatF = 90

   ;Correlation res (with dots.)
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnMonoFillPattern = False
   rescor@cnLevels = (/0.05/)  ;95%
   rescor@cnFillPatterns = (/17,-1/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnFillColors = (/1,1/)
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False
   rescor@cnMonoFillScale = True   
   rescor@cnFillScaleF = 1.
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillOpacityF = 1.0

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsBackgroundFillColor = "white"
   resP@gsnPanelFigureStringsFontColor = "black"
   resP@gsnPanelYWhiteSpacePercent = 5
   resP@gsnPanelLabelBar = True
   resP@pmLabelBarWidthF = 0.3
  ;**********************************************************
  ;poly line
  ; Expts = (/sci_eu_mam_L, sci_eu_mam_L, sci_eu_mam_R, sci_eu_mam_R, sci_eu_mam_L/)
  ; Eypts = (/sci_eu_mam_S, sci_eu_mam_N, sci_eu_mam_N, sci_eu_mam_S, sci_eu_mam_S/)  
  ; dum1 = new(dimsizes(Expts)-1, graphic)
  ; dum2 = new(dimsizes(Expts)-1, graphic)
  ; dum3 = new(dimsizes(Expts)-1, graphic)
  ; plres = True
  ; plres@gsLineColor = "red"
  ; plres@gsLineThicknessF = 1.5
  ; plres@gsLineLabelString = ""

;**********************************************************
;Time Series plot
  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               
  rts@vpHeightF = 0.35        ; Changes the aspect ratio
  rts@vpWidthF  = 0.80
  rts@vpXF      = 0.15        ; change start locations
  rts@vpYF      = 0.75        ; the plot 
  rts@gsnLeftStringFontHeightF = 0.025
  rts@tmYLLabelFontHeightF = 0.015
  rts@tmYLLabelFontHeightF = 0.015

  rts_bar = rts  ; Bar Chart
  rts_bar@gsnXYBarChart         = True
  rts_bar@gsnYRefLine = 0.
  ;rts_bar@gsnLeftString = "(b) PC1"
  ;rts_bar@tmXUseBottom = True
  rts_bar@tmXBMode = "Explicit"
  ; rts_bar@tmXBValues = ispan(1975, 2005, 5)
  ; rts_bar@tmXBLabels = ispan(1975, 2005, 5)
  ; rts_bar@tmXBMinorValues = ispan(1972, 2009, 1)
  rts_bar@tmXTOn = False
  rts_bar@tmYROn = False
  rts_bar@tiXAxisString = "Time (Year)"
  rts_bar@tiYAxisString = " "
  rts_bar@tiXAxisFontHeightF = 0.02
  rts_bar@tiYAxisFontHeightF = 0.02
  ; rts_bar@trXMinF = 1971.5
  ; rts_bar@trXMaxF = 2009.5
  rts_bar@trYMinF = -3.0
  rts_bar@trYMaxF = -1*rts_bar@trYMinF
  rts_bar@gsnXYBarChartBarWidth = 0.35
  rts_bar@gsnAboveYRefLineColor = "red"
  rts_bar@gsnBelowYRefLineColor = "blue"

  rts_bar2 = rts_bar
  rts_bar2@gsnAboveYRefLineColor = "Transparent"
  rts_bar2@gsnBelowYRefLineColor = "Transparent"
  rts_bar2@gsnXYBarChartBarWidth = 0.65

  rts_line = rts   ; Line
  rts_line@xyDashPattern         = 1
  rts_line@xyLineThicknessF      = 4.
  rts_line@xyLineColor = "black"

  rtsP = True
  rtsP@lbLabelAutoStride = True
;**********************************************************
  ;Draw Bar chart
  ; rts_bar@gsnLeftStringFontHeightF = 0.02
  ; rts_bar@gsnLeftString = "b) Time series of SI"
  ; pbar = gsn_csm_xy(wks, year, sci_eu_mam, rts_bar)
  ; ; pbar2 = gsn_csm_xy(wks, year, sci_eu_mam, rts_bar2)
  ; ; pline = gsn_csm_xy(wks, year, sci_eu_mam_lf, rts_line)
  ; ; overlay(pbar, pbar2)
  ; overlay(pbar, pline)
  
  ; res_snow@gsnLeftString = "a) SCE"
  ; res_snow@gsnRightString = yrstrt/100+" - "+yrlast/100
  ; snowplot = gsn_csm_contour_map(wks, sci_sce_rc, res_snow)
  ; snowdot = gsn_csm_contour(wks, p_sce, rescor)
  ; overlay(snowplot, snowdot)
  ;  do i = 0, dimsizes(Expts)-2
  ;      dum2(i) = gsn_add_polyline(wks, snowplot, Expts(i:i+1), \
  ;                                 Eypts(i:i+1), plres)
  ;  end do 

   resrc@cnFillPalette = "MPL_RdBu"
   resrc@cnMaxLevelValF = 0.5
   resrc@cnMinLevelValF = -1*resrc@cnMaxLevelValF
   resrc@cnLevelSpacingF = 0.05

   rescor@cnLevels = (/0.90/)  ;95%
   rescor@cnFillPatterns = (/-1,17/)

   plots = new(5, graphic)
   plots(0) = gsn_csm_contour_map(wks, sc_eu_trend_annual(1,:,:), resrc)
   dotplot := gsn_csm_contour(wks, sc_eu_trend_annual(0,:,:), rescor)
   overlay(plots(0), dotplot)

   plots(1) = gsn_csm_contour_map(wks, sc_eu_trend_mam(1,:,:), resrc)
   dotplot := gsn_csm_contour(wks, sc_eu_trend_mam(0,:,:), rescor)
   overlay(plots(1), dotplot)

   plots(2) = gsn_csm_contour_map(wks, sc_eu_trend_jja(1,:,:), resrc)
   dotplot := gsn_csm_contour(wks, sc_eu_trend_jja(0,:,:), rescor)
   overlay(plots(2), dotplot)

   plots(3) = gsn_csm_contour_map(wks, sc_eu_trend_son(1,:,:), resrc)
   dotplot := gsn_csm_contour(wks, sc_eu_trend_son(0,:,:), rescor)
   overlay(plots(3), dotplot)

   plots(4) = gsn_csm_contour_map(wks, sc_eu_trend_djf(1,:,:), resrc)
   dotplot := gsn_csm_contour(wks, sc_eu_trend_djf(0,:,:), rescor)
   overlay(plots(4), dotplot)

   resP@gsnPanelFigureStrings = (/"(a)Annual","(b)MAM","(c)JJA","(d)SON","(e)DJF"/)
   gsn_panel(wks, plots, (/5,1/), resP)

  ;  plots = new(2, graphic)
  ;  plots(0) = snowplot
  ;  plots(1) = pbar
  ;  gsn_panel(wks, plots, (/2,1/), resP)
  
   ; rts_line@xyDashPattern = 0
   ; rts_line@trYMaxF = 0.5
   ; rts_line@trYMinF = 0.
   ; time = ispan(yrstrt/100 + wSize/2, yrlast/100- wSize/2, 1)
   ; plot_rcor = gsn_csm_xy(wks, time, rcor_snow_sat, rts_line)
   ; draw(plot_rcor)
   ; frame(wks)

    ; data_mk = asciiread(indexpath+"sce_eeu_mk.txt", (/48,4/), "float")
    ; data_mk!0 = "val"
    ; data_mk!1 = "var"
    ; data_mk2 = data_mk(var|:, val|:)

    ; rts_line@xyLineColors := (/"black", "blue", "black", "black"/)
    ; rts_line@xyLineThicknesses := (/4,4,1,1/)
    ; rts_line@xyDashPatterns := (/0,0,1,1/)
    ; rts_line@trYMaxF = 4.5
    ; rts_line@trYMinF = -4.5
    ; rts_line@trXMinF = yrstrt/100
    ; rts_line@trXMaxF = yrlast/100
    ; plot_mk = gsn_csm_xy(wks, year, data_mk2,rts_line)
    ; ; draw(plot_mk)
    ; ; frame(wks)
    
    ; rts_line@trYMaxF = 60.
    ; rts_line@trYMinF = 0.
    ; delete(rts_line@trXMinF)
    ; delete(rts_line@trXMaxF)
    ; plot_spec = gsn_csm_xy(wks, spec_sce@frq, spec_sce@spcx, rts_line)

    ; rts_line@vpHeightF = 0.6
    ; rts_line@vpWidthF  = 0.6
    ; rts_line@vpXF      = 0.15
    ; rts_line@vpYF      = 0.75
    ; rts_line@trYMaxF = 100
    ; rts_line@trYMinF = -10
    ; rts_line@trXMinF = 1
    years = ispan(1, 12, 1)
    ; plot2 = gsn_csm_xy(wks, years, sci_eu_mon, rts_line)
    ; draw(plot2)
    ; frame(wks)

  
    rts_bar@vpHeightF = 0.6
    rts_bar@vpWidthF  = 0.8
    rts_bar@trYMaxF = 90
    rts_bar@trYMinF = 0
    rts_bar@gsnAboveYRefLineColor = "turquoise"
    rts_bar@trXMinF = 0.5
    rts_bar@trXMaxF = 12.5
    rts_bar@tiXAxisString = "Annual Cycle of Eurasian Snow Cover"
    rts_bar@tmXBOn = True
    rts_bar@tmXBMode = "Explicit"
    rts_bar@tmXBValues = ispan(1, 12, 1)
    rts_bar@tmXBLabels = (/"Jul","Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun"/)

    sci_eu_mon2 = sci_eu_mon
    sci_eu_mon2(0:5) = sci_eu_mon(6:11)
    sci_eu_mon2(6:11) = sci_eu_mon(0:5)
    plot3 = gsn_csm_xy(wks, years, sci_eu_mon2, rts_bar)
    draw(plot3)
    frame(wks)
  
    rts_line@trYMaxF = 2.5
    rts_line@trYMinF = -1*rts_line@trYMaxF
    rts_line@trXMinF = 1972
    rts_line@trXMaxF = 2019
    rts_line@xyLineThicknesses := (/4, 2.5,2.5,2.5,2.5/)
    rts_line@xyDashPatterns = (/0, 6,6,6,6/)
    rts_line@gsnYRefLine = 0
    rts_line@gsnYRefLineThicknessF = 1.

    rts_line@pmLegendDisplayMode = "Always"
    rts_line@pmLegendSide = "Top"
    rts_line@pmLegendParallelPosF   = 0.8
    rts_line@pmLegendOrthogonalPosF = -0.4
    rts_line@pmLegendWidthF         = 0.09
    rts_line@pmLegendHeightF        = 0.1
    rts_line@lgPerimOn              = False
    rts_line@lgLabelFontHeightF     = 0.01
    rts_line@xyExplicitLegendLabels = (/" Annual"," MAM"," JJA"," SON"," DJF"/)
    rts_line@lgItemOrder  = (/ 4,3,2,1,0 /)

    rts_line@xyLineColors = (/"black", "blue", "darkgoldenrod", "red","seagreen"/)
    rts_line@tiYAxisString = " "
    rts_line@tiXAxisString = "Year"
    plot := gsn_csm_xy(wks, year, data_ind, rts_line)
    draw(plot)
    frame(wks)



end
