;Calculate the separation between two spacecraft in azimuthal plane
;Returns tplot variables

;Input tplot variables of L-value and MLT (hrs) for
;spacecraft 1 and 2

;radius (km) -> used for converting delta-MLT from deg to km (s=r*theta)
;km -> output in km instead of RE

;Will interpret all variables to the times of l1.

;Written by AWB, 2017-04-13

pro sc_absolute_separation,l1,l2,mlt1,mlt2,km=km,radius=radius


  store_data,['separation_absolute','separation_mlt','separation_lvalue'],/delete

  ;Make sure everything is on the same cadence
  tinterpol_mxn,l2,l1,newname=l2+'_tmp'
  tinterpol_mxn,mlt1,l1,newname=mlt1+'_tmp'
  tinterpol_mxn,mlt2,l1,newname=mlt2+'_tmp'
  copy_data,l1,l1+'_tmp'

  if KEYWORD_SET(km) then fac = 6370. else fac = 1.

  get_data,l1+'_tmp',t,l1v
  get_data,l2+'_tmp',t,l2v

  get_data,mlt1+'_tmp',t,mlt1v
  get_data,mlt2+'_tmp',t,mlt2v

  if ~KEYWORD_SET(radius) then radius = 6370.*l1v[0]


  ;put MLT in degrees
  t1 = (mlt1v - 12)*360./24.
  t2 = (mlt2v - 12)*360./24.

  x1 = l1v * sin(t1*!dtor)
  y1 = l1v * cos(t1*!dtor)
  x2 = l2v * sin(t2*!dtor)
  y2 = l2v * cos(t2*!dtor)
  daa = sqrt((abs(x1-x2))^2 + (abs(y1-y2))^2)
  store_data,'separation_absolute',t,daa*fac
  if ~KEYWORD_SET(km) then begin
    store_data,'separation_mlt',t,mlt1v-mlt2v
    options,'separation_mlt','ytitle','MLT separation!C[hrs]'
  endif else begin
    store_data,'separation_mlt',t,radius*(t1-t2)*!dtor
    options,'separation_mlt','ytitle','approx MLT separation!C[km]'
  endelse
  store_data,'separation_lvalue',t,(l1v-l2v)*fac


  store_data,'separation_comb',data=['separation_absolute','separation_mlt','separation_lvalue']
  options,'separation_comb','colors',[0,50,250]

;  tplot,['separation_comb',l1,l2,mlt1,mlt2]
;  tplot,['separation_comb','separation_absolute','separation_mlt','separation_lvalue']
;  tlimit


  ;delete temporary variables
  store_data,[l1+'_tmp',l2+'_tmp',mlt1+'_tmp',mlt1+'_tmp'],/delete

end
