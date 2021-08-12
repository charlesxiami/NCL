begin
;
  yrstrt =195001
  yrlast =200012
  latS  = -90
  latN  = 90
  lonL  = 0
  lonR  = 360
  cd = "/public/home/charlesxiami/data/ncep/"
  plotpath = "/public/home/charlesxiami/output/"
  wks=gsn_open_wks("pdf", plotpath+"NAO_eof")
  gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;************************************************
;Data read
;************************************************
   filesnow = "/public/home/charlesxiami/data/snow/snow.nc"
   snowdata = addfile(filesnow,"r")
   airdata = addfile(cd+"air.mon.mean.nc", "r")
   slpdata = addfile(cd+"slp.mon.mean.nc", "r")
   hgtdata = addfile(cd+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(cd+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(cd+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(cd+"nswrs.sfc.mon.mean.nc", "r")
   sstdata = addfile(cd+"sst.mnmean.v4.nc", "r")

   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   air_mon =  airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR})
   air_mam =  month_to_season(air_mon, "MAM")

   slp_mon = slpdata->slp(iStrt:iLast,{latS:latN},{lonL:lonR})
   slp_mam = month_to_season(slp_mon, "MAM")

   u_mon = uwnddata->uwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   u_mam = month_to_season(u_mon, "MAM")
   v_mon = vwnddata->vwnd(iStrt:iLast,{850},{latS:latN},{lonL:lonR}) 
   v_mam = month_to_season(v_mon, "MAM")

   z500_mon = hgtdata->hgt(iStrt:iLast,{500},{latS:latN},{lonL:lonR})
   z500_djf = month_to_season(z500_mon, "MAM")
   z500_mam = month_to_season(z500_mon, "MAM")
   x = z500_djf({lat|0:90},{lon|lonL:lonR},time|:)
   ;x = z500_mon({lat|0:90},{lon|lonL:lonR},time|:)
   ;printVarSummary(x)
   
   ;Read NAO index
   indexpath = "/public/home/charlesxiami/data/index/"
   tele_index = asciiread(indexpath+"tele_index.nh.txt", -1, "string")
   nfields = str_fields_count(tele_index(19), " ")
   print("number of fields = " + nfields)
   nao_index = stringtofloat(str_get_field(tele_index(19::), 3, " "))
   printVarSummary(nao_index)

   print(nao_index(0:13))
   nao_mam = new((/67/), float)    ; 1950mam-2016mam
   nao_djf = new((/67/), "float")  ; 1950/51djf-2016/17djf
   do i = 0, 66
     nao_mam(i) = dim_avg(nao_index(i*12+2:i*12+4))
     nao_djf(i) = dim_avg(nao_index(i*12+11:i*12+13))
   end do

;************************************************
;EOF analysis
;************************************************
     neof = 3
     optEOF = True
     optEOF@jopt = 0
     optETS = False
     eof    = eofunc_Wrap(x,neof,optEOF)
     eof_ts = eofunc_ts_Wrap(x,eof,optETS)
     eof_ts = dim_standardize_Wrap(eof_ts, 0)
     printVarSummary(eof)
     ;North significance test: Note any of the following could be used
     dimp   = dimsizes(z500_djf)
     ntim   = dimp(0)
     prinfo = True
     sig_ev  = eofunc_north(eof@eval, ntim, prinfo)
     sig_pcv = eofunc_north(eof@pcvar, ntim, prinfo)
     sig_evt = eofunc_north(eof@eval_transpose, ntim, prinfo)
     ;print(eof_ts)

; Res Settings
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   res@cnFillOn = True
   res@cnLinesOn = False
   res@lbLabelBarOn = False
   res@gsnAddCyclic = False
   res@mpFillOn             = False        ; turn off map fill
   res@mpOutlineOn          = True
   res@mpMinLatF            = 0         ; zoom in on map
   res@mpMaxLatF            = latN
   res@mpMinLonF            = lonL
   res@mpMaxLonF            = lonR
   res@mpCenterLonF = 180
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF = -0.030
   res@cnMaxLevelValF = 0.030
   res@cnLevelSpacingF = 0.005

   respolar = True
   respolar@gsnDraw = False
   respolar@gsnFrame = False
   respolar@gsnPolar = "NH"
   respolar@cnFillOn = True
   respolar@cnLinesOn = False
   respolar@lbLabelBarOn = False
   respolar@cnLevelSelectionMode = "ManualLevels"
   respolar@cnMinLevelValF = -0.030
   respolar@cnMaxLevelValF = 0.030
   respolar@cnLevelSpacingF = 0.005

   resP                 = True                 ; panel resources
   ;resP@txString        = "SAT:MAM:1970-2014"  ; add center string
   resP@gsnPanelLabelBar    = True            ; add common colorbar
   resP@lbLabelAutoStride   = True
   resP@gsnMaximize         = False
   ;resP@gsnPanelYF = (/-1,.68,.30/) 

;*******************************************
; Draw plot
  plot = new(neof, "graphic")
  do n = 0, neof-1
    res@gsnLeftString  = "EOF "+(n+1)
    res@gsnRightString = sprintf("%5.1f", eof@pcvar(n))+"%"
    plot(n) = gsn_csm_contour_map(wks, eof(n,:,:), res)
  end do
  gsn_panel(wks,plot,(/neof,1/),resP)
  ;*******************************************
  ; second plot
  ;*******************************************
  ; EOF time series  [bar form]
  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling
  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot
  rts@tiYAxisString = "gpm"                    ; y-axis label
  rts@gsnYRefLine           = 0.              ; reference line
  rts@gsnXYBarChart         = True            ; create bar chart
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
; panel plot only resources
  rtsP                      = True            ; modify the panel plot
  rtsP@gsnMaximize          = True            ; large format
  rtsP@txString             = "Z500: "+"DJF"+": "+yrstrt+"-"+yrlast
  year = ispan(yrstrt/100,yrlast/100,1)
; create individual plots
  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,year,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)     ; now draw as one plot

; Polar plot
do n = 0, neof-1
  respolar@gsnLeftString  = "EOF "+(n+1)
  respolar@gsnRightString = sprintf("%5.1f", eof@pcvar(n))+"%"
  plot(n) = gsn_csm_contour_map_polar(wks, eof(n,:,:), respolar)
end do
gsn_panel(wks,plot,(/neof,1/),resP)



end
