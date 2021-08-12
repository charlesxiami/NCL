begin
;***
yrstrt =197201
yrlast =200912
  latS     = -90               
  latN     = 90
  lonL     =   0
  lonR     = 360
;**********************************************
;Calcute Snow Cover Index
fname = "/media/sf_Data/Original/snowcover/snow.nc"
data       = addfile(fname,"r")
snow     = data->Snow

fname2 = "/media/sf_Data/Original/ncep/air.mon.mean.nc"
airdata = addfile(fname2,"r")

fname3= "/media/sf_Data/Original/ncep/slp.mon.mean.nc"
slpdata = addfile(fname3,"r")

fname4 = "/media/sf_Data/Original/ncep/hgt.mon.mean.nc"
hgtdata = addfile(fname4,"r")
;hgt= hgtdata->hgt(:,5,:,:)

pcname="/media/sf_Data/Processed/ncep/sat/PC1_hf_sat_MAM1970-2014.bin"
pc = fbindirread(pcname, 0, 45 ,"float")
printVarSummary(pc)

;***************************************
   YYYYMM = cd_calendar( airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   year=ispan(1972, 2009, 1)
   nyrs=dimsizes(year)
   ;***************************************
   ;Month to Year
   ;***************************************
   air_yr      = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   air_mam = month_to_season(air_yr, "MAM")

   slp_yr      = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   slp_mam = month_to_season(slp_yr, "MAM")

   hgt500_yr      = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 
   hgt500_mam = month_to_season(hgt500_yr, "MAM")

    hgt200_yr      = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
    hgt200_mam = month_to_season(hgt200_yr, "MAM")
    ;printVarSummary(hgt500_mam)           
     ;*****************************************************
     ; Regression
     ;*****************************************************
    reg_air=regCoef(pc(2:39),air_mam(lat|:,lon|:,time|:))
    reg_slp=regCoef(pc(2:39),slp_mam(lat|:,lon|:,time|:))
    reg_hgt500=regCoef(pc(2:39),hgt500_mam(lat|:,lon|:,time|:))

    lat_coordinates=ispan(-180, 180, 5) *0.5
    lon_coordinates=ispan(0, 715, 5)*0.5

    reg_air!0="lat"
    reg_air!1="lon"
    reg_air&lat=lat_coordinates
    reg_air&lon=lon_coordinates
    reg_air&lat@units="degrees_north"
    reg_air&lon@units="degrees_east"

    reg_slp!0="lat"
    reg_slp!1="lon"
    reg_slp&lat=lat_coordinates
    reg_slp&lon=lon_coordinates
    reg_slp&lat@units="degrees_north"
    reg_slp&lon@units="degrees_east"

    reg_hgt500!0="lat"
    reg_hgt500!1="lon"
    reg_hgt500&lat=lat_coordinates
    reg_hgt500&lon=lon_coordinates
    reg_hgt500&lat@units="degrees_north"
    reg_hgt500&lon@units="degrees_east"
   ;printVarSummary(rcAair)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;Correlation
;**************************************************
    cor_air=escorc(pc(2:39),air_mam(lat|:,lon|:,time|:))
    cor_slp=escorc(pc(2:39),slp_mam(lat|:,lon|:,time|:))
    cor_hgt500=escorc(pc(2:39),hgt500_mam(lat|:,lon|:,time|:))

    cor_air!0="lat"
    cor_air!1="lon"
    cor_air&lat=lat_coordinates
    cor_air&lon=lon_coordinates
    cor_air&lat@units="degrees_north"
    cor_air&lon@units="degrees_east"

    cor_slp!0="lat"
    cor_slp!1="lon"
    cor_slp&lat=lat_coordinates
    cor_slp&lon=lon_coordinates
    cor_slp&lat@units="degrees_north"
    cor_slp&lon@units="degrees_east"

    cor_hgt500!0="lat"
    cor_hgt500!1="lon"
    cor_hgt500&lat=lat_coordinates
    cor_hgt500&lon=lon_coordinates
    cor_hgt500&lat@units="degrees_north"
    cor_hgt500&lon@units="degrees_east"
    printVarSummary(cor_hgt500)
;*************************************************
;Setting Plot
;***********************************************
   wks=gsn_open_wks("png", "pc_reg")
   gsn_define_colormap(wks, "BlWhRe")
;********************************************************
   resReg = True
  resReg@gsnDraw              = False
  resReg@gsnFrame             = False
   resReg@gsnMaximize           = False            ; make large
   resReg@cnFillOn              = False            ; turn on color
   resReg@cnLinesOn             = True            ; turn off contour lines
   resReg@cnLineLabelsOn        = True            ; turn off contour line labels
   resReg@cnSmoothingOn        = True
   resReg@cnLabelMasking = True
   resReg@cnLineThicknessF =  2.0
    resReg@gsnContourNegLineDashPattern = 5
    resReg@cnInfoLabelOn  = False
    resReg@gsnContourZeroLineThicknessF = 0
    resReg@cnLevelSelectionMode = "ManualLevels"
     ;resReg@cnLevelSpacingF       =   0.4            ; set contour interval
     ;resReg@gsnCenterString       = year(0)+"-"+year(nyrs-1) 
    ;resReg@mpFillOn              = False            ; turn off default background gray
    ;resReg@mpCenterLonF          = 180
;***********************************************************
    resCor= True
    resCor@gsnDraw              = False
    resCor@gsnFrame             = False
    resCor@gsnMaximize           = False             ; make large
    resCor@cnLinesOn             = False            ; turn off contour lines
    resCor@cnLineLabelsOn        = False          ; turn off contour line labels
    resCor@cnFillOn              = True            ; turn on color
    ;resCor@cnLevelSpacingF      =   3.
    resCor@lbLabelBarOn  =   False
    resCor@cnLevelSelectionMode = "ExplicitLevels"  ; set explicit contour levels
    resCor@cnLevels    = (/-0.320,-0.271,0,0.271,0.320/)    ; 90% & 95% Sig Level
    resCor@cnFillColors = (/38,46,52,52,59,65/)
    resCor@mpFillOn              = False            ; turn off default background gray
    resCor@mpCenterLonF          = 180
    resCor@mpMinLonF            = 0.               ; select a subregion
    resCor@mpMaxLonF            = 360.
    resCor@mpMinLatF            =  0. 
    resCor@mpMaxLatF            =  90.
    ;resCor@tiMainString          = "PC_hf - SAT Regression Map"    
;**********************************************************
   plot   = new (3, "graphic") 
   plot(0)= gsn_csm_contour_map_overlay(wks, cor_air, reg_air, resCor, resReg)
   plot(1)= gsn_csm_contour_map_overlay(wks, cor_slp, reg_slp, resCor, resReg)
   plot(2)= gsn_csm_contour_map_overlay(wks, cor_hgt500, reg_hgt500, resCor, resReg)
;********************************************************
;Panel 
;********************************************************
  resP                 = True               ; panel resources
  resP@txString        = "Regression with PC_hf"  ; add center string
  resP@gsnPanelLabelBar    = False                ; add common colorbar
  resP@lbLabelAutoStride   = True
  resP@gsnMaximize         = True                
  gsn_panel(wks,plot,(/3,1/),resP)   

end
