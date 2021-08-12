begin

   ; yrstrt = 197201
   ; yrlast = 199412

   yrstrt = 197201
   yrlast = 201912
;**********************************************************************
   nceppath = "$HOME/data/ncep/"
   ncep2path = "$HOME/data/ncep2/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"
   hadleypath = "$HOME/data/hadley/"
   wafpath = "$HOME/data/waf/tn/"

   plotpath = "$HOME/output/"
;**********************************************************************
   wks=gsn_open_wks("pdf", "refrac_index")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**********************************************************************
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   airdata = addfile(nceppath+"air.mon.mean.level.nc", "r")
;**********************************************************************
   YYYYMM = cd_calendar(uwnddata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)

   ; YYYYMM2 = cd_calendar(snowdata->time, 1)
   ; iStrt2  = ind(YYYYMM2.eq.yrstrt_snow)
   ; iLast2  = ind(YYYYMM2.eq.yrlast_snow)
   ; print("snow time: "+YYYYMM2(iStrt3)+"--"+YYYYMM2(iLast3))

   u_mon = uwnddata->uwnd(iStrt:iLast,:,:,:)
   air_mon = airdata->air(iStrt:iLast,:,:,:)
;**********************************************************************
   season_string = "DJF"
   u_djf = month_to_season(u_mon, season_string)
   air_djf = month_to_season(air_mon, season_string)
;**********************************************************************
   uzm = dim_avg_n_Wrap(u_djf, 3)
   tzm = dim_avg_n_Wrap(air_djf, 3)

   T = tzm
   T = tzm+273.15
   T@units= "K"
;**********************************************************************
k     = 1   ;zonal wavenumber
pi    = 4*atan(1)
g     = 9.807
a     = 6.378e6   ;earth’s radius
R     = 8.31432   ;Gas constant, J/K*mol
kappa = 1.380649e-23   ;Boltzmann constant, J/K
M     = 0.028964   ;mean mass of one mol of atmospheric particles, 0.029 kg/mol for Earth
Lb    = -0.0065   ;standard temperature lapse rate [K/m]
omega = 7.2921e-5   ;earth’s rotation frequency, rad/s

phi   = conform(T, u_djf&lat*pi/180, 2)   ;angle to radian
f     = 2*omega*sin(phi)
P     = 100*conform(T, u_djf&level, 1)   ;Pressure, unit=Pa
copy_VarCoords(T, P)

;calculate height(z) from p
Tb = 288.15   ;standard temperature (temperature at sea level) [K]
P0 = 101325   ;static pressure (pressure at sea level) [Pa]
z = P   ;[time | 48] x [level | 17] x [lat | 73]
z = (Tb/Lb)*((P/P0)^(-R*Lb/(g*M))-1)

;Scale Height
; H = R*T/(M*g)  ;(vary with T)
;or H = kappa*T/(m*g)
H = R*Tb/(M*g)  ;(as a constant)
print(H)


rho = M*P/(R*T)  ;kg/m3
rho0 = M*P0/(R*Tb)   ;rho = 1.224982

drhodz = center_finite_diff_n(rho, z, False, 1, 1)
; printMinMax(drhodz, 0)

N2 = -1*(g/rho)*drhodz  ;square of N (buoyancy frequency)
; printVarSummary(N2)
; printMinMax(N2, 0)

;Calculate the meridional potential vorticity (PV) gradient following Hu and Tung, 2002.
dudz = center_finite_diff_n(uzm, z, False, 1, 1)
dN2dz = center_finite_diff_n(N2, z, False, 1, 1)
ddudzdz = center_finite_diff_n(dudz, z, False, 1, 1)
ducosphidphi = center_finite_diff_n(uzm*cos(phi), phi, False, 1, 2)


pvitem1 = 2*omega*cos(phi)/a
pvitem2 = -1/a^2*(center_finite_diff_n(ducosphidphi/cos(phi), phi, False, 1, 2))
pvitem3 = center_finite_diff_n(uzm, z, False, 1, 1)*(f^2/(H*N2)+(f^2/N2^2)*center_finite_diff_n(N2, z, False, 1, 1)) - \
          (f^2/N2)*center_finite_diff_n(center_finite_diff_n(uzm, z, False, 1, 1), z, False, 1, 1)
dpvdphi = pvitem1 + pvitem2 + pvitem3
; printVarSummary(pvphi)

uzm_mask = mask(uzm, uzm.eq.0., False)     ;Use uzm mask to prevent 0 value in divide

rfc_ind = uzm
rfc_ind = dpvdphi/uzm_mask - (k/(a*cos(phi)))^2 - (f/(2*sqrt(N2)*H))^2
rfc_ind@long_name = "square of refraction index"
; printVarSummary(rfc_ind)
printMinMax(rfc_ind, 0)

;**********************************************************************
;Resources Setting
   res = True
   res@gsnDraw = False
   res@gsnFrame = False

   ;For Fills
   resrc = True
   resrc@cnFillPalette = "NCV_jet"
   resrc@gsnDraw = False
   resrc@gsnFrame = False
   resrc@gsnLeftString = " "
   resrc@cnFillOn = True
   resrc@cnLinesOn = False
   resrc@cnInfoLabelString = " "
   resrc@cnLineLabelsOn = False
   resrc@cnFillDrawOrder = "PreDraw"   
   resrc@lbLabelBarOn = True
   resrc@lbLabelsOn = True
   resrc@pmLabelBarWidthF = 0.5
   resrc@pmLabelBarHeightF = 0.06
   resrc@pmLabelBarOrthogonalPosF = 0.025
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   ; resrc@cnLevelSelectionMode = "ManualLevels"
   ; resrc@mpGridAndLimbOn = False
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   ; resrc@mpOutlineOn = True
   ; resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   ; resrc@mpFillOn = True
   ; resrc@mpMinLonF = 0
   ; resrc@mpMaxLonF = 360
   ; resrc@mpMaxLatF = 90
   ; resrc@mpMinLatF = 0
   ; resrc@mpCenterLonF = (resrc@mpMinLonF+resrc@mpMaxLonF)/2.
   ; resrc@mpAreaMaskingOn = True
   ; resrc@mpOceanFillColor = "white"
   ; resrc@mpLandFillColor = "Transparent"

;**********************************************************************
;Test test
   ; resrc@cnMinLevelValF = 0
   ; resrc@cnMaxLevelValF = 10
   ; resrc@cnLevelSpacingF = 1

   ; rhotm = dim_avg_n_Wrap(rho, 0)
   ; copy_VarCoords(uzm(0,:,:), rhotm)
   ; resrc@gsnCenterString = "rho Air Density kg/m^3"
   ; plot := gsn_csm_pres_hgt(wks, rhotm, resrc)
   ; draw(plot)
   ; frame(wks)

   ; Ttm = dim_avg_n_Wrap(T, 0)
   ; resrc@gsnCenterString = "T Temperature K"
   ; plot := gsn_csm_pres_hgt(wks, Ttm, resrc)
   ; draw(plot)
   ; frame(wks)

   ; N2tm = dim_avg_n_Wrap(N2, 0)
   ; copy_VarCoords(uzm(0,:,:), N2tm)
   ; resrc@gsnCenterString = "N^2 Buoyancy frequency s^-1"
   ; plot := gsn_csm_pres_hgt(wks, N2tm, resrc)
   ; draw(plot)
   ; frame(wks)

   ; Htm = dim_avg_n_Wrap(H, 0)
   ; copy_VarCoords(uzm(0,:,:), Htm)
   ; resrc@gsnCenterString = "H(scale height)"
   ; plot := gsn_csm_pres_hgt(wks, Htm, resrc)
   ; draw(plot)
   ; frame(wks)

   ; rfc_indtm = dim_avg_n_Wrap(rfc_ind, 0)
   ; resrc@gsnCenterString = "refraction index square"
   ; plot := gsn_csm_pres_hgt(wks, rfc_indtm, resrc)
   ; draw(plot)
   ; frame(wks)

   ; Ttm2 = dim_avg_n_Wrap(Ttm, 1)
   ; resrc@gsnCenterString = "Temperature Profile(DJF), K"
   ; resrc@trYReverse = True
   ; plot := gsn_csm_xy(wks, Ttm2, uzm&level, resrc)
   ; draw(plot)
   ; frame(wks)

;**********************************************************************




end