 begin
;***
  yrstrt =197201
  yrlast =200912
;---------------A,B-index Region
  WlatS = 48
  WlatN = 58
  WlonL = 25
  WlonR = 50

  ClatS = 50
  ClatN = 60
  ClonL = 55
  ClonR = 85
  
  ElatS = 60
  ElatN = 70
  ElonL = 100
  ElonR = 125

  latS  = -90
  latN  = 90
  lonL  = 0
  lonR  = 360

  sig1 = 0.497   ; %95
  sig2 = 0.433   ; %95

   cd = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"

  wks=gsn_open_wks("pdf", plotpath+"AO-Snow")
  gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;************************************************
;Calcute Snow Cover Index
;************************************************
   filesnow = "/public/home/charlesxiami/data/snow/snow.nc"
   snowdata = addfile(filesnow,"r")
   airdata = addfile(cd+"air.mon.mean.nc", "r")
   slpdata = addfile(cd+"slp.mon.mean.nc", "r")
   hgtdata = addfile(cd+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(cd+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(cd+"vwnd.mon.mean.nc", "r")
   ;cfnsfdata = addfile(cd+"cfnsf.sfc.mon.mean.nc", "r")
   pc1 = asciiread(indexpath+"pc1.txt", -1, "float")
   tele_index = asciiread(indexpath+"tele_index.nh.txt", -1, "string")

   ;ao_mon 195001-201708
   ao_index = asciiread(indexpath+"monthly.ao.index.b50.current.ascii.txt", -1, "string")
   ao_mon = stringtofloat(str_get_field(ao_index, 3, " "))
   printVarSummary(ao_mon)
   ao_djf_all = new((/67/), float)  ; ao_djf: 1950DJF-2016DJF
   ao_mam_all = new((/67/), float)  ; ao_mam: 1950MAM-2016MAM
   do i = 0,66
    ao_djf_all(i) = dim_avg_Wrap(ao_mon(i*12+11:i*12+13))
   end do 
   do i = 0,66
    ao_mam_all(i) = dim_avg_Wrap(ao_mon(i*12+2:i*12+4))
   end do 
   ;print(ao_mam)

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
   Wregion=snow_mam_wgt(:,{WlatS:WlatN},{WlonL:WlonR})
   Cregion=snow_mam_wgt(:,{ClatS:ClatN},{ClonL:ClonR})
   Eregion=snow_mam_wgt(:,{ElatS:ElatN},{ElonL:ElonR})
   WEU = dim_standardize_Wrap(wgt_areaave_Wrap(Wregion, 1.0, 1.0, 1),0)
   CEU = dim_standardize_Wrap(wgt_areaave_Wrap(Cregion, 1.0, 1.0, 1),0)
   EEU = dim_standardize_Wrap(wgt_areaave_Wrap(Eregion, 1.0, 1.0, 1),0)
;*************************************************
;Filter High-Frequency Pass
;*************************************************
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    WEU_hf = wgt_runave_Wrap(WEU, wgt, 0)
    CEU_hf = wgt_runave_Wrap(CEU, wgt, 0)
    EEU_hf = wgt_runave_Wrap(EEU, wgt, 0)
    pc1_hf = wgt_runave_Wrap(pc1, wgt, 0)
    ao_djf = wgt_runave_Wrap(ao_djf_all, wgt, 0)
    ao_mam = wgt_runave_Wrap(ao_mam_all, wgt, 0)
;*************************************************
   snow_mam1 = snow_mam(0:15,:,:)
   air_mam1  = air_mam(0:15,:,:)
   slp_mam1  = slp_mam(0:15,:,:)
   u_mam1    = u_mam(0:15,:,:)
   v_mam1    = v_mam(0:15,:,:)
   z500_mam1 = z500_mam(0:15,:,:)
   z200_mam1 = z200_mam(0:15,:,:)

   snow_mam2 = snow_mam(17:37,:,:)
   air_mam2  = air_mam(17:37,:,:)
   slp_mam2  = slp_mam(17:37,:,:)
   u_mam2    = u_mam(17:37,:,:)
   v_mam2    = v_mam(17:37,:,:)
   z500_mam2 = z500_mam(17:37,:,:)
   z200_mam2 = z200_mam(17:37,:,:)

;*******************************************************
   ao_sce_rc1  = 100*regCoef(ao_mam(0+22:15+22),snow_mam1(lat|:,lon|:,time|:))
   ao_sce_cor1  = escorc(ao_mam(0+22:15+22),snow_mam1(lat|:,lon|:,time|:))
   copy_VarCoords(snow_mam(0, :, :), ao_sce_rc1)
   copy_VarCoords(snow_mam(0, :, :), ao_sce_cor1)

   ao_sce_rc2  = 100*regCoef(ao_mam(17+22:37+22),snow_mam2(lat|:,lon|:,time|:))
   ao_sce_cor2  = escorc(ao_mam(17+22:37+22),snow_mam2(lat|:,lon|:,time|:))
   copy_VarCoords(snow_mam(0, :, :), ao_sce_rc2)
   copy_VarCoords(snow_mam(0, :, :), ao_sce_cor2)
;*******************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
 ;For SAT
   resrc = res
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   ; resrc@mpGridAndLimbOn = True
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpFillOn = False
   resrc@mpCenterLonF = 180.
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 240.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.
   ;resrc@mpDataSetName         = "Earth..4"   ; This new database contains
   ;resrc@mpDataBaseVersion     = "LowRes"  ; Medium resolution database
   ;resrc@mpOutlineBoundarySets = "National"
   resrc@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15

   ressnow = resrc
   ressnow@mpMinLatF = 40.
   ressnow@mpMaxLatF = 80.
   ressnow@mpMinLonF = 10.
   ressnow@mpMaxLonF = 150.
   ressnow@mpCenterLonF = 80.
   ressnow@lbLabelBarOn = False
   ressnow@cnLevelSelectionMode = "ExplicitLevels"
   ressnow@cnLevels = ispan(-20, 20,4)
   ;print(ressnow@cnLevels)
   ressnow@cnFillColors =(/4,15,25,33,57,100,130,143,150,163,170,180/)
   ; ressnow@cnMinLevelValF = -0.20
   ; ressnow@cnMaxLevelValF = 0.20
   ; ressnow@cnLevelSpacingF = 0.02

  ;Correlation res (with dots.)
   rescor = True
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False

   resP = True
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopRight"
   resP@pmLabelBarWidthF = 0.5
;******************************************************
   rescor@cnLevels = (/-sig1,sig1/)
   ressnow@gsnLeftString  = "(a) AO-Snow cover:P1"
   aorc1 = gsn_csm_contour_map(wks, ao_sce_rc1, ressnow)
   aocor1 = gsn_csm_contour(wks, ao_sce_cor1, rescor)
   overlay(aorc1, aocor1)

   rescor@cnLevels = (/-sig2,sig2/)
   ressnow@gsnLeftString  = "(b) AO-Snow cover:P2"
   aorc2 = gsn_csm_contour_map(wks, ao_sce_rc2, ressnow)
   aocor2 = gsn_csm_contour(wks, ao_sce_cor2, rescor)
   overlay(aorc2, aocor2)

   aosnow = new(2, "graphic")
   aosnow(0) = aorc1
   aosnow(1) = aorc2   

   resP@gsnPanelLabelBar = True
   gsn_panel(wks, aosnow, (/2,1/), resP)

end