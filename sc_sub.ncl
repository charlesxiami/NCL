load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
  yrstrt =197201
  yrlast =198712
  sig95 = 0.497

  ; yrstrt =198901
  ; yrlast =200912
  ; sig95 = 0.433
;---------------A,B-index Region
  AlatS = 48
  AlatN = 58
  AlonL = 25
  AlonR = 50
  
  BlatS = 60
  BlatN = 70
  BlonL = 100
  BlonR = 125

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   cd = "/mnt/f/Data/Original/ncep/"
   plotpath = "/mnt/f/Pic/work1/NCL_pic/"
;************************************************
;Calcute Snow Cover Index
;************************************************
   filesnow = "/mnt/f/Data/Original/snowcover/snow.nc"
   snowdata = addfile(filesnow,"r")

   fileair = cd+"air.mon.mean.nc"
   airdata = addfile(fileair, "r")

   fileslp = cd+"slp.mon.mean.nc"
   slpdata = addfile(fileslp, "r")

   filehgt = cd+"hgt.mon.mean.nc"
   hgtdata = addfile(filehgt, "r")

   fileuwnd = cd+"uwnd.mon.mean.nc"
   uwnddata = addfile(fileuwnd, "r")

   filevwnd = cd+"vwnd.mon.mean.nc"
   vwnddata = addfile(filevwnd, "r")
;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   year=ispan(1972, 2009, 1)
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

   snow_mon  = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")
;************************************************
; Calculate A,B Index
;************************************************
    snow_mam_wgt= SqrtCosWeight(snow_mam)
    Aregion=snow_mam_wgt(:,{AlatS:AlatN},{AlonL:AlonR})
    Bregion=snow_mam_wgt(:,{BlatS:BlatN},{BlonL:BlonR})
    Aindex = wgt_areaave_Wrap(Aregion, 1.0, 1.0, 1)
    Bindex = wgt_areaave_Wrap(Bregion, 1.0, 1.0, 1)
    Ai = dim_standardize_n_Wrap(Aindex, 0, 0)  ;Ai, Bi is the final index 
    Bi = dim_standardize_n_Wrap(Bindex, 0, 0)

;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    
    nwt= 5
    wgt5 = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
    nwt= 3
    wgt3 = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    Ai_hf = wgt_runave_Wrap(Ai, wgt5, 0)
    Bi_hf = wgt_runave_Wrap(Bi, wgt5, 0)

    Ai_hf3 = wgt_runave_Wrap(Ai, wgt3, 0)
    Bi_hf3 = wgt_runave_Wrap(Bi, wgt3, 0)

    Ai_hf(1) = Ai_hf3(1)
    Ai_hf(dimsizes(year)-2) = Ai_hf3(dimsizes(year)-2)

    Bi_hf(1) = Bi_hf3(1)
    Bi_hf(dimsizes(year)-2) = Bi_hf3(dimsizes(year)-2)

; Reserve AI and BI 
    Ai_hf = -1*Ai_hf
    Bi_hf = -1*Bi_hf
    ; asciiwrite(plotpath+"Ai.txt", Ai)
    ; asciiwrite(plotpath+"Bi.txt", Bi)
    printVarSummary(Ai_hf)
;******************************************
;Regression
;******************************************
   Ai_sat_rc  = regCoef(Ai_hf(0:15),air_mam(lat|:,lon|:,time|:)) 
   Ai_slp_rc  = regCoef(Ai_hf(0:15),slp_mam(lat|:,lon|:,time|:)) 
   Ai_z500_rc = regCoef(Ai_hf(0:15),z500_mam(lat|:,lon|:,time|:))
   Ai_z200_rc = regCoef(Ai_hf(0:15),z200_mam(lat|:,lon|:,time|:)) 
   Ai_u_rc    = regCoef(Ai_hf(0:15),u_mam(lat|:,lon|:,time|:))
   Ai_v_rc    = regCoef(Ai_hf(0:15),v_mam(lat|:,lon|:,time|:))

   Ai_sat_cor  = escorc(Ai_hf(0:15),air_mam(lat|:,lon|:,time|:)) 
   Ai_slp_cor  = escorc(Ai_hf(0:15),slp_mam(lat|:,lon|:,time|:)) 
   Ai_z500_cor = escorc(Ai_hf(0:15),z500_mam(lat|:,lon|:,time|:)) 
   Ai_z200_cor = escorc(Ai_hf(0:15),z200_mam(lat|:,lon|:,time|:)) 
   Ai_u_cor    = escorc(Ai_hf(0:15),u_mam(lat|:,lon|:,time|:))
   Ai_v_cor    = escorc(Ai_hf(0:15),v_mam(lat|:,lon|:,time|:))
   Ai_uv_cor   = escorc(Ai_hf(0:15),uv_mam(lat|:,lon|:,time|:))

   Bi_sat_rc  = regCoef(Bi_hf(0:15),air_mam(lat|:,lon|:,time|:)) 
   Bi_slp_rc  = regCoef(Bi_hf(0:15),slp_mam(lat|:,lon|:,time|:)) 
   Bi_z500_rc = regCoef(Bi_hf(0:15),z500_mam(lat|:,lon|:,time|:)) 
   Bi_z200_rc = regCoef(Bi_hf(0:15),z200_mam(lat|:,lon|:,time|:))
   Bi_u_rc    = regCoef(Bi_hf(0:15),u_mam(lat|:,lon|:,time|:))
   Bi_v_rc    = regCoef(Bi_hf(0:15),v_mam(lat|:,lon|:,time|:))

   Bi_sat_cor  = escorc(Bi_hf(0:15),air_mam(lat|:,lon|:,time|:)) 
   Bi_slp_cor  = escorc(Bi_hf(0:15),slp_mam(lat|:,lon|:,time|:)) 
   Bi_z500_cor = escorc(Bi_hf(0:15),z500_mam(lat|:,lon|:,time|:)) 
   Bi_z200_cor = escorc(Bi_hf(0:15),z200_mam(lat|:,lon|:,time|:)) 
   Bi_u_cor    = escorc(Bi_hf(0:15),u_mam(lat|:,lon|:,time|:))
   Bi_v_cor    = escorc(Bi_hf(0:15),v_mam(lat|:,lon|:,time|:))
   Bi_uv_cor   = escorc(Bi_hf(0:15),uv_mam(lat|:,lon|:,time|:))
  ;*******************************************
   copy_VarCoords(air_mam(0, :, :), Ai_sat_rc)
   copy_VarCoords(air_mam(0, :, :), Ai_slp_rc)
   copy_VarCoords(air_mam(0, :, :), Ai_z500_rc)
   copy_VarCoords(air_mam(0, :, :), Ai_z200_rc)
   copy_VarCoords(air_mam(0, :, :), Ai_u_rc)
   copy_VarCoords(air_mam(0, :, :), Ai_v_rc)
   copy_VarCoords(air_mam(0, :, :), Bi_sat_rc)
   copy_VarCoords(air_mam(0, :, :), Bi_slp_rc)
   copy_VarCoords(air_mam(0, :, :), Bi_z500_rc)
   copy_VarCoords(air_mam(0, :, :), Bi_z200_rc)
   copy_VarCoords(air_mam(0, :, :), Bi_u_rc)
   copy_VarCoords(air_mam(0, :, :), Bi_v_rc) 

   copy_VarCoords(air_mam(0, :, :), Ai_sat_cor)
   copy_VarCoords(air_mam(0, :, :), Ai_slp_cor)
   copy_VarCoords(air_mam(0, :, :), Ai_z500_cor)
   copy_VarCoords(air_mam(0, :, :), Ai_z200_cor)
   copy_VarCoords(air_mam(0, :, :), Ai_uv_cor)
   copy_VarCoords(air_mam(0, :, :), Bi_sat_cor)
   copy_VarCoords(air_mam(0, :, :), Bi_slp_cor)
   copy_VarCoords(air_mam(0, :, :), Bi_z500_cor)
   copy_VarCoords(air_mam(0, :, :), Bi_z200_cor)
   copy_VarCoords(air_mam(0, :, :), Bi_uv_cor) 

   ;printVarSummary(Ai_u_rc)
;***********************************************
;Setting Plot
;***********************************************
   output = plotpath
   wks=gsn_open_wks("pdf", output+"sc_sub")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;********************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

 ;For SAT
   resrc = True    
   resrc@gsnDraw = False
   resrc@gsnFrame = False
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = True
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMinLevelValF = -2.
   resrc@cnMaxLevelValF = 2.
   resrc@cnLevelSpacingF = 0.2
   ; resrc@mpGridAndLimbOn = True
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpCenterLonF = 180.
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 360.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.

   resrc@mpDataSetName         = "Earth..4"   ; This new database contains
   resrc@mpDataBaseVersion     = "LowRes"  ; Medium resolution database
   ;resrc@mpOutlineBoundarySets = "National"
   resrc@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)


 ;For SLP
   resrc2 = True     
   resrc2 = res
   resrc2@cnFillOn = False
   resrc2@cnLinesOn = True
   resrc2@cnInfoLabelOn = False
   resrc2@gsnContourNegLineDashPattern = 5
   resrc2@cnLineThicknessF = 2.8
   resrc2@cnLineColor = "red"
   resrc2@gsnContourZeroLineThicknessF = 0.
   resrc2@cnLineLabelsOn = True
   resrc2@cnLineLabelPerimOn = False
   resrc2@cnLineLabelBackgroundColor = 2
   resrc2@cnLineLabelPlacementMode = "Constant"
   resrc2@cnLineLabelInterval = 2
   resrc2@cnLineLabelFontHeightF = 0.007
   ;resrc2@cnLineLabelFontColor = 0
   resrc2@cnLineLabelFontThicknessF = 1.5

;Correlation res (with dots.)
   rescor = True
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/-sig95,sig95/)
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False


  ;Wind Resources
   resV = True
   resV@gsnDraw = False
   resV@gsnFrame = False
   resV@vcRefMagnitudeF = 1.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"
   resV@vcRefAnnoArrowUseVecColor = False
   ;resV@vcRefAnnoOrthogonalPosF = -5.0
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.0               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   ; lnres = True
   ; lnres@gsLineColor      = "gray12"
   ; lnres@gsLineThicknessF = 1.0
   ; dir = "/mnt/f/Programming/NCL/shp/"
   ; filename1 = "CHN_adm_shp/CHN_adm0.shp"
   ; filename2 = "HKG_adm_shp/HKG_adm0.shp"
   ; filename3 = "TWN_adm_shp/TWN_adm0.shp"
;**********************************************************
;AI draw
    resrc@gsnLeftString = "Ai:P1"+"-sat-slp-wind:MAM"
    resrc@cnInfoLabelString = "Dotted Area exceed 95% Sig Level"
    Airc = gsn_csm_contour_map(wks, Ai_sat_rc ,resrc)
    Aslp = gsn_csm_contour(wks, Ai_slp_rc, resrc2)
    Aslp = ColorNegDashZeroPosContour(Aslp,"blue","transparent","red")
    Awnd = gsn_csm_vector(wks, Ai_u_rc, Ai_v_rc, resV)
    Adot = gsn_csm_contour(wks, Ai_sat_cor, rescor)

    overlay(Airc, Awnd)
    overlay(Airc, Adot)
    overlay(Airc, Aslp)

    draw(Airc)
    frame(wks)
    ;

;BI draw
   resrc@gsnLeftString = "Bi:P1"+"-sat-slp-wind:MAM"
   Birc = gsn_csm_contour_map(wks, Bi_sat_rc ,resrc) ;Regression Map as based map
   Bslp = gsn_csm_contour(wks, Bi_slp_rc, resrc2)    ; SLP overlay
   Bslp = ColorNegDashZeroPosContour(Bslp,"blue","transparent","red")
   Bwnd = gsn_csm_vector(wks, Bi_u_rc, Bi_v_rc, resV) ; Wind overlay
   Bdot = gsn_csm_contour(wks, Bi_sat_cor, rescor) ; Correlation overlay
   
   overlay(Birc, Bwnd)
   overlay(Birc, Bdot)
   overlay(Birc, Bslp)
   ; poly1 = gsn_add_shapefile_polylines(wks,Birc,dir+filename1,lnres)
   ; poly2 = gsn_add_shapefile_polylines(wks,Birc,dir+filename2,lnres)
   ; poly3 = gsn_add_shapefile_polylines(wks,Birc,dir+filename3,lnres)
   draw(Birc)
   frame(wks)

  ; SLP-Wind
   resrc@cnMinLevelValF = -3.
   resrc@cnMaxLevelValF = 3.
   resrc@cnLevelSpacingF = 0.5
   resrc@gsnLeftString = "Ai:P1"+"-slp-wind:MAM"
   resrc@cnInfoLabelString = "Dotted Area exceed 95% Sig Level"
   Aslprc = gsn_csm_contour_map(wks, Ai_slp_rc ,resrc)
   Aslpcor = gsn_csm_contour(wks, Ai_slp_cor, rescor)
   Awnd = gsn_csm_vector(wks, Ai_u_rc, Ai_v_rc, resV)
   overlay(Aslprc, Awnd)
   overlay(Aslprc, Aslpcor)
   draw(Aslprc)
   frame(wks)

   resrc@gsnLeftString = "Bi:P1"+"-slp-wind:MAM"
   resrc@cnInfoLabelString = "Dotted Area exceed 95% Sig Level"
   Bslprc = gsn_csm_contour_map(wks, Bi_slp_rc ,resrc)
   Bslpcor = gsn_csm_contour(wks, Bi_slp_cor, rescor)
   Bwnd = gsn_csm_vector(wks, Bi_u_rc, Bi_v_rc, resV)
   overlay(Bslprc, Bwnd)
   overlay(Bslprc, Bslpcor)
   draw(Bslprc)
   frame(wks)
;**********************************************************
;Polar Draw
    respolar = True
    respolar = res
    respolar@cnFillPalette = "ViBlGrWhYeOrRe"
    respolar@cnFillOn = True
    respolar@cnLinesOn = True
    respolar@cnLineLabelsOn = False
    respolar@gsnContourNegLineDashPattern = 5
    respolar@gsnContourZeroLineThicknessF = 0.
    respolar@cnInfoLabelString = "Dotted Area exceed 95% Sig Level"
    respolar@gsnPolar = "NH"
    respolar@mpMinLatF = 20.
    respolar@mpCenterLonF = 90.
    respolar@cnLevelSelectionMode = "ManualLevels"
    respolar@cnMinLevelValF = -40.
    respolar@cnMaxLevelValF = 40.
    respolar@cnLevelSpacingF = 5.
    respolar@lbOrientation = "Vertical"

;Z500 
  ;Ai   
     rescor@cnLevels = (/-sig95,sig95/)  
     respolar@gsnLeftString = "Ai"+"-Z500"
     zrc = gsn_csm_contour_map_polar(wks, Ai_z500_rc, respolar)
     zcor = gsn_csm_contour(wks, Ai_z500_cor, rescor) 

     ; opt = True
     ; opt@gsnShadeFillType = "pattern"
     ; opt@gsnShadeHigh = 17
     ; opt@gsnShadeLow = 17
     ; zcor = gsn_contour_shade(zcor, -0.320, 0.320, opt) ; 95%:0.320 , 90%:0.271

     overlay(zrc, zcor)
     draw(zrc)
     frame(wks)
  ;Bi
     respolar@gsnLeftString = "Bi"+"-Z500"
     zrc = gsn_csm_contour_map_polar(wks, Bi_z500_rc, respolar)
     zcor = gsn_csm_contour(wks, Bi_z500_cor, rescor) 

     ; opt = True
     ; opt@gsnShadeFillType = "pattern"
     ; opt@gsnShadeHigh = 17
     ; opt@gsnShadeLow = 17
     ; zcor = gsn_contour_shade(zcor, -0.320, 0.320, opt) ; 95%:0.320 , 90%:0.271

     overlay(zrc, zcor)
     draw(zrc)
     frame(wks)

;Z200
     respolar@gsnLeftString = "Ai"+"-Z200"
     zrc = gsn_csm_contour_map_polar(wks, Ai_z200_rc, respolar)
     zcor = gsn_csm_contour(wks, Ai_z200_cor, rescor) 

     ; opt = True
     ; opt@gsnShadeFillType = "pattern"
     ; opt@gsnShadeHigh = 17
     ; opt@gsnShadeLow = 17
     ; zcor = gsn_contour_shade(zcor, -0.320, 0.320, opt) ; 95%:0.320 , 90%:0.271

     overlay(zrc, zcor)
     draw(zrc)
     frame(wks)

     respolar@gsnLeftString = "Bi"+"-Z200"
     zrc = gsn_csm_contour_map_polar(wks, Bi_z200_rc, respolar)
     zcor = gsn_csm_contour(wks, Bi_z200_cor, rescor) 

     ; opt = True
     ; opt@gsnShadeFillType = "pattern"
     ; opt@gsnShadeHigh = 17
     ; opt@gsnShadeLow = 17
     ; zcor = gsn_contour_shade(zcor, -0.320, 0.320, opt) ; 95%:0.320 , 90%:0.271

     overlay(zrc, zcor)
     draw(zrc)
     frame(wks)

end
