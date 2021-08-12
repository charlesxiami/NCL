  begin
  ;***************************
  yrstrt = 197201
  yrlast = 200912
  yrmdle = 198812
  ;*
  Awest = 25
  Aeast = 50
  Asouth = 50
  Anorth = 60

  Bwest = 100
  Beast = 125
  Bsouth = 60
  Bnorth = 70
  ;*
  lonL     =  0
  lonR     = 360
  latS     = -90               
  latN     =  90
  ;*****************************
  ;Read File
  ;*****************************
  cd = "/mnt/f/Data/Original/ncep/"

  filesnow = "/mnt/f/Data/Original/snowcover/snow.nc"
  snowdata = addfile(filesnow,"r")

  fileair = cd+"air.mon.mean.nc"
  airdata = addfile(fileair, "r")

  fileslp = cd+"slp.mon.mean.nc"
  slpdata = addfile(fileslp, "r")

  filehgt = cd+"hgt.mon.mean.nc"
  hgtdata = addfile(filehgt, "r")
  ;*
  YYYYMM = cd_calendar( airdata->time, 1)
  iStrt  = ind(YYYYMM.eq.yrstrt)
  iLast  = ind(YYYYMM.eq.yrlast)
  iMdle  = ind(YYYYMM.eq.yrmdle)
  ;*
   air_mon      = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   air_mam = month_to_season(air_mon, "MAM")
   
   slp_mon      = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   slp_mam = month_to_season(slp_mon, "MAM")
   
   hgt500_mon      = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 
   hgt500_mam = month_to_season(hgt500_mon, "MAM")

   hgt200_mon      = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   hgt200_mam = month_to_season(hgt200_mon, "MAM")
   
   snow_mon = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")
   snow_jfm = month_to_season(snow_mon, "JFM")
   ;*
   printVarSummary(snow_mam)
;************************************************
; Calculate A,B Index
;************************************************
    snow_mam_wgt= SqrtCosWeight(snow_mam)
    Aregion=snow_mam_wgt(:,{Asouth:Anorth},{Awest:Aeast})
    Bregion=snow_mam_wgt(:,{Bsouth:Bnorth},{Bwest:Beast})
    Aindex=wgt_areaave_Wrap(Aregion, 1.0, 1.0, 1)
    Bindex=wgt_areaave_Wrap(Bregion, 1.0, 1.0, 1)
    Ai_std = dim_standardize_n_Wrap(Aindex, 0, 0)
    Bi_std = dim_standardize_n_Wrap(Bindex, 0, 0)
    ;*
    reg_A_snow = regCoef(Ai_std,snow_mam(lat|:,lon|:,time|:))
    copy_VarCoords(snow_mam(0, :, :), reg_A_snow)
    reg_B_snow = regCoef(Bi_std,snow_mam(lat|:,lon|:,time|:))
    copy_VarCoords(snow_mam(0, :, :), reg_B_snow)
    ;*
    cor_A_snow=escorc(Ai_std,snow_mam(lat|:,lon|:,time|:))
    copy_VarCoords(snow_mam(0, :, :), cor_A_snow)
    cor_B_snow=escorc(Bi_std,snow_mam(lat|:,lon|:,time|:))
    copy_VarCoords(snow_mam(0, :, :), cor_B_snow)
    ;*
    snow_mam_clim = dim_avg_n_Wrap(snow_mam, 0)
;***********************************************
;Setting Plot and Res
;***********************************************
    plotpath = "/mnt/f/Pic/work1/NCL_pic/"
    wks = gsn_open_wks("pdf", plotpath+"index-snow")
    ;gsn_define_colormap(wks, "BlWhRe")
    ;*
    res = True
    res@cnFillPalette = "BlWhRe"
    res@gsnDraw = False
    res@gsnFrame = False
    ;res@gsnMaximize = False
    res@cnLinesOn = False
    res@cnFillOn = True
    res@mpCenterLonF = 180
    res@mpMinLatF = 0.
    res@mpMaxLatF = 90.
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels = (/-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8/)
    ;*
    plot = new (4 , "graphic")
    plot(0) = gsn_csm_contour_map(wks, cor_A_snow, res)
    plot(1) = gsn_csm_contour_map(wks, cor_B_snow, res)

    ;*
    resP = True
    resP@gsnPanelLabelBar = False
    resP@gsnMaximize = False
    resP@txString = "a,b-index Cor Snow Cover Extent"
    ;resP@gsnPanelDebug = True

    gsn_panel(wks, plot, (/4,1/), resP)
    ;***
    resclim = res
    resclim@cnFillPalette = "OceanLakeLandSnow"
    resclim@cnLinesOn = True
    resclim@cnLineLabelsOn = True
    resclim@cnLineThicknessF = 0.5
    ;resclim@vcLevelPalette = "OceanLakeLandSnow"
    ; resclim@gsnDraw = True
    ; resclim@gsnFrame = True
    resclim@cnLevels = (/0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9/)
    resclim@cnFillColors = (/253,80,72,64,56,48,40,32,24,16/)

    snowclim = new(4, "graphic")
    snowclim(0) = gsn_csm_contour_map(wks, snow_mam_clim, resclim)
    resP@txString = "Climatic SCE in two period"

    gsn_panel(wks, snowclim, (/4,1/), resP)
   ;*
   end
