load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; SON
season = "SON"
idx_A = 8
idx_B = 9
idx_C = 10

yearstart = 1979
yearend = 2017
nyear = yearend - yearstart + 1

ttestval = 2.023

mylev = 200

snow = asciiread("../snow/south-interannual.txt",(/nyear/),"float")

ufile = addfile("/home/qqf/Documents/PhD-Working/mypaper/ncfile/ncep2nc/uwnd.mon.mean.nc","r")
vfile = addfile("/home/qqf/Documents/PhD-Working/mypaper/ncfile/ncep2nc/vwnd.mon.mean.nc","r")

us = short2flt(ufile->uwnd)
vs = short2flt(vfile->vwnd)

lat = ufile->lat
lon = ufile->lon
time = ufile->time
level = ufile->level
year=calendar_decode2(ufile->time,0)
year_idx=ind(year(:,0).ge.(yearstart).and.year(:,0).le.(yearend))
level_wind = ufile->level
lev_wind = ind(level_wind.eq.mylev)

u = us(year_idx,lev_wind,:,:)
v = vs(year_idx,lev_wind,:,:)

uA = u(idx_A::12,:,:)
uB = u(idx_B::12,:,:)
uC = u(idx_C::12,:,:)
u_season = (uA + uB + uC) / 3.0 
copy_VarMeta(uA, u_season)

vA = v(idx_A::12,:,:)
vB = v(idx_B::12,:,:)
vC = v(idx_C::12,:,:)
v_season = (vA + vB + vC) / 3.0 

pi = atan(1.0)*4.
f =  2.*2.*pi/(60.*60.*24.)*sin(pi/180. * lat)

rv = uv2vr_cfd(u_season,v_season,lat,lon,3)
av = rv + conform_dims(dimsizes(rv), f, 1)

av_anom = regCoef_n(snow, av, 0, 0)
av_mean = dim_avg_n_Wrap(av, 0)

div = uv2dv_cfd(u_season,v_season,lat,lon,3)

dv = dv2uvF_Wrap(div)
dv_u = dv(0,:,:,:)
dv_v = dv(1,:,:,:)

dv_u_anom = regCoef_n(snow, dv_u, 0, 0)
dv_v_anom = regCoef_n(snow, dv_v, 0, 0)

dv_u_mean = dim_avg_n_Wrap(dv_u, 0)
dv_v_mean = dim_avg_n_Wrap(dv_v, 0)

s = -uv2dv_cfd(dv_u_anom*av_mean,dv_v_anom*av_mean,lat,lon,3)-uv2dv_cfd(dv_u_mean*av_anom,dv_v_mean*av_anom,lat,lon,3)

ss = -uv2dv_cfd(dv_u*av, dv_v*av, lat, lon, 3)


sssy = regCoef_n(snow, ss, 0, 0)


tval_air = reshape(abs(sssy@tval),(/dimsizes(sssy(:,0)),dimsizes(sssy(0,:))/))
tval_air(0,:) = 0

;sss = sssy * 1e11


;copy_VarMeta(u(0,:,:), s)
;
ab = shaeC(sssy)
ssa = exp_tapershC(ab, 19.4, 2)
sss = shseC(ssa, dimsizes(lon))*1e11
printVarSummary(sss)
copy_VarMeta(u(0,:,:), sss)
copy_VarMeta(u(0,:,:), tval_air)


;cd = shaeC(tval_air)
;sscd = exp_tapershC(cd, 19.4, 2)
;ssscd = shseC(sscd, dimsizes(lon))*1e11
;copy_VarMeta(u(0,:,:), sss)
;
;copy_VarMeta(u(0,:,:), ssscd)



res = True
res@gsnDraw=False
res@gsnFrame=False
res@gsnSpreadColors=True
res@gsnAddCyclic=True
res@gsnMaximize=True


res@mpLimitMode = "LatLon"
res@mpMinLatF = -30
res@mpMinLonF = 40
res@mpMaxLonF = 285



res@mpCenterLonF=180

res@cnFillOn=True
res@cnLinesOn=False
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels=(/-2.25,-1.75,-1.25,-0.75,-0.25,0,0.25,0.75,1.25,1.75,2.25/)
;res@cnLevels=(/-4.5,-3.5,-2.5,-1.5,-0.5,0,0.5,1.5,2.5,3.5,4.5/)
res@cnFillColors=(/2,3,5,6,7,0,0,13,14,15,16,17/)

res@lbOrientation="Vertical"

res@gsnLeftString=""
res@gsnRightString=""

wks = gsn_open_wks("png", "source-"+season)
gsn_define_colormap(wks,"BlueDarkRed18")


map = gsn_csm_contour_map(wks, sss, res)

res2 = True
res2@cnFillOn=False
res2@cnLinesOn=True
res2@gsnLeftString=""
res2@gsnRightString=""
res2@gsnDraw=False
res2@gsnFrame=False
res2@gsnAddCyclic=True

res2@cnInfoLabelOn=False
res2@cnLevelSelectionMode = "ExplicitLevels"
res2@cnLevels=ispan(20,100,10)

res2@cnLineThicknesses = 6

map2 = gsn_csm_contour(wks, dim_avg_n_Wrap(u_season, 0), res2)
overlay(map, map2)



resp = True
resp@gsLineColor      = "gray" ; polylines color
resp@gsLineThicknessF = 2    ; polylines thickness

fty=asciiread("./tibet_shape",(/2066,2/),"float")
poli=gsn_add_polyline(wks,map,fty(:,0),fty(:,1),resp)



resshade=True
resshade@pmTickMarkDisplayMode="Always"
resshade@cnFillOn=False
resshade@cnLinesOn=True
resshade@cnLineLabelsOn=False
resshade@cnMonoFillPattern=False
resshade@cnMonoFillColor=True
resshade@gsnDraw=False
resshade@gsnFrame=False
resshade@gsnLeftString=""
resshade@gsnRightString=""
resshade@lbLabelBarOn=False
resshade@cnInfoLabelOn=False

resshade@cnLevelSelectionMode="ExplicitLevels"
resshade@cnLevels=(/ttestval/)
resshade@cnLineThicknessF = 4 
resshade@cnLineColor = "purple"


map2 = gsn_csm_contour(wks, tval_air, resshade)

overlay(map,map2)

tibet_lat_low = 30
tibet_lat_high = 40.0
tibet_lon_left = 70.0
tibet_lon_right = 82.0
ypts = (/tibet_lat_low,  tibet_lat_low, tibet_lat_high ,  tibet_lat_high, tibet_lat_low/)
xpts = (/tibet_lon_left, tibet_lon_right, tibet_lon_right, tibet_lon_left, tibet_lon_left/)
resc=True
resc@gsLineColor      = "red4"                     ; color of lines
resc@gsLineThicknessF = 3.0                       ; thickness of lines
dum5 = new(4,graphic)
dum6 = new(4,graphic)
dum7 = new(4,graphic)
dum8 = new(4,graphic)
do i = 0 , 3
  dum5(i)=gsn_add_polyline(wks,map,xpts(i:i+1),ypts(i:i+1),resc)
  dum6(i)=gsn_add_polyline(wks,map,xpts(i:i+1),ypts(i:i+1),resc)
  dum7(i)=gsn_add_polyline(wks,map,xpts(i:i+1),ypts(i:i+1),resc)
  dum8(i)=gsn_add_polyline(wks,map,xpts(i:i+1),ypts(i:i+1),resc)
end do


draw(map)
frame(wks)
