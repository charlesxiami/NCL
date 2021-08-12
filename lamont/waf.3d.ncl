; 3-D wave-activity flux derived by Takaya and Nakamura (1999, 2001)
; See (38) of Takaya and Nakamura (2001, JAS)
;
; Used data:
;  Monthly-mean data of NCEP/NCAR reanalys 1
;   geopotential height (hgt: m) ; hgt.mon.mean.nc
;
;  Monthly climatology of NCEP/NCAR reanalys 1
;   geopotential height (hgt: m) ; hgt.mon.mean.nc
;   air tempeature (air: degC)   ; air.mon.mean.nc
;   zonal wind (uwnd: m/s)       ; uwnd.mon.mean.nc
;   meridional wind (vwnd: m/s)  ; vwnd.mon.mean.nc
;
; The data are available at
; http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.html
;
; The period for calcuation is January, 1990 to December, 1990
; (you can modify this by changing fyear,fmon, lyear, lmon)
;
; The unit of level is [hPa]
;
; Basic state: monthly climatology
;
; Perturbation: deviation from climatology
;
; Calculating the flux for each month of input data.
;
; Note that
; (i) "p" (pressure) in Eq. (5.7) is dimensionless (pressure/1000mb)


; Output files are
; x-component:  TN2001-Fx.monthly.1990.nc
; y-component:  TN2001-Fy.monthly.1990.nc
; z-component:  TN2001-Fz.monthly.1990.nc
; QG stream function anomaly: psidev.monthly.1990.nc
; Brunt Vaisala frequency: NN.monthly.1990.nc

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; The first date of calculation
fyear = 1972
fmon = 1

; The last date of calculation
lyear = 2015
lmon = 12

yrstrt = fyear*100+fmon
yrlast = lyear*100+lmon

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

;  direcotry name
   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"

;**************************************************
   wks=gsn_open_wks("pdf", plotpath+"snow.waf")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
  airdata = addfile(nceppath+"air.mon.level.mean.nc", "r")
  slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
  hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
  uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
  vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")

   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   z_mon = hgtdata->hgt(iStrt:iLast,:,{latS:latN},{lonL:lonR})
   t_mon = airdata->air(iStrt:iLast,:,{latS:latN},{lonL:lonR})
   u_mon = uwnddata->uwnd(iStrt:iLast,:,{latS:latN},{lonL:lonR})
   v_mon = vwnddata->vwnd(iStrt:iLast,:,{latS:latN},{lonL:lonR})

zvararr = z_mon
tvararr = t_mon
uvararr = u_mon
vvararr = v_mon

;monthly climatology
zvararr_ts = zvararr(level|:,lat|:,lon|:,time|:)
tvararr_ts = tvararr(level|:,lat|:,lon|:,time|:)
uvararr_ts = uvararr(level|:,lat|:,lon|:,time|:)
vvararr_ts = vvararr(level|:,lat|:,lon|:,time|:)

z_clmon = clmMonLLLT( zvararr_ts )
t_clmon = clmMonLLLT( tvararr_ts )
u_clmon = clmMonLLLT( uvararr_ts )
v_clmon = clmMonLLLT( vvararr_ts )

;dates, lev and lat, lon
time = zvararr&time
level = zvararr&level
lat = zvararr&lat
lon = zvararr&lon

ntime = dimsizes(time)
nlat = dimsizes(lat)
nlon = dimsizes(lon)
nlevel = dimsizes(level)

utc_date = cd_calendar(zvararr&time,0)
syear = tointeger(utc_date(0,0))
smon = tointeger(utc_date(0,1))

; new "time array" for output data
fstep = (fyear - syear)*12 + fmon - smon
lstep = (lyear - syear)*12 + lmon - smon
ctime = time(fstep:lstep)
nctime = dimsizes(ctime)

;selected arrays
szvar = new((/nctime,nlevel,nlat,nlon/),float)

clzvar = new((/nctime,nlevel,nlat,nlon/),float)
cltvar = new((/nctime,nlevel,nlat,nlon/),float)
cluvar = new((/nctime,nlevel,nlat,nlon/),float)
clvvar = new((/nctime,nlevel,nlat,nlon/),float)

do istep = 0,nctime-1
  iyear = tointeger(utc_date(fstep + istep,0))
  imon = tointeger(utc_date(fstep + istep,1))

  clzvar(istep,:,:,:) = z_clmon(:,:,:,imon-1)
  cltvar(istep,:,:,:) = t_clmon(:,:,:,imon-1)
  cluvar(istep,:,:,:) = u_clmon(:,:,:,imon-1)
  clvvar(istep,:,:,:) = v_clmon(:,:,:,imon-1)

end do

; printVarSummary(zvararr)

;height anomaly
szvar = zvararr(fstep:lstep,:,:,:)
zavar = szvar - clzvar

;  Gas constant
gc=290
;  Gravitational acceleration
ga=9.80665

;  Radius of the earth
re=6378388

; scale height
sclhgt=8000.

; pi
pi = atan(1.0)*4.


; Coriolis parameter
f =  2.*2.*pi/(60.*60.*24.)*sin(pi/180. * lat(:))
f!0 = "lat"
f&lat = lat
f@_FillValue = zvararr@_FillValue

; missing for 10S - 10N
do ilat = 0, nlat-1
 if (abs(lat(ilat) ).lt. 10. ) then
  f(ilat)= f@_FillValue
 end if
end do

; cosine
coslat = cos(lat(:)*pi/180.)

; 1-D -> 4-D
; printVarSummary(zvararr)
leveltmp = conform_dims(dimsizes(zvararr),level,1)
coslattmp = conform_dims(dimsizes(zvararr),coslat,2)
ftmp = conform_dims(dimsizes(zvararr),f,2)
; printVarSummary(level)
; leveltmp = conform_dims(dimsizes(zvararr_ts),level,1)
; coslattmp = conform_dims(dimsizes(zvararr_ts),coslat,2)
; ftmp = conform_dims(dimsizes(zvararr_ts),f,2)

; status_exit(1)


; ; 1-D -> 4-D
; leveltmp = conform_dims(dimsizes(zvar),level,1)
; coslattmp = conform_dims(dimsizes(zvar),coslat,2)
; ftmp = conform_dims(dimsizes(zvar),f,2)


; vertical gradient of potential temperature  (K/m)
dthetadz = center_finite_diff_n(cltvar*(1000./leveltmp)^0.286,-sclhgt*log(level/1000),False,0,1)

; Brunt Vaisala frequency
NN = (gc*(leveltmp/1000.)^0.286)/sclhgt * dthetadz
NN@_FillValue = cltvar@_FillValue
NN = where(NN .gt. 0, NN, NN@_FillValue)

; magnitude of climatological wind
cumag = sqrt(cluvar^2 + clvvar^2)
cumag@_FillValue = cluvar@_FillValue
cumag = where(cumag .gt. 0, cumag, cumag@_FillValue)

; QG steam function for anomaly
; psidev = zavar*ga /ftmp
psidev = zavar /ftmp  ; as zvar is alreeady Hgt*g

;dpsidev/dlon
dpsidevdlon =  center_finite_diff_n(psidev,lon*pi/180.,True,0,3)

;ddpsidev/dlonlon
ddpsidevdlonlon =  center_finite_diff_n(dpsidevdlon,lon*pi/180.,True,0,3)

;dpsidev/dlat
dpsidevdlat = center_finite_diff_n(psidev, lat*pi/180., False,0,2)

;ddpsidev/dlonlat
ddpsidevdlonlat =  center_finite_diff_n(dpsidevdlon,lat*pi/180.,False,0,2)

;ddpsidev/dlatdlat
ddpsidevdlatlat = center_finite_diff_n(dpsidevdlat, lat*pi/180.,False,0,2)

;dpsidev/dz
dpsidevdz = center_finite_diff_n(psidev, -sclhgt*log(level/1000),False,0,1)

;ddpsidev/dlondz
ddpsidevdlonz = center_finite_diff_n(dpsidevdlon, -sclhgt*log(level/1000),False,0,1)

;ddpsidev/dlatdz
ddpsidevdlatz = center_finite_diff_n(dpsidevdlat, -sclhgt*log(level/1000),False,0,1)

xuterm = (dpsidevdlon*dpsidevdlon - psidev*ddpsidevdlonlon)
xvterm = (dpsidevdlon*dpsidevdlat - psidev*ddpsidevdlonlat)
;yuterm = xvterm
yvterm = (dpsidevdlat*dpsidevdlat - psidev*ddpsidevdlatlat)

zuterm = (dpsidevdlon*dpsidevdz - psidev*ddpsidevdlonz)
zvterm = (dpsidevdlat*dpsidevdz - psidev*ddpsidevdlatz)

; Mask out where westerlies is small or negative (less than 5 m/s).
;  by using mask

;x-component of (38)
Fx = mask( leveltmp/1000./(2.*cumag*re*re)*( cluvar/coslattmp * xuterm + clvvar * xvterm), cluvar.lt.5,False)

;y-component
Fy = mask(leveltmp/1000./(2.*cumag*re*re)*( cluvar*xvterm + coslattmp*clvvar*yvterm),  cluvar.lt.5,False)

;z-component
Fz = mask(leveltmp/1000.*ftmp*ftmp/(2.*cumag*NN*re)*(cluvar*zuterm + coslattmp*clvvar*zvterm), cluvar.lt.5, False)

; for output
Fx!0 = "time"
Fx&time = ctime
Fx!1 = "level"
Fx&level = level
Fx!2 = "lat"
Fx&lat = lat
Fx!3 = "lon"
Fx&lon = lon

Fy!0 = "time"
Fy&time = ctime
Fy!1 = "level"
Fy&level = level
Fy!2 = "lat"
Fy&lat = lat
Fy!3 = "lon"
Fy&lon = lon

Fz!0 = "time"
Fz&time = ctime
Fz!1 = "level"
Fz&level = level
Fz!2 = "lat"
Fz&lat = lat
Fz!3 = "lon"
Fz&lon = lon

psidev!0 = "time"
psidev&time = ctime
psidev!1 = "level"
psidev&level = level
psidev!2 = "lat"
psidev&lat = lat
psidev!3 = "lon"
psidev&lon = lon

zdev = zavar/ga
zdev!0 = "time"
zdev&time = ctime
zdev!1 = "level"
zdev&level = level
zdev!2 = "lat"
zdev&lat = lat
zdev!3 = "lon"
zdev&lon = lon

NN!0 = "time"
NN&time = ctime
NN!1 = "level"
NN&level = level
NN!2 = "lat"
NN&lat = lat
NN!3 = "lon"
NN&lon = lon

copy_VarMeta(zdev, clzvar)
copy_VarMeta(Fx, cltvar)
copy_VarMeta(Fx, cluvar)
copy_VarMeta(Fx, clvvar)


Fx@units = "m^2/s^2"
Fx@units = "m^2/s^2"
Fz@units = "m^2/s^2"

psidev@units = "m^2/s"

zdev@units = "m**2 s**-2"

NN@units = "1/s^2"

; printVarSummary(Fx)
; printVarSummary(Fz)
;---------------------------------------------------------------------
;Output
  dirout = "$HOME/data/WAF/"
  ncWAF =     addfile(dirout+"WAF.mon"+fyear+"-"+lyear+".nc","c")
  ; ncFx =     addfile(dirout+"Fx.mon.nc","c")
  ; ncFy =     addfile(dirout+"Fy.mon.nc","c")
  ; ncFz =     addfile(dirout+"Fz.mon.nc","c")
  ; ncZdev   = addfile(dirout+"Zdev.mon.nc","c")
  ; ncpsidev = addfile(dirout+"psidev.mon.nc","c")
  ; ncNN =     addfile(dirout+"NN.mon.nc","c")  

  ncWAF->Fx = Fx
  ncWAF->Fy = Fy
  ncWAF->Fz = Fz
  ; ncWAF->psidev = psidev
  ncWAF->Zdev = zdev
  ; ncFx->Fx = Fx
  ; ncFy->Fy = Fy
  ; ncFz->Fz = Fz
  ; ncpsidev->psidev = psidev
  ; ncZdev->Zdev = zdev  

  ; ncNN->NN = NN  

  ; ncWAF->clzvar=clzvar
  ; ncWAF->ctvar=cltvar
  ncWAF->cluvar=cluvar
  ncWAF->clvvar=clvvar


;---------------------------------------------------------------------
;multi months & seasonal mean
;    season = "DJF"
;    Fx_djf0 = month_to_season(Fx, season)
;    Fx_djf = Fx_djf0(1,:,:,:)

;    Fy_djf0 = month_to_season(Fy, season)
;    Fy_djf = Fy_djf0(1,:,:,:)

;    Fz_djf0 = month_to_season(Fz, season)
;    Fz_djf = Fz_djf0(1,:,:,:)

;    nmonth = 9
;    nyrs = lyear - fyear + 1
;    ndimz = dimsizes(Fz)
;    Fz1 = dim_avg_n_Wrap(Fz, 3)
;    Fz2 = dim_avg_n_Wrap(Fz1(:,:,{60:}), 2)
;    Fz_multi = new((/nyrs-1, nmonth, ndimz(1)/), float)
;    do k = 0, nmonth -1 
;      do i = 0, nyrs - 2
;        Fz_multi(i,k,:) = Fz2(6+k+i*12,:)
;      end do
;      copy_VarCoords(Fz2(0:nyrs-2,:), Fz_multi(:,k,:))
;    end do
;    printVarSummary(Fz_multi)


; ;---------------------------------------------------------------------
; ;snow index & regression

;    snow_son_pc1 = asciiread(indexpath+"snow.son.dt.pc1"+".txt", -1, "float")
;    snow_son_pc2 = asciiread(indexpath+"snow.son.dt.pc2"+".txt", -1, "float")

;    imidyr = 20 
;    pc1_p1 = snow_son_pc1(0:imidyr)
;    pc1_p2 = snow_son_pc1(imidyr+1:)

;    pc2_p1 = snow_son_pc2(0:imidyr)
;    pc2_p2 = snow_son_pc2(imidyr+1:)

;   snow_index = pc1_p1

;   sci_fz_rc0 = regCoef_n(snow_index, Fz_multi, 0, 0)*1e4
;   copy_VarCoords(Fz_multi(0,:,:), sci_fz_rc0)
;   sci_fz_cor0 = escorc_n(snow_index, Fz_multi, 0, 0)
;   df_ncep_multi0 = sci_fz_cor0
;   df_ncep_multi0 = nyrs - 2 - 1
;   p_fz0 = student_t(sci_fz_cor0*sqrt(df_ncep_multi0/(1- sci_fz_cor0^2)), df_ncep_multi0)
;   copy_VarCoords(Fz_multi(0,:,:), p_fz0)
;   sci_fz_rc0!0 = "time"
;   p_fz0!0 = "time"
;   printMinMax(sci_fz_rc0, 0)
;   printMinMax(p_fz0, 0)

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

   res_circ = resrc
   res_circ@gsnLeftStringFontHeightF = 0.015
   res_circ@gsnRightStringFontHeightF = 0.015
   res_circ@pmLabelBarOrthogonalPosF = 0.05
   ; res_circ@vpWidthF = 0.75
   ; res_circ@vpHeightF = 0.3
   ; res_circ@gsnLeftString = "Height x time HGT regressed on PC1"
   res_circ@gsnRightString = " "   
   ; res_circ@tmXBLabels = new(nmonth, "string")
   res_circ@tmXBMode = "Explicit"
   ; res_circ@tmXBLabelsOn = True
   ; res_circ@tmXBValues = ispan(1, nmonth, 1)
   res_circ@tmXBLabels = (/"J","A","S","O","N","D","J","F","M"/)


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
   rescor@cnFillScaleF = 2
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillOpacityF = 1.0
   rescor@cnFillDrawOrder = "PreDraw"
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




end
