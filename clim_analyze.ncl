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
   printVarSummary(t)
   ;**********************************************
   cd = "/mnt/f/Data/Original/ncep/"
   plotpath = "/mnt/f/Pic/work1/NCL_pic/"

   fileair = cd+"air.mon.mean.nc"
   airdata = addfile(fileair, "r")

   filesnow = "/mnt/f/Data/Original/snowcover/snow.nc"
   snowdata = addfile(filesnow,"r")

   mtt5pc = new((/3,dimsizes(t)/), "float")
   mtt10pc = new((/3,dimsizes(t2)/), "float")
   mtt10pc_hf = new((/3,dimsizes(t2)/), "float")
   do n= 0,2
   mtt5pc(n,:) = asciiread(plotpath+"mtt5pc"+(n+1)+".txt", -1, "float")
   mtt10pc(n,:) = asciiread(plotpath+"mtt10pc"+(n+1)+".txt", -1, "float")
   mtt10pc_hf(n,:) = asciiread(plotpath+"mtt10pc_hf"+(n+1)+".txt", -1, "float")
   end do
   printVarSummary(mtt10pc_hf)

   Ai = asciiread(plotpath+"Ai.txt", -1, float)
   Bi = asciiread(plotpath+"Bi.txt", -1, float)
   ;***************************************
   YYYYMM = cd_calendar( airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   air_mon = airdata->air(iStrt:iLast,:,:)
   air_mam = month_to_season(air_mon, "MAM")

   ;********************************************
   ; Filter 
   ;********************************************
   ;********************************************
   plotpath = "/mnt/f/Pic/work1/NCL_pic/"
   wks=gsn_open_wks("pdf", plotpath+"ClimAnalyze")
   gsn_define_colormap(wks, "BlWhRe")
   ;********************************************
   ;Time Series plot
   ;*********
      res           = True
      res@gsnDraw   = False       ; don't draw yet
      res@gsnFrame  = False       ; don't advance frame yet
      res@gsnScale  = False        ; force text scaling                  

   ; these four resources allow the user to stretch the plot size, and
   ; decide exactly where on the page to draw it.   

     res@vpHeightF = 0.30        ; Changes the aspect ratio
     res@vpWidthF  = 0.85
     res@vpXF      = 0.10        ; change start locations
     res@vpYF      = 0.75        ; the plot   

     res@gsnYRefLine    = (/-3.36,-2.31,-1.86,3.36,2.31,1.86/) ;reference line
     res@gsnXYBarChart         = False            ; create bar chart
     res@gsnYRefLineDashPattern = 2
     res@tmYUseLeft = False
     res@tmYRLabelsOn = True
     res@tmYRMode = "Explicit"
     res@tmYRValues = (/-1.86,-2.31,-3.36,1.86,2.31,3.36/)
     res@tmYRLabels = (/"90%","95%","99%","90%","95%","99%"/)
     ;res@tmXBLabelConstantSpacingF = 5.
     res@tmXBLabelFontHeightF = 0.01
     ; res@gsnBelowYRefLineColor = (/ "red", "transparent", "transparent"/)
     ; res@gsnAboveYRefLineColor = (/ "transparent","transparent","transparent"/)

     
   resP                 = True                 ; panel resources
   resP@txString        = "Moving T-test of PCs"  ; add center string
   ;resP@gsnPanelLabelBar    = True            ; add common colorbar
   ;resP@lbLabelAutoStride   = True
   resP@gsnMaximize         = False

   resP@gsnPanelFigureStrings = (/"PC1","PC2","PC3"/)
   resP@gsnPanelFigureStringsFontHeightF = 0.01
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopRight"
   resP@gsnPanelYWhiteSpacePercent = 5
   resP@gsnPanelXWhiteSpacePercent = 5

   mvtt5 = new(3, "graphic")
   mvtt10 = new(3, "graphic")
   mvtt10hf = new(3, "graphic")
;First Panel
   do n=0,2
       ;res@tiMainString = "Time Series of PC"+(n+1)
       res@gsnLeftString = "MovingT-Test of PC"+(n+1)
       res@gsnRightString = "5 years" 
       mvtt5(n) = gsn_csm_xy(wks,t,mtt5pc(n,:),res)
   end do
   gsn_panel(wks, mvtt5, (/3,1/), resP)

;Second Panel
     res@gsnYRefLine = (/-2.88,-2.10,-1.73,1.73,2.10,2.88/) ;reference line
     res@tmYRValues = (/-2.88,-2.10,-1.73,2.88,2.10,1.73/)
     res@tmYRLabels = (/"99%","95%","90%","99%","95%","90%"/)
   do n=0,2
       ;res@tiMainString = "Time Series of PC"+(n+1)
       res@gsnLeftString = "MovingT-Test of PC"+(n+1)
       res@gsnRightString = "10 years" 
       mvtt10(n) = gsn_csm_xy(wks,t2,mtt10pc(n,:),res)
   end do
   gsn_panel(wks, mvtt10, (/3,1/), resP)

;Third Panel
   do n=0,2
       ;res@tiMainString = "Time Series of PC"+(n+1)
       res@gsnLeftString = "MovingT-Test of PC_hf"+(n+1)
       res@gsnRightString = "10 years" 
       mvtt10hf(n) = gsn_csm_xy(wks,t2,mtt10pc_hf(n,:),res)
   end do
   gsn_panel(wks, mvtt10hf, (/3,1/), resP)
   


   ;********************************************
   end
