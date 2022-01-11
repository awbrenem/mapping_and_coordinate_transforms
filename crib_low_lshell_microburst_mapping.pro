

t0z = time_double('2015-05-25/18:18:52')
t1z = time_double('2015-05-25/18:18:53')


;SSCWeb
;2015 145 18:19:00      -0.01      -0.75       0.81  47.33 269.33 07:36:24    2.4   49.8 D_Psphere  N_Mid-Lat  N_Mid-Lat  S_Mid-Lat
gsm = [-0.01, -0.75, 0.81] 


store_data,'gsm_vals',[t0z,t1z], [[gsm],[gsm]]




;Make sure R0 is ABOVE the Earth's surface. Takes too long to map to the surface
;Note that R0=50 above surface and rlim=10 lead to glitches
R0 = 6370. + 25.
rlim = 10.*6370.
duration = t1z - t0z
start_time = time_string(t0z)
kp = 2.

model = 't89'
;    model = 'none'  ;IGRF
aaron_map_with_tsy,model,start_time,duration,'fu4','gsm_vals',Kp,R0=R0,rlim=rlim








get_data,plds[i]+'_out_iono_foot_north_glat_glon',data=tmp
geolat = tmp.y[*,0] & geolon = tmp.y[*,1]
store_data,plds[i]+'_out_iono_foot_north_geolat',tmp.x,geolat
store_data,plds[i]+'_out_iono_foot_north_geolon',tmp.x,geolon

get_data,plds[i]+'_out_iono_foot_south_glat_glon',data=tmp
geolat = tmp.y[*,0] & geolon = tmp.y[*,1]
store_data,plds[i]+'_out_iono_foot_south_geolat',tmp.x,geolat
store_data,plds[i]+'_out_iono_foot_south_geolon',tmp.x,geolon


;Mapped quantities have a lower cadence. Interpolate the input times to the
;mapped times.

tinterpol_mxn,plds[i]+'_geolat',tmp.x,/overwrite,/quadratic
tinterpol_mxn,plds[i]+'_geolon',tmp.x,/overwrite,/quadratic
tinterpol_mxn,plds[i]+'_alt',tmp.x,/overwrite,/quadratic
tinterpol_mxn,plds[i]+'_gse',tmp.x,/overwrite,/quadratic
tinterpol_mxn,plds[i]+'_geo',tmp.x,/overwrite,/quadratic
tinterpol_mxn,plds[i]+'_gei',tmp.x,/overwrite,/quadratic
tinterpol_mxn,plds[i]+'_gsm',tmp.x,/overwrite,/quadratic
tinterpol_mxn,plds[i]+'_sm',tmp.x,/overwrite,/quadratic




