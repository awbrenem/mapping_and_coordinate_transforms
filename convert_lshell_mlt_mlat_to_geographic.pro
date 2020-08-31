;Convert satellite Lshell, MLT, mlat coordinates to GEOGRAPHIC coord
;for an input time.

;Forked from plot_geo.pro


;e.g. input: RBSPa test
;time = '2017-12-12/01:55'
;mlt = 12.
;lshell = 4.1
;mlat = -2.2

;From RBSP science gateway, at this time we have:
;sm = [4,0.1,-0.1]
;geo = [-3.7,1.7,0.2]



function convert_lshell_mlt_mlat_to_geographic,$
  lshell,$
  mlat,$
  mlt,$
  time



  colat = 90. - mlat
  smlong = 15.*(12. + mlt)
  rad = lshell*(cos(!dtor*mlat)^2)
  ilat = acos(sqrt(1/lshell))/!dtor  ;invariant latitude
  x_sm = rad*sin(colat*!dtor)*cos(smLong*!dtor)
  y_sm = rad*sin(colat*!dtor)*sin(smLong*!dtor)
  z_sm = rad*cos(colat*!dtor)
  sm = [[x_sm],[y_sm],[z_sm]]


  cotrans,SM,gsm,time,/SM2GSM
  cotrans,gsm,gse,time,/GSM2GSE
  cotrans,gse,gei,time,/GSE2GEI
  cotrans,gei,geo,time,/GEI2GEO

  geo=reform(geo)  ;GEO footpoint coord of the L-shell (x,y,z)

  loc = fltarr(n_elements(time),3)
  for i=0,n_elements(time)-1 do loc[i,*] = cv_coord(FROM_RECT=reform(geo[i,*]),/TO_SPHERE,/Degrees,/double) ;(Long, Lat, Rad)

  return,{sm:reform(sm),geo:geo,geolong:loc[*,0],geolat:loc[*,1],radius:loc[*,2]}


end
