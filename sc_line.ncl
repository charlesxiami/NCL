load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/run_cor.ncl"
;***********************************************
begin
  ;***
  yrstrt =197201
  yrlast =200912
  ;---------------A,B-index Region
  AlatS = 48
  AlatN = 58
  AlonL = 25
  AlonR = 50
  
  BlatS = 60
  BlatN = 70
  BlonL = 100
  BlonR = 125

  latS     = -90               
  latN     = 90
  lonL     =   0
  lonR     = 360

  cd = "/mnt/f/Data/Original/ncep/"
  plotpath = "/mnt/f/Pic/work1/NCL_pic/"
  ;*******************************
  filesnow = "/mnt/f/Data/Original/snowcover/snow.nc"
  snowdata   =  addfile(filesnow,"r")

  airdata = addfile(cd+"air.mon.mean.nc","r")

  pc_hf1 = asciiread(plotpath+"pc_hf1.txt", -1, "float")
  printVarSummary(pc_hf1)
  ;*******************************
  YYYYMM = cd_calendar(airdata->time, 1)
  iStrt  = ind(YYYYMM.eq.yrstrt)
  iLast  = ind(YYYYMM.eq.yrlast)
  year = ispan(1972, 2009, 1)
  nyr = dimsizes(year)
  ;******************************
  air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
  air_mam = month_to_season(air_mon, "MAM")
  snow_mon = snowdata->Snow(:,:,:)
  snow_mam = month_to_season(snow_mon, "MAM")
  ;******************************
  snow_mam_wgt= SqrtCosWeight(snow_mam)
  Aregion=snow_mam_wgt(:,{AlatS:AlatN},{AlonL:AlonR})
  Bregion=snow_mam_wgt(:,{BlatS:BlatN},{BlonL:BlonR})
  Aindex = wgt_areaave_Wrap(Aregion, 1.0, 1.0, 1)
  Bindex = wgt_areaave_Wrap(Bregion, 1.0, 1.0, 1)
  Ai = dim_standardize_n_Wrap(Aindex, 0, 0)  ;Ai, Bi is the final index 
  Bi = dim_standardize_n_Wrap(Bindex, 0, 0)
  ;*******************************************
    ; Running Correlation
  ;*******************************************
    wSize = 15
    year!0 = "time"
    year@long_name = "Year"
    year@units = "Year"
    Aruncor =  run_cor(Ai, pc_hf1(2:39), year, wSize)
    Bruncor =  run_cor(Bi, pc_hf1(2:39), year, wSize)
    ;printVarSummary(Aruncor)

    rcordata = new((/2,dimsizes(Aruncor)/), float)
    rcordata(0,:) = Aruncor
    rcordata(1,:) = Bruncor
    printVarSummary(rcordata)
  ;*******************************************
    ;  Correlation lag
  ;*******************************************
    ; mxlag = 6
    ; totlag= 2*mxlag-1
    ; Accr1 = esccr(Ai, pc_hf1(2:39), mxlag)
    ; Accr2 = esccr(pc_hf1(2:39), Ai, mxlag)
    ; Bccr1 = esccr(Bi, pc_hf1(2:39), mxlag)
    ; Bccr2 = esccr(pc_hf1(2:39), Bi, mxlag)

    ; x =ispan(-mxlag+1, mxlag-1, 1)
    
    ; Accrtot = new((/totlag/), float)
    ; Accrtot(0:mxlag-1) = Accr2(0:mxlag-1:-1) 
    ; Accrtot(mxlag:)       = Accr1(1:mxlag-1)

    ; Bccrtot = new((/totlag/), float)
    ; Bccrtot(0:mxlag-1) = Bccr2(0:mxlag-1:-1) 
    ; Bccrtot(mxlag:)       = Bccr1(1:mxlag-1)

    ; Accrtot@long_name = "Ai-PC1_hf Cor"
    ; Bccrtot@long_name = "Bi-PC1_hf Cor"
    ; printVarSummary(Accrtot)


  ;*******************************************
  ; Plot
  ;*******************************************
  wks  = gsn_open_wks ("pdf",plotpath+"Sliding_Correlation")

; resources for "left" variable
  resL = True 
  resL@gsnDraw = False
  resL@gsnFrame =  False
  resL@vpHeightF = 0.30        ; Changes the aspect ratio
  resL@vpWidthF  = 0.80
  resL@vpXF      = 0.15        ; change start locations
  resL@vpYF      = 0.75        ; the plot   
  resL@tiMainString  = "Sliding Correlation"
  resL@gsnLeftString = wSize+"a window"
  ;resL@gsnRightString  = "Index - PC_hf "
  ;resL@tiYAxisString = " A -"+"[blue]"
  resL@xyLineThicknesses = (/2.,2./)
  resL@xyLineColors = (/"red","blue"/)
  resL@trYMinF = -1.                    ; axis min
  resL@trYMaxF = 0.                   ; axis max
  resL@trXMinF = min(year)+7
  resL@trXMaxF = max(year)-8
  resL@tmXBMode = "Manual"
  resL@tmXBTickStartF = 1980
  resL@tmXBTickSpacingF = 4
  resL@pmLegendDisplayMode = "Always"
  resL@pmLegendSide = "Top"
  resL@pmLegendParallelPosF = .12
  resL@pmLegendOrthogonalPosF = -0.6
  resL@pmLegendWidthF = 0.10
  resL@pmLegendHeightF = 0.06
  resL@lgPerimOn = False
  resL@lgLabelFontHeightF = 0.010
  resL@lgItemOrder = (/1,0/)
  resL@xyExplicitLegendLabels = (/"Ai-PC1_hf","Bi-PC1_hf"/)

  slid_cor = gsn_csm_xy(wks, year(7:nyr-8), rcordata, resL)

  gres   =   True
  gres@gsFillColor  =  "black"
  gres@gsLineColor = "black"
  gres@tfPolyDrawOrder  =  "Draw"
  gres@gsLineDashPattern = 5
  sig_y95 = new(nyr, float)
  sig_y95(:) = -0.514              ; 95%, n=15
  sig_y99 = new(nyr, float)
  sig_y99(:) = -0.641              ;  99%, n=15

  sig95 = gsn_add_polyline(wks, slid_cor, year(4:nyr-5), sig_y95, gres)
  sig99 = gsn_add_polyline(wks, slid_cor, year(4:nyr-5), sig_y99, gres)
  draw(slid_cor)
  frame(wks)

  ; resC      =             True
  ; resC@gsnFrame  = False
  ; resC@gsnDraw  =  False
  ; resC@tiMainString =  "Lag Correlation"
  ; ;resC@tiMainString  =  " index-PC_hf Correlation"
  ; resC@tiXAxisString  = "Lag"
  ; plot(2) = gsn_csm_xy(wks, x, Accrtot, resC)
  ; plot(3) = gsn_csm_xy(wks, x, Bccrtot, resC)


  ; resP                 = True    
  ; resP@gsnMaximize     = False
  ; resP@txString        = "Filter(hf) & Correlation"  ; add center string


end