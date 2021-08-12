  begin
;*******************************************
  latS  = -90
  latN  = 90
  lonL  = 0
  lonR  = 360

  sstLonL = 120
  sstLonR = 270
  sstLatS = -20
  sstLatN = 20

  ZLonL = 0
  ZLonR = 360
  ZLatS = 20
  ZLatN = 90

  yrstrt =194801
  yrlast =201412
  ;year=ispan(1972, 2009, 1)

  sig1 = 0.497   ; %95
  sig2 = 0.433   ; %95

   nceppath  = "/public/home/charlesxiami/data/ncep/"
   plotpath  = "/public/home/charlesxiami/output/"
   indexpath = "/public/home/charlesxiami/data/index/"

   wks=gsn_open_wks("pdf", plotpath+"SVD")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;************************************************
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
  uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
  vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.v4.nc", "r")
 soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")

   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata  = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata  = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print(YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt)
   iLast2  = ind(YYYYMM2.eq.yrlast)
   print(YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))
;********************************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR})
   air_mam = month_to_season(air_mon, "MAM")
   
   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR})
   slp_mam = month_to_season(slp_mon, "MAM")
   
   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR}) 
   z500_mam = month_to_season(z500_mon, "MAM")

   z200_mon = hgtdata->hgt(iStrt:iLast,{200},{latS:latN},{lonL:lonR}) 
   z200_mam = month_to_season(z200_mon, "MAM")

   sst_mon = sstdata->sst(iStrt2:iLast2,{latS:latN},{lonL:lonR})
   sst_mam = month_to_season(sst_mon, "MAM")
;**********************************************************
   x = sst_mam(:,{sstLatS:sstLatN},{sstLonL:sstLonR})
   y = z500_mam(:,{ZLatS:ZLatN},{ZLonL:ZLonR})
   dimX = dimsizes(x)
   dimY = dimsizes(y)

   ntime = dimX(0)
   ncols = dimX(1)*dimX(2)
   ncolz = dimY(1)*dimY(2)
   nsvd  = 3

   x1d = ndtooned(x)
   x2d = onedtond(x1d, (/ncols, dimX(0)/))

   y1d = ndtooned(y)
   y2d = onedtond(y1d, (/ncolz, dimY(0)/))

   homlft = new((/nsvd,ncols/),float)
   hetlft = new((/nsvd,ncols/),float)
   homrgt = new((/nsvd,ncolz/),float)
   hetrgt = new((/nsvd,ncolz/),float)

   sst_z500_svd = svdstd(x2d, y2d, nsvd, homlft, hetlft, homrgt, hetrgt)
   print(sst_z500_svd)



   end