;***
  begin
;***
   ; yrstrt = 196701
   ; yrlast = 201912
   yrstrt = 198901
   yrlast = 201912
;**************************************************
   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"rws_cal")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")

   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
;**************************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))
;**************************************************
   air_mon = airdata->air(iStrt:iLast,:,:)
   u_mon = uwnddata->uwnd(iStrt:iLast,{200},:,:)
   v_mon = vwnddata->vwnd(iStrt:iLast,{200},:,:)

   sea_string = "MAM"
   u_sea = month_to_season(u_mon, sea_string)
   v_sea = month_to_season(v_mon, sea_string)
;**************************************************
;Calculate Rossby Wave Source s
;compute all the components of the RWS: absolute vorticity, divergence, 
;irrotational(divergent)velocity components,and gradients of absolute vorticity
   lat = uwnddata->lat
   lon = uwnddata->lon
   pi = atan(1.0)*4.
   f =  2.*2.*pi/(60.*60.*24.)*sin(pi/180. * lat)

   ;relative vrt + earth vrt (= absolute vrt)
   rvort = uv2vr_cfd(u_sea,v_sea,lat,lon,3)
   avort = rvort + conform_dims(dimsizes(rvort), f, 1)

   ;absolute vrt
   ; vrdvx = uv2vrdvF(u_sea,v_sea)      ; u,v ==> div and vort 
   ; vr = vrdvx(0,:,:,:)
   ; dv = vrdvx(1,:,:,:)
   ; uvd   = dv2uvF(dv)              ; dv  ==> divergent  wind components
   ; dv_u = uvd(0,:,:,:)
   ; dv_v = uvd(1,:,:,:)
   ; uvr   = vr2uvF (vr)              ; vr  ==> rotational wind components
   ; uuvv  = vrdv2uvF (vr,dv)

   div = uv2dv_cfd(u_sea,v_sea,lat,lon,3)
   dv = dv2uvF_Wrap(div)
   dv_u = dv(0,:,:,:)
   dv_v = dv(1,:,:,:)

   ; gzx = av
   ; gzy = av
   ; gradsf(av, gzx, gzy)

   ; eta = av
   ; div = div
   ; uchi = dv_u
   ; vchi = dv_v
   ; etax = gzx
   ; etay = gzy
   ; s = -eta*div - (uchi*etax + vchi*etay)

   s = -uv2dv_cfd(dv_u*avort, dv_v*avort, lat, lon, 3)
   ; copy_VarCoords(u_sea, s)
   ; printVarSummary(s)
   ; printMinMax(s, 0)

;**************************************************
   si = asciiread(indexpath+"SI_EEU_1967-2019MAM.txt", -1, "float")
   ; si = dtrend(si, 0)
   snow_index = si(22:)
;**************************************************
   si_rws_rc = regCoef_n(snow_index, s, 0, 0)
   ; copy_VarCoords(u_sea(0,:,:), si_rws_rc)
   si_rws_cor = escorc_n(snow_index, s, 0, 0)
   ; copy_VarCoords(u_sea(0,:,:), si_rws_cor)

   ab = shaeC(si_rws_rc)
   ssa = exp_tapershC(ab, 19.4, 2)
   sss = shseC(ssa, dimsizes(lon))*1e11
   copy_VarCoords(u_sea(0,:,:), sss)
   printMinMax(sss, 0)

   df_arry = si_rws_cor
   df_arry = dimsizes(snow_index) - 2
   p_rws = student_t(si_rws_cor*sqrt(df_arry/(1- si_rws_cor^2)), df_arry)

;**************************************************
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
   resrc@pmLabelBarOrthogonalPosF = 0.20
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 30
   resrc@mpMaxLonF = 210
   resrc@mpMinLatF = 10
   resrc@mpMaxLatF = 60

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
   resrc2@cnMaxLevelValF = 56
   resrc2@cnMinLevelValF = 0
   resrc2@cnLevelSpacingF = 8
   resrc2@cnInfoLabelOn = False

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

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
;**************************************************

   resrc@lbLabelBarOn = True
   resrc@cnMaxLevelValF = 12
   resrc@cnMinLevelValF = -1*resrc@cnMaxLevelValF
   resrc@cnLevelSpacingF = 0.1*resrc@cnMaxLevelValF

   rwsplot = gsn_csm_contour_map(wks, sss, resrc)
   rwsdot = gsn_csm_contour(wks, p_rws, rescor)
   rwswnd = gsn_csm_contour(wks, dim_avg_n_Wrap(u_sea, 0), resrc2)
   
   overlay(rwsplot, rwsdot)
   overlay(rwsplot, rwswnd)
   draw(rwsplot)
   frame(wks)

end