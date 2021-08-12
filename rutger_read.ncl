begin
   snowpath  = "/public/home/charlesxiami/data/snow/"
   plotpath  = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"

  latS   =  40
  latN   =  80
  lonL   =  80
  lonR   =  150

  WlatS = 48
  WlatN = 58
  WlonL = 25
  WlonR = 50
  
  ElatS = 60
  ElatN = 70
  ElonL = 100
  ElonR = 125

   ; LatS_eof = 

   yrstrt =196701
   yrlast =200712

   sig = 0.320   ;95%
   ; sig1 = 0.497
   ; sig2 = 0.433
;*****************************************************
;I/O
;*****************************************************
   ; wks=gsn_open_wks("pdf", plotpath+"snow_eof")
   ; gsn_define_colormap(wks, "BlAqGrYeOrRe")

   snow_file = addfile(snowpath+"RutgersSnow.mon.mean.nc", "r")
   pc1_all = asciiread(indexpath+"pc1.txt", -1, "float")
   ;print(snow_file->lon)

   YYYYMM = cd_calendar(snow_file->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print(YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   snow_mon = snow_file->snowcover(iStrt:iLast,:,:)
   snow_mam = month_to_season(snow_mon, "MAM")

   lat2d = snow_file->lat
   lon2d = snow_file->lon
   ; asciiwrite(indexpath+"lat2d_NCDC.txt", lat2d)
   ; asciiwrite(indexpath+"lon2d_NCDC.txt", lon2d)
   printMinMax(lat2d, 0)
   printMinMax(lon2d, 0)

   ; yx =  region_ind(lat2d, lon2d, ElatS, ElatN, ElonL, ElonR)
   ; yStrt = yx(0)
   ; yLast = yx(1)
   ; xStrt = yx(2)
   ; xLast = yx(3)

   ; lat2d_new = lat2d(yStrt:yLast,xStrt:xLast)
   ; lon2d_new = lon2d(yStrt:yLast,xStrt:xLast)


   Elat = (/ElatS,ElatN/)
   Elon = (/ElonL,ElonR/)

   nm = getind_latlon2d(lat2d, lon2d, Elat, Elon)
   print(nm)
  do k=0,dimsizes(Elat)-1
     n = nm(k,0)
     m = nm(k,1)
     print(lat2d(n,m)+"   "+lon2d(n,m))
  end do
   jStrt = nm(0,0)
   jLast = nm(1,0)
   iStrt = nm(0,1)
   iLast = nm(1,1)

   lat2d_new = lat2d(jStrt:jLast,iStrt:iLast)
   lon2d_new = lon2d(jStrt:jLast,iStrt:iLast)
   printMinMax(lat2d_new, 0)
   printMinMax(lon2d_new, 0)
;*************************************************
;Res
;*************************************************


end