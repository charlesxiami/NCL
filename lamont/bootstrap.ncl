load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/run_cor.ncl"
;***
  begin
;***
   yrstrt = 197201
   yrlast = 201412

   yrstrt_nao = 197201
   yrlast_nao = 201512

   nyrs = yrlast/100-yrstrt/100+1
   ; print(nyrs+" years")

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  year = ispan(yrstrt_snow/100, yrlast_snow/100, 1)
  year!0 = "time"
  year@units = "year"

;---------------W,E-index Region
  SCI_EEU_N = 70
  SCI_EEU_S = 40
  SCI_EEU_L = 80
  SCI_EEU_R = 140

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   latS_eu = 20
   latN_eu = 70
   lonW_eu = 0
   lonE_eu = 140

   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"bootstrap")
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
   precipdata = addfile(precpath+"precip.mon.anom.nc", "r")

   ;Nao 195001-201806
   nao_index = asciiread(indexpath+"norm.nao.monthly.b5001.current.ascii.txt", -1, "string")
   nao_index2 = stringtofloat(str_get_field(nao_index, 3, " "))
   nao_index3 = nao_index2(0:dimsizes(nao_index2)-9)

   month_time = yyyymm_time(1950, 2018, "integer")
   month_time!0 = "time"
   month_time@long_name = "time"
   month_time@units = "month"
   nao_index3!0 = "time"
   nao_index3&time = month_time

   ;PDO index read
   pdo0 = readAsciiTable(indexpath+"PDO.latest.txt", 13, "float", (/32,12/))
   pdo1 = pdo0(:117,1:) ; 1900-2017 Monthly
   pdo_index = ndtooned(pdo1)

   month_time2 = yyyymm_time(1900, 2017, "integer")
   month_time2!0 = "time"
   month_time2@long_name = "time"
   month_time2@units = "month"
   pdo_index!0 = "time"
   pdo_index&time = month_time2


   ;Nino34 index read
   nino34_0 = readAsciiTable(indexpath+"nino34.long.anom.data.txt", 13, "float", (/1,8/))
   ; printVarSummary(nino34_0)
   nino34_1 = nino34_0(:,1:) ; 1900-2017 Monthly
   nino34_index = ndtooned(nino34_1)

   month_time3 = yyyymm_time(1870, 2019, "integer")
   month_time3!0 = "time"
   month_time3@long_name = "time"
   month_time3@units = "month"
   nino34_index!0 = "time"
   nino34_index&time = month_time3

   ssti = asciiread(indexpath+"na_ssti.txt", -1 ,"float")
      imidyr = 20
      ssti_p1 = ssti(0:imidyr)
   ssti_p2 = ssti(imidyr+1:)
 ;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   ; print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt_sst)
   iLast2  = ind(YYYYMM2.eq.yrlast_sst)
   ; print("sst  time: "+YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))

   iStrt4  = ind(nao_index3&time.eq.yrstrt_nao)
   iLast4  = ind(nao_index3&time.eq.yrlast_nao)
   print("nao time: "+nao_index3&time(iStrt4)+"--"+nao_index3&time(iLast4))

   iStrt5  = ind(pdo_index&time.eq.yrstrt_nao)
   iLast5  = ind(pdo_index&time.eq.yrlast_nao)
   print("pdo time: "+pdo_index&time(iStrt5)+"--"+pdo_index&time(iLast5))

   iStrt6  = ind(nino34_index&time.eq.yrstrt_nao)
   iLast6  = ind(nino34_index&time.eq.yrlast_nao)
   print("nino time: "+nino34_index&time(iStrt6)+"--"+nino34_index&time(iLast6))   
;***************************************************************
   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   nao_mon = nao_index3(iStrt4:iLast4)
   pdo_mon = pdo_index(iStrt5:iLast5)
   nino34_mon = nino34_index(iStrt6:iLast6)
;*****************************************************************   
   snow_son = month_to_season(snow_mon, "SON")
   snow_son_dt = dtrend_n(snow_son, False, 0)
   copy_VarMeta(snow_son, snow_son_dt)

   nao_son = month_to_season(nao_mon, "SON")
   nao_son = dim_standardize_Wrap(nao_son, 1)
   ndimnao = dimsizes(nao_son)

   nao_djf = month_to_season(nao_mon, "DJF")
   ; nao_djf = dim_standardize_Wrap(nao_djf, 1)
   ; print(nao_djf(1:))

   pdo_djf = month_to_season(pdo_mon, "SON")

   nino34_djf  = month_to_season(nino34_mon, "SON")

;*****************************************************************
   snow_son_eu = snow_son(:,{latS_eu:latN_eu},{lonW_eu:lonE_eu})
   snow_son_eui = wgt_areaave_Wrap(snow_son_eu, 1.0, 1.0, 0)
   snow_son_eui = dtrend(snow_son_eui, False)
   snow_son_eui = dim_standardize_Wrap(snow_son_eui, 1)
   
   ndim_snow = dimsizes(snow_son_eui)
;*****************************************************************
   ; snow_pc1_son    = asciiread(indexpath+"snow.son.pc1"+".txt", -1, "float")
   snow_son_pc1 = asciiread(indexpath+"snow.son.dt.pc1"+".txt", -1, "float")
   snow_son_pc2 = asciiread(indexpath+"snow.son.dt.pc2"+".txt", -1, "float")

   pcdim = dimsizes(snow_son_pc1)

    nao_son_dt = dtrend(nao_son, False)
    nao_djf_dt = dtrend(nao_djf, False)
    ; print("NAO dt vs none dt:  " + escorc(nao_djf_dt, nao_djf))
;*****************************************************************
   df_pc = pcdim - 2
   dim_nino = dimsizes(nino34_djf)

   nino34_djf1 = nino34_djf(:dim_nino-2)
   pdo_djf1    = pdo_djf(:dim_nino-2)
   nao_djf_dt1 = nao_djf_dt(1:)

  ;*************************************************************************************************
   ; ;bootstrap calculate
   nboot = 500
   n = 22
   ; n = pcdim
   opt = True
   opt@sample_size = n

   bootstrap := bootstrap_correl(snow_son_pc1, nao_djf_dt1, nboot, (/0,0/) ,opt)
   rboot    := bootstrap[0]
   rbootavg := bootstrap[1]
   rbootstd := bootstrap[2]
   print("PC1-NAO Boot_Avg =: " + rbootavg)
   print("PC1-NAO Boot_Std =: " + rbootstd)
   rBootLow    := bootstrap_estimate(rboot, 0.025, False)   ;  2.5% lower confidence bound 
   rBootMed    := bootstrap_estimate(rboot, 0.500, False)   ; 50.0% median of bootstrapped estimates
   rBootHi     := bootstrap_estimate(rboot, 0.975, False)
   print("rBootLow =: " + rBootLow)
   print("rBootMed =: " + rBootMed)
   print("rBootHi =: " + rBootHi)

   print("----------------------------------------------------------------------")
;***************************************************************
;***************************************************************
    rseed1 = toint(systemfunc(" date +%s"))
    rseed2 = toint((12345l*rseed1)%2147483398l)
    random_setallseed(rseed1, rseed2)

    ny = 43
    ; iwo = generate_sample_indices(n, 0)
    ; print("iwo"+ "  "+ iwo)
    xBoot = new(nboot, typeof(snow_son_pc1))
    do i = 0, nboot - 1
       iwo1 := generate_sample_indices(ny, 0)
       iwo2 := generate_sample_indices(ny, 0)
       xBoot(i) = escorc(snow_son_pc1(iwo1(:n-1)), nao_djf_dt1(iwo2(:n-1)))
    end do
    ; print(nao_djf_dt1(iwo2(:n-1)))
    xAvgBoot= avg(xBoot)
    xStdBoot= stddev(xBoot)
    print("nBoot="+nboot+"  xAvgBoot="+xAvgBoot+"  xStdBoot="+xStdBoot)
    
    idx  = dim_pqsort_n(xBoot, 2, 0)
    i025 = toint(0.025*nboot)
    i975 = toint(0.975*nboot)
    xBoot_025   = xBoot(i025)
    xBoot_975   = xBoot(i975)
    xBoot_Range = xBoot_975 - xBoot_025
    print("XbootLow="+xBoot_025 + "   XbootHi="+xBoot_975)
;***************************************************************
;--- create histogram for the original sample
;***************************************************************
   resh = True
   resh@gsnDraw      = False
   resh@gsnFrame     = False
   resh@gsFillColor  = "green"
   resh@gsnHistogramBinWidth = 0.05
   resh@tiYAxisString = ""                   ; do not want a 2nd 'Frequency' label 
   resh@tiMainString  = "nBoot="+nboot+"  n="+n
   resh@gsnHistogramNumberOfBins = 25
   resh@gsnHistogramCompare = False
   resh@tmXBLabelFontHeightF = 0.01
   ; resh@gsnhistogrambar

   ; z = new((/2,nboot/),float)
   ; z(0,:) = rboot
   ; z(1,:) = xBoot
   hstBoot = gsn_histogram(wks, rboot, resh)
 ;***************************************************************
;--- text object bootstrapped statistics 
;***************************************************************
   txres                       = True
   txres@txFont                = "helvetica-bold"
   txres@txFontHeightF         = 0.0150
   textBoot  = (/"  Mean="+sprintf("%5.2f", rbootavg) +"~C~"+  \
                 "   Std="+sprintf("%5.2f", rbootstd) +"~C~"+  \
                 "  xLow="+sprintf("%5.2f", rBootLow) +"~C~"+  \
                 "  xMed="+sprintf("%5.2f", rBootMed) +"~C~"+  \
                 "   xHi="+sprintf("%5.2f", rBootHi ) /)
   txBoxBoot  = gsn_create_text(wks,textBoot, txres)

   amres  = True
   amres@amParallelPosF   = 0.35             ; move legend to the left
   amres@amOrthogonalPosF = -0.30             ; move the legend up
   ; annoBoot = gsn_add_annotation(hstBoot, txBoxBoot, amres)  ; Attach string to plot
;*****************************************************************

;*****************************************************************
   ; overlay(hstBoot, hstBoot2)
   draw(hstBoot)
   frame(wks)

   resh@gsnHistogramNumberOfBins = 25
   resh@gsFillColor = "red"
   hstBoot2 = gsn_histogram(wks, xBoot, resh)
   draw(hstBoot2)
   frame(wks)

end
