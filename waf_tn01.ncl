load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   yrstrt = 199001  
   yrlast = 201412

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  year=ispan(yrstrt_snow/100, yrlast_snow/100, 1)
  ;t = ispan(1970, 2014, 1)

;---------------W,E-index Region
  SCI_WEU_N = 70
  SCI_WEU_S = 40
  SCI_WEU_L = 20
  SCI_WEU_R = 50

  SCI_EEU_N = 70
  SCI_EEU_S = 40
  SCI_EEU_L = 80
  SCI_EEU_R = 140
  
  SCI_NA_N = 70
  SCI_NA_S = 40
  SCI_NA_L = 240-360
  SCI_NA_R = 300-360

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   nceppath = "/public/home/charlesxiami/data/ncep/"
   snowpath = "/public/home/charlesxiami/data/snow/"
   indexpath = "/public/home/charlesxiami/data/index/"

   plotpath = "/public/home/charlesxiami/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"waf_tn01")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.nc", "r")

   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
   soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")
   snowdata = addfile(snowpath+"snow.rutger.2.0deg.nc","r")

 ;***************************************
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
   
   hgt_mon = hgtdata->hgt(iStrt:iLast,{250},{latS:latN},{lonL:lonR})
   
   u_mon = uwnddata->uwnd(iStrt:iLast,{250},{latS:latN},{lonL:lonR}) 

   v_mon = vwnddata->vwnd(iStrt:iLast,{250},{latS:latN},{lonL:lonR})

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)
;*************************************************
;Filter High-Frequency Pass
;*************************************************
   ihp = 1
   fca = 1.0/120.
   fcb= -999
   nsigma = 1.
   nwt= 21
   wgt_hf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

 ;   snow_mon_hf = wgt_runave_n_Wrap(snow_mon, wgt_hf, 0, 0)
 ;   air_mon_hf  = wgt_runave_n_Wrap(air_mon, wgt_hf, 0, 0)
 ;   slp_mon_hf  = wgt_runave_n_Wrap(slp_mon, wgt_hf, 0, 0)
 ;   z500_mon_hf = wgt_runave_n_Wrap(z500_mon, wgt_hf, 0, 0)
 ;   z200_mon_hf = wgt_runave_n_Wrap(z200_mon, wgt_hf, 0, 0)
 ;   sst_mon_hf  = wgt_runave_n_Wrap(sst_mon, wgt_hf, 0, 0)
 ;   u_mon_hf    = wgt_runave_n_Wrap(u_mon, wgt_hf, 0, 0)
 ;   v_mon_hf    = wgt_runave_n_Wrap(v_mon, wgt_hf, 0, 0)

 ; ;Low frequency
 ;   ihp = 0
 ;   wgt_lf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
 ;   snow_mon_lf = wgt_runave_n_Wrap(snow_mon, wgt_lf, 0, 0)
 ;   air_mon_lf  = wgt_runave_n_Wrap(air_mon, wgt_lf, 0, 0)
 ;   slp_mon_lf  = wgt_runave_n_Wrap(slp_mon, wgt_lf, 0, 0)
 ;   z500_mon_lf = wgt_runave_n_Wrap(z500_mon, wgt_lf, 0, 0)
 ;   z200_mon_lf = wgt_runave_n_Wrap(z200_mon, wgt_lf, 0, 0)
 ;   sst_mon_lf  = wgt_runave_n_Wrap(sst_mon, wgt_lf, 0, 0)
 ;   u_mon_lf    = wgt_runave_n_Wrap(u_mon, wgt_lf, 0, 0)
 ;   v_mon_lf    = wgt_runave_n_Wrap(v_mon, wgt_lf, 0, 0)

  ;************************************************
  ;Seasonal Mean
   ; snow_mam = month_to_season(snow_mon_hf, "MAM")
   ; snow_mam = month_to_season(snow_mon, "MAM")
   ; air_mam   = month_to_season(air_mon, "MAM")
   ; slp_mam   = month_to_season(slp_mon, "MAM")
   ; z500_mam = month_to_season(z500_mon, "MAM")
   ; z200_mam = month_to_season(z200_mon, "MAM")
   ; sst_mam   = month_to_season(sst_mon, "DJF")
   ; u_mam = month_to_season(u_mon, "MAM")
   ; v_mam = month_to_season(v_mon, "MAM")

   ;Climatic Mean
   ndim = dimsizes(hgt_mon)
   uclm = dim_avg_n_Wrap(u_mon(10:ndim(0)-1:12,:,:),0)
   vclm = dim_avg_n_Wrap(u_mon(10:ndim(0)-1:12,:,:),0)
   zclm = dim_avg_n_Wrap(hgt_mon(10:ndim(0)-1:12,:,:),0)
   za = zclm
   za = hgt_mon(ndim(0)-1-1,:,:) - zclm

   magU = sqrt(uclm^2 + vclm^2)

;****************************************************************
;Wave activity flux
;****************************************************************
   

  ;Define
   Ra = 290   ;gas constant
   a = 6400000   ;earth radius
   pai = 4.*atan(1.0)

   ;center diff
   lat = hgtdata&lat
   lon = hgtdata&lon

   r = 1
   ; dlat = center_finite_diff(lat, r, False, 0)
   ; dlon = center_finite_diff(lon, r, False, 0)
   dlat = -2.5
   dlon = 2.5

   coslat = cos(lat*pai/180)
   sinlat = sin(lat*pai/180)
   coslat_2d = conform(zclm, coslat, 0)
   sinlat_2d = conform(zclm, sinlat, 0)

   f = 2*7.24/100000*sinlat
   f = where(f.eq.0, 2*7.24/100000*sin(43*pai/180), 2*7.24/100000*sinlat)
   f_2d = conform(zclm, f, 0)
   ;f0 = 2*7.24/100000*sin(43*pai/180)
   g = 9.8

   psia = g/f_2d*za
   copy_VarCoords(zclm, psia)

   rCyclic = False
   dpsidlon = center_finite_diff_n(psia, r, rCyclic, 0, 1)/dlon
   ddpsidlonlon = center_finite_diff_n(dpsidlon, r, rCyclic, 0, 1)/dlon

   dpsidlat = center_finite_diff_n(psia, r, rCyclic, 0, 0)/dlat
   ddpsidlatlat = center_finite_diff_n(dpsidlat, r, rCyclic, 0, 0)/dlat
   ddpsidlatlon = center_finite_diff_n(dpsidlat, r, rCyclic, 0, 1)/dlon

   termxu = dpsidlon*dpsidlon-psia*ddpsidlonlon
   termxv = dpsidlon*dpsidlat-psia*ddpsidlatlon
   termyv = dpsidlat*dpsidlat-psia*ddpsidlatlat

   coeff = coslat_2d*0.5/(2*magU)

   px = coeff/(a^2*coslat_2d)*(uclm*termxu/coslat_2d + vclm*termxv)  ;10^5*
   py = coeff/(a^2)*(uclm*termxv/coslat_2d + vclm*termyv)
   copy_VarCoords(uclm, px)
   copy_VarCoords(vclm, py)

   printMinMax(px, 0)
   printMinMax(py, 0)
   printMinMax(psia, 0)

   lat_2d = conform(uclm, lat, 0)
   py = mask(py, abs(lat_2d).ge.10.and.magU.ge.5, True)

;**********************************************************
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
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 360.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.

   ;For Line
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
   resrc2@cnLineLabelFontHeightF = 0.010
   ;resrc2@cnLineLabelFontColor = 0
   resrc2@cnLineLabelFontThicknessF = 1.0
   resrc2@gsnAddCyclic = True
   resrc2@cnLevelSelectionMode = "ManualLevels"

   ;Correlation res (with dots.)
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/0.05/)  ;95%
   rescor@cnMonoFillPattern = False
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

   rescor2 = res
   rescor2@cnLinesOn = False
   rescor2@cnFillOn = True
   rescor2@cnInfoLabelOn = False
   rescor2@lbLabelBarOn = False
   ; rescor2@cnMonoFillPattern = True
   rescor2@cnLevelSelectionMode = "ExplicitLevels"
   rescor2@cnLevels = (/0.01, 0.05/)
   rescor2@cnFillColors = (/"grey35", "grey65", "Transparent"/)   
   ; rescor2@cnFillColors = (/1, 2, 4/)
   rescor2@mpCenterLonF = 180.
   rescor2@mpFillOn = False
   rescor2@mpMinLonF = 0.
   rescor2@mpMaxLonF = 360.
   rescor2@mpMaxLatF = 90.
   rescor2@mpMinLatF = 0.

   ;Wind Resources
   resV = True
   resV@gsnDraw = False
   resV@gsnFrame = False
   resV@vcRefMagnitudeF = 5
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"  
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.13
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.0               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"

;**********************************************************
;Draw contour

   resrc@cnMaxLevelValF = 20.
   resrc@cnMinLevelValF = -20.
   resrc@cnLevelSpacingF = 1.

   ; resrc2@cnMaxLevelValF = 24.
   ; resrc2@cnMinLevelValF = -24.
   ; resrc2@cnLevelSpacingF = 4.
   resrc2@mpCenterLonF = 180.
   resrc2@mpFillOn = False
   resrc2@mpMinLonF = 0.
   resrc2@mpMaxLonF = 360.
   resrc2@mpMaxLatF = 90.
   resrc2@mpMinLatF = 0.
   resrc2@cnLineThicknessF = 1.0

   resV@vcLineArrowThicknessF   = 1.5
   hgtplot = gsn_csm_contour_map(wks, psia, resrc2)
   wafvc = gsn_csm_vector(wks, px, py, resV)
   overlay(hgtplot, wafvc)
   draw(hgtplot)
   frame(wks)

    ; pxplot = gsn_csm_contour_map(wks, px, resrc)
    ; draw(pxplot)
    ; frame(wks)


end
