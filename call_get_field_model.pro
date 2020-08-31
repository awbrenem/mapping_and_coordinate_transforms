;Call the program get_field_model.program
;which gets Tsyganenko magnetic field model along spacecraft trajectory



sc = 'a'
ts = time_double(['2016-01-19/22:00','2016-01-20/23:59:59'])
timespan,ts[0],ts[1]-ts[0],/seconds
model = 't04s'
;lmodel = 't01'
;model = 't96'


;load RBSP gse positions
rbsp_load_spice_state,probe=sc,coord='gse';,/no_spice_load
cotrans,'rbsp'+sc+'_state_pos_gse','rbsp'+sc+'_state_pos_gsm',/GSE2GSM
pos_gsm = 'rbsp'+sc+'_state_pos_gsm'


;source = 'wind'
;source = 'ace'
source = 'omni'
get_field_model, pos_gsm, model, ts, source=source
copy_data,'B_'+model+'_gse','B_'+model+'_gse_'+source


get_data,'B_'+model+'_gse_'+source,goot,bo
bmag = sqrt(bo[*,0]^2 + bo[*,1]^2 + bo[*,2]^2)
store_data,'bmag_'+model,goot,bmag
tplot,['B_'+model+'_gse_'+source,'bmag_'+model]

;Load EMFISIS data for comparison

rbsp_load_emfisis,probe=sc,coord='gse',cadence='4sec',level='l3' ;load this for the mag model subtract

tinterpol_mxn,'rbspa_emfisis_l3_4sec_gse_Mag','B_'+model+'_gse_'+source,newname='rbspa_emfisis_l3_4sec_gse_Mag'

options,['rbspa_emfisis_l3_4sec_gse_Mag','B_'+model+'_gse_'+source],'colors',[0,50,250]

tplot,['rbspa_emfisis_l3_4sec_gse_Mag','B_'+model+'_gse_'+source]
dif_data,'rbspa_emfisis_l3_4sec_gse_Mag','B_'+model+'_gse_'+source,newname='magdiff'

get_data,'magdiff',data=md
magdiff_abs = sqrt(md.y[*,0]^2 + md.y[*,1]^2 + md.y[*,2]^2)
store_data,'magdiff_abs',md.x,magdiff_abs

tplot,['magdiff','magdiff_abs']





;Save and restore specific files
;fileroot = '~/Desktop/'
;tplot_save,['B_t04s_gse','B_t04s_gse_omni','bmag_t04s'],filename=fileroot+'rbspa_ts04_mag'    ;don't add .tplot



tplot_restore,filenames=fileroot+'density_proxy.tplot'    ;need .tplot
tplot_restore,filenames=fileroot,/all   ;not working


;-------------------------------------------


;Now map the Firebird 4 to magnetic equator

fileroot = '/Users/aaronbreneman/Desktop/Research/RBSP_Firebird_microburst_conjunction_jan20/FIREBIRD/'
tplot_restore,filenames=fileroot+'fb4_coord_jan20_accurate.tplot'

gsm_coord = 'fb4_gsm'
get_data,gsm_coord,tt,dd
store_data,gsm_coord,tt,dd*6370.,dlim=dlim
sc = 'fb4'


tinterpol_mxn,'fb4_gsm','rbspa_state_pos_gsm',newname='fb4_gsm'

pos_gsm = 'fb4_gsm'

source = 'omni'
get_field_model, pos_gsm, model, ts, source=source

;Save and restore specific files
;fileroot = '~/Desktop/'
;tplot_save,['B_t04s_gse'],filename=fileroot+'fb4_ts04_mag'    ;don't add .tplot
