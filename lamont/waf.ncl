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
    za  =   z - zclm
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
    ; ==============================================================
    ;   用户设置  
    ; ==============================================================  
    ; 设置画图范围 
    latS    =   5
    latN    =   90
    lonL    =   0
    lonR    =   360

    level   =   300. ; 设置绘图层次

    ; 气候态起止时间
    yrStrt  =   1979   
    yrLast  =   2017
	
    ; ==============================================================
    ;   读取数据   
    ; ==============================================================
    fu      =   addfile("uwnd.1979_2019_01.nc", "r")
    fv      =   addfile("vwnd.1979_2019_01.nc", "r")
    fz      =   addfile("hgt.1979_2019_01.nc", "r")
    
    u   =   fu->uwnd(:, {latS:latN}, {lonL:lonR})
    v   =   fv->vwnd(:, {latS:latN}, {lonL:lonR})
    z   =   fz->hgt (:, {latS:latN}, {lonL:lonR})
    lat =   u&lat
    lon =   u&lon

    rz  =   z(2,:,:)    ; 指定月份

    TIME    =   fu->time 
    utc     =   cd_calendar(TIME, 0)
    YYYY    =   utc(:,0)
    iYYYY   =   ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)

    dim2D   =   dimsizes(u(0,:,:))

    ; ==============================================================
    ;   计算TN波通量    
    ; ==============================================================

    ; ***********************************************
    ; 计算气候态
    ; ***********************************************
    uclm    =   dim_avg_n_Wrap(u (iYYYY,:,:), 0)
    vclm    =   dim_avg_n_Wrap(v (iYYYY,:,:), 0)
    zclm    =   dim_avg_n_Wrap(z (iYYYY,:,:), 0)

    tn      =   tn_wave_activity_flux(uclm, vclm, zclm, z (2,:,:), level, lat, lon, False)
    wx      =   tn[0]
    wy      =   tn[1]
    distrb_psi  =   tn[2]   

    ; ==============================================================
    ;   画图    
    ; ==============================================================
    wks     =   gsn_open_wks("x11", "TN")
    ; gsn_define_colormap(wks,"CBR_coldhot")
    
    res = True
    res@gsnDraw     =   False
    res@gsnFrame    =   False

    res@gsnPolar        =   "NH"
    res@mpFillOn        =   False
    res@mpCenterLonF    =   90
    res@mpMinLatF       =   10

    res@cnFillOn    =   True
    res@cnLevelSelectionMode    =   "ManualLevels"
    res@cnMinLevelValF          =   -24
    res@cnMaxLevelValF          =   24  
    res@cnLevelSpacingF         =   4

    res@gsnScalarContour        =   True
    res@vcRefMagnitudeF         =   25.0
    res@vcLineArrowThicknessF   =   2.0
    res@vcRefLengthF            =   0.04    
    res@vcLineArrowColor        =   "black"
    res@vcMinDistanceF          =   0.02    
    res@vcGlyphStyle            =   "CurlyVector"

    distrb_psi := distrb_psi * 1.0e-6
    copy_VarCoords(zclm, distrb_psi)
    plot = gsn_csm_vector_scalar_map_polar(wks, wx, wy, distrb_psi, res)
    draw(plot)
    frame(wks)
end 