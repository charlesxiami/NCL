   ;***
   begin
   ;***
   yrstrt =197001
   yrlast =201412

   latS     = 20               
   latN     = 80
   lonL     = 80
   lonR     = 140

   t = ispan(1974, 2009, 1)
   t2 = ispan(1979,2004,1)
   t_ao = ispan(1959, 2006, 1)
   ;**********************************************
   nceppath = "/public/home/charlesxiami/data/ncep/"
   snowpath = "/public/home/charlesxiami/data/snow/"
   indexpath = "/public/home/charlesxiami/data/index/"

   plotpath = "/public/home/charlesxiami/output/"
   wks=gsn_open_wks("pdf", plotpath+"moving_tt")
   gsn_define_colormap(wks, "BlWhRe")
   ;********************************************
   fileair = nceppath+"air.mon.mean.nc"
   airdata = addfile(fileair, "r")

   filesnow = snowpath+"snow.nc"
   snowdata = addfile(filesnow,"r")

   ; mtt5pc = new((/3,dimsizes(t)/), "float")
   ; mtt10pc = new((/3,dimsizes(t2)/), "float")
    mtt5pc = asciiread(indexpath+"mtt5pc1.txt", -1, "float")
    mtt10pc = asciiread(indexpath+"mtt10pc1.txt", -1, "float")
    ;mtt10_ao = asciiread(indexpath+"ao_mam_mtt10.txt", -1, "float")

   ;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   air_mon = airdata->air(iStrt:iLast,:,:)
   air_mam = month_to_season(air_mon, "MAM")
   ;********************************************
   ;Time Series plot
   ;*********
    res           = True
    res@gsnDraw   = False       ; don't draw yet
    res@gsnFrame  = False       ; don't advance frame yet
    res@gsnScale  = False        ; force text scaling                  
    res@vpHeightF = 0.30        ; Changes the aspect ratio
    res@vpWidthF  = 0.80
    res@vpXF      = 0.08        ; change start locations
    res@vpYF      = 0.75        ; the plot   
    res@gsnXYBarChart         = False            ; create bar chart
    res@gsnYRefLineDashPattern = 2
    res@tmYLLabelFontHeightF = 0.015
    res@tmYRLabelsOn = True
    res@tmYUseLeft = False
    res@tmYRMode = "Explicit"
    res@tmYRLabelFontHeightF = 0.014
    res@tmXBLabelFontHeightF = 0.018
    res@gsnLeftStringFontHeightF = 0.018
    res@gsnRightStringFontHeightF = 0.018
    res@xyMarkLineMode = "MarkLines"
    res@xyMarker = 4
    res@tiXAxisString = "Time (year)"
    res@tiYAxisString = "t value"
    res@tiXAxisFontHeightF = 0.02
    res@tiYAxisFontHeightF = 0.02
    ;res@gsnStringFontHeightF = 0.015
    ;res@tmXBLabelConstantSpacingF = 20.  
     res@tmXBMode = "Explicit"
     res@tmXBValues = ispan(1975, 2005, 5)
     res@tmXBLabels = ispan(1975, 2005, 5)
     res@tmXBMinorValues = ispan(1974, 2009, 1)

    resP                 = True                 ; panel resources
    ;resP@txString        = "Moving T-test of PCs"  ; add center string
    ;resP@gsnPanelLabelBar    = True            ; add common colorbar
    ;resP@lbLabelAutoStride   = True
    resP@gsnMaximize         = False
    ;resP@gsnPanelFigureStrings = (/"PC1","PC2","PC3"/)
    resP@gsnPanelFigureStringsFontHeightF = 0.01
    resP@gsnPanelFigureStringsPerimOn = False
    resP@amJust = "TopRight"
    resP@gsnPanelYWhiteSpacePercent = 5
    resP@gsnPanelXWhiteSpacePercent = 5

   mvtt = new(2, "graphic")
;First Panel
;    do n=0,2
;        ;res@tiMainString = "Time Series of PC"+(n+1)
;        res@gsnLeftString = "MovingT-Test of PC"+(n+1)
;        res@gsnRightString = "5 years" 
;        mvtt5(n) = gsn_csm_xy(wks,t,mtt5pc(n,:),res)
;    end do
;    gsn_panel(wks, mvtt5, (/3,1/), resP)

; ;Second Panel
;      res@gsnYRefLine = (/-2.88,-2.10,-1.73,1.73,2.10,2.88/) ;reference line
;      res@tmYRValues = (/-2.88,-2.10,-1.73,2.88,2.10,1.73/)
;      res@tmYRLabels = (/"99%","95%","90%","99%","95%","90%"/)
;    do n=0,2
;        ;res@tiMainString = "Time Series of PC"+(n+1)
;        res@gsnLeftString = "MovingT-Test of PC"+(n+1)
;        res@gsnRightString = "10 years" 
;        mvtt10(n) = gsn_csm_xy(wks,t2,mtt10pc(n,:),res)
;    end do
;    gsn_panel(wks, mvtt10, (/3,1/), resP)

     res@gsnYRefLine    = (/-3.36,-2.31,-1.86,3.36,2.31,1.86/) ;reference line
     res@tmYRValues = (/-2.31,-1.86,1.86,2.31/)
     res@tmYRLabels = (/"95%","90%","90%","95%"/)
     res@gsnLeftString = "Moving T-Test"
     res@gsnRightString = " "
     mvtt5 = gsn_csm_xy(wks,t,mtt5pc,res)
     ; draw(mvtt5)
     ; frame(wks)

     res@gsnYRefLine = (/-2.88,-2.10,-1.73,1.73,2.10,2.88/) ;reference line
     res@tmYRValues = (/-2.10,-1.73,1.73,2.10/)
     res@tmYRLabels = (/"95%","90%","90%","95%"/)
     res@gsnLeftString = "Moving T-Test"
     res@gsnRightString = " " 
     mvtt10 = gsn_csm_xy(wks,t2,mtt10pc,res)
     ; draw(mvtt10)
     ; frame(wks)

     mvtt(0) = mvtt5
     mvtt(1) = mvtt10
     gsn_panel(wks, mvtt, (/2,1/), resP)





   end
