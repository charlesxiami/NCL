load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;***
  begin
;***
   yrstrt =197201
   yrlast =200912

   ; latS     = 20.
   ; latN     = 80.
   ; lonL     = 80.
   ; lonR     = 140.
;**********************************************
;Calcute Snow Cover Index
;*********************************************
   nceppath = "/public/home/charlesxiami/data/ncep/"
   snowpath = "/public/home/charlesxiami/data/snow/swe/"
   indexpath = "/public/home/charlesxiami/data/index/"
   plotpath = "/public/home/charlesxiami/output/"
;************************************************
;Setting Plot
;************************************************
   wks=gsn_open_wks("pdf", plotpath+"swe_read")
   gsn_define_colormap(wks, "BlAqGrYeOrRe")
;************************************************
   datalist = systemfunc("find "+ "$HOME/data/snow/swe/EASE_SWE/nsidc0271v01/"+ \
                         " -name " +"*.NSIDC8" +"|sort")
   setfileoption("bin","ReadByteOrder","LittleEndian")
   swe_data = new((/dimsizes(datalist), 721, 721/), "short")
   do i = 0, dimsizes(datalist)-1
      swe_data(i,:,:) = fbindirread(datalist(i), 0, (/721,721/), "short")
   end do

   ndim = dimsizes(swe_data(0,:,:))
   ; swe_mam = short2flt(swe_data(0:28,:,:))
   ; do i = 0, 28
   ;    do j = 0, ndim(0) -1
   ;      do k = 0, ndim(1) -1
   ;  swe_mam(i,j,k) = dim_avg_n_Wrap(swe_data(2+2+i*12:2+4+i*12,j,k), 0)
   ;      end do
   ;    end do
   ; end do  
   ; binfilename = snowpath+"EASE_SWE/swe.mam.bin"
   ; system("rm -f " + binfilename)
   ; fbindirwrite(binfilename, swe_mam)

   swe_jja = short2flt(swe_data(0:28,:,:))
   do i = 0, 28
      do j = 0, ndim(0) -1
        do k = 0, ndim(1) -1
    swe_jja(i,j,k) = dim_avg_n_Wrap(swe_data(2+5+i*12:2+7+i*12,j,k), 0)
        end do
      end do
   end do  
   binfilename := snowpath+"EASE_SWE/swe.jja.bin"
   system("rm -f " + binfilename)
   fbindirwrite(binfilename, swe_jja)

   setfileoption("bin","ReadByteOrder","LittleEndian")
   lat2d = fbindirread("$HOME/data/snow/swe/EASE-Grid/NLLATLSB", 0, (/721,721/), "integer")
   lon2d = fbindirread("$HOME/data/snow/swe/EASE-Grid/NLLONLSB", 0, (/721,721/), "integer")
   lat2d = lat2d/100000
   lon2d = lon2d/100000
   lat2d@_FillValue = 14316
   lon2d@_FillValue = 14316
   printMinMax(lat2d, False)
   printMinMax(lon2d, False)

   swe_mam@lat2d = lat2d
   swe_mam@lon2d = lon2d
   printVarSummary(swe_mam)
   
   dump_time = yyyymm_time(1978, 2007, "integer")
   swe_time = dump_time({197811:200705})

   swe_data!0 = "time"
   swe_data!1 = "rows"
   swe_data!2 = "cols"
   swe_data@time = swe_time
   ; swe_data@rows = ispan(1, 721, 1)
   ; swe_data@cols = ispan(1, 721, 1)

   swe_data@lat2d = lat2d
   swe_data@lon2d = lon2d

   swe_data_mask = short2flt(swe_data)
   swe_data_mask = mask(swe_data, swe_data.le.0, False)
   delete(swe_data_mask@_FillValue_original)
   swe_data_mask@_FillValue = 9.96921e+36
   ;printVarSummary(swe_data_mask)

   ; ndims = dimsizes(swe_data)
   ; do i = 0, ndims(0) - 1
   ;   do j = 0, ndims(1) -1 
   ;      do k = 0, ndims(2) - 1
   ;          if (swe_data(i,j,k).lt.0) then
   ;              swe_data_mask(i,j,k) = swe_data@_FillValue
   ;          else
   ;              swe_data_mask(i,j,k) = swe_data(i,j,k)
   ;              end if
   ;      end do
   ;    end do 
   ;  end do
   ;  printVarSummary(swe_data_mask)

    printMinMax(swe_data_mask, 0)

;********************************************************
;res
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   res@cnFillOn = True
   res@cnLinesOn = False
   res@lbLabelBarOn = False
   res@gsnAddCyclic = False
   res@mpFillOn             = False 

   resrc = res
   ; resrc@vpHeightF = 0.6
   ; resrc@vpWidthF  = 0.8
   ; resrc@vpXF      = 0.10 
   ; resrc@vpYF      = 0.75
   ;resrc@gsnAddCyclic = True
   resrc@cnLinesOn = False
   resrc@cnLineLabelsOn = False
   ;resrc@gsnContourNegLineDashPattern = 5
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMinLevelValF = 0
   resrc@cnMaxLevelValF = 200
   resrc@cnLevelSpacingF = 10
   ;resrc@pmLabelBarOrthogonalPosF = 0.12
   resrc@cnInfoLabelOn = False
   ;resrc@cnInfoLabelString = "Dotted Area exceed 99% Sig Level"
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False
   ;resrc@gsnLeftStringFontHeightF = 0.025
   ; resrc@mpMinLonF = 0.
   ; resrc@mpMaxLonF = 150.
   ; resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 0.
   ; resrc@sfXArray     = lon2d
   ; resrc@sfYArray     = lat2d

   resP                 = True                 ; panel resources
   resP@txString        = "SAT:MAM:"+yrstrt/100+"-"+yrlast/100 ; add center string
   resP@gsnPanelLabelBar    = True            ; add common colorbar
   resP@lbLabelAutoStride   = True
   resP@gsnMaximize         = False

;*************************************************************************
;Regrid

    ; Opt                   = True            ; Options for regridding
    ; Opt@InterpMethod      = "patch"
    ; Opt@SrcFileName       = snowpath+"EASE_SWE/regrid/src_grid.nc"  ; Output files
    ; Opt@DstFileName       = snowpath+"EASE_SWE/regrid/des_grid.nc"
    ; Opt@WgtFileName       = snowpath+"EASE_SWE/regrid/wgt_patch.nc"
    ; Opt@ForceOverwrite    = True
    ; Opt@SrcGridMask       = where(.not.ismissing(swe_data(0,:,:)), 1, 0)
    ; Opt@SrcGridLat        = lat2d
    ; Opt@SrcGridLon        = lon2d

    ; Opt@DstGridType       = "0.25deg"       ; Destination grid
    ; Opt@DstTitle          = "Northern Hemisphere 0.25 resolution"
    ; Opt@DstLLCorner       = (/ 0.25d, -179.75d/)
    ; Opt@DstURCorner       = (/89.75d, 179.75d/)

    ; Opt@Debug           = True

    ; ; swe_data_mask@_FillValue = toshort(swe_data_mask@missing_value)

    ; swe_regrid = ESMF_regrid(swe_data(0,:,:),Opt)    ; Regrid 


    ; ; swe_regrid@_FillValue = toshort(swe_regrid@missing_value)

    ; printVarSummary(swe_regrid)
;************************************************************************
;Output

;       rgrd_nc = addfile(snowpath+"/EASE_SWE/swe.ease.mon.nc","c")

; ;---Create variable to hold global file attributes
;       global = True
;       ; copy_VarAtts(snowfile, global)

;         global@TITLE = "Global Monthly EASE-Grid Snow Water Equivalent Climatology " 
;       ; global@remap         = "NCL: ESMF_regrid_with_weights (NCL version '" + \
;       ;                        get_ncl_version() + "')"
;       ; global@remap_method  = Opt@InterpMethod
;       global@creation_date = systemfunc("date")
    
;       fileattdef(rgrd_nc, global )        ; copy global file attributes
;       filedimdef(rgrd_nc,"TIME",-1,True)   ; force an unlimited dimension
; ;
; ; Write variables to file. Coordinate arrays will be written 
; ; automatically
; ;
;       rgrd_nc->swe       = swe_data_mask
      ; rgrd_nc->lon2d     = lon2d
      ; rgrd_nc->lat2d     = lat2d

;************************************************************************
   resrc@trGridType = "TriangularMesh"
   ; resrc@gsnPolar = "NH"

   swe_plot = gsn_csm_contour_map(wks, swe_mam(0,:,:), resrc)
   draw(swe_plot)
   frame(wks)



end
