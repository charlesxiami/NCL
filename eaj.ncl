load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   yrstrt = 196701   ;P1+P2
   yrlast = 201412

   ; yrstrt = 196701   ;P1
   ; yrlast = 198812

   ; yrstrt = 198901  ;P2
   ; yrlast = 201412
   
   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

   year=ispan(yrstrt_snow/100, yrlast_snow/100, 1)

;---------------W,E-index Region
  EAJ_N = 35
  EAJ_S = 30
  EAJ_L = 130
  EAJ_R = 160

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   nceppath = "/public/home/charlesxiami/data/ncep/"
   snowpath = "/public/home/charlesxiami/data/snow/"
   indexpath = "/public/home/charlesxiami/data/index/"

   plotpath = "/public/home/charlesxiami/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"EAJ")
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


 ;*****************************************************************************************
   t_index = ispan(1950, 2017, 1)
   iStrt0 = ind(t_index.eq.yrstrt/100)
   iLast0 = ind(t_index.eq.yrlast/100)

   ;Nao 195001-201806
   nao_index = asciiread(indexpath+"norm.nao.monthly.b5001.current.ascii.txt", -1, "string")
   nao_mon = stringtofloat(str_get_field(nao_index, 3, " "))
   nao_djf_long = new((/67/), float)  ; nao_djf: 1950/51DJF-2016/7DJF
   nao_mam_long = new((/67/), float)  ; nao_mam: 1950MAM-2016MAM
   do i = 0,66
    nao_djf_long(i) = dim_avg_Wrap(nao_mon(i*12+11:i*12+13))
   end do 
   do i = 0,66
    nao_mam_long(i) = dim_avg_Wrap(nao_mon(i*12+2:i*12+4))
   end do
   nao_mam = nao_mam_long(iStrt0:iLast0)

   ;ao_mon 195001-201708
   ao_index = asciiread(indexpath+"monthly.ao.index.b50.current.ascii.txt", -1, "string")
   ao_mon = stringtofloat(str_get_field(ao_index, 3, " "))
   ao_djf_long = new((/67/), float)  ; ao_djf: 1950DJF-2016DJF
   ao_mam_long = new((/67/), float)  ; ao_mam: 1950MAM-2016MAM
   do i = 0,66
    ao_djf_long(i) = dim_avg_Wrap(ao_mon(i*12+11:i*12+13))
   end do
   do i = 0,66
    ao_mam_long(i) = dim_avg_Wrap(ao_mon(i*12+2:i*12+4))
   end do
   ao_mam = ao_mam_long(iStrt0:iLast0)

   ;PNA 195001-
   pna_index = asciiread(indexpath+"norm.pna.monthly.b5001.current.ascii.txt", -1, "string")
   pna_mon = stringtofloat(str_get_field(pna_index, 3, " "))
   pna_djf_long = new((/67/), float)  ; pna_djf: 1950/51DJF-2016/7DJF
   pna_mam_long = new((/67/), float)  ; pna_mam: 1950MAM-2016MAM
   do i = 0,66
    pna_djf_long(i) = dim_avg_Wrap(pna_mon(i*12+11:i*12+13))
   end do 
   do i = 0,66
    pna_mam_long(i) = dim_avg_Wrap(pna_mon(i*12+2:i*12+4))
   end do
   pna_mam = pna_mam_long(iStrt0:iLast0)

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
   
   u850_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR})
   v850_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 

   u200_mon = uwnddata->uwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})
   v200_mon = vwnddata->vwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})

   nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nswr_mam = month_to_season(nswr_mon, "MAM")
   
   nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nlwr_mam = month_to_season(nlwr_mon, "MAM")
   
   shf_mon = shfdata->shtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   shf_mam = month_to_season(shf_mon, "MAM")
   
   lhf_mon = lhfdata->lhtfl(iStrt:iLast,{latS:latN},{lonL:lonR})
   lhf_mam = month_to_season(lhf_mon, "MAM")
   
   soilw_mon = soilwdata->soilw(iStrt:iLast,{latS:latN},{lonL:lonR})
   soilw_mam = month_to_season(soilw_mon, "MAM")

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

   snow_mon_hf = wgt_runave_n_Wrap(snow_mon, wgt_hf, 0, 0)
   air_mon_hf  = wgt_runave_n_Wrap(air_mon, wgt_hf, 0, 0)
   slp_mon_hf  = wgt_runave_n_Wrap(slp_mon, wgt_hf, 0, 0)
   z500_mon_hf = wgt_runave_n_Wrap(z500_mon, wgt_hf, 0, 0)
   z200_mon_hf = wgt_runave_n_Wrap(z200_mon, wgt_hf, 0, 0)

 ;Low frequency
   ihp = 0
   wgt_lf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
   snow_mon_lf = wgt_runave_n_Wrap(snow_mon, wgt_lf, 0, 0)
   air_mon_lf  = wgt_runave_n_Wrap(air_mon, wgt_lf, 0, 0)
   slp_mon_lf  = wgt_runave_n_Wrap(slp_mon, wgt_lf, 0, 0)
   z500_mon_lf = wgt_runave_n_Wrap(z500_mon, wgt_lf, 0, 0)
   z200_mon_lf = wgt_runave_n_Wrap(z200_mon, wgt_lf, 0, 0)
   ; sst_mon_lf  = wgt_runave_n_Wrap(sst_mon, wgt_lf, 0, 0)

;************************************************
;Seasonal Mean
   ; snow_mam = month_to_season(snow_mon_hf, "MAM")
   snow_mam = month_to_season(snow_mon, "MAM")
   air_mam   = month_to_season(air_mon, "MAM")
   slp_mam   = month_to_season(slp_mon, "MAM")
   z500_mam = month_to_season(z500_mon, "MAM")
   z200_mam = month_to_season(z200_mon, "MAM")
   ; sst_mam   = month_to_season(sst_mon, "MAM")
   u200_mam = month_to_season(u200_mon, "MAM")
   v200_mam = month_to_season(v200_mon, "MAM")
   u850_mam  = month_to_season(u850_mon, "MAM")
   v850_mam  = month_to_season(v850_mon, "MAM")
;************************************************
; Calculate Index
;************************************************
  EAJ_AREA = u200_mam(:,{EAJ_S:EAJ_N},{EAJ_L:EAJ_R})
  eaj_index = dim_standardize_Wrap(wgt_areaave_Wrap(EAJ_AREA, 1.0, 1.0, 1),0)
  asciiwrite(indexpath+"eaj_index.txt", eaj_index)

;*****************************************************************
;Partial Reg
 ;DJF
 ;--------------------------------------------------------------
 ;Remove NAO
 ;  sci_weu_res = sci_weu - nao_djf(16:63)*regline(nao_djf(16:63), sci_weu)
 ;  sci_eeu_res = sci_eeu - nao_djf(16:63)*regline(nao_djf(16:63), sci_eeu)
 ;  sci_na_res  = sci_na  - nao_djf(16:63)*regline(nao_djf(16:63), sci_na)
 ; ;Remove AO
 ;  sci_weu_res = sci_weu - ao_djf(16:63)*regline(ao_djf(16:63), sci_weu)
 ;  sci_eeu_res = sci_eeu - ao_djf(16:63)*regline(ao_djf(16:63), sci_eeu)
 ;  sci_na_res  = sci_na  - ao_djf(16:63)*regline(ao_djf(16:63), sci_na)
 ;Remove AO and NAO
  ; sci_weu_res = sci_weu - nao_djf(16:63)*regline(nao_djf(16:63), sci_weu)- \
  ;                        ao_djf(16:63)*regline(ao_djf(16:63), sci_weu)
  ; sci_eeu_res = sci_eeu - nao_djf(16:63)*regline(nao_djf(16:63), sci_eeu)- \
  ;                        ao_djf(16:63)*regline(ao_djf(16:63), sci_eeu)
  ; sci_na_res  = sci_na  - nao_djf(16:63)*regline(nao_djf(16:63), sci_na)- \
  ;                        ao_djf(16:63)*regline(ao_djf(16:63), sci_na)
  ;--------------------------------------------------------------

 ;MAM
 ;--------------------------------------------------------------
 ; print("Remove NAO")
 ;  sci_weu_res = sci_weu - nao_mam(17:64)*regline(nao_mam(17:64), sci_weu)
 ;  sci_eeu_res = sci_eeu - nao_mam(17:64)*regline(nao_mam(17:64), sci_eeu)
 ;  sci_na_res  = sci_na  - nao_mam(17:64)*regline(nao_mam(17:64), sci_na)
 ; print("Remove AO")
 ;  sci_weu_res = sci_weu - ao_mam(17:64)*regline(ao_mam(17:64), sci_weu)
 ;  sci_eeu_res = sci_eeu - ao_mam(17:64)*regline(ao_mam(17:64), sci_eeu)
 ;  sci_na_res  = sci_na  - ao_mam(17:64)*regline(ao_mam(17:64), sci_na)
  ; print("Remove AO and NAO")
  ; sci_weu_res = sci_weu - nao_mam(17:64)*regline(nao_mam(17:64), sci_weu)- \
  ;                        ao_mam(17:64)*regline(ao_mam(17:64), sci_weu)
  ; sci_eeu_res = sci_eeu - nao_mam(17:64)*regline(nao_mam(17:64), sci_eeu)- \
  ;                        ao_mam(17:64)*regline(ao_mam(17:64), sci_eeu)
  ; sci_na_res  = sci_na  - nao_mam(17:64)*regline(nao_mam(17:64), sci_na)- \
  ;                        ao_mam(17:64)*regline(ao_mam(17:64), sci_na)
  ;--------------------------------------------------------------

;**********************************************************
; correlation coeffecient
  ;Whole period
  ; print("cor sci_eeu-ssti =    " + escorc(sci_eeu, ssti))
  ; print("cor sci_eeu-AO =    " + escorc(sci_eeu, ao_mam))
  ; print("cor sci_eeu-NAO =    " + escorc(sci_eeu, nao_mam))
  ; print("cor sci_eeu-PNA =    " + escorc(sci_eeu, pna_mam))

;**********************************************************
  ;snow data
  eaj_sce_rc = regCoef_n(eaj_index, snow_mam, 0, 0)
  copy_VarCoords(snow_mam(0,:,:), eaj_sce_rc)
  eaj_sce_cor = escorc_n(eaj_index, snow_mam, 0, 0)  
  ndim_snow = dimsizes(snow_mam)
  df_snow = eaj_sce_cor
  df_snow = ndim_snow(0) - 2
  t_sce = eaj_sce_cor*sqrt(df_snow/(1- eaj_sce_cor^2 ))
  p_sce = student_t(t_sce, df_snow)
  copy_VarCoords(snow_mam(0,:,:), p_sce)

  ;ncep data 
  ndim_ncep = dimsizes(air_mam)
  eaj_sat_rc = regCoef_n(eaj_index, air_mam, 0, 0)
  copy_VarCoords(air_mam(0,:,:), eaj_sat_rc)
  eaj_sat_cor = escorc_n(eaj_index, air_mam, 0, 0)

  df_ncep = eaj_sat_cor
  df_ncep = ndim_ncep(0) - 2
  t_sat = eaj_sat_cor*sqrt(df_ncep/(1- eaj_sat_cor^2))
  p_sat = student_t(t_sat, df_ncep)
  copy_VarCoords(air_mam(0,:,:), p_sat)

  eaj_slp_rc = regCoef_n(eaj_index, slp_mam, 0, 0)
  copy_VarCoords(slp_mam(0,:,:), eaj_slp_rc)
  eaj_slp_cor = escorc_n(eaj_index, slp_mam, 0, 0)
  p_slp = student_t(eaj_slp_cor*sqrt(df_ncep/(1- eaj_slp_cor^2)), df_ncep)
  copy_VarCoords(slp_mam(0,:,:), p_slp)

  eaj_z500_rc = regCoef_n(eaj_index, z500_mam, 0, 0)
  copy_VarCoords(z500_mam(0,:,:), eaj_z500_rc)
  eaj_z500_cor = escorc_n(eaj_index, z500_mam, 0, 0)
  p_z500 = student_t(eaj_z500_cor*sqrt(df_ncep/(1- eaj_z500_cor^2)), df_ncep)
  copy_VarCoords(z500_mam(0,:,:), p_z500)

  eaj_u200_rc = regCoef_n(eaj_index, u200_mam, 0, 0)
  copy_VarCoords(u200_mam(0,:,:), eaj_u200_rc)
  eaj_u200_cor = escorc_n(eaj_index, u200_mam, 0, 0)
  p_u200 = student_t(eaj_u200_cor*sqrt(df_ncep/(1- eaj_u200_cor^2)), df_ncep)
  copy_VarCoords(u200_mam(0,:,:), p_u200)

  eaj_u850_rc = regCoef_n(eaj_index, u850_mam, 0, 0)
  copy_VarCoords(u850_mam(0,:,:), eaj_u850_rc)
  eaj_u850_cor = escorc_n(eaj_index, u850_mam, 0, 0)
  p_u850 = student_t(eaj_u850_cor*sqrt(df_ncep/(1- eaj_u850_cor^2)), df_ncep)
  copy_VarCoords(u850_mam(0,:,:), p_u850)

  eaj_v850_rc = regCoef_n(eaj_index, v850_mam, 0, 0)
  copy_VarCoords(v850_mam(0,:,:), eaj_v850_rc)
  eaj_v850_cor = escorc_n(eaj_index, v850_mam, 0, 0)
  p_v850 = student_t(eaj_v850_cor*sqrt(df_ncep/(1- eaj_v850_cor^2)), df_ncep)
  copy_VarCoords(v850_mam(0,:,:), p_v850)
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

   res_snow = resrc
   res_snow@lbLabelBarOn = True

   res_htfl = resrc
   res_htfl@cnMaxLevelValF = 8.
   res_htfl@cnMinLevelValF = -8.
   res_htfl@cnLevelSpacingF = 1.

   resSST = resrc
   resSST@lbLabelBarOn = True
   resSST@mpMaxLonF = 360.
   resSST@mpMinLonF = 0.
   resSST@mpMaxLatF = 90.
   resSST@mpMinLatF = -30.
   resSST@mpCenterLonF = 180.

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
   resV@vcRefMagnitudeF = 1.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"  
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.13
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 2.0               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
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
  rts_bar@trYMaxF = 3.0
  rts_bar@gsnXYBarChartBarWidth = 0.66
  rts_bar@gsnAboveYRefLineColor = "red"
  rts_bar@gsnBelowYRefLineColor = "blue"

  rts_line = rts   ; Line
  rts_line@xyDashPattern         = 1
  rts_line@xyLineThicknessF      = 4.
  rts_line@xyLineColor = "black"

  rtsP = True
  rtsP@lbLabelAutoStride = True

  ;Draw Bar chart
  rts_bar@gsnLeftString = "EAJ Index"  
  pbar = gsn_csm_xy(wks, year, eaj_index, rts_bar)
  draw(pbar)
  frame(wks)

;**********************************************************
   res_snow@cnMaxLevelValF = 5.
   res_snow@cnMinLevelValF = -5.
   res_snow@cnLevelSpacingF = 0.5
   res_snow@gsnPolar = "NH"
   res_snow@mpMinLatF = 20.
   res_snow@lbOrientation = "Vertical"
  ;res_snow@gsnLeftString = "SCE_WEU: Reg SCE MAM"
  snowplot = gsn_csm_contour_map_polar(wks, eaj_sce_rc, res_snow)
  snowdot = gsn_csm_contour(wks, p_sce, rescor)
  overlay(snowplot, snowdot)
   
   resrc@lbOrientation = "Vertical"
   resrc@lbLabelBarOn = True   
   resrc@cnMaxLevelValF = 0.8
   resrc@cnMinLevelValF = -0.8
   resrc@cnLevelSpacingF = 0.05
   resrc@gsnPolar = "NH"
   resrc@mpMinLatF = 20.
   satplot = gsn_csm_contour_map_polar(wks, eaj_sat_rc, resrc)
   satdot = gsn_csm_contour(wks, p_sat, rescor)
   vcplot =  gsn_csm_vector(wks, eaj_u850_rc, eaj_v850_rc, resV)
   overlay(satplot, vcplot)
   overlay(satplot, satdot)

   resrc@cnMaxLevelValF = 3.0
   resrc@cnMinLevelValF = -3.0
   resrc@cnLevelSpacingF = 0.3
   slpplot = gsn_csm_contour_map_polar(wks, eaj_slp_rc, resrc)
   slpdot = gsn_csm_contour(wks, p_slp, rescor)
   slpline = gsn_csm_contour(wks, eaj_slp_rc, resrc2)
   overlay(slpplot, slpline)
   overlay(slpplot, slpdot)

   resrc@cnMaxLevelValF = 30.
   resrc@cnMinLevelValF = -30.
   resrc@cnLevelSpacingF = 5.
   z500plot = gsn_csm_contour_map_polar(wks, eaj_z500_rc, resrc)
   z500dot = gsn_csm_contour(wks, p_z500, rescor)   
   z500line = gsn_csm_contour(wks, eaj_z500_rc, resrc2)
   overlay(z500plot, z500line)
   overlay(z500plot, z500dot)

   plot_panel := new(4,graphic)
   plot_panel(0) = snowplot
   plot_panel(1) = satplot
   plot_panel(2) = slpplot
   plot_panel(3) = z500plot
   resP@gsnPanelFigureStrings = (/"SCE","SAT","SLP","Z500"/)
   gsn_panel(wks, plot_panel, (/2,2/), resP)

   resrc@cnMaxLevelValF = 3.0
   resrc@cnMinLevelValF = -3.0
   resrc@cnLevelSpacingF = 0.3
   delete(resrc@gsnPolar)
   resrc@mpMinLatF = 0.
   resrc@lbOrientation = "Horizontal"
   u200plot = gsn_csm_contour_map(wks, eaj_u200_rc, resrc)
   u200dot = gsn_csm_contour(wks, p_u200, rescor)
   u200line = gsn_csm_contour(wks, eaj_u200_rc, resrc2)
   overlay(u200plot, u200line)
   overlay(u200plot, u200dot)
   ; draw(u200plot)
   ; frame(wks)




end
