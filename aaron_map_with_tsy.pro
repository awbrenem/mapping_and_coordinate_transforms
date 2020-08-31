;Map Tsyganenko field model to ionosphere and equator. Requires spacecraft
;GSM coordinates as input.
;NOTE: make sure values are in km, NOT RE

;model --> 'none' (for igrf), 't89', 't96', 't01', 't04'
;storm_start --> For T04, string date and time of the start of the storm (e.g. '2016-01-20/19:44:00')
;                For other models, set to start time of when you want mapping to begin
;dur --> For T04 this is the duration of the storm (seconds)
;        For other models, set this to the duration of the mapping
;sc --> Just a prefix. Can use 'RBSPa' or 'FB4' etc...
;gsm_coord --> tplot variable: GSM coord [km] of the satellite. These are the values that will be mapped
;Kpval -> for the t89 model, input a Kp value for "modpars"
;R0 (km) -> from the ttrace2iono routine. The inner boundary of the trace. Defaults to 1.0,
;   the Earth's surface.
;rlim (km) --> from the ttrace2iono and ttrace2equator routines. The outer boundary of
;     the trace (RE). Defaults to 60 RE, but this can cause unusually long run times
;     "The number of field-line elements exceeded 10000. Computation terminated" error

;Written by Aaron W Breneman, Sept 2016

pro aaron_map_with_tsy,model,storm_start,dur,sc,gsm_coord,Kpval,R0=R0,rlim=rlim

  rbsp_efw_init

  if ~KEYWORD_SET(rlim) then rlim = 60.

  if model eq 't04' then model = 't04s'


;  timespan,time_double(storm_start),dur/86400,/days
;  get_timespan,ts


;  date0 = (strsplit(time_string(storm_start),'/',/extract))[0]
;;  date1 = (strsplit(time_string(ts[1]+24.0*3600.0),'/',/extract))[0]
;  date1 = (strsplit(time_string(ts[1]),'/',/extract))[0]

;timespan,date0,(time_double(date1)-time_double(date0))/60.,/minutes

;  date0 = (strsplit(time_string(storm_start),'/',/extract))[0]
;  date1 = (strsplit(time_string(ts[1]),'/',/extract))[0]


timespan,storm_start,dur,/seconds





  ;------------------------------------------------------------
  ;note: TS04 model integrates parameters from the start of the storm
  ;------------------------------------------------------------

  if model ne 't89' then begin
    omni_hro_load ;load solar wind and sym H

    tdegap,'OMNI_HRO_1min_SYM_H',/overwrite
    tdeflag,'OMNI_HRO_1min_SYM_H','linear',/overwrite
    tdegap,'OMNI_HRO_1min_BY_GSM',/overwrite
    tdeflag,'OMNI_HRO_1min_BY_GSM','linear',/overwrite
    tdegap,'OMNI_HRO_1min_BZ_GSM',/overwrite

;stop
;print,'*****modifying TSY model*****.WARNING...BE SURE TO DESELECT THIS!!!!!$######$'
;  get_data,'OMNI_HRO_1min_BZ_GSM',t,d
;  store_data,'OMNI_HRO_1min_BZ_GSM',t,d/2.
;  stop


    tdeflag,'OMNI_HRO_1min_Bz_GSM','linear',/overwrite
    tdegap,'OMNI_HRO_1min_proton_density',/overwrite
    tdeflag,'OMNI_HRO_1min_proton_density','linear',/overwrite
    tdegap,'OMNI_HRO_1min_flow_speed',/overwrite
    tdeflag,'OMNI_HRO_1min_flow_speed','linear',/overwrite

    store_data,'omni_imf',data=['OMNI_HRO_1min_BY_GSM','OMNI_HRO_1min_BZ_GSM']


;    timespan,storm_start,dur/86400.
    timespan,storm_start,dur,/seconds
    get_timespan,ts


    time_clip,'OMNI_HRO_1min_SYM_H',ts[0],ts[1],/replace
    time_clip,'OMNI_HRO_1min_BY_GSM',ts[0],ts[1],/replace
    time_clip,'OMNI_HRO_1min_BZ_GSM',ts[0],ts[1],/replace
    time_clip,'OMNI_HRO_1min_proton_density',ts[0],ts[1],/replace
    time_clip,'OMNI_HRO_1min_flow_speed',ts[0],ts[1],/replace
    time_clip,gsm_coord,ts[0],ts[1],/replace

  endif

  ;---------------------------------------------------------------------------
  ;Get various parameters from the Tsyganenko model. These are input into the
  ;tracing routines
  ;---------------------------------------------------------------------------


;timespan,'2016-01-20/19:20',30,/minutes


  if model ne 't89' and model ne 'none' then $
    get_tsy_params,'OMNI_HRO_1min_SYM_H','omni_imf','OMNI_HRO_1min_proton_density',$
    'OMNI_HRO_1min_flow_speed',model,/speed,/imf_yz

  if model ne 't89' and model ne 'none' and model ne 't04' then modpars = model + '_par'
  if model eq 't04' then modpars = 't04s_par'
  if model eq 't89' or model eq 'none' then modpars = Kpval


;enhance cadence of position coord
  get_data,gsm_coord,tt,dd

  ndays = (tt[n_elements(tt)-1] - tt[0])/86400
  newtimes = 4.*dindgen(ndays*86400./4.)+tt[0]

  tinterpol_mxn,gsm_coord,newtimes,newname=gsm_coord


  ;Input in GSM --> output in GSM (see crib_ttrace.pro)
  ttrace2equator,gsm_coord,external_model=model,par=modpars,$
  in_coord='gsm',newname=sc+'_out_eq_foot_gsm',/km,R0=R0,rlim=rlim;,set_tilt='tilt'

  ttrace2iono,gsm_coord,external_model=model,par=modpars,$
  in_coord='gsm',newname=sc+'_out_iono_foot_north_gsm',/km,R0=R0,rlim=rlim

  ttrace2iono,gsm_coord,external_model=model,par=modpars,$
  in_coord='gsm',newname=sc+'_out_iono_foot_south_gsm',/km,/south,R0=R0,rlim=rlim

  ;for Lshell calculation
  cotrans,sc+'_out_eq_foot_gsm',sc+'_out_eq_foot_sm',/GSM2SM
  cotrans,sc+'_out_iono_foot_north_gsm',sc+'_out_iono_foot_north_sm',/GSM2SM
  cotrans,sc+'_out_iono_foot_south_gsm',sc+'_out_iono_foot_south_sm',/GSM2SM

  ;for MLT calculation
  cotrans,sc+'_out_eq_foot_gsm',sc+'_out_eq_foot_gse',/GSM2GSE
  cotrans,sc+'_out_iono_foot_north_gsm',sc+'_out_iono_foot_north_gse',/GSM2GSE
  cotrans,sc+'_out_iono_foot_south_gsm',sc+'_out_iono_foot_south_gse',/GSM2GSE



  options,[sc+'_out_iono_foot_north_sm'],labels=['x_sm','y_sm','z_sm']
  options,[sc+'_out_iono_foot_south_sm'],labels=['x_sm','y_sm','z_sm']
  options,[sc+'_out_iono_foot_north_gse'],labels=['x_gse','y_gse','z_gse']
  options,[sc+'_out_iono_foot_south_gse'],labels=['x_gse','y_gse','z_gse']
  options,[sc+'_out_iono_foot_north_gsm'],labels=['x_gsm','y_gsm','z_gsm']
  options,[sc+'_out_iono_foot_south_gsm'],labels=['x_gsm','y_gsm','z_gsm']


  ;--------------------------------------------------------------
  ;Calculate Lshell
  ;--------------------------------------------------------------


  get_data,sc+'_out_eq_foot_sm',data=tmpsm
  postimes_sm=tmpsm.x

  ; Lshell
  Lshell = sqrt(tmpsm.y[*,0]^2+tmpsm.y[*,1]^2+tmpsm.y[*,2]^2)/6371.
  if model ne 'none' then store_data,sc+'!CL-shell-'+model,data={x:postimes_sm,y:Lshell}
  if model eq 'none' then store_data,sc+'!CL-shell-igrf',data={x:postimes_sm,y:Lshell}


  ;-------------------------------------
  ;Find MLT and ILAT of North foot point
  ;-------------------------------------

  get_data,sc+'_out_iono_foot_north_sm',data=tmpsm
  postimes_sm=tmpsm.x

  ;mapped ILAT
  ILAT = atan(tmpsm.y[*,2]/sqrt(tmpsm.y[*,0]^2+tmpsm.y[*,1]^2))*180/!pi
  if model ne 'none' then store_data,sc+'!Cnorth-foot-ILAT!C'+model,data={x:postimes_sm,y:ILAT}
  if model eq 'none' then store_data,sc+'!Cnorth-foot-ILAT!Cigrf',data={x:postimes_sm,y:ILAT}


  get_data,sc+'_out_iono_foot_north_gse',data=tmpgse
  postimes_gse=tmpgse.x


  ; MLT of foot point
;  mloctime=atan(tmpgse.y[*,1]/tmpgse.y[*,0])*180/!pi/15.+12
;  if where(tmpgse.y[*,0] lt 0) ne [-1] then begin
;    if (n_elements(where(tmpgse.y[*,0] lt 0)) ge 1) then mloctime[where(tmpgse.y[*,0] lt 0)]=(atan(tmpgse.y[where(tmpgse.y[*,0] lt 0),1]/$
;    tmpgse.y[where(tmpgse.y[*,0] lt 0),0])+!pi)*180/!pi/15.+12
;  endif
  ;  if (n_elements(where(mloctime ge 24)) ge 1) and where(mloctime ge 24) ne [-1] $
  ;  then mloctime[where(mloctime ge 24)]=mloctime[where(mloctime ge 24)]-24


  ; MLT of foot point
  angle_tmp = atan(tmpgse.y[*,1],tmpgse.y[*,0])/!dtor
  goo = where(angle_tmp lt 0.)
  if goo[0] ne -1 then angle_tmp[goo] = 360. - abs(angle_tmp[goo])
  mloctime = angle_tmp * 12/180. + 12.
  goo = where(mloctime ge 24.)
  if goo[0] ne -1 then mloctime[goo] = mloctime[goo] - 24




  if model ne 'none' then store_data,sc+'!Cnorth-foot-MLT!C'+model,data={x:postimes_gse,y:mloctime}
  if model eq 'none' then store_data,sc+'!Cnorth-foot-MLT!Cigrf',data={x:postimes_gse,y:mloctime}


  outname = sc+'_out_iono_foot_north'
  cotrans,outname+'_gsm',outname+'_gse',/GSM2GSE
  cotrans,outname+'_gse',outname+'_gei',/GSE2GEI
  cotrans,outname+'_gei',outname+'_geo',/GEI2GEO

  get_data,outname+'_geo',data=data
  glat=atan(data.y(*,2)/sqrt(data.y(*,0)^2+data.y(*,1)^2))*180/!pi
  glon=atan(data.y(*,1)/data.y(*,0))*180/!pi

  if (n_elements(where(data.y(*,0) lt 0)) ge 2) then glon[where(data.y(*,0) lt 0)]=glon[where(data.y(*,0) lt 0)]+180
  store_data,outname+'_glat_glon',data={x:data.x,y:[[glat],[glon]]},dlim={colors:[2,4],labels:['GLAT','GLON']}




  ;-------------------------------------
  ;Find MLT and ILAT of South foot point
  ;-------------------------------------


  get_data,sc+'_out_iono_foot_south_sm',data=tmpsm
  postimes_sm=tmpsm.x

  ;mapped ILAT
  ILAT = atan(tmpsm.y[*,2]/sqrt(tmpsm.y[*,0]^2+tmpsm.y[*,1]^2))*180/!pi
  if model ne 'none' then store_data,sc+'!Csouth-foot-ILAT!C'+model,data={x:postimes_sm,y:ILAT}
  if model eq 'none' then store_data,sc+'!Csouth-foot-ILAT!Cigrf',data={x:postimes_sm,y:ILAT}

  ;------

  ; MLT of foot point
  get_data,sc+'_out_iono_foot_south_gse',data=tmpgse
  postimes_gse=tmpgse.x

  angle_tmp = atan(tmpgse.y[*,1],tmpgse.y[*,0])/!dtor
  goo = where(angle_tmp lt 0.)
  if goo[0] ne -1 then angle_tmp[goo] = 360. - abs(angle_tmp[goo])
  mloctime = angle_tmp * 12/180. + 12.
  goo = where(mloctime ge 24.)
  if goo[0] ne -1 then mloctime[goo] = mloctime[goo] - 24


;  mloctime=atan(tmpgse.y[*,1]/tmpgse.y[*,0])*180/!pi/15.+12
;  if where(tmpgse.y[*,0] lt 0) ne [-1] then begin
;    if (n_elements(where(tmpgse.y[*,0] lt 0)) ge 1) then mloctime[where(tmpgse.y[*,0] lt 0)]=(atan(tmpgse.y[where(tmpgse.y[*,0] lt 0),1]/$
;    tmpgse.y[where(tmpgse.y[*,0] lt 0),0])+!pi)*180/!pi/15.+12
;  endif
;
;  if (n_elements(where(mloctime ge 24)) ge 1) and where(mloctime ge 24) ne [-1] $
;  then mloctime[where(mloctime ge 24)]=mloctime[where(mloctime ge 24)]-24

  if model ne 'none' then store_data,sc+'!Csouth-foot-MLT!C'+model,data={x:postimes_gse,y:mloctime}
  if model eq 'none' then store_data,sc+'!Csouth-foot-MLT!Cigrf',data={x:postimes_gse,y:mloctime}



  outname = sc+'_out_iono_foot_south'
  cotrans,outname+'_gsm',outname+'_gse',/GSM2GSE
  cotrans,outname+'_gse',outname+'_gei',/GSE2GEI
  cotrans,outname+'_gei',outname+'_geo',/GEI2GEO

  get_data,outname+'_geo',data=data
  glat=atan(data.y(*,2)/sqrt(data.y(*,0)^2+data.y(*,1)^2))*180/!pi
  glon=atan(data.y(*,1)/data.y(*,0))*180/!pi

  if (n_elements(where(data.y(*,0) lt 0)) ge 2) then glon[where(data.y(*,0) lt 0)]=glon[where(data.y(*,0) lt 0)]+180
  store_data,outname+'_glat_glon',data={x:data.x,y:[[glat],[glon]]},dlim={colors:[2,4],labels:['GLAT','GLON']}



  ;--------------------------------------------------------
  ;Find MLT and ILAT of Equatorial foot point
  ;--------------------------------------------------------


  get_data,sc+'_out_eq_foot_sm',data=tmpsm
  postimes_sm=tmpsm.x

  ;mapped ILAT
  ILAT = atan(tmpsm.y[*,2]/sqrt(tmpsm.y[*,0]^2+tmpsm.y[*,1]^2))*180/!pi
  if model ne 'none' then store_data,sc+'!Cequatorial-foot-ILAT!C'+model,data={x:postimes_sm,y:ILAT}
  if model eq 'none' then store_data,sc+'!Cequatorial-foot-ILAT!Cigrf',data={x:postimes_sm,y:ILAT}


  ; MLT of equatorial point
  get_data,sc+'_out_eq_foot_gse',data=tmpgse
  postimes_gse=tmpgse.x

  angle_tmp = atan(tmpgse.y[*,1],tmpgse.y[*,0])/!dtor
  goo = where(angle_tmp lt 0.)
  if goo[0] ne -1 then angle_tmp[goo] = 360. - abs(angle_tmp[goo])
  mloctime = angle_tmp * 12/180. + 12.
  goo = where(mloctime ge 24.)
  if goo[0] ne -1 then mloctime[goo] = mloctime[goo] - 24

;  mloctime=atan(tmpgse.y[*,1]/tmpgse.y[*,0])*180/!pi/15.+12
;  if where(tmpgse.y[*,0] lt 0) ne [-1] then begin
;    if (n_elements(where(tmpgse.y[*,0] lt 0)) ge 1) then mloctime[where(tmpgse.y[*,0] lt 0)]=(atan(tmpgse.y[where(tmpgse.y[*,0] lt 0),1]/$
;    tmpgse.y[where(tmpgse.y[*,0] lt 0),0])+!pi)*180/!pi/15.+12
;  endif
;
;  if (n_elements(where(mloctime ge 24)) ge 1) and where(mloctime ge 24) ne [-1] $
;  then mloctime[where(mloctime ge 24)]=mloctime[where(mloctime ge 24)]-24

  if model ne 'none' then store_data,sc+'!Cequatorial-foot-MLT!C'+model,data={x:postimes_gse,y:mloctime}
  if model eq 'none' then store_data,sc+'!Cequatorial-foot-MLT!Cigrf',data={x:postimes_gse,y:mloctime}



end
