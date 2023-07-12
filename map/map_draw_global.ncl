begin
;*************************************************************************************
;    yrstrt = 197201   ;P1+P2
;    yrlast = 201912

;    yrstrt_sst = yrstrt
;    yrlast_sst = yrlast

;   year = ispan(yrstrt_snow/100, yrlast_snow/100, 1)
;*************************************************************************************
;   latS     = -90
;   latN     = 90
;   lonL     = 0
;   lonR     = 360

;    nceppath = "$HOME/data/ncep/"
;    indexpath = "$HOME/data/index/"
;    precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"

   mask_specs = (/"Turkey", "Macedonia", "Colombia",  "Chad"/)  ;"North Macedonia"  , "Sudan"

   shp_path = "/mnt/d/research/data/shapefile/"
   sdn_shp = shp_path+"Sudan/data/SDN_adm0.shp"
  ;  sdn_shp = addfile(shp_path+"Sudan/data/SDN_adm0.shp", "r")
;*************************************************************************************
   wks=gsn_open_wks("pdf", "map_draw")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;*************************************************************************************
  res = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@gsnMaximize = True
  res@mpEllipticalBoundary = False
  res@mpPerimOn = False
  res@mpOutlineOn = True
  ; res@mpFillOn = True
  res@mpFillDrawOrder = "Predraw"
  res@mpNationalLineColor = "white"
  res@mpOutlineBoundarySets       = "National"   ; turn on country boundaries
  res@mpOutlineDrawOrder = "Predraw"
  res@mpGeophysicalLineColor      = "transparent"       ; color of cont. outlines
  res@mpGeophysicalLineThicknessF = 1.5          ; thickness of outlines
  res@mpDataBaseVersion = "MediumRes"
  ; res@mpDataSetName = "Earth..4"
  res@mpOceanFillColor       = "transparent"            ; array index in color map
  res@mpLandFillColor        = "gray83"          ; for land, ocean, and inland h20

  res@mpMinLonF              = -180
  res@mpMaxLonF              = 180
  res@mpCenterLonF           = 0

  res@tmYROn = False
  res@tmYLOn = False
  res@tmXTOn = False
  res@tmXBOn = False

  ; res@perimon

  ; res@mpAreaMaskingOn = True
  ; res@mpMaskAreaSpecifiers  = ("Sudan")
  res@mpSpecifiedFillColors       = (/"deepskyblue4","deepskyblue4","deepskyblue4",  "deepskyblue"/) ;,"deepskyblue"
  res@mpFillAreaSpecifiers  = mask_specs

  res@gsnCenterString = "Drew by Ming Wong"
;*************************************************************************************

  plot = gsn_csm_map(wks,res)        ; draw global map\

  lnres                  = True
  lnres@gsLineColor      = "white"
  lnres@gsLineThicknessF = 1.0

  dum = gsn_add_shapefile_polylines(wks, plot, sdn_shp, lnres)

  pres = True
  ; pres@tfPolyDrawOrder = "PostDraw"
  ; pres@cnFillDrawOrder = "PostDraw"
  ; pres@mpFillDrawOrder = "PostDraw"
  pres@gsFillColor  = "deepskyblue"
  dum2 = gsn_add_shapefile_polygons(wks, plot, sdn_shp, pres)

  draw(plot)
  frame(wks)


end