;Crib sheet for aaron_map_with_tsy.pro. This program takes GSM coordinates
;for a sc and traces the requested field line to the equator and footpoints.


;sc = 'a'
;ts = time_double(['2016-01-19/22:00','2016-01-20/23:59:59'])
sc = 'a'
ts = time_double(['2016-01-19/22:00','2016-01-20/23:59:59'])
timespan,ts[0],ts[1]-ts[0],/seconds
;model = 't89'
model = 't04s'
;model = 't01'
;model = 'igrf'

model2 = model
if model eq 'igrf' then model = 'none'

dur = ts[1]-ts[0]
storm_start = time_string(ts[0])

rbsp_load_spice_state,probe=sc,coord='gsm'


;------------------
;****UNDER CONSTRUCTION
;Get dipole tilt angle. Needed for the TSY08 model

get_data,'rbsp'+sc+'_state_pos_gsm',ut,dd
ts = time_string(ut)
yr = strmid(ts,0,4)
mo = strmid(ts,5,2)
dy = strmid(ts,8,2)
hr = strmid(ts,11,2)
mi = strmid(ts,14,2)
sec = strmid(ts,17,2)
msc = sec
msc[*] = 0.


tilt = fltarr(n_elements(sec))
for i=0,n_elements(ut)-1 do begin
  geopack_recalc_08, yr[i], mo[i], dy[i], hr[i], mi[i], sec[i]+msc[i]*0.001d, /date,tilt=tt
  tilt[i] = tt
endfor

store_data,'tilt',ut,tilt


;------------------

;for t89 model only
Kpval = 5.

;Altitude of FIREBIRD
R0 = (6370.+500.)/6370.
;R0 = 1.


if model ne 't89' and model ne 'none' then $
  aaron_map_with_tsy,model,storm_start,dur,'RBSP'+sc,'rbsp'+sc+'_state_pos_gsm',R0=R0
if model eq 't89' or model eq 'none' then $
  aaron_map_with_tsy,model,storm_start,dur,'RBSP'+sc,'rbsp'+sc+'_state_pos_gsm',Kpval,R0=R0


;stop

copy_data,'RBSP'+sc+'_out_iono_foot_north_gse','RBSP'+sc+'_out_iono_foot_north_gse'+'_'+model

vars = ['RBSP'+sc+'!CL-shell-'+model,$
'RBSP'+sc+'!Cequatorial-foot-MLT!C'+model,$
'RBSP'+sc+'!Cnorth-foot-MLT!C'+model,$
'RBSP'+sc+'!Csouth-foot-MLT!C'+model,$
'RBSP'+sc+'_out_iono_foot_north_gse'+'_'+model]

get_data,'RBSP'+sc+'_out_iono_foot_north_gse'+'_'+model,tt,dd
gsemag = sqrt(dd[*,0]^2 + dd[*,1]^2 + dd[*,2]^2)
store_data,'gsemag',tt,gsemag

tplot,vars

if model eq 'none' then tplot_save,vars,filename='~/Desktop/RBSP'+sc+'_igrf_mapping_500km_20160120'
if model eq 't89' then tplot_save,vars,filename='~/Desktop/RBSP'+sc+'_tsy89_mapping_500km_20160120'
if model eq 't96' then tplot_save,vars,filename='~/Desktop/RBSP'+sc+'_tsy96_mapping_500km_20160120'
if model eq 't04' or model eq 't04s' then tplot_save,vars,filename='~/Desktop/RBSP'+sc+'_tsy04_mapping_500km_20160120'
if model eq 't01' then tplot_save,vars,filename='~/Desktop/RBSP'+sc+'_tsy01_mapping_500km_20160120'


;***************************************************************
;Now map the Firebird 4 to magnetic equator

fileroot = '/Users/aaronbreneman/Desktop/Research/RBSP_Firebird_microburst_conjunction_jan20/FIREBIRD/'
tplot_restore,filenames=fileroot+'fb4_coord_jan20_accurate.tplot'

gsm_coord = 'fb4_gsm'
get_data,gsm_coord,tt,dd

;Apply time shift
tshift = 0.
store_data,gsm_coord,tt + tshift,dd*6370.
sc2 = 'fb4'


tinterpol_mxn,'fb4_gsm','rbsp'+sc+'_state_pos_gsm',newname='fb4_gsm'

if model ne 't89' and model ne 'none' then aaron_map_with_tsy,model,storm_start,dur,'FB4',gsm_coord,R0=R0
if model eq 't89' or model eq 'none' then aaron_map_with_tsy,model,storm_start,dur,'FB4',gsm_coord,Kpval

copy_data,'FB4_out_iono_foot_north_gse','FB4_out_iono_foot_north_gse'+'_'+model



vars = ['FB4!CL-shell-'+model,$
'FB4!Cequatorial-foot-MLT!C'+model,$
'FB4!Cnorth-foot-MLT!C'+model,$
'FB4!Csouth-foot-MLT!C'+model,$
'FB4_out_iono_foot_north_gse'+'_'+model]


tplot,vars

;Save and restore specific files
fileroot = '~/Desktop/'
if model eq 't96' then tplot_save,vars,$
filename=fileroot+'fb4_ts96_mapping_500km_20160120'
if model eq 't89' then tplot_save,vars,$
filename=fileroot+'fb4_ts89_mapping_500km_20160120'
if model eq 'none' then tplot_save,vars,$
filename=fileroot+'fb4_igrf_mapping_500km_20160120'
if model eq 't04' or model eq 't04s' then tplot_save,vars,$
filename=fileroot+'fb4_ts04_mapping_500km_20160120'
if model eq 't01' then tplot_save,vars,$
filename=fileroot+'fb4_ts01_mapping_500km_20160120'


stop

;if model eq 't04' then tplot_save,['RBSP'+sc+'!CL-shell-'+model,'FB4!CL-shell-'+model,$
;  'FB4!Cequatorial-foot-MLT!C'+model,'RBSP'+sc+'!Cequatorial-foot-MLT!C'+model],$
;    filename=fileroot+'RBSP'+sc+'_fb4_ts04_lshell_MLT_hires'    ;don't add .tplot
;    if model eq 't04s' then tplot_save,['RBSP'+sc+'!CL-shell-'+model,'FB4!CL-shell-'+model,$
;      'FB4!Cequatorial-foot-MLT!C'+model,'RBSP'+sc+'!Cequatorial-foot-MLT!C'+model],$
;      filename=fileroot+'RBSP'+sc+'_fb4_ts04s_lshell_MLT_hires'    ;don't add .tplot
;      if model eq 't89' then tplot_save,['RBSP'+sc+'!CL-shell-'+model,'FB4!CL-shell-'+model,$
;        'FB4!Cequatorial-foot-MLT!C'+model,'RBSP'+sc+'!Cequatorial-foot-MLT!C'+model],$
;        filename=fileroot+'RBSP'+sc+'_fb4_ts04s_lshell_MLT_hires'    ;don't add .tplot



;tinterpol_mxn,'RBSP'+sc+'!CL-shell-'+model,'RBSP'+sc+'_fbk1_7pk_5_smoothed',newname='RBSP'+sc+'L_tmp',/spline
;tinterpol_mxn,'FB4!CL-shell-'+model,'RBSP'+sc+'_fbk1_7pk_5_smoothed',newname='fb4L_tmp',/spline
;tplot,['RBSP'+sc+'L_tmp','fb4L_tmp']

;tt = time_double('2016-01-20/19:43:54.600')
;tt = time_double('2016-01-20/19:43:58.000')
;tt = time_double('2016-01-20/19:44:00.800')
;tt = time_double('2016-01-20/19:44:06.200')
;tt = time_double('2016-01-20/19:44:07.000')
;tt = time_double('2016-01-20/19:44:08.000')
;print,tsample('fb4L_tmp',tt,times=tms)



;La = 5.770
;Lf = 5.248, 5.150, 4.902, 4.876
;dLf = 0.098, 0.248, 0.026

tt = time_double('2016-01-20/19:43:54.600')
tt = time_double('2016-01-20/19:44:08.000')
;0.372 max

tt = time_double('2016-01-20/19:43:58.000')
tt = time_double('2016-01-20/19:44:07.000')
;0.248 mid

;min
tt = time_double('2016-01-20/19:44:00.800')
tt = time_double('2016-01-20/19:44:06.200')
;5.072 - 4.922 = 0.15




;Load dipole Lshell
rbsp_efw_position_velocity_crib



dif_data,'RBSP'+sc+'_state_lshell','alex_fb4_lshell',newname='deltaLsimple'
dif_data,'RBSP'+sc+'_state_mlt','alex_fb4_mlt',newname='deltaMLTsimple'


dif_data,'RBSP'+sc+'!CL-shell-'+model2,'FB4!CL-shell-'+model2,newname='deltaL_'+model2
dif_data,'RBSP'+sc+'!Cequatorial-foot-MLT!C'+model2,'FB4!Cequatorial-foot-MLT!C'+model2,newname='deltaMLT_'+model2
if model eq 'none' then options,'deltaL_'+model2,'ytitle','RBSP'+sc+'L-FB4L (IGRF)'
if model eq 't89' then options,'deltaL_'+model2,'ytitle','RBSP'+sc+'L-FB4L (T89)'
if model eq 't96' then options,'deltaL_'+model2,'ytitle','RBSP'+sc+'L-FB4L (T96)'
if model eq 't01' then options,'deltaL_'+model2,'ytitle','RBSP'+sc+'L-FB4L (T01)'
if model eq 't04' then options,'deltaL_'+model2,'ytitle','RBSP'+sc+'L-FB4L (T04s)'

if model eq 'none' then options,'deltaMLT_'+model2,'ytitle','RBSP'+sc+'MLT-FB4MLT!C(Equatorial_mapped!C'+'_IGRF)'
if model eq 't89' then options,'deltaMLT_'+model2,'ytitle','RBSP'+sc+'MLT-FB4MLT!C(Equatorial_mapped!C'+'_T89)'
if model eq 't96' then options,'deltaMLT_'+model2,'ytitle','RBSP'+sc+'MLT-FB4MLT!C(Equatorial_mapped!C'+'_T96)'
if model eq 't01' then options,'deltaMLT_'+model2,'ytitle','RBSP'+sc+'MLT-FB4MLT!C(Equatorial_mapped!C'+'_T01)'
if model eq 't04' then options,'deltaMLT_'+model2,'ytitle','RBSP'+sc+'MLT-FB4MLT!C(Equatorial_mapped!C'+'_T04s)'





options,['deltaMLT_'+model2,'deltaL_'+model2],'constant',0
tplot_options,'title','from call_aaron_map_with_tsy.pro'
tplot,['deltaL_'+model2,'deltaMLT_'+model2]
timebar,['2016-01-20/19:43:55','2016-01-20/19:44:05']

store_data,'deltaLcomb_'+model2,data=['deltaL_'+model2,'deltaLsimple']
options,'deltaLcomb_'+model2,'colors',[0,250]

store_data,'deltaMLTcomb_'+model2,data=['deltaMLT_'+model2,'deltaMLTsimple']
options,'deltaMLTcomb_'+model2,'colors',[0,250]
tplot,['deltaLcomb_'+model2,'deltaMLTcomb_'+model2]
timebar,['2016-01-20/19:43:55','2016-01-20/19:44:05']


tplot,['RBSP'+sc+'!CL-shell-'+model,'FB4!CL-shell-'+model,'deltaL_'+model]


tplot,['RBSP'+sc+'!CL-shell-'+model2,'RBSP'+sc+'!CMLT-'+model2,'FB4!CL-shell-'+model2,$
'deltaL_'+model2,'deltaMLT_'+model2]


store_data,'deltaL_comb',data=['deltaL_t04s','deltaL_t96']
store_data,'deltaMLT_comb',data=['deltaMLT_t04s','deltaMLT_t96']
options,'deltaL_comb','colors',[0,250,50]
options,'deltaMLT_comb','colors',[0,250,50]

ylim,'deltaL_comb',-3,2
ylim,'deltaMLT_comb',-0.2,0.2
options,'deltaL_comb','ytitle','RBSP'+sc+' deltaL!CRBSP'+sc+'-FB4!CBlack=TSY04, Red=T96'
options,'deltaMLT_comb','ytitle','RBSP'+sc+' deltaMLT!CRBSP'+sc+'-FB4!CBlack=TSY04, Red=T96'
tplot,['deltaL_comb','deltaMLT_comb']
timebar,['2016-01-20/19:43:55','2016-01-20/19:44:05']




;0.34 - 0.89 = 0.55
stop

end
