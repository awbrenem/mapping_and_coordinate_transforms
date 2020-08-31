; NAME: get_field_model
; SYNTAX: see call_get_field_model.pro to see how to call program
; PURPOSE: gets Tsyganenko magnetic field model along spacecraft trajectory
; INPUT: pos_gsm -> sc position [km] tplot variable in GSM coord
;        model -> Works with [IGRF, t89, t96, t01, t04s]
;        ts -> array of start and stop times for model
;        source -> 'omni','ace','wind'
;        kpindex -> use for T89 model (for "modpars")
; OUTPUT: B_[model]_gse -> tplot variable with the model magnetic field along satellite
;         trajectory.
; KEYWORDS:
;
; NOTES: IGRF model from t89 procedure with igrf_only keyword
;
; HISTORY: Written by Aaron W Breneman, June 2016



pro get_field_model, pos_gsm, model, ts, source=source, kpindex=kpindex

  if ~KEYWORD_SET(source) then source = 'none'
  if model eq 't04' then model = 't04s'
  if model eq 't89' then source = 'none'
  if model eq 'igrf' then source = 'none'

  timespan,ts[0],ts[1]-ts[0],/seconds

  modpars = model + '_par'
  modelcall = 't' + model

  ;since this isn't referenced w/r to Wind, ACE, or OMNI, need to
  ;delete so that I don't use the wrong one
  store_data,modpars,/delete

  if source eq 'wind' then begin

    kyoto_load_dst
    tdegap,'kyoto_dst',/overwrite
    tdeflag,'kyoto_dst','linear',/overwrite


    ;load wind data
    wi_mfi_load,tplotnames=tn
    wi_3dp_load,tplotnames=tn2

    if (tn[0] ne '') and (tn2[0] ne '') then begin

      tdegap,'wi_h0_mfi_B3GSE',/overwrite
      tdeflag,'wi_h0_mfi_B3GSE','linear',/overwrite
      tdegap,'wi_3dp_k0_ion_density',/overwrite
      tdeflag,'wi_3dp_k0_ion_density','linear',/overwrite
      tdegap,'wi_3dp_k0_ion_vel',/overwrite
      tdeflag,'wi_3dp_k0_ion_vel','linear',/overwrite

      cotrans,'wi_h0_mfi_B3GSE','wi_b3gsm',/GSE2GSM

      get_data,'wi_b3gsm',data=goo
      ;;only the By and Bz IMF components used
      store_data,'wi_imf',data={x:goo.x,y:[[goo.y[*,0]],[goo.y[*,1]],[goo.y[*,2]]]}

      get_tsy_params,'kyoto_dst','wi_imf','wi_3dp_k0_ion_density','wi_3dp_k0_ion_vel',strupcase(model)

    endif else begin
      print,' '
      print,'*************************************************'
      print,'RETURNING....INSUFFICIENT WIND VALUES TO CONTINUE'
      print,'*************************************************'
      print,' '
      return
    endelse
  endif

  if source eq 'ace' then begin

    ace_mfi_load,tplotnames=tn
    ace_swe_load,tplotnames=tn2

    kyoto_load_dst
    tdegap,'kyoto_dst',/overwrite
    tdeflag,'kyoto_dst','linear',/overwrite

    if (tn[0] ne '') and (tn2[0] ne '') then begin

      tdegap,'ace_k0_mfi_BGSEc',/overwrite
      tdeflag,'ace_k0_mfi_BGSEc','linear',/overwrite
      tdegap,'ace_k0_swe_Np',/overwrite
      tdeflag,'ace_k0_swe_Np','linear',/overwrite
      tdegap,'ace_k0_swe_Vp',/overwrite
      tdeflag,'ace_k0_swe_Vp','linear',/overwrite

      ;load_ace_mag loads data in gse coords
      cotrans,'ace_k0_mfi_BGSEc','ace_mag_Bgsm',/GSE2GSM
      get_data,'ace_mag_Bgsm',data=goo

      ;;only the By and Bz IMF components used
      store_data,'ace_imf',data={x:goo.x,y:[[goo.y[*,0]],[goo.y[*,1]],[goo.y[*,2]]]}
      get_tsy_params,'kyoto_dst','ace_imf','ace_k0_swe_Np','ace_k0_swe_Vp',strupcase(model),/speed

    endif else begin
      print,' '
      print,'*************************************************'
      print,'RETURNING....INSUFFICIENT ACE VALUES TO CONTINUE'
      print,'*************************************************'
      print,' '
      return
    endelse
  endif


  if source eq 'omni' then begin

    ;load OMNI data for Tsyganenko model
    omni_hro_load,tplotnames=tn

    if (tn[0] ne '') then begin

      ;stop
      ;get_data,'OMNI_HRO_1min_BZ_GSM',t,d
      ;store_data,'OMNI_HRO_1min_BZ_GSM',t,d/2.
      ;stop
      tdegap,'OMNI_HRO_1min_SYM_H',/overwrite
      tdeflag,'OMNI_HRO_1min_SYM_H','linear',/overwrite
      tdegap,'OMNI_HRO_1min_BY_GSM',/overwrite
      tdeflag,'OMNI_HRO_1min_BY_GSM','linear',/overwrite
      tdegap,'OMNI_HRO_1min_BZ_GSM',/overwrite
      tdeflag,'OMNI_HRO_1min_Bz_GSM','linear',/overwrite
      tdegap,'OMNI_HRO_1min_proton_density',/overwrite
      tdeflag,'OMNI_HRO_1min_proton_density','linear',/overwrite
      tdegap,'OMNI_HRO_1min_flow_speed',/overwrite
      tdeflag,'OMNI_HRO_1min_flow_speed','linear',/overwrite

      store_data,'omni_imf',data=['OMNI_HRO_1min_BY_GSM','OMNI_HRO_1min_BZ_GSM']

      get_tsy_params,'OMNI_HRO_1min_SYM_H','omni_imf','OMNI_HRO_1min_proton_density',$
      'OMNI_HRO_1min_flow_speed',model,/speed,/imf_yz

    endif else begin
      print,' '
      print,'*************************************************'
      print,'RETURNING....INSUFFICIENT OMNI VALUES TO CONTINUE'
      print,'*************************************************'
      print,' '
      return
    endelse
  endif

;  get_tsy_params,model,/speed,/imf_yz


  if model ne 't89' and model ne 'igrf' then call_procedure, modelcall, pos_gsm, period=0.5, parmod=modpars
  if model eq 't89' then call_procedure, modelcall, pos_gsm, period=0.5;, kp=kpindex
  if model eq 'igrf' then call_procedure, 'tt89', pos_gsm, period=0.5,/igrf_only


  if model ne 'igrf' then begin
    time_clip,pos_gsm+'_b'+model,time_double(ts[0]),time_double(ts[1]),/replace
    cotrans,pos_gsm+'_b'+model,'B_'+model+'_gse',/GSM2GSE
    store_data,pos_gsm+'_b'+model,/delete
  endif else begin
    time_clip,pos_gsm+'_bt89',time_double(ts[0]),time_double(ts[1]),/replace
    cotrans,pos_gsm+'_bt89','B_igrf_gse',/GSM2GSE
    store_data,pos_gsm+'_bt89',/delete
  endelse

end
