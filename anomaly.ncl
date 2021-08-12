  ;***********************************************
  begin
  ;***
  yrstrt =196701
  yrlast =201502

  latS     = -90               
  latN     = 90
  lonL     =   0
  lonR     = 360
  ;*******************************
  fname2 = "/public/home/charlesxiami/data/ncep/air.mon.mean.nc"
  airdata = addfile(fname2,"r")

  ;*******************************
  YYYYMM = cd_calendar( airdata->time, 1)
  iStrt  = ind(YYYYMM.eq.yrstrt)
  iLast  = ind(YYYYMM.eq.yrlast)
  year = ispan(1967, 2014, 1)
  nyr = dimsizes(year)
  print(nyr)
   ;******************************
   air_mon = airdata->air(iStrt:iLast,{latS:latN},{lonL:lonR}) 
   air_djf = air_mon(0:nyr-1,:,:)
   air_djf_ano = air_mon(0:nyr-1,:,:)
   
   do i = 0, nyr-1
       air_djf(i, :, :) = (air_mon(i*12+11,:,:)+ \
        air_mon(i*12+12,:,:)+air_mon(i*12+13,:,:))/3.0
   end do

   air_clim = dim_avg_n_Wrap(air_djf, 0)

    ;*******************************************
    ; Plot
    ;*******************************************
    pltType = "pdf"
    pltName = "/public/home/charlesxiami/output/5yr_sat_ano_djf"
    wks  = gsn_open_wks (pltType,pltName)
    gsn_define_colormap(wks, "BlueRed")
    ; resources for "left" variable MPL_gist_yarg
    res = True
    res@gsnFrame = False
    res@gsnDraw = False
    res@cnLinesOn = True
    res@cnFillOn = True
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF = -8
    res@cnMaxLevelValF = 8
    res@cnLevelSpacingF = 1.0
    res@gsnContourNegLineDashPattern = 1
    res@cnLineLabelsOn = True
    res@cnLineLabelPlacementMode = "constant"
    ; res@cnLevels = (/-8.,-6.,-4.,-2.,-1.,1.,2.,4.,6.,8./)
    ; res@cnFillColors = (//)
    ; res@cnLevelSelectionMode = "EqualSpacedLevels"
    ; res@cnMaxLevelCount = 20

    res@gsnAddCyclic = True
    res@mpMaxLonF = -40
    res@mpMinLonF = -150
    res@mpMaxLatF = 70
    res@mpMinLatF = 10
    ;res@mpCenterLonF = 180

    ; res@gsnLeftString = "Climatic SAT 1967-2014DJF"
    ; plot = gsn_csm_contour_map(wks, air_clim, res)
    ; draw(plot)
    ; frame(wks)

    res@gsnLeftString = "DJF SAT Anomaly"
   ;************************************************
   do i = 0, 5
       air_djf_ano(i,:,:) = air_djf(nyr-1-i,:,:)- \
       air_clim(:,:)
       nmb = 2014-i
       res@gsnCenterString = "year "+nmb
       ano = gsn_csm_contour_map(wks, air_djf_ano(i,:,:),res)

       draw(ano)
       frame(wks)
   end do
   printVarSummary(air_djf_ano)


    end

