;convert_geo_to_lshell_mlt.pro

t0 = time_double('2014-01-11/20:00')
t1 = time_double('2014-01-11/23:30')

timespan,'2014-01-11',1,/days
load_barrel_lc,'2X',type='ephm'



get_data,'alt_2X',data=alts  ;needs to be from Earth's center (km)
store_data,'alt_2X_center',alts.x,6370.+alts.y
get_data,'alt_2X_center',data=alts
get_data,'lat_2X',data=lats
get_data,'lon_2X',data=lons
times = alts.x

ylim,['alt_2X_center','lat_2X','lon_2X'],0,0
tplot,['alt_2X_center','lat_2X','lon_2X']


pld = '2X'

;lats = 43.2
;lons = 76.9
;alts = 6370.  ;from Earth's center (km)

times2 = congrid(times,n_elements(times)/1024)
alts2 = congrid(alts.y,n_elements(alts.y)/1024)
lats2 = congrid(lats.y,n_elements(lats.y)/1024)
lons2 = congrid(lons.y,n_elements(lons.y)/1024)

store_data,'alts2',times2,alts2
store_data,'lons2',times2,lons2
store_data,'lats2',times2,lats2

tplot,['alts2','lons2','lats2']

xgeo = alts2*cos(!dtor*lats2)*cos(!dtor*lons2)
ygeo = alts2*cos(!dtor*lats2)*sin(!dtor*lons2)
zgeo = alts2*sin(!dtor*lats2)



store_data,pld+'_geo',times2,[[xgeo],[ygeo],[zgeo]]
tplot,pld+'_geo'


;Calculate MLT
cotrans,pld+'_geo',pld+'_gei',/geo2gei
cotrans,pld+'_gei',pld+'_gse',/gei2gse
cotrans,pld+'_gse',pld+'_gsm',/gse2gsm
cotrans,pld+'_gsm',pld+'_sm',/gsm2sm

;put GSM coord in km
get_data,pld+'_gsm',data=d
store_data,pld+'_gsm',d.x,d.y

get_data,pld+'_gsm',data=d
;store_data,pld+'_radius',d.x,sqrt(d.y[*,0]^2 + d.y[*,1]^2 + d.y[*,2]^2)/6370.
tplot,pld+'_gsm'


;Reduce to times of interest
yv = tsample(pld+'_gsm',[t0,t1],times=tms)
store_data,pld+'_gsm2',tms,yv



;Make sure R0 is ABOVE the Earth's surface. Takes too long to map to the surface
R0 = 6370. + 50.
rlim = 10.*6370.
storm_duration = 3600.*3.5
storm_start = time_string(t0)
kp = 2.

model = 't89'
aaron_map_with_tsy,model,storm_start,storm_duration,pld,pld+'_gsm2',2,R0=R0,rlim=rlim
copy_data,'2X!CL-shell-t89','2X!CL-shell-t89_Kp2'
copy_data,'2X!Cequatorial-foot-MLT!Ct89','2X!Cequatorial-foot-MLT!Ct89_Kp2'
;aaron_map_with_tsy,model,storm_start,storm_duration,pld,pld+'_gsm2',3,R0=R0,rlim=rlim
;copy_data,'2X!CL-shell-t89','2X!CL-shell-t89_Kp3'
;copy_data,'2X!Cequatorial-foot-MLT!Ct89','2X!Cequatorial-foot-MLT!Ct89_Kp3'
;aaron_map_with_tsy,model,storm_start,storm_duration,pld,pld+'_gsm2',7,R0=R0,rlim=rlim
;copy_data,'2X!CL-shell-t89','2X!CL-shell-t89_Kp7'

;model = 't96'
;aaron_map_with_tsy,model,storm_start,storm_duration,pld,pld+'_gsm2',Kp,R0=R0,rlim=rlim
;model = 't01'
;aaron_map_with_tsy,model,storm_start,storm_duration,pld,pld+'_gsm2',Kp,R0=R0,rlim=rlim
;model = 'none'
;aaron_map_with_tsy,model,storm_start,storm_duration,pld,pld+'_gsm2',Kp,R0=R0,rlim=rlim


store_data,'lcomb',data=['2X!CL-shell-igrf','2X!CL-shell-t89_Kp2','2X!CL-shell-t89_Kp3','2X!CL-shell-t96','2X!CL-shell-t01']
options,'lcomb','colors',[0,50,100,200,250]
store_data,'mltcomb',data=['2X!Cequatorial-foot-MLT!Cigrf','2X!Cequatorial-foot-MLT!Ct89_Kp2','2X!Cequatorial-foot-MLT!Ct89_Kp3','2X!Cequatorial-foot-MLT!Ct96','2X!Cequatorial-foot-MLT!Ct01']
options,'mltcomb','colors',[0,50,100,200,250]

tplot,['lcomb','mltcomb']


;Compare with BARREL ephem L-value
tplot,['L_Kp2_2X','2X!CL-shell-t89_Kp2']

store_data,'bar_comp',data=['MLT_Kp2_2X','2X!Cequatorial-foot-MLT!Ct89_Kp2']
tplot,'bar_comp'

stop

end
