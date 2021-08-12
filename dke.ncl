;----------------------------------------------------------------------
; Concepts illustrated:
;   - Reading a variable off several NetCDF files using 'addfiles' and 'cat' mode
;----------------------------------------------------------------------
;Disturbance kinetic energy
begin
;---Get list of files from
   inpath = "/public/home/charlesxiami/data/ncep/daily/"
   plotpath = "/public/home/charlesxiami/output/"

   wks=gsn_open_wks("pdf", plotpath+"DKE_daily_clim")
   gsn_define_colormap(wks, "WhiteYellowOrangeRed")

   nyrs      = ispan(1975,2015,1)
   uwnd_files = inpath+"uwnd/"+"uwnd."+nyrs+".nc"
   vwnd_files = inpath+"vwnd/"+"vwnd."+nyrs+".nc"
  
;---Open files using addfiles
   udata = addfiles (uwnd_files, "r")
   vdata = addfiles (vwnd_files, "r")

   dystrt = 20111201
   dylast = 20140228
   YYYYMMDD = cd_calendar(udata[:]->time, 2)
   iStrt  = ind(YYYYMMDD.eq.dystrt)
   ;print(iStrt)

   ;ListSetType(udata, "join")  ;Join mode

;---Read "" in "cat" mode and print a summary of the variable
   uwnd = udata[:]->uwnd   ; note syntax [:]
   printVarSummary(uwnd)
   u200 = uwnd(:,{200},:,:)
   u500 = uwnd(:,{500},:,:)
   u850 = uwnd(:,{850},:,:)
   delete(uwnd)

   vwnd = vdata[:]->vwnd
   printVarSummary(vwnd)
   v200 = vwnd(:,{200},:,:)
   v500 = vwnd(:,{500},:,:)
   v850 = vwnd(:,{850},:,:)
   ; printVarSummary(u200)
   ; printVarSummary(v850)

  ;Calculate
  ;*****************************************
   ;Filter 
    ihp = 2
    nsigma = 1.0
    fca = 1.0/8.0
    fcb=  1.0/2.0
    nwt= 201
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    u200 = wgt_runave_n_Wrap(u200, wgt, 0, 0)
    u500 = wgt_runave_n_Wrap(u500, wgt, 0, 0)
    u850 = wgt_runave_n_Wrap(u850, wgt, 0, 0)

    v200 = wgt_runave_n_Wrap(v200, wgt, 0, 0)
    v500 = wgt_runave_n_Wrap(v500, wgt, 0, 0)
    v850 = wgt_runave_n_Wrap(v850, wgt, 0, 0)

    ; printVarSummary(u200)
    ; printVarSummary(v850)

   ;K 
    
    ke_200 = u200(0:dimsizes(nyrs)-2,:,:)
    ke_500 = u200(0:dimsizes(nyrs)-2,:,:)
    ke_850 = u200(0:dimsizes(nyrs)-2,:,:)
    ke_200 = 0.0
    ke_500 = 0.0
    ke_850 = 0.0
    printVarSummary(ke_200)

    u200sum = u200(0,:,:)
    u500sum = u500(0,:,:)
    u850sum = u850(0,:,:)
    u200sum = 0.0
    u500sum = 0.0
    u850sum = 0.0

    v200sum = v200(0,:,:)
    v500sum = v500(0,:,:)
    v850sum = v850(0,:,:)
    v200sum = 0.0
    v500sum = 0.0
    v850sum = 0.0
    ; printVarSummary(u200sum)

    n = 90
    do i = 0, dimsizes(nyrs)-2
      do t = 0, n-1
   u200sum=u200sum+((u200(334+i*365+t,:,:)-dim_avg_n_Wrap(u200(334+i*365:334+90+i*365,:,:),0))^2)/n
   v200sum=v200sum+((v200(334+i*365+t,:,:)-dim_avg_n_Wrap(v200(334+i*365:334+90+i*365,:,:),0))^2)/n
   u500sum=u500sum+((u500(334+i*365+t,:,:)-dim_avg_n_Wrap(u500(334+i*365:334+90+i*365,:,:),0))^2)/n
   v500sum=v500sum+((v500(334+i*365+t,:,:)-dim_avg_n_Wrap(v500(334+i*365:334+90+i*365,:,:),0))^2)/n
   u850sum=u850sum+((u850(334+i*365+t,:,:)-dim_avg_n_Wrap(u850(334+i*365:334+90+i*365,:,:),0))^2)/n
   v850sum=v850sum+((v850(334+i*365+t,:,:)-dim_avg_n_Wrap(v850(334+i*365:334+90+i*365,:,:),0))^2)/n
      end do
      ke_200(i,:,:) = 0.5*(u200sum + v200sum)
      ke_500(i,:,:) = 0.5*(u500sum + v500sum)
      ke_850(i,:,:) = 0.5*(u850sum + v850sum)
     u200sum = 0.0
     u500sum = 0.0
     u850sum = 0.0
     v200sum = 0.0
     v500sum = 0.0
     v850sum = 0.0
    end do 

   ; do i = 0, dimsizes(nyrs)-2
   ;   do t = 0, n-1
   ; u200_ano = dim_rmvmean_n_Wrap(u200(), dims)

    ke_200_clim = dim_avg_n_Wrap(ke_200, 0)
    ke_500_clim = dim_avg_n_Wrap(ke_500, 0)
    ke_850_clim = dim_avg_n_Wrap(ke_850, 0)
   ;Res
   ;****************************************
    res = True
    res@gsnDraw = False
    res@gsnFrame = False

    rescn = res
    rescn@cnFillOn = True
    rescn@cnLinesOn = True
    rescn@cnLineLabelsOn = False
    rescn@lbLabelBarOn = False
    rescn@lbLabelsOn = True
    rescn@cnInfoLabelOn = False
    rescn@mpOutlineSpecifiers=(/"China","Taiwan","China-Hainan-Dao-Island"/)
    rescn@tmXBLabelFontHeightF = 0.015
    rescn@tmYLLabelFontHeightF = 0.015
    rescn@pmLabelBarOrthogonalPosF = 0.15
    rescn@cnLevelSelectionMode = "ManualLevels"
    rescn@cnMinLevelValF = 0.
    rescn@cnMaxLevelValF = 120.
    rescn@cnLevelSpacingF = 10.
    rescn@gsnRightString = ""

    rescn@mpFillOn = False
    rescn@mpCenterLonF = 180.
    rescn@mpMinLonF = 90.
    rescn@mpMaxLonF = 270.
    rescn@mpMaxLatF = 90.
    rescn@mpMinLatF = 0.

    resP = True                
    resP@gsnMaximize = False
    resP@gsnPanelFigureStringsFontHeightF = 0.01
    resP@gsnPanelFigureStringsPerimOn = False
    resP@amJust = "TopRight"
    resP@gsnPanelMainString = "Climatic Disturbance Kinetic Energy"
    resP@gsnPanelLabelBar = True
    resP@lbLabelFontHeightF = 0.008

  ;***************************************************************
    rescn@gsnLeftString = "200hPa DKE"
    plot200 = gsn_csm_contour_map(wks, ke_200_clim, rescn)
    ; draw(plot)
    ; frame(wks)

    rescn@gsnLeftString = "500hPa DKE"
    plot500 = gsn_csm_contour_map(wks, ke_500_clim, rescn)

    rescn@gsnLeftString = "850hPa DKE"
    plot850 = gsn_csm_contour_map(wks, ke_850_clim, rescn)

    plotall = new(3,"graphic")
    plotall(0) = plot200
    plotall(1) = plot500
    plotall(2) = plot850

    gsn_panel(wks, plotall, (/3,1/), resP)

    ; uwdplot1 = gsn_csm_contour_map(wks, u200(0,:,:), res)
    ; uwdplot2 = gsn_csm_contour_map(wks, u500(0,:,:), res)
    ; uwdplot3 = gsn_csm_contour_map(wks, u850(0,:,:), res)
    ; plotall(0) = uwdplot1
    ; plotall(1) = uwdplot2
    ; plotall(2) = uwdplot3
    ; gsn_panel(wks, plotall, (/3,1/), resP)



end