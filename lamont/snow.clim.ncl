load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   yrstrt = 197201
   yrlast = 201412

   nyrs = yrlast/100-yrstrt/100+1
   print(nyrs+" years")

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

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

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"snow.clim")
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
   precipdata = addfile(precpath+"precip.mon.anom.nc", "r")

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

   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   snow_mon_wgt = SqrtCosWeight(snow_mon)

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
   v200_djf  = month_to_season(u200_mon, season)

   u200_son  = month_to_season(u200_mon, "SON")
   u200_djf  = month_to_season(u200_mon, "DJF")
 ;*****************************************************************
   imdyr = 20

   u200_son_clim1 = dim_avg_n_Wrap(u200_son(:imdyr,:,:), 0)
   u200_son_clim2 = dim_avg_n_Wrap(u200_son(imdyr+1:,:,:), 0)

   u200_son_dif = u200_son_clim1
   u200_son_dif = u200_son_clim2 - u200_son_clim1


   u200_djf_clim1 = dim_avg_n_Wrap(u200_djf(:imdyr,:,:), 0)
   u200_djf_clim2 = dim_avg_n_Wrap(u200_djf(imdyr+1:,:,:), 0)
   u200_djf_dif = u200_djf_clim1
   u200_djf_dif = u200_djf_clim2 - u200_djf_clim1
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
   ; resrc@mpOceanFillColor = "white"
   resrc@mpLandFillColor = "Transparent"
   ; resrc@mpMaskAreaSpecifiers =(/"China","Taiwan"/)

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.015
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsBackgroundFillColor = "black"
   resP@gsnPanelFigureStringsFontColor = "white"


;***************************************************************
   plots = new(3, graphic)
   plots(0) = gsn_csm_contour_map(wks, u200_son_clim1, resrc)
   plots(1) = gsn_csm_contour_map(wks, u200_son_clim2, resrc)
   plots(2) = gsn_csm_contour_map(wks, u200_son_dif, resrc)
   gsn_panel(wks, plots, (/3,1/), resP)
   frame(wks)


   plots2 = new(3, graphic)
   plots2(0) = gsn_csm_contour_map(wks, u200_djf_clim1, resrc)
   plots2(1) = gsn_csm_contour_map(wks, u200_djf_clim2, resrc)
   plots2(2) = gsn_csm_contour_map(wks, u200_djf_dif, resrc)
      gsn_panel(wks, plots2, (/3,1/), resP)
   frame(wks)


end
