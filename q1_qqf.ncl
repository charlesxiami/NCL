load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

season="MAM"
;idx_A = 5
;idx_B = 6
;idx_C = 7
idx_A = 2
idx_B = 3
idx_C = 4

ttestval = 2.040

dlwrf_sfc_file = addfile("./ncep2nc/dlwrf.sfc.mon.mean.nc","r")
dswrf_ntat_file = addfile("./ncep2nc/dswrf.ntat.mon.mean.nc","r")
dswrf_sfc_file = addfile("./ncep2nc/dswrf.sfc.mon.mean.nc","r")
lhtfl_sfc_file = addfile("./ncep2nc/lhtfl.sfc.mon.mean.nc","r")
prate_sfc_file = addfile("./ncep2nc/prate.sfc.mon.mean.nc","r")
shtfl_sfc_file = addfile("./ncep2nc/shtfl.sfc.mon.mean.nc","r")
ulwrf_ntat_file = addfile("./ncep2nc/ulwrf.ntat.mon.mean.nc","r")
ulwrf_sfc_file = addfile("./ncep2nc/ulwrf.sfc.mon.mean.nc","r")
uswrf_ntat_file = addfile("./ncep2nc/uswrf.ntat.mon.mean.nc","r")
uswrf_sfc_file = addfile("./ncep2nc/uswrf.sfc.mon.mean.nc","r")
air_sfc_file = addfile("./ncep2nc/air.2m.mon.mean.nc","r")

lat=dlwrf_sfc_file->lat
lon=dlwrf_sfc_file->lon


year=calendar_decode2(dlwrf_sfc_file->time,0)
year_idx=ind(year(:,0).ge.1979.and.year(:,0).le.2009)

dlwrf_sfc_data  = short2flt(dlwrf_sfc_file->dlwrf)
dswrf_ntat_data = short2flt(dswrf_ntat_file->dswrf)
dswrf_sfc_data  = short2flt(dswrf_sfc_file->dswrf)
lhtfl_sfc_data  = short2flt(lhtfl_sfc_file->lhtfl)
prate_sfc_data  = short2flt(prate_sfc_file->prate)
shtfl_sfc_data  = short2flt(shtfl_sfc_file->shtfl)
ulwrf_ntat_data = short2flt(ulwrf_ntat_file->ulwrf)
ulwrf_sfc_data  = short2flt(ulwrf_sfc_file->ulwrf)
uswrf_ntat_data = short2flt(uswrf_ntat_file->uswrf)
uswrf_sfc_data  = short2flt(uswrf_sfc_file->uswrf)
air_sfc_data = short2flt(air_sfc_file->air)

dlwrf_sfc_year  = dlwrf_sfc_data(year_idx,:,:)
dswrf_ntat_year = dswrf_ntat_data(year_idx,:,:)
dswrf_sfc_year  = dswrf_sfc_data(year_idx,:,:)
lhtfl_sfc_year  = lhtfl_sfc_data(year_idx,:,:)
prate_sfc_year  = prate_sfc_data(year_idx,:,:)
shtfl_sfc_year  = shtfl_sfc_data(year_idx,:,:)
ulwrf_ntat_year = ulwrf_ntat_data(year_idx,:,:)
ulwrf_sfc_year  = ulwrf_sfc_data(year_idx,:,:)
uswrf_ntat_year = uswrf_ntat_data(year_idx,:,:)
uswrf_sfc_year  = uswrf_sfc_data(year_idx,:,:)
air_sfc_year = air_sfc_data(year_idx,0,:,:)

dlwrf_sfc  = (dlwrf_sfc_year(idx_A::12,:,:)+dlwrf_sfc_year(idx_B::12,:,:)+dlwrf_sfc_year(idx_C::12,:,:))/3.0
dswrf_ntat = (dswrf_ntat_year(idx_A::12,:,:)+dswrf_ntat_year(idx_B::12,:,:)+dswrf_ntat_year(idx_C::12,:,:))/3.0
dswrf_sfc  = (dswrf_sfc_year(idx_A::12,:,:)+dswrf_sfc_year(idx_B::12,:,:)+dswrf_sfc_year(idx_C::12,:,:))/3.0
lhtfl_sfc  = (lhtfl_sfc_year(idx_A::12,:,:)+lhtfl_sfc_year(idx_B::12,:,:)+lhtfl_sfc_year(idx_C::12,:,:))/3.0
prate_sfc  = (prate_sfc_year(idx_A::12,:,:)+prate_sfc_year(idx_B::12,:,:)+prate_sfc_year(idx_C::12,:,:))/3.0
shtfl_sfc  = (shtfl_sfc_year(idx_A::12,:,:)+shtfl_sfc_year(idx_B::12,:,:)+shtfl_sfc_year(idx_C::12,:,:))/3.0
ulwrf_ntat = (ulwrf_ntat_year(idx_A::12,:,:)+ulwrf_ntat_year(idx_B::12,:,:)+ulwrf_ntat_year(idx_C::12,:,:))/3.0
ulwrf_sfc  = (ulwrf_sfc_year(idx_A::12,:,:)+ulwrf_sfc_year(idx_B::12,:,:)+ulwrf_sfc_year(idx_C::12,:,:))/3.0
uswrf_ntat = (uswrf_ntat_year(idx_A::12,:,:)+uswrf_ntat_year(idx_B::12,:,:)+uswrf_ntat_year(idx_C::12,:,:))/3.0
uswrf_sfc  = (uswrf_sfc_year(idx_A::12,:,:)+uswrf_sfc_year(idx_B::12,:,:)+uswrf_sfc_year(idx_C::12,:,:))/3.0
air_sfc = (air_sfc_year(idx_A::12,:,:)+air_sfc_year(idx_B::12,:,:)+air_sfc_year(idx_C::12,:,:))/3.0

;print(prate_sfc)

q1_data = (shtfl_sfc + lhtfl_sfc) + (ulwrf_sfc - ulwrf_ntat + uswrf_sfc - uswrf_ntat + dswrf_ntat - dswrf_sfc - dlwrf_sfc) + prate_sfc*1859*air_sfc
;q1_data = shtfl_sfc + lhtfl_sfc + (ulwrf_sfc + uswrf_sfc - dswrf_sfc - dlwrf_sfc) + prate_sfc*1859*air_sfc
copy_VarMeta(dlwrf_sfc_year(0:30,:,:), q1_data)

aa = asciiread("./SCAE.txt",(/31/),"float")
bb = asciiread("./SCAE_hf.txt",(/31/),"float")

rc_hgt = regCoef_n(bb, q1_data, 0, 0)

tval_hgt = reshape(abs(rc_hgt@tval),(/dimsizes(rc_hgt(:,0)),dimsizes(rc_hgt(0,:))/))

copy_VarMeta(q1_data(0,:,:),rc_hgt)

copy_VarMeta(q1_data(0,:,:),tval_hgt)

res = True
res@gsnDraw=False
res@gsnFrame=False
res@gsnSpreadColors=True
res@gsnAddCyclic=True
res@gsnMaximize=True


res@mpLimitMode = "LatLon"
res@mpMinLatF = 0

res@mpCenterLonF=180

res@cnFillOn=True
res@cnLinesOn=False
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels=(/-10,-8,-6,-4,-2,0,2,4,6,8,10/)
res@cnFillColors=(/2,5,6,7,8,0,0,13,14,15,16,17/)

res@lbOrientation="Vertical"

res@gsnLeftString=""
res@gsnRightString=""

wks = gsn_open_wks("pdf", "Q1-"+season)
gsn_define_colormap(wks,"BlueDarkRed18")


map = gsn_csm_contour_map(wks, rc_hgt, res)


resp = True
resp@gsLineColor      = "gray" ; polylines color
resp@gsLineThicknessF = 2    ; polylines thickness

f=asciiread("../tibet_shape",(/2066,2/),"float")
poli=gsn_add_polyline(wks,map,f(:,0),f(:,1),resp)

resshade=True
resshade@pmTickMarkDisplayMode="Always"
resshade@cnFillOn=True
resshade@cnLinesOn=False
resshade@cnLineLabelsOn=False
resshade@cnMonoFillPattern=False
resshade@cnMonoFillColor=True

resshade@cnFillPatterns=(/-1,17/)
resshade@cnFillDotSizeF=0.005
resshade@cnFillColor="green"

resshade@cnLevelSelectionMode="ExplicitLevels"
resshade@cnLevels=(/ttestval/)
resshade@lbLabelBarOn=False
resshade@cnInfoLabelOn=False

resshade@gsnAddCyclic=True

resshade@gsnDraw=False
resshade@gsnFrame=False

resshade@gsnLeftString=""
resshade@gsnRightString=""


map2 = gsn_csm_contour(wks, tval_hgt, resshade)

overlay(map,map2)

tibet_lat_low = 29.0
tibet_lat_high = 34.0
tibet_lon_left = 90.0
tibet_lon_right = 100.0
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
