begin

   ; yrstrt = 199401
   ; yrlast = 201412
   ; nyrs = yrlast/100 - yrstrt/100 + 1

;read ascii soviet snow 
   snow_path = "$HOME/data/snow/soviet_snow_depth/daily_data/"
   
   fasc = "*.dat"
   FASC = "snow_soviet_2.asc"
   system ("/bin/rm -f "+snow_path + FASC)
   system ("cd "+ snow_path + " ; cat " + fasc + " > " + snow_path + FASC)
   nrows = numAsciiRow(snow_path+FASC)   ; contributed.ncl
   ncols = numAsciiCol(snow_path+FASC)
   data  = asciiread(snow_path+FASC,(/nrows,ncols/),"float")
   print(data)

   ; file_list = systemfunc("ls "+snow_path+"*.dat")
   ; printVarSummary(file_list)
   ; print(file_list(0:10))
   ; snow_station = addfiles(file_list, "r")
   ; printVarSummary(snow_station)





end