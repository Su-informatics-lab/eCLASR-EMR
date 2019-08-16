--------------------------------------------------------------------------------
-- I2B2-based EMR Data Extraction for US-POINTER
-- Authors: Jing Su, Wedell M. Futrell, Kerry W. Hauser, Brian Ostasiewski
-- Date: Oct 2018
--
-- Copyright (C) 2018 Jing Su <Jing.Su.66@gmail.com>
-- This software may be modified and distributed under the terms
-- of the MIT license.  See the LICENSE file for details.
--------------------------------------------------------------------------------

create table kwh_767 as
with icd_pats as
(
        select /*+ driving_site(pd) */ distinct pd.patient_num
        from patient_dimension@b2db pd
        join visit_dimension@b2db vd on vd.patient_num = pd.patient_num
        where pd.age_in_years_num >= 58
          and pd.age_in_years_num <= 79
          and pd.vital_status_cd = 'N'
          and pd.death_date is null
          and vd.start_date >= to_date('01-01-2013', 'mm-dd-yyyy')
        minus
        select /*+ driving_site(obs) */ distinct pd.patient_num
        from patient_dimension@b2db pd
        join observation_fact@b2db obs on obs.patient_num = pd.patient_num
        join visit_dimension@b2db vd on vd.patient_num = pd.patient_num
        where obs.concept_cd in ('ICD9:331.0', 'ICD10:G30.0', 'ICD10:G30.1', 'ICD10:G30.8', 'ICD10:G30.9', 'ICD9:331.93' )
          and pd.age_in_years_num >= 58
          and pd.age_in_years_num <= 79
          and pd.vital_status_cd = 'N'
          and pd.death_date is null
          and vd.start_date >= to_date('01-01-2013', 'mm-dd-yyyy')

)
select distinct icd.patient_num, 
                b.mr_nbr
from icd_pats icd
join patient_mapping@b2db pm on pm.patient_num = icd.patient_num
join phi_blind_mr@b2db b on pm.patient_ide = b.pat_id
;
commit;

--All 
select distinct obs.patient_num, 
                obs.encounter_num, 
                obs.provider_id, 
                TO_CHAR(obs.START_DATE,'YYYY-MM-DD HH24:MM:SS') start_date,
                TO_CHAR(obs.END_DATE,'YYYY-MM-DD HH24:MM:SS') end_date,
                obs.concept_cd, 
                obs.modifier_cd, 
                obs.tval_char, 
                obs.nval_num, 
                obs.units_cd
from kwh_767@b2stg pats
join observation_fact obs on obs.patient_num = pats.patient_num
order by 1,2,4,6
;
--Encounters
select /*+ driving_site(ed) */ distinct 
                ed.patient_num, 
                ed.encounter_num, 
                ed.ACTIVE_STATUS_CD, 
                TO_CHAR(ed.START_DATE,'YYYY-MM-DD HH24:MM:SS') start_date,
                TO_CHAR(ed.END_DATE,'YYYY-MM-DD HH24:MM:SS') end_date,
                ed.INOUT_CD, 
                ed.LOCATION_CD, 
                ed.PAT_TYP_CDE, 
                ed.ADM_TYP, 
                ed.ADM_SRC,
                ADM_PHYN_ID,
                ADM_MSPCL_ID,
                DSCH_TYP,
                DSCH_PHYN_ID,
                DSCH_MSPCL_ID,
                LOS,
                AGE_YRS,
                SRC_INST_ID,
                DRG_NBR,
                DRG_V25_NBR,
                ZIP,
                ST,
                RLGN,
                ADM_DIAG_CDE,
                PRIN_DIAG_CDE,
                PRIN_ICD_PROC_CDE,
                PRIN_CPT_PROC_CDE,
                REF_PHYN_ID,
                FMLY_PHYN_ID,
                LENGTH_OF_STAY,
                FACILITY_ID,
                FACILITY_ZIP,
                ENCOUNTER_NUM_PRIMARY,
                ENC_TYPE_C,
                HOSP_SERV_C
from kwh_767 pats
join visit_dimension@b2db ed on ed.patient_num = pats.patient_num
order by 1,2,4
;

--Census
  select distinct 
      kwh.patient_num,
      kwh.mr_nbr,
      coordinates,
      census_block
    from addr_patient ap 
    join addr_lookup al on ap.addr_hash = al.addr_hash and al.coordinates is not null
    join patient@clarityprod pat on pat.pat_id = ap.pat_id
    join kwh_767 kwh on kwh.mr_nbr = pat.pat_mrn_id
    where ap.eff_end_date is null and instr(al.coordinates,',') > 0
;

--Demo
select distinct pats.patient_num, 
                pats.mr_nbr,
                pd.vital_status_cd, 
                pd.birth_date,
                pd.sex_cd, 
                pd.language_cd, 
                pd.race_cd, 
                pd.marital_status_cd, 
                pd.religion_cd, substr(pd.zip_cd,0,3) as zip3,
                pd.ethnicity_cd
from kwh_767 pats
join patient_dimension@b2db pd on pd.patient_num = pats.patient_num
;
