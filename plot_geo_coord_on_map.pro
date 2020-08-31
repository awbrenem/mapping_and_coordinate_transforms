;Plot geographic quantities on an Earth map.
;...Also see convert_lshell_mlt_mlat_to_geographic.pro
;...as well as magnetic field mapping routines.

;Forked from plot_geo.pro

pro plot_geo_coord_on_map,geolong,geolat



map_set,/mollweide,0,0,/grid,label=1,title='Title'
map_continents
plots,geolong,geolat,psym=2,color=250



;-----------------------------------------
;CIRCLES TO PLOT AROUND THE VLF TRANSMITTERS
;*****NOT WORKING YET
;------------------------------------------

;Tlong1 = [111]
;Tlats1 = [29]
;;minutes
;Tlong_min = [43]
;Tlats_min = [4]
;Tlong = float(Tlong1) + Tlong_min/60.
;Tlats = float(Tlats1) + Tlats_min/60.



;;radius of circle surrounding sc. (scaling is not quite right here)
;rad_circle = 400.   ;km
;rad_circle = 100.*rad_circle
;long_circle = fltarr(360,n_elements(Tlong))
;lat_circle = fltarr(360,n_elements(Tlong))

;Tlong2 = replicate(Tlong,360)
;Tlats2 = replicate(Tlong,360)

;long_circle = Tlong2 + rad_circle*cos(!dtor*indgen(360))/6370.
;lat_circle = Tlats2 + rad_circle*sin(!dtor*indgen(360))/6370.

;plots,long_circle,lat_circle,color=50,psym=3


end
