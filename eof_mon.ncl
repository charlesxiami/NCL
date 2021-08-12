 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

;***
  begin
;***
   yrstrt =197001
   yrlast =201412

   latS     = 20.               
   latN     = 80.
   lonL     = 80.
   lonR     = 140.
;**********************************************
;Calcute Snow Cover Index
;*********************************************
   cd = "/public/home/charlesxiami/data/ncep/"
   plotpath = "/public/home/charlesxiami/output/"
;************************************************
   wks=gsn_open_wks("pdf", plotpath+"eof_mam_mon")
   gsn_define_colormap(wks, "ViBlGrWhYeOrRe")
;***************************************
   airdata = addfile(cd+"air.mon.mean.nc", "r")
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
;********************************************
   air_mon = airdata->air(iStrt:iLast,:,:)
   printVarSummary(air_mon)

   air_mam = month_to_season(air_mon, "MAM")
   air_mam_wgt = SqrtCosWeight(air_mam)
   ;x = air_mam_wgt(:,{latS:latN},{lonL:lonR})  

   air_march = air_mon(2:539:12,:,:)
   air_april = air_mon(3:539:12,:,:)
   air_may   = air_mon(4:539:12,:,:)

   x = air_may(:,{latS:latN},{lonL:lonR})
   printVarSummary(x)
 ;************************************************
 ;EOF 
 ;************************************************
   neof = 3
   optEOF = True
   optEOF@jopt = 0
   optETS = False
   eof    = eofunc_n_Wrap(x,neof,optEOF,0)
   eof_ts = eofunc_ts_n_Wrap(x,eof,optETS,0)
   eof_ts = dim_standardize_Wrap(eof_ts, 0)
   printVarSummary(eof)
   printVarSummary(eof_ts)
  ;*******************************************
  ; North significance test: Note any of the following could be used
  ;*******************************************
   dimp   = dimsizes(air_mam_wgt)
   ntim   = dimp(0)

   prinfo = True
   sig_pcv = eofunc_north(eof@pcvar, ntim, prinfo)
   sig_ev  = eofunc_north(eof@eval, ntim, prinfo)
   sig_evt = eofunc_north(eof@eval_transpose, ntim, prinfo)

   ;print(eof_ts)
;************************************************
;Res
;************************************************
   plot = new(neof, "graphic")
  ;*********
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
  rts@tiYAxisString = ""                    ; y-axis label 
  rts@gsnYRefLine           = 0.              ; reference line   
  rts@gsnXYBarChart         = True            ; create bar chart 
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

  rtsP                     = True             ; modify the panel plot
  rtsP@gsnMaximize         = False             ; large format

  t = ispan(1970, 2014, 1)
  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,t,-1.0*eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)        ; draw all 'neof' as one plot

;*********************************************************
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   res@cnFillOn = True
   res@cnLinesOn = False
   res@lbLabelBarOn = False
   res@gsnAddCyclic = False
   res@mpFillOn             = False        ; turn off map fill


   resrc = True
   resrc = res
   ;resrc@gsnAddCyclic = True
   resrc@cnLinesOn = True
   resrc@cnLineLabelsOn = False
   resrc@cnLineLabelFormat  =  "@^sg"
   resrc@gsnContourNegLineDashPattern = 5
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@cnMinLevelValF = -1.6
   resrc@cnMaxLevelValF = 1.6
   resrc@cnLevelSpacingF = 0.2
   resrc@pmLabelBarOrthogonalPosF = 0.12
   resrc@cnInfoLabelOn = False
   ;resrc@cnInfoLabelString = "Dotted Area exceed 99% Sig Level"
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   ;resrc@lgLabelsOn = False
   resrc@gsnLeftStringFontHeightF = 0.025
   resrc@mpFillOn = False
   resrc@mpMinLonF = 0.
   resrc@mpMaxLonF = 180.
   resrc@mpMaxLatF = 90.
   resrc@mpMinLatF = 20.

   rescor = True
   rescor@gsnDraw = False
   rescor@gsnFrame = False
   rescor@cnFillOn = True
   rescor@cnLinesOn = False
   rescor@cnInfoLabelOn = False
   ;rescor@lgLabelsOn = False
   rescor@cnLineLabelsOn = False
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/-0.294,0.294/) 
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1,17/)
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillColors = (/1,1,1/)
   rescor@lbLabelBarOn = False

   resP                 = True                 ; panel resources
   resP@txString        = "SAT:MAM:1970-2014"  ; add center string
   resP@gsnPanelLabelBar    = True            ; add common colorbar
   resP@lbLabelAutoStride   = True
   resP@gsnMaximize         = False
   ;resP@gsnPanelDebug = True 

   xpts = (/lonL, lonL, lonR, lonR, lonL/)
   ypts = (/latS, latN, latN, latS, latS/)
   dum = new(dimsizes(xpts)-1, graphic)
   plres = True
   plres@gsLineColor = "red"
   plres@gsLineThicknessF = 2.8
   ;plres@gsLineLabelString = "sce"

    rc = -1.0*regCoef(eof_ts,air_mam_wgt(lat|:,lon|:,time|:))
    cor = escorc(eof_ts,air_mam_wgt(lat|:,lon|:,time|:))

   do n = 0, neof-1
     copy_VarCoords(air_mam_wgt(0,:,:), rc(n,:,:))
     copy_VarCoords(air_mam_wgt(0,:,:), cor(n,:,:))
     resrc@gsnLeftString  = "EOF "+(n+1)
     resrc@gsnRightString = sprintf("%5.1f", eof@pcvar(n))+"%"
     reg =  gsn_csm_contour_map(wks, rc(n,:,:),resrc)
     corre = gsn_csm_contour(wks, cor(n,:,:), rescor)
     overlay(reg, corre)

    do i = 0, dimsizes(xpts)-2
        dum(i) = gsn_add_polyline(wks, reg, xpts(i:i+1), ypts(i:i+1), plres)
    end do
    draw(reg)
    frame(wks)
    end do


end
