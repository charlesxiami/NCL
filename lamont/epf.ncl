load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   yrstrt = 197201   ;P1+P2
   yrlast = 201912

   ; yrstrt = 197201   ;P1
   ; yrlast = 199412

   ; yrstrt = 199501  ;P2
   ; yrlast = 201912

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

   year=ispan(yrstrt_snow/100, yrlast_snow/100, 1)

   season_string = "SON"
   print("season:  " + season_string)
;**************************************************
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
   ncep2path = "$HOME/data/ncep2/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"
   hadleypath = "$HOME/data/hadley/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", "epf")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")

   airdata = addfile(nceppath+"air.mon.mean.level.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
 ;**************************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))
 ;***************************************************
   air_mon = airdata->air(iStrt:iLast,:,:,:)
   air_mon = air_mon + 273.15
   u_mon = uwnddata->uwnd(iStrt:iLast,:,:,:)
   v_mon = vwnddata->vwnd(iStrt:iLast,:,:,:)

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
;************************************************
;Seasonal Mean
   sc_season  = month_to_season(snow_mon, season_string)
   air_season = month_to_season(air_mon, season_string)
   u_season = month_to_season(u_mon, season_string)
   v_season = month_to_season(v_mon, season_string)
 ;*****************************************************************
   pc = asciiread(indexpath+"snow_pc1dt_1972-2019SON.txt", -1, "float")
   ; si = asciiread(indexpath+"SI_EEU_1967-2019MAM.txt", -1, "float")
;**********************************************************
;Data analysis
;**********************************************************
  ;Define index
  ; snow_index = si(0:21)
  ; snow_index = si(22:)
   snow_index = pc

  ; ;snow data
  sci_sce_rc = regCoef_n(snow_index, sc_season, 0, 0)
  copy_VarCoords(sc_season(0,:,:), sci_sce_rc)
  sci_sce_cor = escorc_n(snow_index, sc_season, 0, 0)  
  ndim_snow = dimsizes(sc_season)
  df_snow = sci_sce_cor
  df_snow = ndim_snow(0) - 2
  t_sce = sci_sce_cor*sqrt(df_snow/(1- sci_sce_cor^2 ))
  p_sce = student_t(t_sce, df_snow)
  copy_VarCoords(sc_season(0,:,:), p_sce)

  sc_air_rc = regCoef_n(snow_index, air_season, 0, 0)
  copy_VarCoords(air_mon(0,:,:,:), sc_air_rc)

  sc_u_rc = regCoef_n(snow_index, u_season, 0, 0)
  copy_VarCoords(u_mon(0,:,:,:), sc_u_rc)

  sc_v_rc = regCoef_n(snow_index, v_season, 0, 0)
  copy_VarCoords(v_mon(0,:,:,:), sc_v_rc)

   T = conform(air_mon(:0,:,:,:), sc_air_rc,(/1,2,3/))
   U = conform(u_mon(:0,:,:,:), sc_u_rc, (/1,2,3/))
   V = conform(v_mon(:0,:,:,:), sc_v_rc, (/1,2,3/))

   copy_VarCoords(air_mon(:0,:,:,:), T)
   copy_VarCoords(u_mon(:0,:,:,:), U)
   copy_VarCoords(v_mon(:0,:,:,:), V)

   ; printVarSummary(T)
   ; printVarSummary(U)
   ; printVarSummary(V)
;**********************************************************
   plvl = u_season&level
   lat = u_season&lat

   opt = False
   opt@magf = 5.0

   ; eepf = epflux(u_mon, v_mon, air_mon, plvl, lat, opt)

   ; sc_epf   = epflux(sc_u_rc, sc_v_rc, sc_air_rc, plvl, lat, opt)
   ; sc_epf   = epflux(U, V, T, plvl, lat, opt)
   sc_epf   = epflux(u_season, v_season, air_season, plvl, lat, opt)

   sc_Fphi  = sc_epf[0]
   sc_Fp    = sc_epf[1]
   sc_EPdiv = sc_epf[2]
   sc_dudt  = sc_epf[3]

   ; printVarSummary(sc_Fphi)
   ; printVarSummary(sc_Fp)

   delete("sc_epf")
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
   resrc@pmLabelBarWidthF = 0.5
   resrc@pmLabelBarHeightF = 0.06
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@mpGridAndLimbOn = False
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpOutlineOn = True
   ; resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
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

   res_snow = resrc
   res_snow@lbLabelBarOn = True
   res_snow@lbBoxLinesOn = False
   res_snow@lbOrientation = "Vertical"
   res_snow@cnLevelSelectionMode = "ManualLevels"
   res_snow@cnMaxLevelValF = 10.
   res_snow@cnMinLevelValF = -1*res_snow@cnMaxLevelValF
   res_snow@cnLevelSpacingF = 1.

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
   rescor@cnFillScaleF = 1.0
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillOpacityF = 1.0
   rescor@cnFillDrawOrder = "PreDraw"

    res_vec = res
    res_vec@vfXArray              = lat               ; use lat for x axis
    res_vec@vfYArray              = plvl              ; use pressure for y axis
    res_vec@trYReverse            = True              ; reverse y-axis
    res_vec@gsnYAxisIrregular2Log = True              ; set y-axis to log scale
    res_vec@tiXAxisString         = "latitude"        ; x-axis label
    res_vec@tiYAxisString         = "pressure (mb)"   ; y-axis label
    res_vec@tiXAxisFontHeightF    = 0.0175
    res_vec@tiYAxisFontHeightF    = 0.0175
    res_vec@vcRefMagnitudeF       = 10               ; add a reference vector
    res_vec@vcRefLengthF          = 0.05              ; what the ref length is
    res_vec@vcMonoLineArrowColor  = False             ; vec's colored by their mag
    res_vec@vcLevelPalette        = "rainbow"         
    res_vec@vcLevelSelectionMode  = "ManualLevels"
    ; res_vec@vcLevelSpacingF       = 25.0
    ; res_vec@vcMinLevelValF        = 0.0
    ; res_vec@vcMaxLevelValF        = 400.0
    res_vec@vcRefAnnoOn           = False              ; turn off ref wind barb
    res_vec@vcMinDistanceF        = 0.00875            ; trial and error
    res_vec@pmLabelBarDisplayMode = "Always"          ; Turn on a label bar.
    res_vec@pmLabelBarWidthF      = 0.08              ; make it thinner
    res_vec@lbPerimOn             = False             ; no box around it
    ; res_vec@tiMainString          = vectitle          ; plot title
    res_vec@tiMainFontHeightF     = 0.0185
    res_vec@tmXBLabelFontHeightF  = 0.0125
    res_vec@tmYLLabelFontHeightF  = 0.0125
    res_vec@tmXBMajorLengthF      = -0.0075           ; minus mean outward face
    res_vec@tmYLMajorLengthF      = -0.0075           ; minus mean outward face
    res_vec@tmYLMode              = "Explicit"        ; Pressure (YL) axis
    res_vec@tmYLValues            = plvl            
    res_vec@tmYLLabels            = tostring(toint(plvl)) 
    res_vec@tmYLLabels(1)         = ""                ; no 925 label
    res_vec@tmYLLabels(2)         = ""                ;    850
    res_vec@tmYLLabels(4)         = ""                ;    600
    res_vec@tmYLLabels(8)         = ""                ;    250 
    res_vec@vpWidthF              = 0.60              ; shape
    res_vec@vpHeightF             = 0.35

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.015
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsBackgroundFillColor = "black"
   resP@gsnPanelFigureStringsFontColor = "white"
;**********************************************************
;Draw contour

   ; res_snow@cnLevels = ispan(-10, 10, 2)
   ; res_snow@cnFillColors = (/35,55,65,75,85,105,137,160,165,173,182,190/)
   res_snow@mpMinLonF = 0
   res_snow@mpMaxLonF = 180
   res_snow@mpMaxLatF = 80
   res_snow@mpMinLatF = 20
   snowplot = gsn_csm_contour_map(wks, sci_sce_rc, res_snow)
   snowdot = gsn_csm_contour(wks, p_sce, rescor)
   overlay(snowplot, snowdot)
   draw(snowplot)
   frame(wks)
  
   ; rescor2@gsnLeftString = "a) UV@850 P1"
   ; rescor2@gsnLeftString = "b) UV@850 P2"
   ; resV@vcRefAnnoOrthogonalPosF = -0.2
   ; sigplot = gsn_csm_contour_map(wks, p_uv850, rescor2)
   ; vcplot  = gsn_csm_vector(wks, sci_u850_rc, sci_v850_rc, resV)
   ; overlay(sigplot, vcplot)
   ; draw(sigplot)
   ; frame(wks)

   ; sc_Fphi = sc_Fphi*10e2
   ; sc_Fp = sc_Fp*10e-3

   printMinMax(sc_Fphi, False)
   printMinMax(sc_Fp, False)

   plot = gsn_vector(wks, sc_Fphi, sc_Fp, res_vec)
   draw(plot)
   frame(wks)




end
