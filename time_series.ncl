load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;***
  yrstrt =197201
  yrlast =200912
  ;************************************************
   cd = "/public/home/charlesxiami/data_temp/dingke/"
   plotpath = "/public/home/charlesxiami/output/"

   wks=gsn_open_wks("pdf", plotpath+"pc1_dingk")
   ;gsn_define_colormap(wks, "BlueWhiteOrangeRed")

   snowdata = addfile("/public/home/charlesxiami/data/snow/snow.nc","r")
   airdata = addfile(cd+"air.mon.mean.nc", "r")
   slpdata = addfile(cd+"slp.mon.mean.nc", "r")
   hgtdata = addfile(cd+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(cd+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(cd+"vwnd.mon.mean.nc", "r")
   nswrdata = addfile(cd+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(cd+"nlwrs.sfc.mon.mean.nc", "r")
   sstdata = addfile(cd+"sst.mnmean.v4.nc", "r")

   pc1 = asciiread(cd+"1972-2009mamTEMP1.txt", -1, "float")
   pc1_hf_dk = asciiread(cd+"fliter1972-2009.txt", -1, "float")

   ;Calculate PC_high frequence component 
    ihp = 1
    fca = 1.0/8.0
    fcb= -999.
    nsigma = 1.
    nwt= 5
    wgt = filwgts_lanczos(nwt, ihp, fca, fcb, nsigma)

    pc1_hf = wgt_runave_Wrap(pc1, wgt, 0)

     ;xy_base_res
     rts           = True
     rts@gsnDraw   = False       ; don't draw yet
     rts@gsnFrame  = False       ; don't advance frame yet
     rts@gsnScale  = True        ; force text scaling               
     rts@vpHeightF = 0.35        ; Changes the aspect ratio
     rts@vpWidthF  = 0.85
     rts@vpXF      = 0.10        ; change start locations
     rts@vpYF      = 0.75        ; the plot 
     rts@tiYAxisString = ""                    ; y-axis label
     rts@gsnLeftStringFontHeightF = 0.025
     rts@gsnYRefLine = 0.
     rts@tmYLLabelFontHeightF = 0.015
     rts@tmYLLabelFontHeightF = 0.015

     ;Bar Chart
     rts1 = rts  
     rts1@gsnXYBarChart         = True                  ; reference line
     rts1@gsnAboveYRefLineColor = "red"           
     rts1@gsnBelowYRefLineColor = "blue"   
     rts1@gsnLeftString = "PC1"      

     ;Line
     rts2 = rts   
     rts2@xyDashPattern         = 1
     rts2@xyLineThicknessF      = 4.
     rts2@xyLineColor = "black"

     ;line2
     rts3 = rts
     rts3@xyLineColor = "black"
     rts3@xyLineThicknessF = 2.
     rts3@xyDashPatterns = (/0, 1/)
     rts3@pmLegendDisplayMode = "Always"
     rts3@pmLegendSide = "Top"
     rts3@pmLegendParallelPosF = 0.15
     rts3@pmLegendOrthogonalPosF = -0.30
     rts3@pmLegendWidthF = 0.10
     rts3@pmLegendHeightF = 0.06
     rts3@lgPerimOn = False
     rts3@lgLabelFontHeightF = 0.010
     rts3@lgItemOrder = (/1,0/)
     rts3@xyExplicitLegendLabels = (/"  PC1","  Region Averaged"/)
     rts3@gsnRightString = "Cor = 0.98"
     rts3@gsnRightStringFontHeightF = 0.015

     t = ispan(1972, 2009, 1)
     print(t)
     plotpc1 = gsn_csm_xy(wks,t,pc1,rts1)
     plotpc1_hf = gsn_csm_xy(wks, t, pc1_hf, rts2)

     rts2@xyLineColor = "green"
     plotpc1_hf_dk = gsn_csm_xy(wks, t, pc1_hf_dk, rts2)

     overlay(plotpc1, plotpc1_hf)
     overlay(plotpc1, plotpc1_hf_dk)
     draw(plotpc1)
     frame(wks)




;
end