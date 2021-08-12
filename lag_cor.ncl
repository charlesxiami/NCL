  ;***
  begin
;***
   yrstrt =197201
   yrlast =200912
;---------------A,B-index Region
   Aleft     = 25
   Aright   = 50
   Asouth = 50
   Anorth = 60

   Bleft    = 100
   Bright   = 125
   Bsouth = 60
   Bnorth = 70
  
   latS     = -90               
   latN     = 90
   lonL     =   0
   lonR     = 360
;**********************************************
;Calcute Snow Cover Index
;*********************************************
  diri1 = "/public/home/charlesxiami/data/"
  diri2 = "/public/home/charlesxiami/data/ncep/ncep/"

  fname = diri1+"snow.nc"
  snowdata   =  addfile(fname,"r")

  fname2 = diri2+"air.mon.mean.nc"
  airdata = addfile(fname2,"r")

  fname3= diri2+"slp.mon.mean.nc"
  slpdata = addfile(fname3,"r")
;***************************************
   YYYYMM = cd_calendar( airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   year=ispan(1972, 2009, 1)
   nyrs=dimsizes(year)
;********************************************
   snow_mon      = snowdata->Snow(:,:,:)
   snow_mam =month_to_season(snow_mon, "MAM")

   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR})
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR})
   air_mon = SqrtCosWeight(air_mon)
   slp_mon = SqrtCosWeight(slp_mon)
   air_mon_ave = wgt_areaave_Wrap(air_mon(:,{Asouth:Anorth},{Aleft:Aright}), 1, 1, 1)
   printVarSummary(air_mon_ave)
;************************************************
; Calculate A,B Index
;************************************************
   snow_mam_wgt= SqrtCosWeight(snow_mam)
   Aregion=snow_mam_wgt(:,{Asouth:Anorth},{Aleft:Aright})
   Asnow=wgt_areaave_Wrap(Aregion, 1.0, 1.0, 1)
;********************************************
; Standardize
;********************************************
    A_stad = dim_standardize_n_Wrap(Asnow, 0, 0)
;**************************************************
;Lag Correlation

    do k = 0, 11
    do t = 1, nyrs-1
        air_season(t) = avg(air_mon_ave(t*12-k-1:air_mon_ave(t*12-k-2))
    end do 
        lag_air(k) = escorc(A_stad, air_season)
    end do
    print(lag_air)
;*************************************************
;Setting Plot
;***********************************************
   output = "/public/home/charlesxiami/output/"
   wks=gsn_open_wks("pdf", output+"sc_index_reg")
   gsn_define_colormap(wks, "BlWhRe")
;********************************************************
   resLine = True
   resLine@gsnDraw              = False
   resLine@gsnFrame             = False
   resLine@gsnMaximize           = False            ; make large
   resLine@cnFillOn              = False            ; turn on color
   resLine@cnLinesOn             = True            ; turn off contour lines
   resLine@cnLineLabelsOn        = True            ; turn off contour line labels
   resLine@cnSmoothingOn        = True
   resLine@cnLabelMasking = True
   resLine@cnLineThicknessF =  2.0
   resLine@gsnContourNegLineDashPattern = 5
   resLine@cnInfoLabelOn  = False
   resLine@gsnContourZeroLineThicknessF = 0
   ;resLine@cnLevelSelectionMode = "ManualLevels"
   ;resLine@cnLevelSpacingF       =   0.2            ; set contour interval
   ;resLine@gsnCenterString       = year(0)+"-"+year(nyrs-1) 
   ;resLine@mpFillOn              = False            ; turn off default background gray
   ;resLine@mpCenterLonF          = 180
;**********************************************************
   plot   = new (4, "graphic") 

;********************************************************
;Panel 
;********************************************************
  resP                 = True               ; panel resources
  resP@txString        = "A,B-Index  Regression Map"  ; add center string
  resP@gsnPanelLabelBar    = False                ; add common colorbar
  resP@lbLabelAutoStride   = True
  resP@gsnMaximize         = True                
  gsn_panel(wks,plot,(/4,1/),resP)   

end
