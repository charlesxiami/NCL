;************************************************************
;   
;   @file   :   plt_tn_wave_activity_flux.ncl   
;   @author :   Siyuan Chen
;   @email  :   CN_SiyuanChen@outlook.com
;
;   Takaya and Nakamura (1999, 2001) 得出的水平TN波活动通量
;   参考 Takaya 及 Nakamura (2001) (38)式
;   注意假设(38)式中Cu = 0, 此时波是静止波 
;   
;   -uclm       多年气候态风的U分量(单位:m/s), 2维数组(lat, lon)  
;   -vclm       多年气候态风的V分量(单位:m/s), 2维数组(lat, lon)  
;   -zclm       多年气候态的位势高度(单位:gpm), 2维数组(lat, lon) 
;   -z          扰动位势高度场(单位:gpm), 2维数组(lat, lon)       
;   -level      等压面高度(单位:hPa), float                      
;   -lat        uclm, vclm, zclm及z所带有的纬度, 1维数组(lat)
;   -lon        uclm, vclm, zclm及z所带有的经度, 1维数组(lon)
;   -rCyclic    是否为全球循环数据, logical
;
;   -wx         水平TN波活动通量x分量
;   -wy         水平TN波活动通量y分量
;   -distrb_psi 扰动流函数场
undef("tn_wave_activity_flux")
function tn_wave_activity_flux(uclm[*][*]:numeric, vclm[*][*]:numeric, zclm[*][*]:numeric, \
                               z[*][*]:numeric, level[1]:numeric, lat[*]:numeric, lon[*]:numeric, \
                               rCyclic[1]:logical)
local uclm, vclm, zclm, z, lat, lon, rCyclic, RE, OMEGA, G, \
        ndims, ndims1, ndims2, ndims3, ndims4, dim2D, d2r, f, \
        za, distrb_psi, lat2d, lon2d, cosphi, dpsidlambda, dpsid2lambda, \
        dpsidphi, dpsid2phi, dpsidlambdadphi, p, magU, coeff, coeff1, \
        coeff2, coeff3, coeff4, term1, term2, term3, term4, level, wx, wy
begin 
    RE      =   6371220.0 
    OMEGA   =   7.292e-5  
    G       =   9.80665 

    ndims1  =   dimsizes(uclm)
    ndims2  =   dimsizes(vclm)
    ndims3  =   dimsizes(zclm)
    ndims4  =   dimsizes(z)
    if dimsizes(ndims1).ne.dimsizes(ndims2) .or. dimsizes(ndims1).ne.dimsizes(ndims3) .or. \
        dimsizes(ndims2).ne.dimsizes(ndims3) then 
        print("tn_wave_activity_flux: uclm, vclm, and zclm dimensions must be the same size!")
        exit()
    end if 
    if any(dimsizes(uclm).ne.dimsizes(vclm)) .or. any(dimsizes(uclm).ne.dimsizes(zclm)) .or. \
        any(dimsizes(vclm).ne.dimsizes(zclm)) then 
        print("tn_wave_activity_flux: uclm, vclm, and zclm dimensions must be the same size!")
        exit()
    end if 
    if dimsizes(ndims1).ne.dimsizes(ndims4) then 
        print("tn_wave_activity_flux: Array z does not match the size of the climatology array!")
        exit()
    end if 
    if any(dimsizes(uclm).ne.dimsizes(z)) then 
        print("tn_wave_activity_flux: Array z does not match the size of the climatology array!")
        exit()
    end if 
    ndims = dimsizes(uclm)
    if dimsizes(ndims).ne.2 then 
        print("tn_wave_activity_flux: The input array dimension must be a 2-dimensional" \ 
            + " array with latitude and longitude!")
        exit()
    end if 
    if ndims(0).ne.dimsizes(lat) .or. ndims(1).ne.dimsizes(lon) then 
        print("tn_wave_activity_flux: Input latitude or longitude array does not match!")
        exit()
    end if 
    if typeof(rCyclic).ne."logical" then 
        print("tn_wave_activity_flux: The variable rCyclic must be logical!")
        exit()
    end if 
    if ismissing(get1Dindex(lat, 0)).eq.False then 
        print("tn_wave_activity_flux: Cannot include 0 degree latitude!")
        exit()
    end if 

    dim2D   =   ndims
    ; ***********************************************
    ; 计算扰动流函数等
    ; ***********************************************
    d2r     =   get_d2r("float")

    f       =   new(dim2D, "float")     
    do i = 0, dim2D(0) - 1
        f(i,:)  =   2 * OMEGA * sin(lat(i) * d2r)
    end do
    ; za  =   z - zclm
    za  =   z
    distrb_psi  =   G / f * za
    copy_VarCoords(zclm, distrb_psi)

    ; ***********************************************
    ; 计算各项差分、结果等
    ; ***********************************************
    lat2d   =   conform_dims(dim2D, lat, 0) * d2r
    lon2d   =   conform_dims(dim2D, lon, 1) * d2r

    cosphi  =   new(dim2D, "float")     
    do i = 0, dim2D(0) - 1
        cosphi(i,:) =   cos(lat(i) * d2r)
    end do

    dpsidlambda     =   center_finite_diff_n (distrb_psi, lon2d, rCyclic, 0, 1)
    dpsid2lambda    =   center_finite_diff_n (dpsidlambda, lon2d, rCyclic, 0, 1)
    dpsidphi        =   center_finite_diff_n (distrb_psi, lat2d, False, 0, 0)
    dpsid2phi       =   center_finite_diff_n (dpsidphi, lat2d, False, 0, 0)
    dpsidlambdadphi =   center_finite_diff_n (dpsidlambda, lat2d, False, 0, 0)

    p       =   level / 1000.
    magU    =   sqrt(uclm * uclm + vclm * vclm)
    coeff   =   p * cosphi / (2 * magU)
    coeff1  =   uclm / (RE * RE * cosphi * cosphi)
    coeff2  =   vclm / (RE * RE * cosphi)
    coeff3  =   coeff2 
    coeff4  =   vclm / (RE * RE)
    term1   =   dpsidlambda * dpsidlambda - distrb_psi * dpsid2lambda
    term2   =   dpsidlambda * dpsidphi - distrb_psi * dpsidlambdadphi
    term3   =   term2 
    term4   =   dpsidphi * dpsidphi - distrb_psi * dpsid2phi
    wx      =   coeff * (coeff1 * term1 + coeff2 * term2)
    wy      =   coeff * (coeff3 * term3 + coeff4 * term4)

    copy_VarCoords(z, wx)
    copy_VarCoords(z, wy)

    return [/wx,wy,distrb_psi/]
end 

begin
  ; yrstrt = 196701
  ; yrlast = 198812

  yrstrt = 198901
  yrlast = 201912

   ; yrstrt_nino = 197201
   ; yrlast_nino = 201412

   yrstrt_snow = yrstrt
   yrlast_snow = yrlast

  SCI_EEU_N = 70
  SCI_EEU_S = 40
  SCI_EEU_L = 80
  SCI_EEU_R = 140

  latS     = 5
  latN     = 90
  lonL     = 0
  lonR     = 360

   season = "MAM"
   print("season: "+season)

  ;direcotry name
   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"

  ;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"waf.reg")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
  ;**************************************************
  airdata = addfile(nceppath+"air.mon.mean.nc", "r")
  slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
  hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
  uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
  vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")

   snowdata  = addfile(snowpath+"snowcover_new.nc","r")

   ; ;Nino34 index read
   ; nino34_0 = readAsciiTable(indexpath+"nino34.long.anom.data.txt", 13, "float", (/1,8/))
   ; ; printVarSummary(nino34_0)
   ; nino34_1 = nino34_0(:,1:) ; 1900-2017 Monthly
   ; nino34_index = ndtooned(nino34_1)

   ; month_time3 = yyyymm_time(1870, 2019, "integer")
   ; month_time3!0 = "time"
   ; month_time3@long_name = "time"
   ; month_time3@units = "month"
   ; nino34_index!0 = "time"
   ; nino34_index&time = month_time3

  ; wafdata = addfile("$HOME/data/WAF/WAF.mon1972-2015.nc", "r")

   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))

   ; iStrt6  = ind(nino34_index&time.eq.yrstrt_nino)
   ; iLast6  = ind(nino34_index&time.eq.yrlast_nino)
   ; print("nino time: "+nino34_index&time(iStrt6)+"--"+nino34_index&time(iLast6)) 
  ;---------------------------------------------------------------------
   air_mon = airdata->air(iStrt:iLast,:,:)

   level = 500
   z_mon = hgtdata->hgt(iStrt:iLast,{level},{latS:latN},{lonL:lonR})
   u_mon = uwnddata->uwnd(iStrt:iLast,{level},{latS:latN},{lonL:lonR})
   v_mon = vwnddata->vwnd(iStrt:iLast,{level},{latS:latN},{lonL:lonR})

   lat = z_mon&lat
   lon = z_mon&lon

   z_sea = month_to_season(z_mon, season)
   u_sea = month_to_season(u_mon, season)
   v_sea = month_to_season(v_mon, season)

   zclm = dim_avg_n_Wrap(z_sea, 0)
   uclm = dim_avg_n_Wrap(u_sea, 0)
   vclm = dim_avg_n_Wrap(v_sea, 0)


   ; nino34_mon = nino34_index(iStrt6:iLast6)
   ; nino_sea = month_to_season(nino34_mon, "SON")

;***************************************************************************   
   ; EEU = snow_mam(:,{SCI_EEU_S:SCI_EEU_N},{SCI_EEU_L:SCI_EEU_R})
   ; sci_eeu = dim_standardize_Wrap(wgt_areaave_Wrap(EEU, 1.0, 1.0, 1),0)
;***************************************************************************
   ; imidyr = 20 
   
   ; nino_p1 = nino_sea(0:imidyr)
   ; nino_p2 = nino_sea(imidyr+1:)

   ; ssti_enp = asciiread(indexpath+"trop_sst_72-15DJF.txt", -1, "float")
   ; dimsst = dimsizes(ssti_enp)
   
   ; ; ssti = ssti_enp(0:20)
   ; ssti = ssti_enp(21:dimsst-2)

   ao_mam = asciiread(indexpath+"ao_1967-2019mam.txt", -1, "float")

   si = asciiread(indexpath+"SI_EEU_1967-2019MAM.txt", -1, "float")

   ; si_res = si(:21) - ao_mam(:21)*regline(ao_mam(:21), si(:21))
   si_res = si(22:) - ao_mam(22:)*regline(ao_mam(22:), si(22:))

   ; snow_index = si(:21)
   ; snow_index = si(22:)
   ssti = asciiread(indexpath+"natsi_1967-2019MAM.txt", -1, "float")
   ssti = dtrend(ssti, 0)

   ; snow_index = si_res
   snow_index = si(22:)
   ; snow_index = ssti(:21)
   ; snow_index = ssti(22:)
; ;---------------------------------------------------------------------
; ;snow index & regression
  ndim_ncep = dimsizes(z_sea)
  sci_z500_rc = regCoef_n(snow_index, z_sea, 0, 0)
  copy_VarCoords(z_sea(0,:,:), sci_z500_rc)
  sci_z500_cor = escorc_n(snow_index, z_sea, 0, 0)
  df_ncep = sci_z500_cor
  df_ncep = ndim_ncep(0) - 2
  p_z500 = student_t(sci_z500_cor*sqrt(df_ncep/(1- sci_z500_cor^2)), df_ncep)
  copy_VarCoords(z_sea(0,:,:), p_z500)

   ;Calculate wave activity flux
    tn      =   tn_wave_activity_flux(uclm, vclm, zclm, sci_z500_rc, level, lat, lon, True)
    wx      =   tn[0]
    wy      =   tn[1]
    distrb_psi  =   tn[2] 

    distrb_psi := distrb_psi * 1.0e-5
    copy_VarCoords(zclm, distrb_psi)

    ; printMinMax(wx,0)
    ; printMinMax(wy,0)
    printMinMax(distrb_psi,0)

;---------------------------------------------------------------------
;Resources Setting
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   ;For Fills
   resrc = True    
   resrc@gsnDraw = False
   resrc@gsnFrame = False
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnInfoLabelString = " "
   resrc@cnLineLabelsOn = False
   resrc@cnFillDrawOrder = "PreDraw"   
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   resrc@pmLabelBarHeightF = 0.1
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpAreaMaskingOn = True
   ; resrc@mpOceanFillColor = "white"
   resrc@mpLandFillColor = "Transparent"

   ;For Line
   resrc2 = res
   resrc2@cnFillOn = False
   resrc2@cnLinesOn = True
   resrc2@cnInfoLabelOn = False
   resrc2@gsnContourNegLineDashPattern = 5
   resrc2@gsnContourZeroLineThicknessF = 0.
   resrc2@cnLineThicknessF = 2.0
   ;resrc2@cnLineColor = "red"
   resrc2@cnLineLabelsOn = True
   resrc2@cnLineLabelPerimOn = False
   resrc2@cnLineLabelBackgroundColor = 2
   resrc2@cnLineLabelPlacementMode = "Constant"
   resrc2@cnLineLabelInterval = 2
   resrc2@cnLineLabelFontHeightF = 0.010
   ;resrc2@cnLineLabelFontColor = 0
   resrc2@cnLineLabelFontThicknessF = 1.0
   resrc2@gsnAddCyclic = True
   resrc2@cnLevelSelectionMode = "ManualLevels"
   resrc2@cnMaxLevelValF = 20
   resrc2@cnMinLevelValF = -1*resrc2@cnMaxLevelValF
   resrc2@cnLevelSpacingF = 5

   res_circ = resrc
   ; res_circ@gsnLeftStringFontHeightF = 0.015
   ; res_circ@gsnRightStringFontHeightF = 0.015
   res_circ@pmLabelBarOrthogonalPosF = 0.08
   ; res_circ@vpWidthF = 0.75
   ; res_circ@vpHeightF = 0.3
   ; res_circ@gsnLeftString = "Height x time HGT regressed on PC1"
   res_circ@gsnRightString = " "   
   ; res_circ@tmXBLabels = new(nmonth, "string")
   ; res_circ@tmXBMode = "Explicit"
   ; res_circ@mpCenterLonF = 180
   res_circ@pmLabelBarWidthF = 0.5

   ;Correlation res (with dots.)
   rescor = res
   rescor@cnLinesOn = False
   rescor@cnFillOn = True
   rescor@cnLevelSelectionMode = "ExplicitLevels"
   rescor@cnLevels = (/0.05/)  ;95%
   rescor@cnMonoFillPattern = False
   rescor@cnFillPatterns = (/17,-1/)
   rescor@cnFillDotSizeF = 0.004
   rescor@cnFillColors = (/1,1/)
   rescor@cnLineLabelsOn = False
   rescor@lbLabelBarOn = False
   ;rescor@lbOrientation = "Vertical"
   ;rescor@lbLabelsOn = False
   rescor@cnInfoLabelOn = False
   rescor@cnMonoFillScale = True   
   rescor@cnFillScaleF = 1.2
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillOpacityF = 1.0
   rescor@cnFillDrawOrder = "PreDraw"

   ;Wind Resources
   resV = res
   resV@vcRefMagnitudeF = 0.3
   resV@vcRefLengthF = 0.06
   resV@vcRefAnnoArrowLineColor = "black"  
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.67
   ; resV@vcGlyphStyle = "CurlyVector"
   resV@vcGlyphStyle = "LineArrow"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 2.8
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02
;---------------------------------------------------------------------
;Plot
   ; res_circ@cnMaxLevelValF = 20
   ; res_circ@cnMinLevelValF = -1*res_circ@cnMaxLevelValF
   ; res_circ@cnLevelSpacingF = 2
   ; fzplot = gsn_csm_pres_hgt(wks, sci_fz_rc0(level|:, time|:), res_circ)
   ; fzdot = gsn_csm_contour(wks, p_fz0(level|:, time|:), rescor)
   ; overlay(fzplot, fzdot)
   ; draw(fzplot)
   ; frame(wks)

    ww = wx
    ww = sqrt(wx^2+wy^2)

    mask_speed = 0.01
    wx = mask(wx, abs(ww).ge.mask_speed, True)
    wy = mask(wy, abs(ww).ge.mask_speed, True)
  
   ; res_circ@gsnPolar = "NH"

   res_circ@pmLabelBarOrthogonalPosF = 0.15
   res_circ@gsnLeftString = "a) WAF+Z500 NATSI P1"
   ; res_circ@gsnLeftString = "b) WAF+Z500 NATSI P2"

   res_circ@mpMinLatF = 20
   res_circ@mpMaxLatF = 90
   res_circ@mpMinLonF = 30
   res_circ@mpMaxLonF = 360
   res_circ@cnMaxLevelValF =  20
   res_circ@cnMinLevelValF = -20
   res_circ@cnLevelSpacingF = 2
   ; res_circ@cnLinesOn = True

   res_circ@gsnLeftString = "a) WAF+Z500 NATSI P1"
   res_circ@tmXBOn = False
   res_circ@tmXTOn = False
   res_circ@tmYLOn = False
   res_circ@tmYROn = False
   
   plot_cn = gsn_csm_contour_map(wks, sci_z500_rc, res_circ)
   ; plot_ln = gsn_csm_contour(wks, sci_z500_rc, resrc2)
   plot_vc = gsn_csm_vector(wks, wx, wy, resV)
   plot_dot = gsn_csm_contour(wks, p_z500, rescor)
   overlay(plot_cn, plot_dot)
   overlay(plot_cn, plot_vc)
   overlay(plot_cn, plot_ln)
   draw(plot_cn)
   frame(wks)





end
