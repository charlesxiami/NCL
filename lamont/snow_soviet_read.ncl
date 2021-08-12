
begin

   yrstrt = 197201
   yrlast = 199512
   ; nyrs = yrlast/100 - yrstrt/100 + 1

   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"
   plotpath = "$HOME/output/"

   snowdata = addfile(snowpath+"snow.rutger.2.0deg.nc","r")
   snow_mon = snowdata->snowcover(:,:,:)

   wks = gsn_open_wks("pdf", plotpath+"snow_fsu_test")
   gsn_define_colormap(wks, "cmp_b2r")

;read ascii soviet snow 
   snow_path = "$HOME/data/snow/fsu/"

   FASC = "snow_soviet_2.asc"
   ; nrows = numAsciiRow(snow_path+FASC)   ; contributed.ncl
   ; ncols = numAsciiCol(snow_path+FASC)
   ; data  = asciiread(snow_path+FASC,(/nrows,ncols/),"float")
   nrows = 11928568
   ncols = 9
   data  = asciiread(snow_path+FASC,(/nrows,ncols/),"float")

   nstation = 284
   nday = 42002
   data_reshape = reshape(data, (/nstation,nday,9/))
   
   ndim = dimsizes(data_reshape)
   n0 = ndim(0)
   
   snow_station_daily = new((/nstation,nday/), float)

   do i = 0, nstation -1
      do j = 0, nday -1
         if (data_reshape(i,j,5).eq.0) then
            if (data_reshape(i,j,4).eq.1.and.data_reshape(i,j,3).eq.0) then
               snow_station_daily(i,j) = data_reshape(i,j,4)*100
            else 
                snow_station_daily(i,j) = data_reshape(i,j,3)*10
            end if
         else if (data_reshape(i,j,5).eq.2) then
            snow_station_daily(i,j) = data_reshape(i,j,3)*10
         else 
            snow_station_daily(i,j) = default_fillvalue("float")
         end if
        end if
      end do
   end do 
   
   snow_station_daily!0 = "station"
   snow_station_daily!1 = "time"

   day_time = yyyymmdd_time(1881, 1995, "integer")
   day_time!0 = "time"
   day_time@long_name = "time"
   day_time@units = "days"

   yyyy  = day_time/10000 
   mmdd  = day_time-yyyy*10000                ; mmdd = yyyymmdd%10000
   mm    = mmdd/100
   dd    = mmdd-mm*100                        ; dd   = mmdd%100
   hh    = dd                                 ; create arrays [*] of required size
   mn    = dd
   sc    = dd
   hh    = 0                                  ; array syntax
   mn    = 0
   sc    = 0
   units  = "hours since 1900-01-01 00:00:00" ; "seconds/hours/days since ...."
                                             ; do NOT use "months since ...."
   time   = cd_inv_calendar(yyyy,mm,dd,hh,mn,sc,units, 0)
   time!0 = "time"

   snow_station_daily&time = time
   ; printVarSummary(snow_station_daily)

   snow_station_monthly = calculate_monthly_values(snow_station_daily(time|:,station|:), "avg", 0, False)
   ; printVarSummary(snow_station_monthly)

  ;read WMO stations
   wmo_station = asciiread("$HOME/data/snow/soviet_snow_depth/wmo_station.txt", -1, "string")

   slat = stringtofloat(str_get_field(wmo_station, 2, ","))
   slon = stringtofloat(str_get_field(wmo_station, 3, ","))

  ;Interpolation
   zlat  = slat
   zlon = slon
   z = snow_station_monthly
   glon = snow_mon&lon
   glat = snow_mon&lat
   rscan = (/10, 5, 3/)
   ; print(glon)
  
   snow_grid_month = obj_anal_ic_Wrap(zlon, zlat, z, glon, glat, rscan, False)
   printVarSummary(snow_grid_month)
   ; snow_grid_daily = obj_anal_ic_Wrap(zlon, zlat, snow_station_daily, glon, glat, rscan, False)

   yyyymm1 = cd_calendar(snow_grid_month&time, 1)
   ; print(yyyymm1(0:23))
   iyear1 = ind(yyyymm1.ge.yrstrt.and.yyyymm1.le.yrlast)

   yyyymm2 = cd_calendar(snowdata->time, 1)
   iyear2 = ind(yyyymm2.ge.yrstrt.and.yyyymm2.le.yrlast)

   season = "MAM"
   snow_grid_sea = month_to_season(snow_grid_month(iyear1,:,:), season)
   snow_rutger_sea = month_to_season(snow_mon(iyear2,:,:), season)
   
   snow_grid_avg = dim_avg_n_Wrap(snow_grid_sea, 0)
   snow_rutger_avg = dim_avg_n_Wrap(snow_rutger_sea, 0)

   printMinMax(snow_grid_avg, 0)
   printMinMax(snow_rutger_avg, 0)

;Res
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
   resrc@mpMaxLonF = 180
   resrc@mpMaxLatF = 90
   resrc@mpMinLatF = 10
   resrc@mpCenterLonF = (resrc@mpMinLonF+resrc@mpMaxLonF)/2.
   resrc@mpAreaMaskingOn = True
   resrc@mpOceanFillColor = "white"
   resrc@mpLandFillColor = "Transparent"
   ; resrc@mpMaskAreaSpecifiers =(/"China","Taiwan"/)

;Plot
   resrc@cnMaxLevelValF = 100
   resrc@cnMinLevelValF = 10
   resrc@cnLevelSpacingF = 10

   plot = gsn_csm_contour_map(wks, snow_grid_avg, resrc)
   draw(plot)
   frame(wks)

   plot2 = gsn_csm_contour_map(wks, snow_rutger_avg, resrc)
   draw(plot2)
   frame(wks)


;Output nc

   fname = "snow.fsu.monthly.nc"
   system("/bin/rm -f "+ snowpath+fname )
   ncdf = addfile(snowpath+fname ,"c")
   ; ncdf2 = addfile(snowpath"snow.fsu.daily.nc" ,"c")

       fAtt               = True            ; assign file attributes
       fAtt@process  = "Processed by Min Wang"
       fAtt@source   =  "Historical Soviet Daily Snow Depth (HSDSD), Version 2"
       fAtt@title    = "Former Soviet Snow Cover"
       ; fAtt@creation_date = systemfunc ("date")
       fileattdef( ncdf, fAtt )            ; copy file attributes
       ; fileattdef( ncdf2, fAtt )            ; copy file attributes

   ncdf->snow = snow_grid_month


end