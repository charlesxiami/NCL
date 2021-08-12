load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   ; yrstrt = 196701   ;P1
   ; yrlast = 201912

   yrstrt = 198901  ;P2
   yrlast = 201912

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

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

  rwsS     = 30
  rwsN     = 40
  rwsL     = 135
  rwsR     = 150

   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"sci_rws")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")
   sstdata = addfile(nceppath+"sst.mnmean.v5.nc", "r")

   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")

   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
   ; soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")

   ;ao 195001-201912
   ao_table = asciiread(indexpath+"monthly.ao.index.b50.current.ascii.txt", -1, "string")
   ao_index_origin = stringtofloat(str_get_field(ao_table, 3, " "))
   ao_mon_all = ao_index_origin(0:839)
   month_time2 = yyyymm_time(1950, 2019, "integer")
   month_time2!0 = "time"
   month_time2@long_name = "time"
   month_time2@units = "month"

   ao_mon_all!0 = "time"
   ao_mon_all&time = month_time2
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

   iStrt_ao  = ind(ao_mon_all&time.eq.yrstrt)
   iLast_ao  = ind(ao_mon_all&time.eq.yrlast)
   print("ao  time: "+ao_mon_all&time(iStrt_ao)+"--"+ao_mon_all&time(iLast_ao))
 ;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})

   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   
   u850_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR})
   v850_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 

   u200_mon = uwnddata->uwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})
   v200_mon = vwnddata->vwnd(iStrt:iLast,{200},{latS:latN},{lonL:lonR})

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   
   ao_mon = ao_mon_all(iStrt_ao:iLast_ao)
   ao_mam = month_to_season(ao_mon, "MAM")
;*************************************************
;Filter 
;*************************************************
   ; ;High-Frequency Pass
   ; ihp = 1
   ; fca = 1.0/120.
   ; fcb= -999
   ; nsigma = 1.
   ; nwt= 21
   ; wgt_hf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

   ; snow_mon_hf = wgt_runave_n_Wrap(snow_mon, wgt_hf, 0, 0)
   ; air_mon_hf  = wgt_runave_n_Wrap(air_mon, wgt_hf, 0, 0)
   ; slp_mon_hf  = wgt_runave_n_Wrap(slp_mon, wgt_hf, 0, 0)
   ; z500_mon_hf = wgt_runave_n_Wrap(z500_mon, wgt_hf, 0, 0)
   ; z200_mon_hf = wgt_runave_n_Wrap(z200_mon, wgt_hf, 0, 0)
   ; sst_mon_hf  = wgt_runave_n_Wrap(sst_mon, wgt_hf, 0, 0)

   ; ;Low frequency
   ; ihp = 0
   ; wgt_lf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
   ; snow_mon_lf = wgt_runave_n_Wrap(snow_mon, wgt_lf, 0, 0)
   ; air_mon_lf  = wgt_runave_n_Wrap(air_mon, wgt_lf, 0, 0)
   ; slp_mon_lf  = wgt_runave_n_Wrap(slp_mon, wgt_lf, 0, 0)
   ; z500_mon_lf = wgt_runave_n_Wrap(z500_mon, wgt_lf, 0, 0)
   ; z200_mon_lf = wgt_runave_n_Wrap(z200_mon, wgt_lf, 0, 0)
   ; sst_mon_lf  = wgt_runave_n_Wrap(sst_mon, wgt_lf, 0, 0)

;************************************************
;Seasonal Mean
   season = "MAM"
   ; snow_mam = month_to_season(snow_mon_hf, "MAM")
   snow_mam  = month_to_season(snow_mon, season)
   air_mam    = month_to_season(air_mon, season)
   slp_mam    = month_to_season(slp_mon, season)
   z500_mam  = month_to_season(z500_mon, season)
   z200_mam  = month_to_season(z200_mon, season)
   sst_mam    = month_to_season(sst_mon, season)
   u850_mam  = month_to_season(u850_mon, season)
   v850_mam  = month_to_season(v850_mon, season)
   u200_mam  = month_to_season(u200_mon, season)
   v200_mam  = month_to_season(v200_mon, season)

;************************************************
; Calculate Index
;************************************************
  WEU = snow_mam(:,{SCI_WEU_S:SCI_WEU_N},{SCI_WEU_L:SCI_WEU_R})
  EEU = snow_mam(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
  sci_weu = dim_standardize_Wrap(wgt_areaave_Wrap(WEU, 1.0, 1.0, 1),0)
  sci_eeu = dim_standardize_Wrap(wgt_areaave_Wrap(EEU, 1.0, 1.0, 1),0)

  sci_eeu = dtrend(sci_eeu, False)

  sci_eeu_res = sci_eeu - ao_mam*regline(ao_mam, sci_eeu)

   si = asciiread(indexpath+"SI_EEU_1967-2019MAM.txt", -1, "float")
  ;Define index
   snow_index = sci_eeu
   ; snow_index = si(:21)
   ; snow_index = si(22:)
   ; print(snow_index)
;**********************************************************
;Rossby wave source
lat = uwnddata->lat
lon = uwnddata->lon

pi = atan(1.0)*4.
f =  2.*2.*pi/(60.*60.*24.)*sin(pi/180. * lat)

rv = uv2vr_cfd(u200_mam,v200_mam,lat,lon,3)
av = rv + conform_dims(dimsizes(rv), f, 1)

av_anom = regCoef_n(snow_index, av, 0, 0)
av_mean = dim_avg_n_Wrap(av, 0)

div = uv2dv_cfd(u200_mam,v200_mam,lat,lon,3)

dv = dv2uvF_Wrap(div)
dv_u = dv(0,:,:,:)
dv_v = dv(1,:,:,:)

dv_u_anom = regCoef_n(snow_index, dv_u, 0, 0)
dv_v_anom = regCoef_n(snow_index, dv_v, 0, 0)

dv_u_mean = dim_avg_n_Wrap(dv_u, 0)
dv_v_mean = dim_avg_n_Wrap(dv_v, 0)

s = -uv2dv_cfd(dv_u_anom*av_mean,dv_v_anom*av_mean,lat,lon,3)-uv2dv_cfd(dv_u_mean*av_anom,dv_v_mean*av_anom,lat,lon,3)

ss = -uv2dv_cfd(dv_u*av, dv_v*av, lat, lon, 3)
copy_VarMeta(u200_mam(:,:,:), ss)

sssy = regCoef_n(snow_index, ss, 0, 0)

;sss = sssy * 1e11

rws_ind = wgt_areaave_Wrap(ss(:,{rwsS:rwsN},{rwsL:rwsR}), 1., 1., 0)
rws_ind = dim_standardize_Wrap(rws_ind, 1)
print("Cor<RWSI, SI>= "+ escorc(rws_ind, snow_index))

tval_air = reshape(abs(sssy@tval),(/dimsizes(sssy(:,0)),dimsizes(sssy(0,:))/))
tval_air(0,:) = 0

ab = shaeC(s)
ssa = exp_tapershC(ab, 19.4, 2)
sss = shseC(ssa, dimsizes(lon))*1e11

; copy_VarCoords(u200_mam(0,:,:), sss)
; copy_VarCoords(u200_mam(0,:,:), tval_air)

copy_VarMeta(u200_mam(0,:,:), sss)
copy_VarMeta(u200_mam(0,:,:), tval_air)

   ndim_u = dimsizes(u200_mam)
   df_air = ndim_u(0) - 2
   print("Df =  " + df_air)
   p_air = student_t(tval_air, df_air)
   copy_VarCoords(u200_mam(0,:,:), p_air)
  
  ; ;Calculate RWS itself
  ;  abb = shaeC(ss)
  ;  ssaa = exp_tapershC(abb, 19.4, 2)
  ;  rws = shseC(ssaa,dimsizes(lon))*1e11
  ;  printVarSummary(rws)

   ; rws_index = wgt_areaave_Wrap(q, wgty, wgtx, opt)

; printVarSummary(sss)
; printVarSummary(tval_air)
;**********************************************************
;3-D Data analysis
;**********************************************************
 ;Reg and Cor


  ; ;snow data
  ; sci_sce_rc = regCoef_n(snow_index, snow_mam, 0, 0)
  ; copy_VarCoords(snow_mam(0,:,:), sci_sce_rc)
  ; sci_sce_cor = escorc_n(snow_index, snow_mam, 0, 0)  
  ; ndim_snow = dimsizes(snow_mam)
  ; df_snow = sci_sce_cor
  ; df_snow = ndim_snow(0) - 2
  ; t_sce = sci_sce_cor*sqrt(df_snow/(1- sci_sce_cor^2 ))
  ; p_sce = student_t(t_sce, df_snow)
  ; copy_VarCoords(snow_mam(0,:,:), p_sce)

  ; ;ncep data 
  ; ndim_ncep = dimsizes(air_mam)
  ; sci_sat_rc = regCoef_n(snow_index, air_mam, 0, 0)
  ; copy_VarCoords(air_mam(0,:,:), sci_sat_rc)
  ; sci_sat_cor = escorc_n(snow_index, air_mam, 0, 0)

  ; df_ncep = sci_sat_cor
  ; df_ncep = ndim_ncep(0) - 2
  ; t_sat = sci_sat_cor*sqrt(df_ncep/(1- sci_sat_cor^2))
  ; p_sat = student_t(t_sat, df_ncep)
  ; copy_VarCoords(air_mam(0,:,:), p_sat)

  ; sci_slp_rc = regCoef_n(snow_index, slp_mam, 0, 0)
  ; copy_VarCoords(slp_mam(0,:,:), sci_slp_rc)
  ; sci_slp_cor = escorc_n(snow_index, slp_mam, 0, 0)
  ; p_slp = student_t(sci_slp_cor*sqrt(df_ncep/(1- sci_slp_cor^2)), df_ncep)
  ; copy_VarCoords(slp_mam(0,:,:), p_slp)

  
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
   resrc@pmLabelBarOrthogonalPosF = 0.20
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 30.
   resrc@mpMaxLonF = 210.
   resrc@mpMaxLatF = 60.
   resrc@mpMinLatF = 10.
   resrc@gsnSpreadColors=True

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
   resrc2@lbLabelBarOn = False
   resrc2@gsnContourNegLineDashPattern = 5
   resrc2@gsnContourZeroLineThicknessF = 0.
   resrc2@cnLineThicknessF = 1.0
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
   resrc2@gsnLeftString = " "
   resrc2@gsnRightString = " "

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
   resV@vcLineArrowThicknessF   = 1.8               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"

;****************************************************************
;Draw plot
   resrc@lbLabelBarOn = True
   resrc@cnMaxLevelValF = 12.
   resrc@cnMinLevelValF = -1*resrc@cnMaxLevelValF
   resrc@cnLevelSpacingF = 1.
   ; resrc@gsnLeftString = "a) Rossby wave source  P1"
   resrc@gsnLeftString = "b) Rossby wave source  P2"
   rwsplot = gsn_csm_contour_map(wks, sss, resrc)

   ; rescor@cnLevels = 2.07
   ; rescor@cnLevels = 2.06
   ; rescor@cnFillPatterns = (/-1,17/)
   rwsdot = gsn_csm_contour(wks, p_air, rescor)

   resrc2@cnMaxLevelValF = 56
   resrc2@cnMinLevelValF = 0
   resrc2@cnLevelSpacingF = 8
   resrc2@cnInfoLabelOn = False
   rwswnd = gsn_csm_contour(wks, dim_avg_n_Wrap(u200_mam, 0), resrc2)

   overlay(rwsplot, rwsdot)
   overlay(rwsplot, rwswnd)
   draw(rwsplot)
   frame(wks)



end
