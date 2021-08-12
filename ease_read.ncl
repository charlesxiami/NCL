load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

    WRITE_RESULTS = True 

;----------------------------------------------------------------------
   snow_ease  = "/public/home/charlesxiami/data/snow/EASE2_N25km.snowice/"
   plotpath  = "/public/home/charlesxiami/output/"

   wks=gsn_open_wks("pdf", plotpath+"ease_snow")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;----------------------------------------------------------------------
   ease_list = systemfunc("ls "+snow_ease+"*.bin")
   printVarSummary(ease_list)
   print(ease_list(0))
   
   ;setfileoption("bin", "ReadByteOrder", "BigEndian")
   rec_num = 0
   rec_dims = (/720,720/)
   rec_type = "ubyte"

   lat_name = "EASE2_N25km.lats.720x720x1.double"
   lon_name = "EASE2_N25km.lons.720x720x1.double"
   lat_ease = fbindirread(snow_ease+lat_name, rec_num, rec_dims, "double")
   lon_ease = fbindirread(snow_ease+lon_name, rec_num, rec_dims, "double")
   print(min(lon_ease)+"  "+max(lon_ease))
   print(min(lat_ease)+"  "+max(lat_ease))

   s = new((/dimsizes(ease_list),720,720/), "integer")
   do i = 0, dimsizes(ease_list)-1
     s(i,:,:) = fbindirread(ease_list(i), rec_num, rec_dims, rec_type)
   end do
   do i = 0, dimsizes(ease_list)-1
    do j = 0,719
      do k= 0,719
     if (s(i,j,k).lt.0.or.s(i,j,k).gt.1) then
       s(i,j,k) = -999
     end if
   end do
   end do
   end do

   s!0 = "time"
   s!1 = "y"
   s!2 = "x"
   s@lon2d = lon_ease
   s@lat2d = lat_ease
   s@_FillValue = -999
   printVarSummary(s)
   print(s(2000,540,540))
   print(min(s)+" --- "+max(s))

;Plot Test EASE2 SCE Data
;----------------------------------------------------------------------
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   res@cnLinesOn = False
   res@cnFillOn = True
   res@cnFillMode = "RasterFill"
   res@trGridType = "TriangularMesh"
   res@cnLevelSelectionMode= "ExplicitLevels" ; set explicit contour levels
   ;res@cnLevels  = (/0,1,2,3,4,5,253,254,255/)
   res@cnLevels  = (/0.5,1.5/)
   res@cnFillColors = (/122,50,122/)

   res@gsnPolar = "NH"
   res@mpMinLatF = 0.

   ;snow_clim = dim_avg_n_Wrap(s, 0)

   plot = gsn_csm_contour_map_polar(wks, s(13,:,:), res)
   draw(plot)
   frame(wks)

   ; plot = gsn_csm_contour(wks, s(0,:,:), res)
   ; draw(plot)
   ; frame(wks)


; Write the regridded variable to a file using the "inefficient" method.
;----------------------------------------------------------------------
;     if(WRITE_RESULTS) then
;       rgrdFileName = snow_ease+"snow.rutger."+Opt@DstGridType+"."+Opt@InterpMethod+".nc"
;       system("rm -f " + rgrdFileName)
;       rgrd_nc = addfile(rgrdFileName,"c")

; ;---Create variable to hold global file attributes
;       global = True
;       copy_VarAtts(snowfile, global)

;       if (isatt(snowfile,"title")) then
;         global@TITLE = "REMAPPED: " + snowfile@title
;       end if
;       global@remap         = "NCL: ESMF_regrid_with_weights (NCL version '" + \
;                              get_ncl_version() + "')"
;       global@remap_method  = Opt@InterpMethod
;       global@creation_date = systemfunc("date")
    
;       fileattdef(rgrd_nc, global )        ; copy global file attributes
;       filedimdef(rgrd_nc,"TIME",-1,True)   ; force an unlimited dimension
; ;
; ; Write variables to file. Coordinate arrays will be written 
; ; automatically
; ;
;       rgrd_nc->snowcover       = sce_regrid
;       ;rgrd_nc->DEPTHedges = snowfile->DEPTHedges

    ; end if


end