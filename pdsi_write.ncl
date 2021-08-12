;***
   begin
;***
   yrstrt = 187001
   yrlast = 201712

   latS = -90
   latN = 90
   lonL = 0
   lonR = 360

   cn_northN = 42
   cn_northS = 35
   cn_northL = 110
   cn_northR = 120

   t = ispan(yrstrt/100, yrlast/100, 1)

;*********************************************** 
   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/sce/"
   indexpath = "$HOME/data/index/"
   plotpath = "$HOME/output/"
   precpath = "$HOME/data/precip/PREC/"
;********************************************
   wks_type          = "pdf"
   ;wks_type@wkOrientation = "landscape"
   ; wks_type@wkPaperHeightF = 11
   ; wks_type@wkPaperWidthF  = 8.5
   wks_type@wkPaperSize = "A4"

   wks = gsn_open_wks(wks_type, plotpath+"pdsi_write")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
   gsn_reverse_colormap(wks)
;************************************************
   sstdata = addfile(nceppath+"sst.mnmean.nc", "r")

   pdsi_table = readAsciiTable(indexpath+"pdsipm_ob.txt", 520, "float", (/0,0/))
   pdsi_table!0 = "time"
   pdsi_table!1 = "station"

   ; pdsi_time = yyyymmdd_time(1962, 2013, "float")
   ; pdsi_time!0 = "time"
   ; pdsi_time@long_name = "time"
   ; pdsi_time@units = "month"
   ; pdsi_table&time = pdsi_time
   
   ; pdsi_station = asciiread(indexpath+"pdsi_china_station.txt", -1, "float")

   cn_station_table = asciiread(indexpath+"station.csv", -1, "string")
   cn_part = str_get_field(cn_station_table, 4, ",")
   ndim = dimsizes(cn_part)
   cn_lon = stringtofloat(cn_part(1:ndim-1))
   cn_part = str_get_field(cn_station_table, 5, ",")
   cn_lat = stringtofloat(cn_part(1:ndim-1))
  
   glon = tofloat(ispan(tointeger(min(cn_lon)), tointeger(max(cn_lon))+1, 1))
   glon!0 = "lon"
   glon@long_name = "longitude"
   glon@units = "degrees_east"

   glat = tofloat(ispan(tointeger(min(cn_lat)), tointeger(max(cn_lat))+1, 1))
   glat!0 = "lat"
   glat@long_name = "latitude"
   glat@units = "degrees_north"

   rscan = (/10,5,3/)
   option = False
   pdsi_latlon = obj_anal_ic_Wrap(cn_lon, cn_lat, pdsi_table, \
                                        glon, glat, rscan, option)

   month_time = yyyymm_time(1962, 2013, "integer")
   month_time!0 = "time"
   month_time@long_name = "time"
   month_time@units = "month"

   pdsi_latlon&time = month_time

   ; Write the regridded variable to a file using the "inefficient" method.
;----------------------------------------------------------------------
      rgrdFileName = "$HOME/data/pdsi/pdsi.mon.nc"
      system("rm -f " + rgrdFileName)
      rgrd_nc = addfile(rgrdFileName,"c")

;---Create variable to hold global file attributes
      global = True

      global@TITLE = "REMAPPED: PDSI INDEX from 520 Station in China"
      global@creation_date = systemfunc("date")
    
      ; fileattdef(rgrd_nc, global )        ; copy global file attributes
      fileattdef(rgrd_nc, global)
      dim_names = (/"lon", "lat", "time"/)
      dim_sizes = (/dimsizes(glon), dimsizes(glat), dimsizes(month_time)/)
      dim_unlimited = (/False, False, True/)
      filedimdef(rgrd_nc, dim_names, dim_sizes, dim_unlimited)
;
; Write variables to file. Coordinate arrays will be written 
; automatically
;
      rgrd_nc->pdsi  = pdsi_latlon
      ; rgrd_nc->lon   = glon
      ; rgrd_nc->lat   = glat
      rgrd_nc->time  = month_time
;----------------------------------------------------------------------


   system("date")
   
end
