load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***
  begin
;***
   yrstrt = 196701   ;P1+P2
   yrlast = 201412

   ; yrstrt = 196701   ;P1
   ; yrlast = 198812

   ; yrstrt = 198901  ;P2
   ; yrlast = 201412

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  year=ispan(yrstrt_snow/100, yrlast_snow/100, 1)

;---------------W,E-index Region
  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   nceppath = "/public/home/charlesxiami/data/ncep/"
   snowpath = "/public/home/charlesxiami/data/snow/"
   indexpath = "/public/home/charlesxiami/data/index/"
   binpath = "/public/home/charlesxiami/data/binary/"

   plotpath = "/public/home/charlesxiami/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"mk")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.nc", "r")

   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
   soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")
   snowdata = addfile(snowpath+"snow.rutger.2.0deg.nc","r")


 ;*****************************************************************************************
   t_index = ispan(1950, 2017, 1)
   iStrt0 = ind(t_index.eq.yrstrt/100)
   iLast0 = ind(t_index.eq.yrlast/100)

   ;Nao 195001-201806
   nao_index = asciiread(indexpath+"norm.nao.monthly.b5001.current.ascii.txt", -1, "string")
   nao_mon = stringtofloat(str_get_field(nao_index, 3, " "))
   nao_djf_long = new((/67/), float)  ; nao_djf: 1950/51DJF-2016/7DJF
   nao_mam_long = new((/67/), float)  ; nao_mam: 1950MAM-2016MAM
   do i = 0,66
    nao_djf_long(i) = dim_avg_Wrap(nao_mon(i*12+11:i*12+13))
   end do 
   do i = 0,66
    nao_mam_long(i) = dim_avg_Wrap(nao_mon(i*12+2:i*12+4))
   end do
   nao_mam = nao_mam_long(iStrt0:iLast0)

   mk = fbindirread(binpath+"mk.grd", 0, (/48,4/), "float")
   printVarSummary(mk)
   uf = new(48, float)
   ub = new(48, float)
   uf = mk(:,0)
   ub = mk(:,1)
   ; uf = fbindirread(binpath+"mk.grd", 0, 48, "float")
   ; ub = fbindirread(binpath+"mk.grd", 1, 48, "float")

   print(uf)
   print(ub)

;**********************************************************
;Time Series plot
  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               
  rts@vpHeightF = 0.35        ; Changes the aspect ratio
  rts@vpWidthF  = 0.80
  rts@vpXF      = 0.15        ; change start locations
  rts@vpYF      = 0.75        ; the plot 
  rts@gsnLeftStringFontHeightF = 0.025
  rts@tmYLLabelFontHeightF = 0.015
  rts@tmYLLabelFontHeightF = 0.015

  rts_bar = rts  ; Bar Chart
  rts_bar@gsnXYBarChart         = True
  rts_bar@gsnYRefLine = 0.
  ;rts_bar@gsnLeftString = "(b) PC1"
  ;rts_bar@tmXUseBottom = True
  rts_bar@tmXBMode = "Explicit"
  ; rts_bar@tmXBValues = ispan(1975, 2005, 5)
  ; rts_bar@tmXBLabels = ispan(1975, 2005, 5)
  ; rts_bar@tmXBMinorValues = ispan(1972, 2009, 1)
  rts_bar@tmXTOn = False
  rts_bar@tmYROn = False
  rts_bar@tiXAxisString = "Time (Year)"
  rts_bar@tiYAxisString = " "
  rts_bar@tiXAxisFontHeightF = 0.02
  rts_bar@tiYAxisFontHeightF = 0.02
  ; rts_bar@trXMinF = 1971.5
  ; rts_bar@trXMaxF = 2009.5
  rts_bar@trYMinF = -3.0
  rts_bar@trYMaxF = -1*rts_bar@trYMinF
  rts_bar@gsnXYBarChartBarWidth = 0.66
  rts_bar@gsnAboveYRefLineColor = "red"
  rts_bar@gsnBelowYRefLineColor = "blue"

  rts_line = rts   ; Line
  rts_line@xyDashPattern         = 1
  rts_line@xyLineThicknessF      = 4.
  rts_line@xyLineColor = "black"
  rts_line@trYMinF = -4
  rts_line@trYMaxF = -1*rts_line@trYMinF

  rtsP = True
  rtsP@lbLabelAutoStride = True


  puf = gsn_csm_xy(wks, year, uf, rts_line)
  pub = gsn_csm_xy(wks, year, ub, rts_line)
  overlay(puf, pub)
  draw(puf)
  frame(wks)

  
  ; plots = new(2, graphic)
  ; plots(0) = snowplot
  ; plots(1) = pbar
  ; gsn_panel(wks, plots, (/2,1/), resP)
  
  ; draw(pbar)
  ; frame(wks)



end
