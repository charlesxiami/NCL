load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   yrstrt = 197201
   yrlast = 199212

   ; yrstrt = 199401
   ; yrlast = 201512

   nyrs = yrlast/100-yrstrt/100+1
   print(nyrs+" years")

   yrstrt_snow = 197201
   yrlast_snow = 199212

   ; yrstrt_snow = 199301
   ; yrlast_snow = 201412

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   year = ispan(yrstrt_snow/100, yrlast_snow/100, 1)
   ;t = ispan(1970, 2014, 1)
;---------------W,E-index Region
  SCI_EEU_N = 70
  SCI_EEU_S = 40
  SCI_EEU_L = 80
  SCI_EEU_R = 140
  
  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"
   twtypath = "$HOME/data/20thCR/20thC_V2c/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"snow.20thC")
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
   precipdata = addfile(precpath+"precip.mon.anom.nc", "r")

   snowdata = addfile(twtypath+"snowc.mon.mean.nc","r")
 ;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt_sst)
   iLast2  = ind(YYYYMM2.eq.yrlast_sst)
   ; print("sst  time: "+YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))
 ;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})

   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR})

   z70_mon = hgtdata->hgt(iStrt:iLast,{70},{latS:latN},{lonL:lonR})

   z50_mon = hgtdata->hgt(iStrt:iLast,{50},{latS:latN},{lonL:lonR})

   u850_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR})
   v850_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 

   u200_mon = uwnddata->uwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})
   v200_mon = vwnddata->vwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})

   nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   
   nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})

   shf_mon = shfdata->shtfl(iStrt:iLast,{latS:latN},{lonL:lonR})

   lhf_mon = lhfdata->lhtfl(iStrt:iLast,{latS:latN},{lonL:lonR})

   soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})

   precip_mon = precipdata->precip(iStrt:iLast,{latS:latN},{lonL:lonR})

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowc(iStrt3:iLast3,:,:)
   ; snow_mon_wgt = SqrtCosWeight(snow_mon)

;*************************************************
;Filter High-Frequency Pass
;*************************************************
   fcb= -999
   nsigma = 1.
   ihp = 1
   fca = 1.0/120.
   nwt= 21
   wgt_hf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

 ;   snow_mon_hf = wgt_runave_n_Wrap(snow_mon, wgt_hf, 0, 0)
 ;   air_mon_hf  = wgt_runave_n_Wrap(air_mon, wgt_hf, 0, 0)
 ;   slp_mon_hf  = wgt_runave_n_Wrap(slp_mon, wgt_hf, 0, 0)
 ;   z500_mon_hf = wgt_runave_n_Wrap(z500_mon, wgt_hf, 0, 0)
 ;   z200_mon_hf = wgt_runave_n_Wrap(z200_mon, wgt_hf, 0, 0)
 ;   sst_mon_hf  = wgt_runave_n_Wrap(sst_mon, wgt_hf, 0, 0)
 ;   u850_mon_hf = wgt_runave_n_Wrap(u850_mon, wgt_hf, 0, 0)
 ;   v850_mon_hf = wgt_runave_n_Wrap(v850_mon, wgt_hf, 0, 0)
 ;   u200_mon_hf = wgt_runave_n_Wrap(u200_mon, wgt_hf, 0, 0)

 ; ;Low frequency
 ;   ihp = 0
 ;   wgt_lf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
 ;   snow_mon_lf = wgt_runave_n_Wrap(snow_mon, wgt_lf, 0, 0)
 ;   air_mon_lf  = wgt_runave_n_Wrap(air_mon, wgt_lf, 0, 0)
 ;   slp_mon_lf  = wgt_runave_n_Wrap(slp_mon, wgt_lf, 0, 0)
 ;   z500_mon_lf = wgt_runave_n_Wrap(z500_mon, wgt_lf, 0, 0)
 ;   z200_mon_lf = wgt_runave_n_Wrap(z200_mon, wgt_lf, 0, 0)
 ;   sst_mon_lf  = wgt_runave_n_Wrap(sst_mon, wgt_lf, 0, 0)

;************************************************
;Seasonal Mean
   snow_mam  = month_to_season(snow_mon, "SON")

   season = "DJF"
   air_mam    = month_to_season(air_mon, season)
   slp_mam    = month_to_season(slp_mon, season)
   z500_mam  = month_to_season(z500_mon, season)
   z200_mam  = month_to_season(z200_mon, season)
   z70_mam  = month_to_season(z70_mon, season)
   z50_mam  = month_to_season(z50_mon, season)
   ; zmulti_mam = month_to_season(zmulti_mon, season)
   sst_mam    = month_to_season(sst_mon, season)
   u850_mam  = month_to_season(u850_mon, season)
   v850_mam  = month_to_season(v850_mon, season)
   u200_mam  = month_to_season(u200_mon, season)
   precip_mam = month_to_season(precip_mon, season)

   nswr_mam   = month_to_season(nswr_mon, season)
   nlwr_mam   = month_to_season(nlwr_mon, season)
   shf_mam     = month_to_season(shf_mon, season)
   lhf_mam     = month_to_season(lhf_mon, season)
   soilw_mam = month_to_season(soilw_mon, season)

   print("season:  " + season)
 ;*****************************************************************
   ;p1 = 1972-1992, p2 = 1993-2014
   ; snow_pc1_p1 = asciiread(indexpath+"snow.pc1.p1.txt", -1, "float")
   ; snow_pc1_p2 = asciiread(indexpath+"snow.pc1.p2.txt", -1, "float")
   ; snow_pc2_p1 = asciiread(indexpath+"snow.pc2.p1.txt", -1, "float")
   ; snow_pc2_p2 = asciiread(indexpath+"snow.pc2.p2.txt", -1, "float")

   snow_son_pc1 = asciiread(indexpath+"snow.son.dt.pc1"+".txt", -1, "float")
   snow_son_pc2 = asciiread(indexpath+"snow.son.dt.pc2"+".txt", -1, "float")

   imidyr = 20
   pc1_p1 = snow_son_pc1(0:imidyr)
   pc1_p2 = snow_son_pc1(imidyr+1:)

   pc2_p1 = snow_son_pc2(0:imidyr)
   pc2_p2 = snow_son_pc2(imidyr+1:)

;*****************************************************************

;**********************************************************
;3-D Data analysis
;**********************************************************
 ;Reg and Cor

  ;Define index
  ndim1 = dimsizes(pc1_p1)
  ndim2 = dimsizes(pc1_p2)

  snow_index = pc2_p1

  ;snow data
  sci_sce_rc = regCoef_n(snow_index, snow_mam, 0, 0)
  copy_VarCoords(snow_mam(0,:,:), sci_sce_rc)
  sci_sce_cor = escorc_n(snow_index, snow_mam, 0, 0)  
  ndim_snow = dimsizes(snow_mam)
  df_snow = sci_sce_cor
  df_snow = ndim_snow(0) - 2
  t_sce = sci_sce_cor*sqrt(df_snow/(1- sci_sce_cor^2 ))
  p_sce = student_t(t_sce, df_snow)
  copy_VarCoords(snow_mam(0,:,:), p_sce)
  
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
   resrc@cnFillDrawOrder = "PreDraw"   
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@mpGridAndLimbOn = False
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpOutlineOn = True
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = True
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 360
   ; resrc@mpMinLonF = 180
   ; resrc@mpMaxLonF = 330
   resrc@mpMaxLatF = 90
   resrc@mpMinLatF = 0
   resrc@mpCenterLonF = (resrc@mpMinLonF+resrc@mpMaxLonF)/2.
   resrc@mpAreaMaskingOn = True
   resrc@mpOceanFillColor = "white"
   resrc@mpLandFillColor = "Transparent"
   ; resrc@mpMaskAreaSpecifiers =(/"China","Taiwan"/)

   res_circ = resrc
   res_circ@mpFillOn = False   
   ; res_circ@mpMinLonF = 0
   ; res_circ@mpMaxLonF = 360
   ; res_circ@mpMaxLatF = 90
   res_circ@mpMinLatF = 0
   ; res_circ@mpCenterLonF = (res_circ@mpMinLonF+res_circ@mpMaxLonF)/2.

   res_snow = resrc
   res_snow@lbLabelBarOn = True

   res_htfl = res_circ
   res_htfl@cnMaxLevelValF = 8.
   res_htfl@cnMinLevelValF = -8.
   res_htfl@cnLevelSpacingF = 1.

   resSST = res_circ
   ; resSST@lbLabelBarOn = True
   resSST@mpMaxLonF = 360
   resSST@mpMinLonF = 0
   resSST@mpMaxLatF = 90
   resSST@mpMinLatF = -30
   resSST@mpCenterLonF = 180

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
   rescor@cnFillDrawOrder = "PreDraw"

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
   resV@vcRefMagnitudeF = 1.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"  
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.65
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.8               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.015
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsBackgroundFillColor = "black"
   resP@gsnPanelFigureStringsFontColor = "white"
;**********************************************************
;****************************************************************
;Polyline
   ;Polyline Setting
   Expts = (/SCI_EEU_L, SCI_EEU_L, SCI_EEU_R, SCI_EEU_R, SCI_EEU_L/)
   Eypts = (/SCI_EEU_S, SCI_EEU_N, SCI_EEU_N, SCI_EEU_S, SCI_EEU_S/)

   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 1.5
   plres@gsLineLabelString = ""

   dum1 = new(dimsizes(Expts)-1, graphic)
   dum2 = new(dimsizes(Expts)-1, graphic)
   dum3 = new(dimsizes(Expts)-1, graphic)
;**********************************************************
;Draw contour

   res_snow@cnMaxLevelValF = 8
   res_snow@cnMinLevelValF = -1*res_snow@cnMaxLevelValF
   res_snow@cnLevelSpacingF = 0.5
   res_snow@mpMinLonF = 0
   res_snow@mpMaxLonF = 160
   res_snow@mpMaxLatF = 80
   res_snow@mpMinLatF = 20
   ; res_snow@gsnPolar = "NH"
   ; res_snow@mpMinLatF = 20.
   ; res_snow@lbOrientation = "Vertical"
  ; res_snow@gsnLeftString = "Snow Reg "+season
  snowplot = gsn_csm_contour_map(wks, sci_sce_rc, res_snow)
  snowdot = gsn_csm_contour(wks, p_sce, rescor)
  overlay(snowplot, snowdot)
   ; do i = 0, dimsizes(Expts)-2
   ;     dum2(i) = gsn_add_polyline(wks, snowplot, Expts(i:i+1), \
   ;                                Eypts(i:i+1), plres)
   ; end do
   draw(snowplot)
   frame(wks)




end
