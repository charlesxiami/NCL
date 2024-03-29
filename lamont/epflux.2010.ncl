; NCL Script to calculate near-realtime Eliassen-Palm flux from NCEP Reanalysis Data
;
;*******************************************************
; Code written by Joe Barsugli joseph.barsugli@noaa.gov
; from the NOAA/ESRL PSL
; adapted by Cathy Smith cathy.smoth@noaa.gov
; last checked Nov 2009.
; modified by Joe Barsugli to add contours of EP-Flux divergence June 2010
; modified by Joe Barsugli to redo scaling of arrows in the vertical June 2010
;********************************************************
;
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"      	; functions required to
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"           	; plot.  include before
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"         	; begin
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
begin

; This version wich produces Quasi-geostrophic Eliassen-Palm  Fluxes in spherical coordinates
; Plots the EP Flux vectors in a latitude-log(pressure) coordinate
; Optionally plot the divergence of EP-Flux

; open files and get some basic coordinate information.  
calc_div=1
show_accel=0
scale_by_sqrt_p=1

yearstart=stringtointeger(getenv("yearstart"))
monstart=stringtointeger(getenv("monstart"))
daystart=stringtointeger(getenv("daystart"))
year=stringtointeger(getenv("year"))
mon=stringtointeger(getenv("mon"))
day=stringtointeger(getenv("day"))
outnameps=(getenv("outname"))
sf=stringtofloat(getenv("sc_fact_strat"))

; dataflag  says the data sampling interval,  '4xdaily' , 'dailyavg' are the only acceptable values
; here I set some constants that will be used later in the code
dataflag=getenv("dataflag")
hourstart = 0
if (dataflag .eq. "dailyavg") then
  hourlast = 0
  avgoffset = 24
else
  hourlast = 18
 avgoffset = 6
end if

utmp=(getenv("utmp"))
vtmp=(getenv("vtmp"))
ttmp=(getenv("ttmp"))

ufile = addfile(utmp,"r")
vfile = addfile(vtmp,"r")
tfile = addfile(ttmp,"r")

ntimes   = filevardimsizes(ufile,"time")
nlat     = filevardimsizes(ufile,"lat" )
nlon     = filevardimsizes(ufile,"lon" )
nlevels  = filevardimsizes(ufile,"level" )
time     = ufile->time
level    = ufile->level
lat      = ufile->lat
lon      = ufile->lon


tstart = ut_inv_calendar(yearstart,monstart,daystart,hourstart,0,0,time@units,0)
tlast = ut_inv_calendar(year,mon,day,hourlast,0,0,time@units,0)

print( (/tstart/) )
print( (/tlast/) )

; I'm assuming that the same data is available for v and t as for u, but you should check!


;  utcal to go from integers ,M,D,H ...to hours since xxx times. for beginning and end times that I want.

U = short2flt(ufile->uwnd({tstart:tlast},:,:,:))
V = short2flt(vfile->vwnd({tstart:tlast},:,:,:))
T = short2flt(tfile->air({tstart:tlast},:,:,:))

THETA = T
THETA =  T*(conform(T,level,1)/1000)^(-0.286) 
THETAzm = dim_avg_Wrap(THETA)

;  Calculate d(THETA)/dp  from vertical finite difference in log-pressure cordinates. 
; Note that dT/dp = (1/p)*dT/d(lnp)
THETAp = THETAzm   ; use assignment to copy attributes
loglevel = log(level)
THETAptemp  = center_finite_diff (THETAzm(time|:,lat|:,level|:),loglevel,False,0)   ; derivative in log coords doesn't care whether in Pa or in mb.
THETAptemp = THETAptemp/conform(THETAptemp,100.0*level,2)   ; converts "level" to pascals from millibars while dividing by pressure.
THETAptemp!0="time"   ; center_finite_diff strips coordinate names, so give them names
THETAptemp!1="lat"
THETAptemp!2="level"
THETAp = (/ THETAptemp(time|:,level|:,lat|:) /)  ; Put the reordered data into THETAp.

; za stands for zonal anomaly
; zm stands for zonal mean

Uza = dim_rmvmean_Wrap(U)
Vza = dim_rmvmean_Wrap(V)
THETAza = dim_rmvmean_Wrap(THETA)

UV = Uza*Vza
UVzm = dim_avg(UV)
UVzm!0="time"   
UVzm!1="level"
UVzm!2="lat"
UVzmtm=dim_avg_Wrap(UVzm(level|:,lat|:,time|:))

VTHETA = Vza*THETAza
copy_VarCoords(Vza,VTHETA)
VTHETAzm = dim_avg_Wrap(VTHETA)
VTHETAzmtm=dim_avg_Wrap(VTHETAzm(level|:,lat|:,time|:))

THETAptm = dim_avg(THETAp(level|:,lat|:,time|:)) ; compute time mean of d(theta)/dp

a = 6.37122e06 ;  radius of the earth
PI=3.14159265358979
phi = lat*PI/180.0     ; latitude in radians
acphi=a*cos(phi)       ; 
asphi=a*sin(phi)       ; a* sin latitude for use in calculating the divergence.
omega = 7.2921e-5      ;
f = 2*omega*sin(phi)   ; coriolis parameter

latfac=acphi*cos(phi)   ; scale factor includes extra cos(phi) for graphical display of arrows (see Edmon et al, 1980)

Fphi = -UVzmtm*conform(UVzmtm,latfac,1)
Fp = conform(VTHETAzmtm,f*acphi,1)*VTHETAzmtm/THETAptm
copy_VarMeta(UVzmtm,Fphi)
copy_VarMeta(VTHETAzmtm,Fp)

; Only compute divergence if it is requested

if (calc_div .eq. 1) then
; take derivative w.r.t latitude  using  1/[a cos(phi)]  d/dphi [cos(phi)*X] =  d/d [asin(phi)] Fphi
; note that Fphi already has the extra  factor of cos(phi)
  EPdiv1  = center_finite_diff(Fphi,asphi,False,0)
; take derivative w.r.t pressure  (in Pascals, hence the factor of 100.0)
;  Need to re-order the coordinates to pass to center_finite_diff 
  EPdiv2temp  = center_finite_diff(Fp(lat|:,level|:),level*100.0,False,0);
  EPdiv2temp!0="lat" 
  EPdiv2temp!1="level"
  EPdiv2 = (/EPdiv2temp(level|:,lat|:) /)  ; And then re-order the coordiantes again  (NCL awkwardness! will be fixed in NCL 5.2)
  EPdiv = EPdiv1 + EPdiv2    ;   Add these together to get the divergence of F
  copy_VarMeta(Fp,EPdiv)
else
  EPdiv = 0.0*Fp;
  copy_VarMeta(Fp,EPdiv)
end if
; interpolate to a regular grid in log(pressure) ; This dimension re-ordering due to NCL awkwardness
; show  every other latitude -- excluding the poles. 

level_int = 10^fspan(3,1,15)   ; interpolation targets
lat_int = lat(1:71:2)
linlog=2                       ; Option to int2p that gives log-interpolation with no extrapolation
Fp_int2 = int2p(level,Fp(lat|1:71:2,level|:),level_int,linlog)
Fphi_int2 = int2p(level,Fphi(lat|1:71:2,level|:),level_int,linlog)
EPdiv_int2 = int2p(level,EPdiv(lat|1:71:2,level|:),level_int,linlog)
; copy coords
Fp_int2!0="lat_int"
Fp_int2!1="level_int"
copy_VarMeta(Fp_int2,Fphi_int2)
copy_VarMeta(Fp_int2,EPdiv_int2)
; re-order
Fp_int = Fp_int2(level_int|:,lat_int|:)
Fphi_int = Fphi_int2(level_int|:,lat_int|:)
EPdiv_int = EPdiv_int2(level_int|:,lat_int|:)

; compute acceleration from div(F).   Note I am taking the rate of chagne in angular momentum per unit mass and dividing by a*cos(phi).  This has numerical problems at the pole due
;      due to finite differences used.  Thus we are not showing the polar points.  

if (show_accel .eq. 1) then
  dudt_int = 86400.0*EPdiv_int/conform(EPdiv_int,a*cos(phi(1:71:2)),1) ; 
  copy_VarMeta(EPdiv_int,dudt_int)
else
  dudt_int = 0.0*EPdiv_int
end if


; Scale the vectors for display 
; First scale according to Edmon et al. for pressure coordinates
;      (even though I am using log-p display -- not entirely consistent as the arrows may "look" divergent when they are not, but better visibility in practice)
Fp_int = Fp_int*conform(Fp_int,cos(phi(1:71:2)),1)   
Fphi_int = Fphi_int/a

; Next scale by the relative ranges of the two axes of the plot(  3.14 radians by 10^5 Pa)
Fp_int = Fp_int/1.0e5
Fphi_int = Fphi_int/PI
; Optionaly scale by sqrt(presure)
if (scale_by_sqrt_p .eq. 1)
rhofac = sqrt(1000/level_int)
Fp_int = Fp_int*conform(Fp_int,rhofac,0)
Fphi_int = Fphi_int*conform(Fphi_int,rhofac,0)
end if

; Scale by a magnification factor above 100 mb. 
strat1 = new(15,float)
strat1 = (/ 1., 1., 1., 1., 1., 1., 1.,1., sf, sf, sf, sf, sf, sf, sf/)
stratmask=conform(Fp_int,strat1,0)
Fp_int = Fp_int*stratmask
Fphi_int = Fphi_int*stratmask

monthname = (/ "January  ","February ","March    ","April    ","May      ","June     ","July     ","August   ","September","October  ","November ","December " /)

if (mon .le. 9 ) then
ch1 = "0"
else 
ch1 = ""
end if
if (day .le. 9 ) then
ch2 = "0"
ch3 = " "
else 
ch2 = ""
ch3 = ""
end if

; avgper is calculated from the first and last times (in hours).  avgoffset is determined from the dataflag
; Note:  round(.,3) outputs type integer.
avgper = round((tlast - tstart + avgoffset)/24 ,3)
if ( avgper .eq. 1 ) then
vectitle =   "EPFlux  " + avgper + " day average  " +  ch3 + day + " " + monthname(mon-1) + " " + year
else 
vectitle =   "EPFlux  " + avgper + " day average ending  " + ch3 + day + " " + monthname(mon-1) + " " + year
end if

filename = "EPFlux." + sprinti("%i",avgper) + "davg."+ getenv("year") + ch1 + getenv("mon") + ch2 + getenv("day")
filename=outnameps

;************************************************
; Create Plot 
;************************************************
; create vector plot resources for pressure-level grid  (not used for plotting in this version)
  res_vec = True
  res_vec@vfYArray              = level                ; use pressure for y axis
  res_vec@vfXArray              = lat             ; use lat for x axis
  res_vec@tiXAxisString         = "latitude"           ; x-axis label
  res_vec@tiYAxisString         = "pressure (mb)"         ; y-axis label
  res_vec@trYReverse            = True                 ; reverse y-axis
  res_vec@gsnSpreadColors       = True		       	    ; use full colormap
  res_vec@vcRefMagnitudeF       = 200                 ; add a reference vector
  res_vec@vcRefLengthF          = 0.05                ; what the ref length is
  res_vec@vcMonoLineArrowColor  = False                ; vec's colored by their mag
  res_vec@pmLabelBarDisplayMode = "Always"          ; Turn on a label bar.
  res_vec@pmLabelBarWidthF      = 0.08              ; make it thinner
  res_vec@lbPerimOn             = False             ; no box around it
  res_vec@gsnYAxisIrregular2Log = True                 ; set y-axis to log scale
  res_vec@tiMainString          = vectitle		           ; plot title
  res_vec@tiMainFontHeightF     = 0.0185
  res_vec@tiXAxisFontHeightF    = 0.0185
  res_vec@tiYAxisFontHeightF    = 0.0185

;  You can't assign new coordinates to a resource because the attributes are of different sizes
;  You can't delete just the one attribute, so you have to list them all over again.

;  Create vector plot resources for interpolated grid

  res_vec_int = res_vec
  delete(res_vec_int@vfXArray)
  delete(res_vec_int@vfYArray)
  res_vec_int@vfYArray              = level_int                ; use pressure for y axis
  res_vec_int@vfXArray              = lat(1:71:2)             ; use lat for x axis
  res_vec_int@tiXAxisString         = "latitude"           ; x-axis label
  res_vec_int@tiYAxisString         = "pressure (mb)  log-scale"         ; y-axis label
  res_vec_int@vpWidthF              = 0.60
  res_vec_int@vpHeightF             = 0.35
;  res_vec_int@lbLabelBarOn          = False                     ; turn off label bar
;  res_vec_int@gsnMaximize           = True
 res_vec_int@gsnDraw                = False                     ; turn off automatic draw -- allows for manual overalying of plots
 res_vec_int@gsnFrame               = False                     ; turn off automatic frame -- allows for manual overalying of plots
 res_vec_int@vcLevelSelectionMode = "ManualLevels"
 res_vec_int@vcLevelSpacingF  = 25.0
 res_vec_int@vcMinLevelValF = 0.0
 res_vec_int@vcMaxLevelValF = 400.0
 res_vec_int@vcRefAnnoOn             = False              ; turn off ref wind barb


; Create contour plot resources for interpolated grid
  res_con_int                       = True
  res_con_int@sfYArray              = level_int                ; use pressure for y axis
  res_con_int@sfXArray              = lat(1:71:2)             ; use lat for x axis
;  res_con_int@cnFillOn             = True     ; turn on color fill
  res_con_int@trYReverse            = True                 ; reverse y-axis
  res_con_int@gsnYAxisIrregular2Log = True                 ; set y-axis to log scale
 res_con_int@gsnDraw                = False
 res_con_int@gsnFrame               = False
 res_con_int@gsnContourZeroLineThicknessF = 0.0
 res_con_int@gsnContourPosLineDashPattern = 2
; res_con_int@gsnContourNegLineDashPattern = 2
 res_con_int@cnSmoothingOn          = True
 res_con_int@cnLineLabelsOn         = False
 res_con_int@gsnContourLineThicknessesScale  = 0.5

; Hide the 1000 mb level for the divergence and acceleration
dudt_int@_FillValue = -999.0
dudt_int(0,:)=dudt_int@_FillValue
EPdiv_int@_FillValue = -999.0
EPdiv_int(0,:)=EPdiv_int@_FillValue

; open file and create graphic
  print(filename)
  wksvec_int  = gsn_open_wks("ps",filename)                ; Opens a ps file 
  gsn_define_colormap(wksvec_int,"rainbow") 
  plotvec = gsn_vector(wksvec_int,Fphi_int,Fp_int,res_vec_int)     ; creates plot
  if (calc_div .eq. 1) then
    if (show_accel .eq. 1) then 
      res_con_int@cnLevelSpacingF        = 5.                   ;Contour level Spacing
      plotvec2 = gsn_contour(wksvec_int,dudt_int,res_con_int)     ; creates plot for du/dt = div(F)/(a*cos(phi))
    else
      res_con_int@cnLevelSpacingF        = 200.                   ;Contour level Spacing
      plotvec2 = gsn_contour(wksvec_int,EPdiv_int,res_con_int)     ; creates plot for div(F)
    end if
    overlay(plotvec,plotvec2)
  end if
  draw(plotvec)

; add PSL identifier text to plot 
 restxt = True 
  restxt@txFontHeightF = 0.01 
  restxt@txJust        = "CenterLeft"       
  gsn_text_ndc(wksvec_int, "NOAA/PSL",0.12,0.37,restxt) 
  frame(wksvec_int)
;***********************************************

print ( "done" )
end
