undef("Q1Q2_yanai.ncl")
function Q1Q2_yanai(time[*]:numeric,p,u,v,H,T,omega,npr[1]:integer,opt[1]:logical)
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; NOT SUPPORTED:  NOT FULLY TESTED : WORK in PROGRESS
;                  **CHECK UNITS**
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; Nomenclature
; time    - "seconds since ..."
; p       - Pressure [Pa]
; u,v     - zonal, meridional wind components[m/s]
; H       - specific humidity [g/kg]
; T       - temperature [K]  or [C]
; omega   - vertical velocity [Pa/s]
; npr     - demension number corresponding to pressure dimension
; opt     - set to False
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
;;  Q1  = Cp*dTdt - Cp*(omega*ss-advT)
;;  Q1  = Cp*[ dTdt- omega*ss-advT ]
;;  q1  = dTdt- omega*ss-advT    
;;  Q1  = Cp*[ q1 ]                   
;;
;;  Q1  = Total diabatic heating [including radiation, latent heating, and
;;        sfc heat flux) and sub-grid scale heat flux convergence
;;---
;;  q2  = -(dHdt +advH +dHdp)
;;  Q2  = Lc*[ q2 ]
;;
;;  Q2  = the latent heating due to condensation or evaporation processes
;;        and subgrid-scale moisture flux convergences,
;++++++++++++++++++++++++++++++++++++++++++++
; References:
; 
; https://renqlsysu.github.io/2019/02/01/apparent_heat_source/
;
; Yanai, M. (1961): 
; A detailed analysis of typhoon formation.
; J. Meteor. Soc. Japan , 39 , 187â€“214
; 
; Yanai et al (1973):
;  Determination of bulk properties of tropical cloud clusters 
;    from large-scale heat and moisture budgets.
;  J.  Atmos.  Sci.  , 30 , 611â€“627,
;  https://doi.org/10.1175/1520-0469(1973)030<0611:DOBPOT>2.0.CO;2
;
; Yanai, M and T.Tomita (1998):
; https://pdfs.semanticscholar.org/fb57/a6a59cc4a684194b5e622ea6f875d0b4439a.pdf
;********************************************
; Diabatic heating in the atmosphere is a combined consequence of 
; radiative fluxes, phase changes of water substance, and turbulent 
; flux of sensible heat from the earth's surface. 
; 
; In the tropics, it is the major driving force of the atmospheric circulation. 
; It responds to the vertical gradient of diabatic heating.
;********************************************
local dimp, dimu, dimv, dimH, dimT, dimo             \
    , rankp, ranku, rankv, rankH, rankT, ranko       \
    , Cp, Lc, dTdt, ss, opt_adv, long_name, units    \
    , gridType, advT, q1, Q1, dHdt, advH, loq, q2, Q2
begin
;;             Use for error testing
;;dimp         = dimsizes(p)
;;dimu         = dimsizes(u)
;;dimv         = dimsizes(v)
;;dimH         = dimsizes(H)
;;dimT         = dimsizes(T)
;;dimo         = dimsizes(omega)

;;rankp        = dimsizes(dimp)
;;ranku        = dimsizes(dimu)
;;rankv        = dimsizes(dimv)
;;rankH        = dimsizes(dimH)
;;rankT        = dimsizes(dimT)
;;ranko        = dimsizes(dimo)

;*******************************************
;---Compute local dT/dt  [K/s]
;*******************************************

  dTdt = center_finite_diff_n (T,time,False,0,0)   ; 'time' is 'seconds since'
  copy_VarCoords(T, dTdt)
  dTdt@longname = "Temperature: Local Time derivative"
  dTdt@units = "K/s"
  printVarSummary(dTdt)
  printMinMax(dTdt,0)
  print("-----")
   
;****************************************
;---Compute static stability [K/Pa] <==>  or "K-m-s2/kg"
;****************************************

  ss  = static_stability (p , T, 1, 0) 
  printVarSummary(ss)
  printMinMax(ss,0)
  print("-----")

;****************************************
;---Compute advection term: spherical harmonics
;---U*(dT/dx) + V*(dT/dy):  [m/s][K/m] -> [K/s]
;****************************************

  opt_adv   = 0
  long_name = "temp advection"
  units     = "K/s"
  gridType  = 1  
  advT      = advect_variable(u,v,T,gridType,long_name,units,opt_adv) 
   
;****************************************
;---Net Heat
;****************************************

  q1 = dTdt - (omega*ss-advT)      ; term_1 - term_2
  q1@long_name = "q1: Net Heat Flux"
  q1@units     = "K/s"
  copy_VarCoords(T,q1)
  printVarSummary(q1) 
  printMinMax(q1,0)
  print("-----")

;****************************************
;---Apparent Heat Source
;****************************************

  Cp           = 1004.64 
  Cp@long_name = "specific heat of dry air at constant pressure"
  Cp@units     = "J/(K-kg)"  ; [kg-m2/s2]/(K-kg) => [kg-m2]/[K-kg-s2] => m2/[K-s2]  

  Q1  = Cp*q1  ; [J/(K-kg)][K/s] -> [J/(kg-s)] -> [(kg-m2/s2)/(kg-s)) -> [ m2/s3 ] 
               ; [J/(K-kg)][K/s] -> [(J/s)(1/kg)] -> W/kg   ???
  Q1@long_name = "Q1: Total Diabatic Heating as the Apparent Heat Source"
  Q1@units     = "m2/s3"     
  copy_VarCoords(T,Q1)
  printVarSummary(Q1) 
  printMinMax(Q1,0)
  print("-----") 

;*******************************************
;---Compute local dH/dt     
;*******************************************

  dHdt = center_finite_diff_n (H,time,False,0,0)
  copy_VarCoords(H, dHdt)
  dHdt@longname = "Specific Humidity: Local Time derivative"
  dHdt@units = "g/(kg-s)"    ; (g/kg)/s  
  printVarSummary(dHdt)
  printMinMax(dHdt,0)
  print("-----")

;****************************************
;---Compute advection term: global fixed grid: spherical harmonics
;---U*(dH/dlon) + V*(dH/dlat)
;****************************************

  long_name = "moisture advection"
  units     = "g/(kg-s)"     ; (m/s)*(g/kg)*(1/m)
  advH      = advect_variable(u,v,H,gridType,long_name,units,opt_adv) 

;****************************************
;---Compute vertical movement of H
;****************************************

  dHdp = center_finite_diff_n (H,p,False,1,npr)
  copy_VarCoords(H, dHdp)
  dHdp@longname = "Specific Humidity: Local Vertical Derivative"
  dHdp@units = "g/(kg-Pa)"   ; (g/kg)/Pa 
  printVarSummary(dHdp)
  printMinMax(dHdp,0)
  print("-----")

  dHdp  = omega*dHdp               ; overwrite ... convenience
  dHdp@longname = "Specific Humidity: Vertical Moisture Transport"
  dHdp@units    = "g/(kg-s)"       ; [(Pa/s)(g/kg)/Pa)]  
  printVarSummary(dHdp)
  printMinMax(dHdp,0)
  print("-----")
   
;****************************************
;---Apparent Moisture Sink
;****************************************

  q2    = -(dHdt +advH +dHdp)
  q2@long_name = "q2: moisture sink"      ; "?apparent? drying rate"
  q2@units     = "g/(kg-s)"
  copy_VarCoords(T,q2)
  printVarSummary(q2) 

  Lc           = 2.26e6    ; [J/kg]=[m2/s2]  Latent Heat of Condensation/Vaporization
  Lc@long_name = "Latent Heat of Condensation/Vaporization"
  Lc@units     = "J/kg"  ; ==> "m2/s2"

  Q2    = Lc*q2          ; (J/kg)(g/(kg-s))->(m2/s2)(g/(kg-s)) ->[(g/kg)][m2/s3]
                         ; J[oule]->  kg-m2/s2 = N-m = Pa/m3 = W-s       ; energy           
  Q2@long_name = "Q2: Apparent Moisture Sink"
  Q2@units     = "(g/kg)[m2/s3]"    
  copy_VarCoords(T,Q2)
  printVarSummary(Q2) 
  printMinMax(Q2,0)
  print("-----")
   
;****************************************
;---Make q1, q2 to per day
;****************************************

  q1 = q1*86400
  q2 = q2*86400
  q1@units     = "K/day"
  q2@units     = "g/(kg-day)"
   
;****************************************
;---Make Q1, Q2 to per W/m2
;****************************************

;;Q1 = Q1*?????
;;Q2 = Q2*?????
;;Q1@units = "W/m2"
;;Q2@units = "W/m2"

  return( [/q1, q2, Q1, Q2/] )
end
;==============================================================================
;                           MAIN
;==============================================================================
  netCDF  = True                                       ; Write netCDF 

;---Variable and file handling

  diri    = "/Users/shea/Data/netCDF/"
  f1      = addfile(diri+"temp_lag4tolead2.nc","r")    ; daily mean data
  f2      = addfile(diri+"omega_lag4tolead2.nc","r")     
  f3      = addfile(diri+"uwnd_lag4tolead2.nc","r")
  f4      = addfile(diri+"vwnd_lag4tolead2.nc","r")
  f5      = addfile(diri+"rhum_lag4tolead2.nc","r")
                                                       ; convenience: make all:  S->N
  temp    = f1->air(:,:,::-1,:)                        ; degK
  omega   = f2->omega(:,:,::-1,:)                      ; Pascal/s
  uwnd    = f3->uwnd(:,:,::-1,:)                       ; m/s
  vwnd    = f4->vwnd(:,:,::-1,:)                       ; m/s
  rhum    = short2flt(f5->rhum(:,:,::-1,:))            ; %   

;---Need specific humidity

  p       = f1->level                                  ; hPa [*]
  p4d     = conform(temp, p, 1)
  q       = mixhum_ptrh (p4d, temp, rhum,-2)           ; g/kg
  delete( [/p4d, rhum/] )
  q@long_name = "specific humidity"
  q@units = "g/kg"
  copy_VarCoords(temp, q)
  printVarSummary(q)
  printMinMax(q, 0)

;---Convert "hours since ..." to "seconds since ..."

  time    = f5->time                                   ; "hours since 1800-1-1"
  time    = time*3600                                          
  time@units  = "seconds since 1800-1-1 00:00:0.0"
  printVarSummary(time)
  print("---")
  t       = time                 ; Lyndz' name 

  ymdh = cd_calendar(time,-3)
  print(ymdh)

;---Convert hPa -> Pa for function

  p       = p*100                                      ; Pa  [100000,...,10000]
  p@units = "Pa"
  p!0     = "p"
  p&p     =  p                   ; not necessary
  printVarSummary(p)
  print("---")
  
;++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Cp       = 1004.64      ; specific heat of dry air at constant pressure 
  Cp@units = "J/(K*kg)"  

  npr  = 1
  opt  = True
  q1q2 = Q1Q2_yanai(time,p,uwnd,vwnd,q,temp,omega,npr,opt)
  print(q1q2)
 
  q1   = q1q2[0]
  q2   = q1q2[1]
  printVarSummary(q1)
  printMinMax(q1,0)
  print("================")
  printVarSummary(q2)
  printMinMax(q2,0)
  print("================")

 ;Q1   = q1q2[2]
 ;Q2   = q1q2[3]

;********************************************
;---Vertical integration
; J[oule]      kg-m2/s2 = N-m = Pa/m3 = W-s       ; energy           
;********************************************

  ptop  = 30000.0                       ; Pa
  pbot  = 100000.0
  vopt  = 1 

  g     = 9.80665                       ; [m/s2] gravity at 45 deg lat used by the WMO
  dp    = dpres_plevel_Wrap(p,pbot,ptop,0)
  dpg   = dp/g                          ; Pa/(m/s2)=> (Pa-s2)/m   
  dpg@long_name = "Layer Mass Weighting"
  dpg@units     = "kg/m2"               ; dp/g     => Pa/(m/s2) => [kg/(m-s2)][m/s2] reduce to (kg/m2)
                                        ;             Pa (s2/m) => [kg/(m-s2)][s2/m]=>[kg/m2]
  dpg  := conform(q1,dpg,1)             ; reassign [convenience]

  q1int = wgt_vertical_n(q1,dpg,vopt,1) ; SUM[q1*dpg]  => (K/s)(kg/m2)
  q1int@long_name = "Heat Source: vertically integrated"
  q1int@units     = "(K/day)(kg/m2)"      ; (K/s)(kg/m2) => (kg-K)/(m2-s)
  printVarSummary(q1int)
  copy_VarCoords(temp(:,0,:,:),q1int)
  printMinMax(q1int,0)
  print("-----")

  q2int = wgt_vertical_n(q2,dpg,vopt,1)
  q2int@long_name = "Moisture Sink: vertically integrated"
  q2int@units     = "g/(day-m2)"
  copy_VarCoords(temp(:,0,:,:),q2int)
  printMinMax(q2int,0)
  print("-----")

;***********************************************
;---Save to a netcdf file
;***********************************************

  if (netCDF) 
      diro = "./"
      filo = "YANAI.apparent_heat.nc"
      ptho = diro+filo
      system("/bin/rm -f "+ptho)
      ncdf = addfile(ptho,"c")
    
      fAtt = True
      fAtt@title         = "Apparent Heat Source based on Yanai et al. 1973"
      fAtt@source_name   = "NCEP-NCAR Reanalysis 2"
      fAtt@source_URL    = "https://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis2.html"
      fAtt@source        = "NOAA/OAR/ESRL PSD, Boulder, Colorado, USA"
      fAtt@Conventions   = "None"
      fAtt@creation_date = systemfunc("date")
      fileattdef(ncdf,fAtt)            ; copy file attributes
     
      filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension
      ncdf->q1 = q1
      ncdf->q2 = q2
  end if

;***********************************************
;---Plot
;***********************************************

  nt    = 4
  YMDH  = ymdh(nt)
  LEVP  = 600

  opt = True
  opt@PrintStat = True
  stat_q1 = stat_dispersion(q1(nt,{LEVP},:,:), opt )
  stat_q2 = stat_dispersion(q2(nt,{LEVP},:,:), opt )
  stat_q1i= stat_dispersion(q1int(nt,:,:), opt )
  stat_q2i= stat_dispersion(q2int(nt,:,:), opt )

  plot  = new(2,graphic)

  wks   = gsn_open_wks("png","q2q1_yanai")        ; send graphics to PNG file
        
;--- mfc_adv and mfc_con at a specified pressure level

  res                   = True             ; plot mods desired
  res@gsnDraw           = False            ; don't draw yet
  res@gsnFrame          = False            ; don't advance frame yet

  res@cnFillOn          = True             ; turn on color
  res@cnLinesOn         = False            ; turn off contour lines
  res@cnLineLabelsOn    = False            ; turn off contour lines
 ;res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
  res@cnFillPalette     = "amwg256"        ; set White-in-Middle color map
 ;res@cnFillMode        = "RasterFill"
  res@mpFillOn          = False            ; turn off map fill
;;res@lbLabelBarOn      = False            ; turn off individual cb's
  res@lbOrientation     = "Vertical"
                                           ; Use a common scale
  res@cnLevelSelectionMode = "ManualLevels"; manual set levels so lb consistent
  res@cnMaxLevelValF       =    5.0        ; max level
  res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
  res@cnLevelSpacingF      =    0.20       ; contour interval

  res@gsnCenterString      = LEVP+"hPa"
  plot(0) = gsn_csm_contour_map(wks,q1(nt,{LEVP},:,:),res)

  res@cnMaxLevelValF       =    5.0        ; max level
  res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
  res@cnLevelSpacingF      =    0.20       ; contour interval
  plot(1) = gsn_csm_contour_map(wks,q2(nt,{LEVP},:,:),res)

  resP                     = True          ; modify the panel plot
  resP@gsnMaximize         = True
  resP@gsnPanelMainString := YMDH
;;resP@gsnPanelLabelBar    = True          ; add common colorbar
  gsn_panel(wks,plot,(/2,1/),resP)         ; now draw as one plot

  delete(res@gsnCenterString) ; not used for this plot

  res@cnMaxLevelValF       =   14000.0     ; max level
  res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
  res@cnLevelSpacingF      =    500.0      ; contour interval
  plot(0) = gsn_csm_contour_map(wks,q1int(nt,:,:),res)

  res@cnMaxLevelValF       =    7000.0     ; max level
  res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
  res@cnLevelSpacingF      =    500.0      ; contour interval
  plot(1) = gsn_csm_contour_map(wks,q2int(nt,:,:),res)

  gsn_panel(wks,plot,(/2,1/),resP)         ; now draw as one plot


;---Cross section
 
  rescx                      = True                  ; plot mods desired
  rescx@gsnMaximize          = True

  LAT = 10 
  if (LAT.ge.0) then
      rescx@tiMainString     = YMDH+": "+LAT+"N"
  else
      rescx@tiMainString     = YMDH+": "+ABS(LAT)+"S"
  end if

  rescx@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
  rescx@cnLinesOn            = False            ; turn off contour lines
  rescx@cnLineLabelsOn       = False
  rescx@cnFillOn             = True                  ; turn on color fill
  rescx@cnFillPalette        = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
  rescx@cnFillPalette        = "amwg256"        ; set White-in-Middle color map
  
  rescx@cnMaxLevelValF       =  5.0                  ; max level
  rescx@cnMinLevelValF       = -rescx@cnMaxLevelValF ; min level
  rescx@cnLevelSpacingF      =  0.25                 ; contour interval
  plt_q1 = gsn_csm_pres_hgt(wks,q1(nt,{1000:200},{LAT},:),rescx)
  rescx@cnMaxLevelValF       =  5.0                  ; max level
  rescx@cnMinLevelValF       = -rescx@cnMaxLevelValF ; min level
  rescx@cnLevelSpacingF      =  0.25                 ; contour interval
  plt_q2 = gsn_csm_pres_hgt(wks,q2(nt,{1000:200},{LAT},:),rescx)