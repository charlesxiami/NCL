load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;***
  yrstrt =197201
  yrlast =200912
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
  ;************************************************
   cd = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"

   snowdata = addfile("/public/home/charlesxiami/data/snow/snow.nc","r")
   airdata = addfile(cd+"air.mon.mean.nc", "r")
   slpdata = addfile(cd+"slp.mon.mean.nc", "r")
   hgtdata = addfile(cd+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(cd+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(cd+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(cd+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(cd+"nlwrs.sfc.mon.mean.nc", "r")
   sstdata = addfile(cd+"sst.mnmean.v4.nc", "r")

;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)
;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   air_mam = month_to_season(air_mon, "MAM")
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   slp_mam = month_to_season(slp_mon, "MAM")
   
   ; z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 
   ; z500_mam = month_to_season(z500_mon, "MAM")
   ; z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   ; z200_mam = month_to_season(z200_mon, "MAM")
   
   u_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   u_mam = month_to_season(u_mon, "MAM")
   v_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   v_mam = month_to_season(v_mon, "MAM")

   snow_mon = snowdata->Snow(:,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   nswr_mon = nswrdata->nswrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nswr_mam = month_to_season(nswr_mon, "MAM")

   nlwr_mon = nlwrdata->nlwrs(iStrt:iLast,{latS:latN},{lonL:lonR})
   nlwr_mam = month_to_season(nlwr_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   sst_djf = month_to_season(sst_mon, "DJF")
   sst_mam = month_to_season(sst_mon, "MAM")
;************************************************
; Calculate A,B Index
;************************************************
   snow_mam_wgt= SqrtCosWeight(snow_mam)
   Aregion=snow_mam_wgt(:,{AlatS:AlatN},{AlonL:AlonR})
   Bregion=snow_mam_wgt(:,{BlatS:BlatN},{BlonL:BlonR})
   Aindex = wgt_areaave_Wrap(Aregion, 1.0, 1.0, 1)
   Bindex = wgt_areaave_Wrap(Bregion, 1.0, 1.0, 1)
   Ai = dim_standardize_n_Wrap(Aindex, 0, 0)
   Bi = dim_standardize_n_Wrap(Bindex, 0, 0)

   ihp = 1
   fca = 1.0/10.0
   fcb= -999
   nsigma = 1.
   nwt= 9
   wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

   Ai_hf = -1*wgt_runave_Wrap(Ai, wgt, 0)
   Bi_hf = -1*wgt_runave_Wrap(Bi, wgt, 0)
   sst_mam = wgt_runave_n_Wrap(sst_mam, wgt, 0, 0)
   ;
   Ai_air_pcor = air_mam(0,:,:)
   Bi_air_pcor = air_mam(0,:,:)
   Ai_slp_pcor = slp_mam(0,:,:)
   Bi_slp_pcor = slp_mam(0,:,:)
   Ai_u_pcor = u_mam(0,:,:)
   Bi_u_pcor = u_mam(0,:,:)
   Ai_v_pcor = v_mam(0,:,:)
   Bi_v_pcor = v_mam(0,:,:)
   Ai_sst_pcor = sst_mam(0,:,:)
   Bi_sst_pcor = sst_mam(0,:,:)

   rAB   = escorc(Ai_hf, Bi_hf)
   print(rAB)

   rAair = escorc(Ai_hf,air_mam(lat|:,lon|:,time|:))
   rAslp = escorc(Ai_hf,slp_mam(lat|:,lon|:,time|:)) 
   rAu   = escorc(Ai_hf,u_mam(lat|:,lon|:,time|:))
   rAv   = escorc(Ai_hf,v_mam(lat|:,lon|:,time|:))
   rAsst = escorc(Ai_hf,sst_mam(lat|:,lon|:,time|:))
   ; rAz500 = escorc(Ai_hf,z500_mam(lat|:,lon|:,time|:))
   ; rAz200 = escorc(Ai_hf,z200_mam(lat|:,lon|:,time|:))
   ; rA = escorc(Ai_hf,uv_mam(lat|:,lon|:,time|:))
   ; rA = escorc(Ai_hf,nswr_mam(lat|:,lon|:,time|:))
   ; rA = escorc(Ai_hf,nlwr_mam(lat|:,lon|:,time|:))
   rBair = escorc(Bi_hf,air_mam(lat|:,lon|:,time|:))
   rBslp = escorc(Bi_hf,slp_mam(lat|:,lon|:,time|:))
   rBu   = escorc(Bi_hf,u_mam(lat|:,lon|:,time|:))
   rBv   = escorc(Bi_hf,v_mam(lat|:,lon|:,time|:))
   rBsst = escorc(Bi_hf,sst_mam(lat|:,lon|:,time|:))

   ;air
   Ai_air_pcor = (rAair - rAB*rBair)/sqrt((1- rAB^2)*(1- rBair^2))
   Bi_air_pcor = (rBair - rAB*rAair)/sqrt((1- rAB^2)*(1- rAair^2))
   ;SLP
   Ai_slp_pcor = (rAslp - rAB*rBslp)/sqrt((1- rAB^2)*(1- rBslp^2))
   Bi_slp_pcor = (rBslp - rAB*rAslp)/sqrt((1- rAB^2)*(1- rAslp^2))
   ;Wind
   Ai_u_pcor = (rAu - rAB*rBu)/sqrt((1- rAB^2)*(1- rBu^2))
   Bi_u_pcor = (rBu - rAB*rAu)/sqrt((1- rAB^2)*(1- rAu^2))
   Ai_v_pcor = (rAv - rAB*rBv)/sqrt((1- rAB^2)*(1- rBv^2))
   Bi_v_pcor = (rBv - rAB*rAv)/sqrt((1- rAB^2)*(1- rAv^2))
   ;SST
   Ai_sst_pcor = (rAsst - rAB*rBsst)/sqrt((1- rAB^2)*(1- rBsst^2))
   Bi_sst_pcor = (rBsst - rAB*rAsst)/sqrt((1- rAB^2)*(1- rAsst^2))

   ;
   wks=gsn_open_wks("pdf", plotpath+"ABi_partial_cor")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")

   ;Map resources
   ; resM = True
   ; resM@gsnDraw = False
   ; resM@gsnFrame = False
   ; resM@mpFillOn = False
   ; resM@mpOutlineOn = True
   ; resM@mpMaxLatF = 90
   ; resM@mpMinLatF = 0
   ; resM@mpMaxLonF = 360
   ; resM@mpMinLonF = 0
   ; resM@mpCenterLonF = 180
   ; resM@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   ; map = gsn_csm_map(wks, resM)

   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   
   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   ;resrc@lbLabelBarOn = True
   ;resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@gsnRightString = ""
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMinLevelValF = -0.8
   resrc@cnMaxLevelValF = 0.8
   resrc@cnLevelSpacingF = 0.1
   resrc@mpFillOn = False
   resrc@mpOutlineOn = True
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMinLonF = 0.
   resrc@mpCenterLonF = 180.
   resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)

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
   resrc2@cnLineLabelFontHeightF = 0.015
   ;resrc2@cnLineLabelFontColor = 0
   resrc2@cnLineLabelFontThicknessF = 1.0
   resrc2@gsnAddCyclic = True
   resrc2@gsnLeftString = ""
   resrc2@gsnRightString = ""
   
   ressnow = resrc
   ressnow@mpMinLatF = 20.
   ressnow@mpMaxLatF = 80.
   ressnow@mpMinLonF = 10.
   ressnow@mpMaxLonF = 150.
   ressnow@mpCenterLonF = 80.

   resSST = resrc
   resSST@mpMaxLonF = 10.
   resSST@mpMinLonF = -90.
   resSST@mpMaxLatF = 80.
   resSST@mpMinLatF = -10.
   resSST@mpCenterLonF = 0.
   resSST@cnMinLevelValF = -0.8
   resSST@cnMaxLevelValF = 0.8
   resSST@cnLevelSpacingF = 0.1
   
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/-0.320,0.320/)  ;95%
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   rescor@cnInfoLabelOn = False
   rescor@gsnLeftString = ""
   rescor@gsnRightString = ""

  ;Wind Resources
   resV = True
   resV@gsnDraw = False
   resV@gsnFrame = False
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"          
   resV@vcLineArrowThicknessF   = 1.0               
   resV@vcVectorDrawOrder       = "PostDraw"        
   resV@vcMinDistanceF     = 0.02
   resV@vcRefMagnitudeF = 1.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.49
   resV@gsnLeftString = ""
   resV@gsnRightString = ""

  ;Plot
   resrc@gsnLeftString = "Partial cor Ai: SAT+Wind(850hPa)"
   Aair = gsn_csm_contour_map(wks, Ai_air_pcor, resrc)
   Aair2 = gsn_csm_contour(wks, Ai_air_pcor, rescor)
   Awnd = gsn_csm_vector(wks, Ai_u_pcor, Ai_v_pcor, resV)
   overlay(Aair, Awnd)
   overlay(Aair, Aair2)
   draw(Aair)
   frame(wks)
   resrc@gsnLeftString = "Partial cor Ai: SAT+Wind(850hPa)"
   Bair = gsn_csm_contour_map(wks, Bi_air_pcor, resrc)
   Bair2 = gsn_csm_contour(wks, Bi_air_pcor, rescor)
   Bwnd = gsn_csm_vector(wks, Bi_u_pcor, Bi_v_pcor, resV)
   overlay(Bair, Bwnd)
   overlay(Bair, Bair2)
   draw(Bair)
   frame(wks)
   
   resrc@gsnLeftString = "Partial cor Ai: SLP"
   Aslp = gsn_csm_contour_map(wks, Ai_slp_pcor, resrc)
   Aslp2 = gsn_csm_contour(wks, Ai_slp_pcor, rescor)
   line = gsn_csm_contour(wks, Ai_slp_pcor, resrc2)
   overlay(Aslp, line)
   overlay(Aslp, Aslp2)
   draw(Aslp)
   frame(wks)
   resrc@gsnLeftString = "Partial cor Bi: SLP"
   Bslp = gsn_csm_contour_map(wks, Bi_slp_pcor, resrc)
   Bslp2 = gsn_csm_contour(wks, Bi_slp_pcor, rescor)
   line = gsn_csm_contour(wks, Bi_slp_pcor, resrc2)
   overlay(Bslp, line)
   overlay(Bslp, Bslp2)
   draw(Bslp)
   frame(wks)

   resSST@gsnLeftString = "Partial cor Ai: SST"
   Asst = gsn_csm_contour_map(wks, Ai_sst_pcor, resSST)
   Asst2 = gsn_csm_contour(wks, Ai_sst_pcor, rescor)
   Awnd = gsn_csm_vector(wks, Ai_u_pcor, Ai_v_pcor, resV)
   overlay(Asst, Awnd)
   overlay(Asst, Asst2)
   draw(Asst)
   frame(wks)
   resSST@gsnLeftString = "Partial cor Bi: SST"
   Bsst = gsn_csm_contour_map(wks, Bi_sst_pcor, resSST)
   Bsst2 = gsn_csm_contour(wks, Bi_sst_pcor, rescor)
   Bwnd = gsn_csm_vector(wks, Bi_u_pcor, Bi_v_pcor, resV)
   overlay(Bsst, Bwnd)
   overlay(Bsst, Bsst2)
   draw(Bsst)
   frame(wks)

;
end