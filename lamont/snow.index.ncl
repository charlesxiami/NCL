load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/run_cor.ncl"
;***
  begin
;***
   yrstrt = 197201
   yrlast = 201912

   nyrs = yrlast/100-yrstrt/100+1
   ; print(nyrs+" years")

   yrstrt_sst = yrstrt
   yrlast_sst = yrlast

   yrstrt_snow = yrstrt
   yrlast_snow = 201812

   yrstrt_nao = 197301
   yrlast_nao = 201912

  year = ispan(yrstrt/100, yrlast/100, 1)
  year!0 = "time"
  year@units = "year"

;---------------W,E-index Region
  SCI_EEU_N = 70
  SCI_EEU_S = 40
  SCI_EEU_L = 20
  SCI_EEU_R = 140

  latS     = -90
  latN     = 90
  lonL     = 0
  lonR     = 360

   latS_eu = 20
   latN_eu = 70
   lonW_eu = 0
   lonE_eu = 140

   nceppath = "$HOME/data/ncep/"
   snowpath = "$HOME/data/snow/"
   indexpath = "$HOME/data/index/"
   precpath = "$HOME/data/precip/PREC/"

   plotpath = "$HOME/output/"
;**************************************************
   wks=gsn_open_wks("pdf", "snow.index")
   gsn_define_colormap(wks, "BlueWhiteOrangeRed")
;**************************************************
;Read Data
   snowdata  = addfile(snowpath+"snowcover_new.nc","r")
   precipdata = addfile(precpath+"precip.mon.anom.nc", "r")
   sstdata = addfile(nceppath+"sst.mnmean.v5.nc", "r")

   airdata = addfile(nceppath+"air.mon.mean.nc", "r")
   slpdata = addfile(nceppath+"slp.mon.mean.nc", "r")
   hgtdata = addfile(nceppath+"hgt.mon.mean.nc", "r")
   uwnddata = addfile(nceppath+"uwnd.mon.mean.nc", "r")
   vwnddata = addfile(nceppath+"vwnd.mon.mean.nc", "r")

   nswrdata = addfile(nceppath+"nswrs.sfc.mon.mean.nc", "r")
   nlwrdata = addfile(nceppath+"nlwrs.sfc.mon.mean.nc", "r")
   lhfdata = addfile(nceppath+"lhtfl.sfc.mon.mean.nc", "r")
   shfdata = addfile(nceppath+"shtfl.sfc.mon.mean.nc", "r")
   ; soilwdata = addfile(nceppath+"soilw.mon.mean.v2.nc", "r")
   tccdata = addfile(nceppath+"tcdc.eatm.mon.mean.nc", "r")

   ;Nao 195001-
   nao_index = asciiread(indexpath+"norm.nao.monthly.b5001.current.ascii.txt", -1, "string")
   nao_index2 = stringtofloat(str_get_field(nao_index, 3, " "))
   nao_index3 = nao_index2(0:dimsizes(nao_index2)-1-2)

   month_time = yyyymm_time(1950, 2020, "integer")
   month_time!0 = "time"
   month_time@long_name = "time"
   month_time@units = "month"
   nao_index3!0 = "time"
   nao_index3&time = month_time

   ;PDO index read
   pdo0 = readAsciiTable(indexpath+"pdo.long.data.txt", 13, "float", (/1,12/))
   ; pdo1 = pdo0(:117,1:)
   pdo_index = ndtooned(pdo0(:,1:))

   month_time2 = yyyymm_time(1900, 2020, "integer")
   month_time2!0 = "time"
   month_time2@long_name = "time"
   month_time2@units = "month"
   pdo_index!0 = "time"
   pdo_index&time = month_time2

   ;Nino34 index read
   nino34_0 = readAsciiTable(indexpath+"nino34.long.data.txt", 13, "float", (/1,5/))
   nino34_1 = nino34_0(:,1:)
   nino34_index = ndtooned(nino34_1)

   month_time3 = yyyymm_time(1870, 2020, "integer")
   month_time3!0 = "time"
   month_time3@long_name = "time"
   month_time3@units = "month"
   nino34_index!0 = "time"
   nino34_index&time = month_time3


   ;ao 195001-201912
   ao_table = asciiread(indexpath+"monthly.ao.index.b50.current.ascii.txt", -1, "string")
   ao_index_origin = stringtofloat(str_get_field(ao_table, 3, " "))
   ao_mon_all = ao_index_origin(0:839)
   month_time4 = yyyymm_time(1950, 2019, "integer")
   month_time4!0 = "time"
   month_time4@long_name = "time"
   month_time4@units = "month"

   ao_mon_all!0 = "time"
   ao_mon_all&time = month_time4
   ; ssti = asciiread(indexpath+"na_ssti.txt", -1 ,"float")
   ; imidyr = 20
   ; ssti_p1 = ssti(0:imidyr)
   ; ssti_p2 = ssti(imidyr+1:)
 ;***************************************
   YYYYMM = cd_calendar(airdata->time, 1)
   iStrt  = ind(YYYYMM.eq.yrstrt)
   iLast  = ind(YYYYMM.eq.yrlast)
   ; print("ncep time: "+YYYYMM(iStrt)+"--"+YYYYMM(iLast))

   YYYYMM2 = cd_calendar(sstdata->time, 1)
   iStrt2  = ind(YYYYMM2.eq.yrstrt_sst)
   iLast2  = ind(YYYYMM2.eq.yrlast_sst)
   ; print("sst  time: "+YYYYMM2(iStrt2)+"--"+YYYYMM2(iLast2))

   YYYYMM3 = cd_calendar(snowdata->time, 1)
   iStrt3  = ind(YYYYMM3.eq.yrstrt_snow)
   iLast3  = ind(YYYYMM3.eq.yrlast_snow)
   print("snow time: "+YYYYMM3(iStrt3)+"--"+YYYYMM3(iLast3))

   iStrt4  = ind(nao_index3&time.eq.yrstrt_nao)
   iLast4  = ind(nao_index3&time.eq.yrlast_nao)
   print("nao time: "+nao_index3&time(iStrt4)+"--"+nao_index3&time(iLast4))

   iStrt5  = ind(pdo_index&time.eq.yrstrt)
   iLast5  = ind(pdo_index&time.eq.yrlast)
   print("pdo time: "+pdo_index&time(iStrt5)+"--"+pdo_index&time(iLast5))

   iStrt6  = ind(nino34_index&time.eq.yrstrt)
   iLast6  = ind(nino34_index&time.eq.yrlast)
   print("nino time: "+nino34_index&time(iStrt6)+"--"+nino34_index&time(iLast6))   
;***************************************************************
   snow_mon = snowdata->snowcover(iStrt3:iLast3,:,:)
   nao_mon = nao_index3(iStrt4:iLast4)
   pdo_mon = pdo_index(iStrt5:iLast5)
   nino34_mon = nino34_index(iStrt6:iLast6)
;*****************************************************************   
   snow_son = month_to_season(snow_mon, "SON")
   snow_son_dt = dtrend_n(snow_son, False, 0)
   copy_VarMeta(snow_son, snow_son_dt)

   nao_son = month_to_season(nao_mon, "SON")
   nao_son = dim_standardize_Wrap(nao_son, 1)
   ndimnao = dimsizes(nao_son)

   nao_djf = month_to_season(nao_mon, "DJF")
   ; nao_djf = dim_standardize_Wrap(nao_djf, 1)

   pdo_son = month_to_season(pdo_mon, "SON")

   nino34_son  = month_to_season(nino34_mon, "SON")

;*****************************************************************
   snow_son_eu = snow_son(:,{latS_eu:latN_eu},{lonW_eu:lonE_eu})
   snow_son_eui = wgt_areaave_Wrap(snow_son_eu, 1.0, 1.0, 0)
   snow_son_eui = dtrend(snow_son_eui, False)
   snow_son_eui = dim_standardize_Wrap(snow_son_eui, 1)
   
   ndim_snow = dimsizes(snow_son_eui)
;*****************************************************************
   ; snow_pc1_son    = asciiread(indexpath+"snow.son.pc1"+".txt", -1, "float")
   snow_son_pc1 = asciiread(indexpath+"snow_pc1dt_1972-2019SON.txt", -1, "float")
   snow_son_pc2 = asciiread(indexpath+"snow_pc2dt_1972-2019SON.txt", -1, "float")

    ; nao_son_dt = dtrend(nao_son, False)
    ; nao_djf_dt = dtrend(nao_djf, False)
    ; print("NAO dt vs none dt:  " + escorc(nao_djf_dt, nao_djf))
;*****************************************************************
   si  = snow_son_pc1(:dimsizes(snow_son_pc1)-2)
   si2 = snow_son_pc2(:dimsizes(snow_son_pc2)-2)

   ; dim_nino = dimsizes(nino34_djf)
   ; nino34_djf1 = nino34_djf(:dim_nino-2)
   ; pdo_djf1    = pdo_djf(:dim_nino-2)
   ; nao_djf_dt1 = nao_djf_dt(1:)
   
   df_pc = dimsizes(si) - 2

   print("------------DJF NAO-------------------------------------------------------")
   cor_pc1_pc2 = escorc(si, si2)
   print("cor_pc1_pc2: "+ cor_pc1_pc2)

   cor_pc_nao = escorc(si, nao_djf)
   p_pc_nao = student_t(cor_pc_nao*sqrt(df_pc/(1- cor_pc_nao^2)), df_pc)
   print("PC1-NAO："+ "Cor="+cor_pc_nao + ", p="+p_pc_nao)
   
   iyr = 22
   df_sub = iyr - 1
   cor_pc_nao := escorc(si(:iyr), nao_djf(:iyr))
   p_pc_nao := student_t(cor_pc_nao*sqrt(df_sub/(1- cor_pc_nao^2)), df_sub)
   print("PC1-NAO_P1："+ "Cor="+cor_pc_nao + ", p="+p_pc_nao)
   cor_pc_nao := escorc(si(iyr+2:), nao_djf(iyr+2:))
   p_pc_nao := student_t(cor_pc_nao*sqrt(df_sub/(1- cor_pc_nao^2)), df_sub)
   print("PC1-NAO_P2："+ "Cor="+cor_pc_nao + ", p="+p_pc_nao)

   cor_pc_nao := escorc(si2, nao_djf)
   p_pc_nao := student_t(cor_pc_nao*sqrt(df_pc/(1- cor_pc_nao^2)), df_pc)
   print("PC2-NAO："+ "Cor="+cor_pc_nao + ", p="+p_pc_nao)

   cor_pc_nao := escorc(si2(:iyr), nao_djf(:iyr))
   p_pc_nao := student_t(cor_pc_nao*sqrt(df_sub/(1- cor_pc_nao^2)), df_sub)
   print("PC2-NAO_P1："+ "Cor="+cor_pc_nao + ", p="+p_pc_nao)
   cor_pc_nao := escorc(si2(iyr+2:), nao_djf(iyr+2:))
   p_pc_nao := student_t(cor_pc_nao*sqrt(df_sub/(1- cor_pc_nao^2)), df_sub)
   print("PC2-NAO_P2："+ "Cor="+cor_pc_nao + ", p="+p_pc_nao)

   print("--------------SON PDO-------------------------------------------------------")
   df_pc = df_pc + 1 
   cor_pc_pdo = escorc(snow_son_pc1, pdo_son)
   p_pc_pdo = student_t(cor_pc_pdo*sqrt(df_pc/(1- cor_pc_pdo^2)), df_pc)
   print("PDO-PC1："+ "Cor="+cor_pc_pdo + ", p="+p_pc_pdo)

   iyr = 23
   df_sub = iyr-1
   cor_pc_pdo := escorc(snow_son_pc1(:iyr), pdo_son(:iyr))
   p_pc_pdo := student_t(cor_pc_pdo*sqrt(df_sub/(1- cor_pc_pdo^2)), df_sub)
   print("PDO-PC1_P1："+ "Cor="+cor_pc_pdo + ", p="+p_pc_pdo)
   cor_pc_pdo := escorc(snow_son_pc1(iyr+1:), pdo_son(iyr+1:))
   p_pc_pdo := student_t(cor_pc_pdo*sqrt(df_sub/(1- cor_pc_pdo^2)), df_sub)
   print("PDO-PC1_P2："+ "Cor="+cor_pc_pdo + ", p="+p_pc_pdo)

   cor_pc_pdo := escorc(snow_son_pc2, pdo_son)
   p_pc_pdo := student_t(cor_pc_pdo*sqrt(df_pc/(1- cor_pc_pdo^2)), df_pc)
   print("PDO-PC2："+ "Cor="+cor_pc_pdo + ", p="+p_pc_pdo)

   cor_pc_pdo := escorc(snow_son_pc2(:iyr), pdo_son(:iyr))
   p_pc_pdo := student_t(cor_pc_pdo*sqrt(df_sub/(1- cor_pc_pdo^2)), df_sub)
   print("PDO-PC2_P1："+ "Cor="+cor_pc_pdo + ", p="+p_pc_pdo)
   cor_pc_pdo := escorc(snow_son_pc2(iyr+1:), pdo_son(iyr+1:))
   p_pc_pdo := student_t(cor_pc_pdo*sqrt(df_sub/(1- cor_pc_pdo^2)), df_sub)
   print("PDO-PC2_P2："+ "Cor="+cor_pc_pdo + ", p="+p_pc_pdo)

   print("--------------SON Nino34-------------------------------------------------------")
   cor_pc_nino34 = escorc(snow_son_pc1, nino34_son)
   p_pc_nino34 = student_t(cor_pc_nino34*sqrt(df_pc/(1- cor_pc_nino34^2)), df_pc)
   print("nino34-PC1："+ "Cor="+cor_pc_nino34 + ", p="+p_pc_nino34)

   cor_pc_nino34 := escorc(snow_son_pc1(:iyr), nino34_son(:iyr))
   p_pc_nino34 := student_t(cor_pc_nino34*sqrt(df_sub/(1- cor_pc_nino34^2)), df_sub)
   print("nino34-PC1_P1："+ "Cor="+cor_pc_nino34 + ", p="+p_pc_nino34)
   cor_pc_nino34 := escorc(snow_son_pc1(iyr+1:), nino34_son(iyr+1:))
   p_pc_nino34 := student_t(cor_pc_nino34*sqrt(df_sub/(1- cor_pc_nino34^2)), df_sub)
   print("nino34-PC1_P2："+ "Cor="+cor_pc_nino34 + ", p="+p_pc_nino34)

   cor_pc_nino34 := escorc(snow_son_pc2, nino34_son)
   p_pc_nino34 := student_t(cor_pc_nino34*sqrt(df_pc/(1- cor_pc_nino34^2)), df_pc)
   print("nino34-PC2："+ "Cor="+cor_pc_nino34 + ", p="+p_pc_nino34)

   cor_pc_nino34 := escorc(snow_son_pc2(:iyr), nino34_son(:iyr))
   p_pc_nino34 := student_t(cor_pc_nino34*sqrt(df_sub/(1- cor_pc_nino34^2)), df_sub)
   print("nino34-PC2_P1："+ "Cor="+cor_pc_nino34 + ", p="+p_pc_nino34)
   cor_pc_nino34 := escorc(snow_son_pc2(iyr+1:), nino34_son(iyr+1:))
   p_pc_nino34 := student_t(cor_pc_nino34*sqrt(df_sub/(1- cor_pc_nino34^2)), df_sub)
   print("nino34-PC2_P2："+ "Cor="+cor_pc_nino34 + ", p="+p_pc_nino34)
   print("-------------------------------------------------------------------------------")

   ; cor_pc1_nino = escorc(snow_son_pc1, nino34_djf1)
   ; print("cor_pc1_nino： "+ cor_pc1_nino)
   ; cor_pc1_nino1 = escorc(snow_son_pc1(:imidyr), nino34_djf1(:imidyr))
   ; print("cor_pc1_nino1: " + cor_pc1_nino1)
   ; cor_pc1_nino2 = escorc(snow_son_pc1(imidyr+1:), nino34_djf1(imidyr+1:))
   ; print("cor_pc1_nino2: " + cor_pc1_nino2)
   ; print("-----------------------------------")

   ; cor_pc1_ssti := escorc(snow_son_pc1, ssti)
   ; print("cor_pc1_ssti: "+ cor_pc1_ssti)
   ; cor_pc1_ssti1 := escorc(snow_son_pc1(:imidyr), ssti(:imidyr))
   ; print("cor_pc1_ssti1: " + cor_pc1_ssti1)
   ; cor_pc1_ssti2 := escorc(snow_son_pc1(imidyr+1:), ssti(imidyr+1:))
   ; print("cor_pc1_ssti2: " + cor_pc1_ssti2)
   ; print("-----------------------------------")

;*************************************************************************************************
;print("----------------------------------------------------------------------")
;pc2-nao
   ; cor02 = escorc(snow_son_pc2, nao_djf_dt(1:ndimnao-1))
   ; print("PC2-NAO: "+cor02)
   ; cor_21 = escorc(snow_son_pc2(0:imidyr), nao_djf_dt(1:imidyr+1))
   ; print("Cor PC2-NAO_1: " + cor_21)
   ; cor_22 = escorc(snow_son_pc2(imidyr+1:42), nao_djf_dt(imidyr+2:ndimnao-1))
   ; print("Cor PC2-NAO_2: " + cor_22)
   ; print("-----------------------------------")

   ; cor_pc2_nino = escorc(snow_son_pc2, nino34_djf1)
   ; print("cor_pc2_nino： "+ cor_pc2_nino)
   ; cor_pc2_nino1 = escorc(snow_son_pc2(:imidyr), nino34_djf1(:imidyr))
   ; print("cor_pc2_nino1: " + cor_pc2_nino1)
   ; cor_pc2_nino2 = escorc(snow_son_pc2(imidyr+1:), nino34_djf1(imidyr+1:))
   ; print("cor_pc2_nino2: " + cor_pc2_nino2)
   ; print("-----------------------------------")

   ; cor_pc2_pdo = escorc(snow_son_pc2, pdo_djf1)
   ; print("cor_pc2_pdo: "+ cor_pc2_pdo)
   ; cor_pc2_pdo1 = escorc(snow_son_pc2(:imidyr), pdo_djf1(:imidyr))
   ; print("cor_pc2_pdo1: " + cor_pc2_pdo1)
   ; cor_pc2_pdo2 = escorc(snow_son_pc2(imidyr+1:), pdo_djf1(imidyr+1:))
   ; print("cor_pc2_pdo2: " + cor_pc2_pdo2)
   ; print("-----------------------------------")

   ; ;EU Snow Index
   ; print("----------------------------------------------------------------------")
   ; cor_eui_pc1 = escorc(snow_son_eui, snow_son_pc1)
   ; print("cor_eui_pc1: "+ cor_eui_pc1)
   ; cor_eui_pc2 = escorc(snow_son_eui, snow_son_pc2)
   ; print("cor_eui_pc2: "+ cor_eui_pc2)
   ; print("-----------------------------------")

   ; cor_eui_nao = escorc(snow_son_eui, nao_djf_dt(1:))
   ; print("cor_eui_nao: "+ cor_eui_nao)
   ; cor_eui_nao1 = escorc(snow_son_eui(:imidyr), nao_djf_dt(1:imidyr+1))
   ; print("cor_eui_nao1: " + cor_eui_nao1)
   ; cor_eui_nao2 = escorc(snow_son_eui(imidyr+1:), nao_djf_dt(imidyr+2:ndimnao-1))
   ; print("cor_eui_nao2: " + cor_eui_nao2)
   ; print("-----------------------------------")

   ; cor_eui_nino = escorc(snow_son_eui, nino34_djf1)
   ; print("cor_eui_nino "+ cor_eui_nino)
   ; cor_eui_nino1 = escorc(snow_son_eui(:imidyr), nino34_djf1(:imidyr))
   ; print("cor_eui_nino1: " + cor_eui_nino1)
   ; cor_eui_nino2 = escorc(snow_son_eui(imidyr+1:), nino34_djf1(imidyr+1:))
   ; print("cor_eui_nino2: " + cor_eui_nino2)
   ; print("-----------------------------------")
   
   ; cor_eui_pdo = escorc(snow_son_eui, pdo_djf1)
   ; print("cor_eui_pdo: "+ cor_eui_pdo)
   ; cor_eui_pdo1 = escorc(snow_son_eui(:imidyr), pdo_djf1(:imidyr))
   ; print("cor_eui_pdo1: " + cor_eui_pdo1)
   ; cor_eui_pdo2 = escorc(snow_son_eui(imidyr+1:), pdo_djf1(imidyr+1:))
   ; print("cor_eui_pdo2: " + cor_eui_pdo2)
   ; print("-----------------------------------")

   ; print("----------------------------------------------------------------------")
   ; cor_nao_nino = escorc(nao_djf_dt(1:), nino34_djf1)
   ; print("cor_nao_nino: " + cor_nao_nino)
   ; cor_nao_nino1 = escorc(nao_djf_dt(1:imidyr+1), nino34_djf1(:imidyr))
   ; print("cor_nao_nino1: " + cor_nao_nino1)
   ; cor_nao_nino2 = escorc(nao_djf_dt(imidyr+2:ndimnao-1), nino34_djf1(imidyr+1:))
   ; print("cor_nao_nino2: " + cor_nao_nino2)
   ; print("-----------------------------------")

   ; cor_nao_pdo = escorc(nao_djf_dt(1:), pdo_djf1)
   ; print("cor_nao_pdo: " + cor_nao_pdo)
   ; cor_nao_pdo1 = escorc(nao_djf_dt(1:imidyr+1), pdo_djf1(:imidyr))
   ; print("cor_nao_pdo1: " + cor_nao_pdo1)
   ; cor_nao_pdo2 = escorc(nao_djf_dt(imidyr+2:ndimnao-1), pdo_djf1(imidyr+1:))
   ; print("cor_nao_pdo2: " + cor_nao_pdo2)
   ; print("-----------------------------------")

   ; cor_nao_ssti := escorc(nao_djf_dt1, ssti)
   ; print("cor_nao_ssti: " + cor_nao_ssti)
   ; cor_nao_ssti1 := escorc(nao_djf_dt1(:imidyr), ssti(:imidyr))
   ; print("cor_nao_ssti1: " + cor_nao_ssti1)
   ; cor_nao_ssti2 := escorc(nao_djf_dt1(imidyr+1:), ssti(imidyr+1:))
   ; print("cor_nao_ssti2: " + cor_nao_ssti2)
   ; print("-----------------------------------")

   ; cor_nino_ssti := escorc(nino34_djf1, ssti)
   ; print("cor_nino_ssti: " + cor_nino_ssti)
   ; cor_nino_ssti1 := escorc(nino34_djf1(:imidyr), ssti(:imidyr))
   ; print("cor_nino_ssti1: " + cor_nino_ssti1)
   ; cor_nino_ssti2 := escorc(nino34_djf1(imidyr+1:), ssti(imidyr+1:))
   ; print("cor_nino_ssti2: " + cor_nino_ssti2)
   ; print("-----------------------------------")
   ; print("----------------------------------------------------------------------")
   ; df = dimsizes(snow_son_eui) - 2
   ; cor_snow_nao = escorc(snow_son_eui, nao_son_dt(0:ndimnao-2))
   ; p_snow_nao = student_t(cor_snow_nao*sqrt(df/(1- cor_snow_nao^2)), df)
   ; print("Cor:snow(SON)-nao(SON) = "+ cor_snow_nao +", p="+p_snow_nao)

   ; cor_snow_nao := escorc(snow_son_eui, nao_djf_dt(1:ndimnao-1))
   ; p_snow_nao := student_t(cor_snow_nao*sqrt(df/(1- cor_snow_nao^2)), df)
   ; print("Cor:snow(SON)-nao(DJF) = "+ cor_snow_nao +", p="+p_snow_nao)

   ; cor_nao_nao = escorc(nao_son_dt(0:ndimnao-2), nao_djf_dt(1:ndimnao-1))
   ; p_nao_nao = student_t(cor_nao_nao*sqrt(df/(1- cor_nao_nao^2)), df)
   ; print("Cor:NAO(SON)-NAO(DJF) = "+ cor_nao_nao +", p="+p_nao_nao)

;*************************************************************************************************
;bootstrap calculate
   ;-------------------------------------------------------------------------------------------------
   ; nboot = 500
   ; opt = True
   ; opt@sample_size = 22

   ; bootstrap := bootstrap_correl(snow_son_pc1, nao_djf_dt1, nboot, (/0,0/) ,opt)
   ; rboot    := bootstrap[0]
   ; rbootavg := bootstrap[1]
   ; rbootstd := bootstrap[2]
   ; print("PC1-PDO P1 Boot_Avg =: " + rbootavg)
   ; print("PC1-PDO P1 Boot_Std =: " + rbootstd)
   ; rBootLow    := bootstrap_estimate(rboot, 0.025, False)   ;  2.5% lower confidence bound 
   ; rBootMed    := bootstrap_estimate(rboot, 0.500, False)   ; 50.0% median of bootstrapped estimates
   ; rBootHi     := bootstrap_estimate(rboot, 0.975, False)
   ; print("rBootLow =: " + rBootLow)
   ; print("rBootMed =: " + rBootMed)
   ; print("rBootHi =: " + rBootHi)
   ; print("-----------------------------------")

   ; bootstrap := bootstrap_correl(snow_son_pc1(:imidyr), pdo_djf1(:imidyr), nboot, (/0,0/) ,opt)
   ; rboot    := bootstrap[0]
   ; rbootavg := bootstrap[1]
   ; rbootstd := bootstrap[2]
   ; print("PC1-PDO P1 Boot_Avg =: " + rbootavg)
   ; print("PC1-PDO P1 Boot_Std =: " + rbootstd)
   ; rBootLow    := bootstrap_estimate(rboot, 0.025, False)   ;  2.5% lower confidence bound 
   ; rBootMed    := bootstrap_estimate(rboot, 0.500, False)   ; 50.0% median of bootstrapped estimates
   ; rBootHi     := bootstrap_estimate(rboot, 0.975, False)
   ; print("rBootLow =: " + rBootLow)
   ; print("rBootMed =: " + rBootMed)
   ; print("rBootHi =: " + rBootHi)
   ; print("-----------------------------------")

   ; bootstrap := bootstrap_correl(snow_son_pc1(imidyr+1:), pdo_djf1(imidyr+1:), nboot, (/0,0/) ,opt)
   ; rboot    := bootstrap[0]
   ; rbootavg := bootstrap[1]
   ; rbootstd := bootstrap[2]
   ; print("PC1-PDO P2 Boot_Avg =: " + rbootavg)
   ; print("PC1-PDO P2 Boot_Std =: " + rbootstd)
   ; rBootLow    := bootstrap_estimate(rboot, 0.025, False)   ;  2.5% lower confidence bound 
   ; rBootMed    := bootstrap_estimate(rboot, 0.500, False)   ; 50.0% median of bootstrapped estimates
   ; rBootHi     := bootstrap_estimate(rboot, 0.975, False)
   ; print("rBootLow =: " + rBootLow)
   ; print("rBootMed =: " + rBootMed)
   ; print("rBootHi =: " + rBootHi)
   ; print("-----------------------------------")

   ; ;
   ; bootstrap := bootstrap_correl(snow_son_pc1(:imidyr), nino34_djf1(:imidyr), nboot, (/0,0/) ,opt)
   ; rboot    := bootstrap[0]
   ; rbootavg := bootstrap[1]
   ; rbootstd := bootstrap[2]
   ; print("PC1-nino P1 Boot_Avg =: " + rbootavg)
   ; print("PC1-nino P1 Boot_Std =: " + rbootstd)
   ; rBootLow    := bootstrap_estimate(rboot, 0.025, False)   ;  2.5% lower confidence bound 
   ; rBootMed    := bootstrap_estimate(rboot, 0.500, False)   ; 50.0% median of bootstrapped estimates
   ; rBootHi     := bootstrap_estimate(rboot, 0.975, False)
   ; print("rBootLow =: " + rBootLow)
   ; print("rBootMed =: " + rBootMed)
   ; print("rBootHi =: " + rBootHi)
   ; print("-----------------------------------")

   ; bootstrap := bootstrap_correl(snow_son_pc1(imidyr+1:), nino34_djf1(imidyr+1:), nboot, (/0,0/) ,opt)
   ; rboot    := bootstrap[0]
   ; rbootavg := bootstrap[1]
   ; rbootstd := bootstrap[2]
   ; print("PC1-nino P2 Boot_Avg =: " + rbootavg)
   ; print("PC1-nino P2 Boot_Std =: " + rbootstd)
   ; rBootLow    := bootstrap_estimate(rboot, 0.025, False)   ;  2.5% lower confidence bound 
   ; rBootMed    := bootstrap_estimate(rboot, 0.500, False)   ; 50.0% median of bootstrapped estimates
   ; rBootHi     := bootstrap_estimate(rboot, 0.975, False)
   ; print("rBootLow =: " + rBootLow)
   ; print("rBootMed =: " + rBootMed)
   ; print("rBootHi =: " + rBootHi)
   ; print("-----------------------------------")

;*****************************************************************
;Partial Correlation
   ; xx = snow_son_pc1
   ; yy = nao_djf_dt1
   ; zz = ssti     ;control variable
   ; partial_cor = (escorc(xx, yy) - escorc(xx, zz)*escorc(yy, zz))/(sqrt(1-escorc(xx,zz)^2)*sqrt(1-escorc(yy,zz)))

   ; df_ppc = df_pc - 1
   ; p_partial = student_t(partial_cor*sqrt(df_ppc/(1- partial_cor^2)), df_ppc)
   ; print("Pcor pc1-nao(PDO removed): " + partial_cor + ",   p-value: " + p_partial)
   
   ; ;First Period
   ; xx := snow_son_pc1(:imidyr)
   ; yy := nao_djf_dt1(:imidyr)
   ; zz := pdo_djf1(:imidyr)     ;control variable
   ; partial_cor := (escorc(xx, yy) - escorc(xx, zz)*escorc(yy, zz))/(sqrt(1-escorc(xx,zz)^2)*sqrt(1-escorc(yy,zz)))

   ; df_ppc := imidyr - 3
   ; p_partial := student_t(partial_cor*sqrt(df_ppc/(1- partial_cor^2)), df_ppc)
   ; print("Pcor pc1-nao(PDO removed) P1: " + partial_cor + ",   p-value: " + p_partial)
   
   ; ;Second Period
   ; xx := snow_son_pc1(imidyr+1:)
   ; yy  := nao_djf_dt1(imidyr+1:)
   ; zz  := pdo_djf1(imidyr+1:)     ;control variable
   ; partial_cor := (escorc(xx, yy) - escorc(xx, zz)*escorc(yy, zz))/(sqrt(1-escorc(xx,zz)^2)*sqrt(1-escorc(yy,zz)))

   ; df_ppc := imidyr - 1
   ; p_partial := student_t(partial_cor*sqrt(df_ppc/(1- partial_cor^2)), df_ppc)
   ; print("Pcor pc1-nao(PDO removed) P2: " + partial_cor + ",   p-value: " + p_partial)
   ; print("-----------------------------------")

   ; ;Partial Correlation using multi regression
   ; pc1_res = snow_son_pc1 - \
   ;                  pdo_djf1*regline(pdo_djf1, snow_son_pc1)
   ;                ; nino34_djf1*regline(nino34_djf1, snow_son_pc1)
   ; nao_res = nao_djf_dt1  - \
   ;                  pdo_djf1*regline(pdo_djf1, nao_djf_dt1)
   ;                  ; nino34_djf1*regline(nino34_djf1, nao_djf_dt1)
   ; pcor_pc1_nao = escorc(pc1_res, nao_res)
   ; print("Partial Correlation using multi regression")
   ; print("pcor_pc1_nao: " + pcor_pc1_nao)

   ; pc1_res1 = snow_son_pc1(:imidyr) -  \
   ;          pdo_djf1(:imidyr)*regline(pdo_djf1(:imidyr), snow_son_pc1(:imidyr))
   ;         ; nino34_djf1(:imidyr)*regline(nino34_djf1(:imidyr),snow_son_pc1(:imidyr))  
   ; nao_res1 = nao_djf_dt1(:imidyr)  -  \
   ;        pdo_djf1(:imidyr)*regline(pdo_djf1(:imidyr), nao_djf_dt1(:imidyr))
   ;        ; nino34_djf1(:imidyr)*regline(nino34_djf1(:imidyr),nao_djf_dt1(:imidyr)) 
   ; pcor_pc1_nao1 = escorc(pc1_res1, nao_res1)
   ; print("pcor_pc1_nao1: " + pcor_pc1_nao1)

   ; pc1_res2 = snow_son_pc1(imidyr+1:)  - \ 
   ;        pdo_djf1(imidyr+1:)*regline(pdo_djf1(imidyr+1:), snow_son_pc1(imidyr+1:)) 
   ;      ; - nino34_djf1(imidyr+1:)*regline(nino34_djf1(imidyr+1:),snow_son_pc1(imidyr+1:))
   ; nao_res2 = nao_djf_dt1(imidyr+1:) - \
   ;        pdo_djf1(imidyr+1:)*regline(pdo_djf1(imidyr+1:), nao_djf_dt1(imidyr+1:)) 
   ;      ; - nino34_djf1(imidyr+1:)*regline(nino34_djf1(imidyr+1:),nao_djf_dt1(imidyr+1:))
   ; pcor_pc1_nao2 = escorc(pc1_res2, nao_res2)
   ; print("pcor_pc1_nao2: " + pcor_pc1_nao2)
   
   ; print("-----------------------------------")
   ; pc2_res = snow_son_pc2 - nino34_djf1*regline(nino34_djf1, snow_son_pc2) 
   ; ; - pdo_djf1*regline(pdo_djf1, snow_son_pc2)
   ; nao_res = nao_djf_dt1  - nino34_djf1*regline(nino34_djf1, nao_djf_dt1) 
   ; ; - pdo_djf1*regline(pdo_djf1, nao_djf_dt1)
   ; pcor_pc2_nao = escorc(pc2_res, nao_res)
   ; print("pcor_pc2_nao: " + pcor_pc2_nao)

   ; pc2_res1 = snow_son_pc2(:imidyr) - nino34_djf1(:imidyr)*regline(nino34_djf1(:imidyr),snow_son_pc2(:imidyr)) \ 
   ;      ; - pdo_djf1(:imidyr)*regline(pdo_djf1(:imidyr), snow_son_pc2(:imidyr))
   ; nao_res1 = nao_djf_dt1(:imidyr)  - nino34_djf1(:imidyr)*regline(nino34_djf1(:imidyr),nao_djf_dt1(:imidyr)) \
   ;    ; - pdo_djf1(:imidyr)*regline(pdo_djf1(:imidyr), nao_djf_dt1(:imidyr))
   ; pcor_pc2_nao1 = escorc(pc2_res1, nao_res1)
   ; print("pcor_pc2_nao1: " + pcor_pc2_nao1)

   ; pc2_res2 = snow_son_pc2(imidyr+1:)  \ 
   ;      - nino34_djf1(imidyr+1:)*regline(nino34_djf1(imidyr+1:),snow_son_pc2(imidyr+1:))
   ;      ; - pdo_djf1(imidyr+1:)*regline(pdo_djf1(imidyr+1:), snow_son_pc2(imidyr+1:)) \ 
   ; nao_res2 = nao_djf_dt1(imidyr+1:) \
   ;      - nino34_djf1(imidyr+1:)*regline(nino34_djf1(imidyr+1:),nao_djf_dt1(imidyr+1:))
   ;      ; - pdo_djf1(imidyr+1:)*regline(pdo_djf1(imidyr+1:), nao_djf_dt1(imidyr+1:)) \ 
   ; pcor_pc2_nao2 = escorc(pc2_res2, nao_res2)
   ; print("pcor_pc2_nao2: " + pcor_pc2_nao2)

   ;Multi reg
   ; M = 2
   ; N = imidyr + 2
   ;     X  = new ( (/M+1,N/), "float" )  
   ;     X(0,:) = 1.0
   ;     X(1,:) = nino34_djf1(imidyr+1:)
   ;     X(2,:) = pdo_djf1(imidyr+1:)
   ;  beta = reg_multlin (snow_son_pc1(imidyr+1:),X,False)

   ;  snow_pc1_res2 = snow_son_pc1(imidyr+1:) - beta(1)*nino34_djf1(imidyr+1:) - beta(2)*pdo_djf1(imidyr+1:)
   ;  pcor_snow_nao2 = escorc(snow_pc1_res2, nao_djf_dt1(imidyr+1:))
   ;  print(pcor_snow_nao2)
;*****************************************************************
;run cor
   wSize = 31
   ; print("wSize =  "+ wSize)
   ; rcor_pc1 = run_cor(si, nao_djf, snow_son_eu&time, wSize)
   rcor_pc1 = run_cor(pdo_son(:dimsizes(pdo_son)-2), nao_djf, snow_son_eu&time, wSize)

   rcor_pc2 = run_cor(si2, nao_djf, snow_son_eu&time, wSize)
   ;----------------------------------------------------------------------
   ;Manual
   ; rcor = new(23, float)
   ; do i = 0, dimsizes(rcor) - 1 
   ;     rcor(i) = escorc(snow_son_pc1(i:i+wSize-1), nao_djf_dt(i+1:i+wSize))
   ; end do
   ; printVarSummary(rcor)
   ; print(rcor)
   ;*****************************************************************
    ; pdo_rave = runave_Wrap(pdo_djf, 7, -1)
    pdo_rave = runave_Wrap(pdo_son, 11, -1)

    nao_rave = runave_Wrap(nao_djf, 11, -1)

;*****************************************************************
 ;climatic average
   ; snow_son_p1 = snow_son(0:imidyr,:,:)
   ; snow_son_p2 = snow_son(imidyr+1:ndim_snow-1,:,:)

   ; snow_clim_p1 = dim_avg_n_Wrap(snow_son_p1, 0)
   ; snow_clim_p2 = dim_avg_n_Wrap(snow_son_p2, 0)

   ; snow_clim_dif = snow_clim_p2
   ; snow_clim_dif = snow_clim_p2 - snow_clim_p1

   ; snow_var_p1 = dim_stddev_n_Wrap(snow_son_p1, 0)
   ; snow_var_p2 = dim_stddev_n_Wrap(snow_son_p2, 0)
   ; snow_var_dif = snow_var_p2
   ; snow_var_dif = snow_var_p2 - snow_var_p1

   ; printMinMax(snow_var_p1, 0)
   ; printMinMax(snow_var_p2, 0)
   ; printMinMax(snow_var_dif, 0)

;*****************************************************************
;Resources Fill,line
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
   ;resrc@lbOrientation = "Vertical"
   ;resrc@lgLabelsOn = False
   resrc@cnInfoLabelOn = False
   resrc@cnLevelSelectionMode = "ManualLevels"
   resrc@mpGridAndLimbOn = False
   ; resrc@mpGridSpacingF = 5
   ; resrc@mpGridLineDashPattern = 5
   resrc@mpOutlineOn = True
   ; resrc@mpOutlineSpecifiers = (/"China","Taiwan","China-Hainan-Dao-Island"/)
   resrc@tmXBLabelFontHeightF = 0.015
   resrc@tmYLLabelFontHeightF = 0.015
   resrc@pmLabelBarOrthogonalPosF = 0.15
   resrc@mpFillOn = True
   resrc@mpMinLonF = 0
   resrc@mpMaxLonF = 360
   ; resrc@mpMinLonF = 180
   ; resrc@mpMaxLonF = 330
   resrc@mpMaxLatF = 90
   resrc@mpMinLatF = 0
   resrc@mpCenterLonF = (resrc@mpMinLonF+resrc@mpMaxLonF)/2.
   resrc@mpAreaMaskingOn = True
   resrc@mpOceanFillColor = "white"
   resrc@mpLandFillColor = "Transparent"
   ; resrc@mpMaskAreaSpecifiers =(/"China","Taiwan"/)

   res_snow = resrc
   res_snow@lbLabelBarOn = True
   res_snow@mpMinLatF = latS_eu-10
   res_snow@mpMaxLatF = latN_eu
   res_snow@mpMinLonF = lonW_eu
   res_snow@mpMaxLonF = lonE_eu

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
   rescor@cnFillScaleF = 1.
   rescor@cnFillDotSizeF = 0.003
   rescor@cnFillOpacityF = 1.0
   rescor@cnFillDrawOrder = "PreDraw"

   rescor2 = res
   rescor2@cnLinesOn = False
   rescor2@cnFillOn = True
   rescor2@cnInfoLabelOn = False
   rescor2@lbLabelBarOn = False
   ; rescor2@cnMonoFillPattern = True
   rescor2@cnLevelSelectionMode = "ExplicitLevels"
   rescor2@cnLevels = (/0.01, 0.05/)
   rescor2@cnFillColors = (/"grey35", "grey65", "Transparent"/)   
   ; rescor2@cnFillColors = (/1, 2, 4/)
   rescor2@mpCenterLonF = 180.
   rescor2@mpFillOn = False
   rescor2@mpMinLonF = 0.
   rescor2@mpMaxLonF = 360.
   rescor2@mpMaxLatF = 90.
   rescor2@mpMinLatF = 0.

   ;Wind Resources
   resV = True
   resV@gsnDraw = False
   resV@gsnFrame = False
   resV@vcRefMagnitudeF = 1.0
   resV@vcRefLengthF = 0.04
   resV@vcRefAnnoArrowLineColor = "black"  
   resV@vcRefAnnoArrowUseVecColor = False
   resV@vcRefAnnoFontHeightF = 0.008
   resV@vcRefAnnoPerimOn = True
   resV@vcRefAnnoString2On = False
   resV@vcRefAnnoOrthogonalPosF = -0.65
   resV@vcGlyphStyle = "CurlyVector"
   resV@vcLineArrowColor        = "black"           ; change vector color
   resV@vcLineArrowThicknessF   = 1.8               ; change vector thickness
   resV@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
   resV@vcMinDistanceF     = 0.02

   resP = True                
   resP@gsnMaximize = False
   resP@gsnPanelFigureStringsFontHeightF = 0.015
   resP@gsnPanelFigureStringsPerimOn = False
   resP@amJust = "TopLeft"
   resP@gsnPanelFigureStringsBackgroundFillColor = "black"
   resP@gsnPanelFigureStringsFontColor = "white"
   ;**********************************************************
   ;Res, XY 
   rts           = True
   rts@gsnDraw   = False       ; don't draw yet
   rts@gsnFrame  = False       ; don't advance frame yet
   rts@gsnScale  = True        ; force text scaling               
   rts@vpHeightF = 0.35        ; Changes the aspect ratio
   rts@vpWidthF  = 0.80
   rts@vpXF      = 0.15        ; change start locations
   rts@vpYF      = 0.75        ; the plot 
   rts@tmYLLabelFontHeightF = 0.015
   rts@tmYLLabelFontHeightF = 0.015
   rts@gsnLeftStringFontHeightF = 0.015

   rts_bar = rts  ; Bar Chart
   rts_bar@gsnXYBarChart = True
   rts_bar@gsnYRefLine  = 0.
   rts_bar@gsnAboveYRefLineColor = "blue"
   rts_bar@gsnBelowYRefLineColor = "red"
   rts_bar@gsnXYBarChartBarWidth = 0.6
   ;rts_bar@gsnLeftString = "(b) PC1"
   ;rts_bar@tmXUseBottom = True
   ; rts_bar@tmXBMode = "Explicit"
   ; rts_bar@tmXBValues = ispan(1975, 2005, 5)
   ; rts_bar@tmXBLabels = ispan(1975, 2005, 5)
   ; rts_bar@tmXBMinorValues = ispan(1972, 2009, 1)
   rts_bar@tmXTOn = False
   rts_bar@tmYROn = False
   rts_bar@tmXBLabelFontHeightF = 0.015
   ; rts_bar@tiXAxisString = "Time (Year)"
   rts_bar@tiXAxisFontHeightF = 0.02
   rts_bar@tiYAxisString = " "
   rts_bar@tiYAxisFontHeightF = 0.02
   ; rts_bar@trXMinF = 1971.5
   ; rts_bar@trXMaxF = 2009.5

   rts_line0 = rts
   rts_line0@xyLineThicknesses = 2
   rts_line0@gsnLeftStringFontHeightF = 0.015
   rts_line0@gsnRightStringFontHeightF = 0.015
   rts_line0@gsnYRefLineDashPattern = 1
   ; rts_line0@trXMinF = yrstrt/100
   ; rts_line0@trXMaxF = yrlast/100

   rts_line = rts   ; Line
   rts_line@xyLineThicknesses = (/2, 2.5/)
   rts_line@xyLineColors = (/"orange","black"/)
   rts_line@xyDashPatterns = (/0,1/)
   rts_line@pmLegendDisplayMode    = "Always"              ; turn on legend
   rts_line@pmLegendSide           = "Top"                 ; Change location of 
   rts_line@pmLegendParallelPosF   = 0.28                   ; move units right
   rts_line@pmLegendOrthogonalPosF = -0.28                  ; more neg = down
   rts_line@pmLegendWidthF         = 0.12                  ; Change width and
   rts_line@pmLegendHeightF        = 0.05                  ; height of legend.
   rts_line@lgLabelFontHeightF     = 0.01                   ; change font height
   rts_line@lgPerimOn              = False                 ; no box around

   rtsP = True
   rtsP@lbLabelAutoStride = True
;**********************************************************************
   ; time_year = ispan(yrstrt/100, yrlast/100, 1)
  
   ; ; data_pc = new((/2,ndimnao-1/), typeof(nao_son))
   ; ; data_pc (0,:) = nao_son_dt(0:ndimnao-2)
   ; ; data_pc (1,:) = nao_djf_dt(1:ndimnao-1)
   ; rts_bar@trYMaxF = 4
   ; rts_bar@trYMinF = -4
   ; rts_bar@gsnLeftString = "PC2 and NAO(DJF)"
   ; plot0 = gsn_csm_xy(wks, time_year, snow_son_pc2, rts_bar)
   ; ; rts_line@xyExplicitLegendLabels = (/" NAO_SON", " NAO_DJF"/)
   ; ; plot01 =  gsn_csm_xy(wks, time_year, data_pc, rts_line)
   ; rts_line@xyExplicitLegendLabels = (/" NAO_DJF"/)
   ; plot01 =  gsn_csm_xy(wks, time_year, nao_djf_dt(1:), rts_line)   
   
   ; overlay(plot0, plot01)
   ; draw(plot0)
   ; frame(wks)

  ;-------------------------------------------------------------
   ; time_rcor = ispan(1972+tointeger(wSize/2), yrstrt/100-tointeger(wSize/2), 1)
    ; time_rcor = ispan(1972, 1994, 1)

   ; sig95_15 = 0.514
   sig95_21 = 0.433
   ; sig95_25 = 0.404
   sig95_31 = 0.355

   ; ; signame =  "sig95_"+wSize
   rts_line0@trYMaxF = 0.
   rts_line0@trYMinF = -0.65
   rts_line0@gsnYRefLine = sig95_31*-1
   rts_line0@gsnRightString = "wSize = " + wSize + " years"

   ; rts_line0@gsnLeftString = "a) Running Correlation <AEUSC_PC1,NAO>"
   plot0 = gsn_csm_xy(wks, rcor_pc1&time, rcor_pc1, rts_line0)

   draw(plot0)
   frame(wks)

   ; rts_line0@gsnLeftString = "b) Running Correlation <AEUSC_PC2,NAO>"
   plot1 = gsn_csm_xy(wks, rcor_pc2&time, rcor_pc2, rts_line0)

   rcor_panel = new(2, graphic)
   rcor_panel(0) = plot0
   rcor_panel(1) = plot1
   resP@gsnPanelYWhiteSpacePercent = 8
   gsn_panel(wks, rcor_panel, (/2,1/), resP)

   delete(rts_line0@gsnYRefLine)
   rts_line0@gsnRightString = " "

   ; rts_bar@gsnXYBarChartBarWidth = 0.05
   rts_bar@gsnLeftString = " "
   rts_bar@trYMaxF = 3
   rts_bar@trYMinF = -3
   ; plot1 := gsn_csm_xy(wks, year, snow_son_pc1, rts_bar)
      plot1 := gsn_csm_xy(wks, year(0:46), nao_djf, rts_bar)

   ; data_ts := new((/3,ndimnao-1/), typeof(nao_son))
   ; data_ts (0,:) = nao_djf_dt1
   ; data_ts (1,:) = nino34_djf(1:)
   ; data_ts (2,:) = pdo_djf(1:)
   ; rts_line@xyLineColors := (/"darkgoldenrod","black", "red"/)
   ; rts_line@xyExplicitLegendLabels := (/"NAO","Nino34" ,"PDO"/)
   ; rts_line@xyDashPatterns := (/0,0,1/)
   ; rts_line@xyLineThicknesses := (/2, 2, 2.5/)

   ; plot2 := gsn_csm_xy(wks, year, data_ts, rts_line)
   ; rts_line0@gsnRightString = " "
   ; rts_line0@gsnYRefLineDashPattern = 0
   ; rts_line0@gsnXRefLineColor = "red"
   ; plot2 = gsn_csm_xy(wks, year, nino34_djf(1:), rts_line0)

   rts_line0@gsnYRefLineDashPattern = 2
   rts_line0@gsnXRefLineColor = "black"
   ; plot3 = gsn_csm_xy(wks, year, pdo_rave, rts_line0)
      plot3 = gsn_csm_xy(wks, year(0:46), nao_rave, rts_line0)

   ; overlay(plot1, plot2)
   overlay(plot1, plot3)
   draw(plot1)
   frame(wks)
;*****************************************************************************
   ; res_snow@cnMaxLevelValF = 80
   ; res_snow@cnMinLevelValF = 20
   ; res_snow@cnLevelSpacingF = 2
   ; res_snow@cnFillPalette = "MPL_YlGnBu"
   ; cnplots = new(3, graphic)
   ; res_snow@gsnLeftString = "climatic-average snow cover P1"
   ; cnplots(0) = gsn_csm_contour_map(wks, snow_clim_p1, res_snow)

   ; res_snow@gsnLeftString = "climatic-average snow cover P2"
   ; cnplots(1) = gsn_csm_contour_map(wks, snow_clim_p2, res_snow)

   ; res_snow@cnMaxLevelValF = 20
   ; res_snow@cnMinLevelValF = -20
   ; res_snow@cnFillPalette = "MPL_RdBu"
   ; res_snow@gsnLeftString = "climatic-average snow cover Dif"
   ; cnplots(2) = gsn_csm_contour_map(wks, snow_clim_dif, res_snow)

   ; ; gsn_panel(wks, cnplots, (/3,1/), resP)


   ; res_snow@cnMaxLevelValF = 20
   ; res_snow@cnMinLevelValF = 0
   ; res_snow@cnLevelSpacingF = 2
   ; res_snow@cnFillPalette = "MPL_YlGnBu"
   ; res_snow@gsnLeftString = "Stddev snow cover P1"
   ; cnplots(0) = gsn_csm_contour_map(wks, snow_var_p1, res_snow)

   ; res_snow@gsnLeftString = "Stddev snow cover P2"
   ; cnplots(1) = gsn_csm_contour_map(wks, snow_var_p2, res_snow)

   ; res_snow@cnMaxLevelValF = 10
   ; res_snow@cnMinLevelValF = -10
   ; res_snow@cnFillPalette = "MPL_RdBu"
   ; res_snow@gsnLeftString = "Stddev snow cover Dif"
   ; cnplots(2) = gsn_csm_contour_map(wks, snow_var_dif, res_snow)

   ; gsn_panel(wks, cnplots, (/3,1/), resP)



end
