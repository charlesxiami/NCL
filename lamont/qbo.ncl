load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
  ;This One for SON

   ; yrstrt = 197201
   ; yrlast = 201912

   ; yrstrt = 197201
   ; yrlast = 199412

   yrstrt = 199601
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
  
  SCI_NA_N = 70
  SCI_NA_S = 40
  SCI_NA_L = 240-360
  SCI_NA_R = 300-360

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
   wafpath = "$HOME/data/waf/tn/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", "snow.pc_reg")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   ; snowdata  = addfile(snowpath+"snow.rutger.2.0deg.nc","r")
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")
   precipdata= addfile(precpath+"precip.mon.anom.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.v5.nc", "r")
   sicdata = addfile(hadleypath+"HadISST_ice.nc", "r")

   ;NCEP 1
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   ; nswrdata  = addfile(ncep2path+"nswrs.sfc.mon.mean.nc", "r")
   ; nlwrdata  = addfile(ncep2path+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata   = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata   = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
   ; soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")


   ;Nao 195001-201806
   nao_index = asciiread(indexpath+"norm.nao.monthly.b5001.current.ascii.txt", -1, "string")
   nao_mon = stringtofloat(str_get_field(nao_index, 3, " "))
   nao_djf = new((/67/), float)  ; nao_djf: 1950/51DJF-2016/7DJF
   nao_mam = new((/67/), float)  ; nao_mam: 1950MAM-2016MAM
   do i = 0,66
    nao_djf(i) = dim_avg_Wrap(nao_mon(i*12+11:i*12+13))
   end do 
   do i = 0,66
    nao_mam(i) = dim_avg_Wrap(nao_mon(i*12+2:i*12+4))
   end do

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

   ; ;PNA 195001-
   ; pna_index = asciiread(indexpath+"norm.pna.monthly.b5001.current.ascii.txt", -1, "string")
   ; pna_mon = stringtofloat(str_get_field(pna_index, 3, " "))
   ; pna_djf = new((/67/), float)  ; pna_djf: 1950/51DJF-2016/7DJF
   ; pna_mam = new((/67/), float)  ; pna_mam: 1950MAM-2016MAM
   ; do i = 0,66
   ;  pna_djf(i) = dim_avg_Wrap(pna_mon(i*12+11:i*12+13))
   ; end do 
   ; do i = 0,66
   ;  pna_mam(i) = dim_avg_Wrap(pna_mon(i*12+2:i*12+4))
   ; end do

   ; nat_p1 = asciiread(indexpath+"nat_p1.txt", -1, "float")
   ; nat_p2 = asciiread(indexpath+"nat_p2.txt", -1, "float")
 ;*******************************************
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

   YYYYMM4 = cd_calendar(sicdata->time, 1)
   iStrt4  = ind(YYYYMM4.eq.yrstrt)
   iLast4  = ind(YYYYMM4.eq.yrlast)
   print("sea ice time: "+YYYYMM4(iStrt4)+"--"+YYYYMM4(iLast4))

   iStrt_ao  = ind(ao_mon_all&time.eq.yrstrt)
   iLast_ao  = ind(ao_mon_all&time.eq.yrlast)
   print("ao  time: "+ao_mon_all&time(iStrt_ao)+"--"+ao_mon_all&time(iLast_ao))
 ;********************************************
   air_mon  = airdata->air(iStrt:iLast, {latS:latN},{lonL:lonR})
   ; air_mon  = short2flt(airdata->air(iStrt:iLast, 0, {latS:latN},{lonL:lonR}))
   slp_mon  = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR})
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})
   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR})
  
   u_mon = uwnddata->uwnd(iStrt:iLast,:,:,:)
   u850_mon = u_mon(:,{850},:,:)
   u200_mon = u_mon(:,{200},:,:)

   v_mon = vwnddata->vwnd(iStrt:iLast,:,:,:)
   v850_mon = v_mon(:,{850},:,:)
   v200_mon = v_mon(:,{200},:,:)

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)

   ao_mon = ao_mon_all(iStrt_ao:iLast_ao)
   ao_mam = month_to_season(ao_mon, "MAM")
   ; ao_mam = dtrend(ao_mam, False)
   ; asciiwrite(indexpath+"ao_1967-2019mam.txt", ao_mam)

;*************************************************
;Filter High-Frequency Pass
;*************************************************
 ;   fcb= -999
 ;   nsigma = 1.
 ;   ihp = 1
 ;   fca = 1.0/120.
 ;   nwt= 21
 ;   wgt_hf = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

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
   season_string = "SON"
   print("season:  " + season_string)   
   snow_mam  = month_to_season(snow_mon, "SON")
   air_mam    = month_to_season(air_mon, season_string)
   slp_mam    = month_to_season(slp_mon, season_string)
   z500_mam  = month_to_season(z500_mon, season_string)
   z200_mam  = month_to_season(z200_mon, season_string)
   sst_mam    = month_to_season(sst_mon, season_string)

   u_mam = month_to_season(u_mon, season_string)
   v_mam = month_to_season(v_mon, season_string)

   u850_mam  = month_to_season(u850_mon, season_string)
   v850_mam  = month_to_season(v850_mon, season_string)
   u200_mam  = month_to_season(u200_mon, season_string)

   uv850_mam = u850_mam
   uv850_mam = sqrt(u850_mam^2 + v850_mam^2)

;************************************************
; Calculate Index
;************************************************
   snow_son_pc = asciiread(indexpath+"snow_pc1dt_1972-2019SON.txt", -1, "float")
   ; snow_son_pc = asciiread(indexpath+"snow_pc2dt_1972-2019SON.txt", -1, "float")

   pc_p1 = snow_son_pc(0:22)     ;1972-1994 SON for PC_P1
   pc_p2 = snow_son_pc(24:)      ;1996-2018 SON for PC_P2

   ;Define index
   ; snow_index = pc_p1
   snow_index = pc_p2
 ;*****************************************************************

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

   res_circ = resrc
   res_circ@mpFillOn = False   
   res_circ@mpMinLonF = 0
   res_circ@mpMaxLonF = 360
   res_circ@mpMaxLatF = 90
   res_circ@mpMinLatF = 0
   res_circ@mpCenterLonF = (res_circ@mpMinLonF+res_circ@mpMaxLonF)/2.

   res_snow = resrc
   res_snow@lbLabelBarOn = True
   res_snow@lbBoxLinesOn = False
      ; res_snow@lbOrientation = "Vertical"
   ; cmap = read_colormap_file("BlueWhiteOrangeRed")
   ; colormap = cmap(49:253-50,:)
   ; res_snow@cnFillPalette = colormap

   res_htfl = resrc
   res_htfl@cnMaxLevelValF := 10.5
   res_htfl@cnMinLevelValF = -1*res_htfl@cnMaxLevelValF
   res_htfl@cnLevelSpacingF = 0.5
   res_htfl@cnFillPalette = "cmp_b2r"
   ; res_htfl@cnFillPalette = "BlWhRe"

   resSST = res_circ
   ; resSST@lbLabelBarOn = True
   resSST@mpMaxLonF = 360
   resSST@mpMinLonF = 0
   resSST@mpMaxLatF = 80
   resSST@mpMinLatF = -20
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
   rescor@cnFillScaleF = 1.0
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
   resV@vcMinDistanceF     = 0.015

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.015
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsBackgroundFillColor = "black"
   resP@gsnPanelFigureStringsFontColor = "white"
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

  rts_line = rts   ; Line
  rts_line@xyDashPattern         = 1
  rts_line@xyLineThicknessF      = 4.
  rts_line@xyLineColor = "black"

  rtsP = True
  rtsP@lbLabelAutoStride = True

;****************************************************************


end
