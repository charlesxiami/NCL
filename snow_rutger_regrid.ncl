load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

    PLOT_RESULTS  = True
    WRITE_RESULTS = True 

;*************************************************
;Res
;*************************************************
   ; res = True
   ; res@gsnDraw = False
   ; res@gsnFrame = False

   ; resmap = True
   ; resmap@mpFillOn = False
   ; resmap@mpCenterLonF = 180.
   ; resmap@mpMinLonF = 0.
   ; resmap@mpMaxLonF = 240.
   ; resmap@mpMaxLatF = 90.
   ; resmap@mpMinLatF = 0.
   ; resmap@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)

   ; resrc = res
   ; resrc@cnFillOn = True
   ; resrc@cnLinesOn = False
   ; resrc@cnLineLabelsOn = False
   ; resrc@lbLabelBarOn = False
   ; resrc@lbLabelsOn = True
   ; ;resrc@lbOrientation = "Vertical"
   ; resrc@cnInfoLabelOn = False
   ; resrc@cnLevelSelectionMode = "ManualLevels"
   ; resrc@tmXBLabelFontHeightF = 0.015
   ; resrc@tmYLLabelFontHeightF = 0.015
   ; resrc@pmLabelBarOrthogonalPosF = -0.1

   ; ; rescor = True
   ; ; rescor = res
   ; ; rescor@cnLinesOn = False
   ; ; rescor@cnFillOn = True
   ; ; rescor@cnLevelSelectionMode = "ExplicitLevels"
   ; ; rescor@cnMonoFillPattern = False
   ; ; rescor@cnFillDotSizeF = 0.004
   ; ; rescor@cnLineLabelsOn = False
   ; ; rescor@lbLabelBarOn = False
   ; ; ;rescor@lbOrientation = "Vertical"
   ; ; ;rescor@lbLabelsOn = False
   ; ; rescor@cnInfoLabelOn = False
   ; ; rescor@cnFillPatterns = (/17,-1,17/)

   ; resP = True
   ; resP@gsnMaximize = False
   ; resP@gsnPanelLabelBar = True
   ; ;resP@lblabel
   ; ;resP@gsnPanelFigureStrings = (/"a)","b)","c)","d)","e)","f)"/)
   ; resP@gsnPanelFigureStringsFontHeightF = 0.012
   ; resP@gsnPanelFigureStringsPerimOn = False
   ; resP@gsnPanelFigureStringsBackgroundFillColor = 0  ; 0=white, 1=black
   ; resP@amJust = "TopLeft"
   ; resP@amOrthogonalPosF = -0.50  ;Y-axis   ; -0.5,-0.5 = TopLeft
   ; resP@amParallelPosF = -0.50    ;X-axis
;*****************************************************
   snowpath  = "/public/home/charlesxiami/data/snow/"
   indexpath = "/public/home/charlesxiami/data/index/"
   plotpath  = "/public/home/charlesxiami/output/"

   wks=gsn_open_wks("pdf", plotpath+"snow_rutger_regrid")
   ;gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;********************************************************
   snowfile = addfile(snowpath+"RutgersSnow.mon.mean.nc", "r")
   lat2d = snowfile->lat
   lon2d = snowfile->lon
   ; print(min(lat2d)+" --- "+max(lat2d))
   ; print(min(lon2d)+" --- "+max(lon2d))

   yyyymm = 198805
   utc_date = cd_calendar(snowfile->time, 1)
   nt = ind(utc_date.eq.yyyymm)
   sce2d = snowfile->snowcover
   print("--------------------------------------------")
   sce2d@_FillValue = toshort(sce2d@missing_value)

   ;print("--------------------------------------------")

    Opt                   = True            ; Options for regridding

    Opt@InterpMethod      = "neareststod"

    Opt@SrcFileName       = snowpath+"regrid/src_rutger_grid.nc"  ; Output files
    Opt@DstFileName       = snowpath+"regrid/des_rutger_grid.nc"
    Opt@WgtFileName       = snowpath+"regrid/wgt_rutger_patch.nc"
    Opt@ForceOverwrite    = True
    ;Opt@SrcGridMask       = where(ismissing(lat2d),0,1)
    Opt@SrcGridLat        = lat2d
    Opt@SrcGridLon        = lon2d

    Opt@DstGridType       = "2.0deg"       ; Destination grid
    Opt@DstTitle          = "Northern Hemisphere 2.0 resolution"
    Opt@DstLLCorner       = (/ 0.5d, -179.0d/)
    Opt@DstURCorner       = (/88.5d, 179.0d/)

    Opt@Debug           = True

    sce_regrid = ESMF_regrid(sce2d,Opt)    ; Regrid sce


    sce_regrid@_FillValue = toshort(sce_regrid@missing_value)

    printVarSummary(sce2d)
    printVarSummary(sce_regrid)


; Write the regridded variable to a file using the "inefficient" method.
;----------------------------------------------------------------------
    if(WRITE_RESULTS) then
      rgrdFileName = snowpath+"snow.rutger."+Opt@DstGridType+"."+Opt@InterpMethod+".nc"
      system("rm -f " + rgrdFileName)
      rgrd_nc = addfile(rgrdFileName,"c")

;---Create variable to hold global file attributes
      global = True
      copy_VarAtts(snowfile, global)

      if (isatt(snowfile,"title")) then
        global@TITLE = "REMAPPED: " + snowfile@title
      end if
      global@remap         = "NCL: ESMF_regrid_with_weights (NCL version '" + \
                             get_ncl_version() + "')"
      global@remap_method  = Opt@InterpMethod
      global@creation_date = systemfunc("date")
    
      fileattdef(rgrd_nc, global )        ; copy global file attributes
      filedimdef(rgrd_nc,"TIME",-1,True)   ; force an unlimited dimension
;
; Write variables to file. Coordinate arrays will be written 
; automatically
;
      rgrd_nc->snowcover       = sce_regrid
      ;rgrd_nc->DEPTHedges = snowfile->DEPTHedges
    end if
   

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------

    res                     = True              ; Plot mods desired.
    res@gsnMaximize         = True              ; Maximize plot

    res@gsnDraw             = False
    res@gsnFrame            = False

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "amwg"            ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
    ;res@cnFillMode          = "RasterFill"      ; turn raster on       

    res@cnLevelSelectionMode= "AutomaticLevels" ; set explicit contour levels
    ; res@cnLevels            = (/-300,-250,-200,-150,-100,   \
    ;                             0,1,5,10,25,100,200,300,400/)

    res@lbLabelBarOn        = False              ; turn on in panel


    res@gsnPolar            = "NH"               ; specify the hemisphere
    res@mpMinLatF           = 30

;---Compare the plots in a panel
    pres                    = True
    pres@gsnMaximize        = False
    pres@gsnPanelLabelBar   = True
    pres@lbLabelFontHeightF = 0.01
    pres@pmLabelBarWidthF   = 0.8


;---Plot original data.
    res@gsnAddCyclic = False
    res@sfXArray     = lon2d
    res@sfYArray     = lat2d
    res@tiMainString = "Original NCDC grid (" + str_join(dimsizes(lat2d),",") + ")"
    res@trGridType = "TriangularMesh"
    res@cnFillMode = "RasterFill"

    plot_month = 9+12
    plot_orig   = gsn_csm_contour_map_polar(wks,sce2d(plot_month,:,:),res)

    plots1 = new(12*12, "graphic")
    ; do i = 0, 12*12-1
    ;    plots1(i) = gsn_csm_contour_map_polar(wks, sce2d(i,:,:), res)
    ; end do
    ; gsn_panel(wks, plots1, (/12,12/), pres)

    delete(res@sfXArray)
    delete(res@sfYArray)


;---Plot regridded data.
    res@gsnAddCyclic = True

    dims = tostring(dimsizes(sce_regrid))
    res@tiMainString = "Regridded to 2.0 degree grid (" + \
                       str_join(dims(1:2)," x ") + ")"

    plot_regrid = gsn_csm_contour_map_polar(wks,sce_regrid(plot_month,:,:),res)


    gsn_panel(wks,(/plot_orig,plot_regrid/),(/1,2/),pres)

   
    ; res@cnFillMode = "AreaFill"
    ; delete([/res@trGridType, res@gsnPolar/])
    ; res@mpMinLatF = 0

    ; plot_regrid2 = gsn_csm_contour_map(wks, sce_regrid(11,:,:), res)
    ; draw(plot_regrid2)
    ; frame(wks)

    plots2 = new(12*12, "graphic")
    ; do i = 0, 12*12-1
    ;    plots2(i) = gsn_csm_contour_map_polar(wks, sce_regrid(i,:,:), res)
    ; end do
    ; gsn_panel(wks, plots2, (/12,12/), pres)


;--------------------------------------------------------
;Draw index
    sce2d_index0 = dim_avg_n_Wrap(sce2d, 1)
    sce2d_index = dim_avg_n_Wrap(sce2d_index0, 1)
    sce_regrid_index0 = dim_avg_n_Wrap(sce_regrid, 1)
    sce_regrid_index = dim_avg_n_Wrap(sce_regrid_index0, 1)

    ; sce2d_index = dim_standardize(sce2d_index, 0)
    ; sce_regrid_index = dim_standardize(sce_regrid_index, 0)

    ; sce2d_index = runave_Wrap(sce2d_index, 31, 0)
    ; sce_regrid_index = runave_Wrap(sce_regrid_index, 31, 0)

    ;printVarSummary(sce2d_index)
    ;printVarSummary(sce_regrid_index)

     rts           = True
     rts@gsnDraw   = False
     rts@gsnFrame  = False
     rts@gsnScale  = True
     rts@vpHeightF = 0.35
     rts@vpWidthF  = 0.85
     rts@vpXF      = 0.10
     rts@vpYF      = 0.75
     rts@tiYAxisString = ""
     rts@gsnLeftStringFontHeightF = 0.025
     rts@gsnYRefLine = 0.
     rts@tmYLLabelFontHeightF = 0.015
     rts@tmYLLabelFontHeightF = 0.015

     year = utc_date(11:dimsizes(utc_date)-1:12)/100

     sce2d_index_dec = sce2d_index(14:dimsizes(sce2d_index)-1:12)
     linep1 = gsn_csm_xy(wks, year, sce2d_index_dec, rts)
     draw(linep1)
     frame(wks)

     sce_regrid_index_dec = sce_regrid_index(14:dimsizes(sce_regrid_index)-1:12)
     linep2 = gsn_csm_xy(wks, year, sce_regrid_index_dec, rts)
     draw(linep2)
     frame(wks)

     ; printMinMax(sce2d_index, 0)
     ; printMinMax(sce_regrid_index, 0)




end