   ;***
   begin
   ;***
   yrstrt =197001
   yrlast =201412

   latS     = 20               
   latN     = 80
   lonL     = 80
   lonR     = 140

   t = ispan(1970, 2014, 1)
   nyrs = dimsizes(t)
   ;**********************************************
   cd = "/mnt/f/Data/Original/ncep/"
   plotpath = "/mnt/f/Pic/work1/NCL_pic/"

   fileair = cd+"air.mon.mean.nc"
   airdata = addfile(fileair, "r")

   filesnow = "/mnt/f/Data/Original/snowcover/snow.nc"
   snowdata = addfile(filesnow,"r")

   pc = new((/3,45/), "float")
   do n= 0,2
   pc(n,:) = asciiread(plotpath+"pc"+(n+1)+".txt", -1, "float")
   end do
   printVarSummary(pc)
   ;***************************************
   YYYYMM = cd_calendar( airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   air_mon = airdata->air(iStrt:iLast,:,:)
   air_mam = month_to_season(air_mon, "MAM")

   ;********************************************
   ; Filter 
   ;********************************************
    pc_hf = pc
    pc_hf2 = pc
    yreg = pc
    trd = new(3, "float")

    nwt= 5
    ihp = 1
    fca = 1.0/10.0
    fcb= -999
    nsigma = 1.
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    do n=0,2
        pc_hf(n,:) = wgt_runave_Wrap(pc(n,:), wgt, 0)

        nwt = 3
        wgt2 = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)
        pc_hf2(n,:) = wgt_runave_Wrap(pc(n,:), wgt2, 0)    

        pc_hf(n,1) = pc_hf2(n,1)
        pc_hf(n,43) = pc_hf2(n,43)
       
        trend = regline(t, pc(n,:))
        trd(n) = trend
        yreg(n,:) = t*trend + trend@yintercept

    end do 

    print(trd)
    printVarSummary(yreg)
   ;********************************************
   ;********************************************
   plotpath = "/mnt/f/Pic/work1/NCL_pic/"
   wks=gsn_open_wks("pdf", plotpath+"pc_filter_array")
   gsn_define_colormap(wks, "BlWhRe")
   ;********************************************
   ;Time Series plot
   ;*********
   rts           = True
   rts@gsnDraw   = False       ; don't draw yet
   rts@gsnFrame  = False       ; don't advance frame yet
   rts@gsnScale  = False        ; force text scaling               

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot


  rts@tiYAxisString = "degC"                    ; y-axis label
  

  rts@gsnYRefLine           = 0.              ; reference line
  rts@gsnXYBarChart         = True            ; create bar chart
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

  ; rtsP                     = True             ; modify the panel plot
  ; rtsP@gsnMaximize         = False             ; large format
  ; rts@gsnLeftString  = "PC 1"
   
   do n=0,2
       ;rts@tiMainString = "Time Series of PC"+(n+1)
       rts@gsnLeftString = "PC"+(n+1)
       rts@gsnRightString = "Trend ="+trd(n)+"/year" 
       ts = gsn_csm_xy(wks,t,pc(n,:),rts)
    
       rts2 = True
       rts2 = rts
       rts2@gsnXYBarChart = False
       rts2@xyDashPattern         = 5
       rts2@xyLineThicknessF      = 2.
       rts2@xyLineColor = "black"
       delete(rts2@gsnYRefLine)
       delete(rts2@gsnAboveYRefLineColor)
       delete(rts2@gsnBelowYRefLineColor)
       ts2 = gsn_csm_xy(wks, t, pc_hf(n,:),rts2)
    
       delete(rts2@xyDashPattern)
       rts2@xyLineColor = "chartreuse4"
       rts2@xyLineThicknessF      = 4.
       trnd = gsn_csm_xy(wks, t, yreg(n,:), rts2)

       overlay(ts, trnd)
       overlay(ts, ts2)
       draw(ts)
       frame(wks)
       
       ;asciiwrite(plotpath+"pc_hf"+(n+1)+".txt", pc_hf(n,:))
   end do


   ;********************************************
   end
