--------------------------------------------------------------------------------
-- Schema of POINTER Encounters table
-- Authors: Jing Su
-- Date: Oct 2018
--
-- Copyright (C) 2018 Jing Su <Jing.Su.66@gmail.com>
-- This software may be modified and distributed under the terms
-- of the MIT license.  See the LICENSE file for details.
--------------------------------------------------------------------------------

-- Table: pointer.pointer_encounters
-- Contents: encounter data
-- Tool to import: pointer_import.sh 
-- Headers of imput csv file:
-- "PATIENT_NUM","ENCOUNTER_NUM","ACTIVE_STATUS_CD","START_DATE","END_DATE","INOUT_CD","LOCATION_CD","PAT_TYP_CDE","ADM_TYP","ADM_SRC","ADM_PHYN_ID","ADM_MSPCL_ID","DSCH_TYP","DSCH_PHYN_ID","DSCH_MSPCL_ID","LOS","AGE_YRS","SRC_INST_ID","DRG_NBR","DRG_V25_NBR","ZIP","ST","RLGN","ADM_DIAG_CDE","PRIN_DIAG_CDE","PRIN_ICD_PROC_CDE","PRIN_CPT_PROC_CDE","REF_PHYN_ID","FMLY_PHYN_ID","LENGTH_OF_STAY","FACILITY_ID","FACILITY_ZIP","ENCOUNTER_NUM_PRIMARY","ENC_TYPE_C","HOSP_SERV_C"

DROP TABLE IF EXISTS pointer.pointer_encounters;

CREATE TABLE pointer.pointer_encounters (
    patient_num           BIGINT,
    encounter_num         BIGINT,
    active_status_cd      TEXT,
    start_date            TIMESTAMP WITHOUT TIME ZONE,
    end_date              TIMESTAMP WITHOUT TIME ZONE,
    inout_cd              CHARACTER(4),
    location_cd           TEXT,
    pat_typ_cde           CHARACTER(8),
    adm_typ               CHARACTER(8),
    adm_src               CHARACTER(8),
    adm_phyn_id           CHARACTER VARYING(16),
    adm_mspcl_id          CHARACTER VARYING(16),
    dsch_typ              CHARACTER(8),
    dsch_phyn_id          CHARACTER VARYING(16),
    dsch_mspcl_id         CHARACTER VARYING(16),
    los                   INTEGER,
    age_yrs               INTEGER,
    src_inst_id           CHARACTER(12),
    drg_nbr               CHARACTER(8),
    drg_v25_nbr           CHARACTER(4),
    zip                   CHARACTER(5),
    st                    CHARACTER(4),
    rlgn                  CHARACTER(4),
    adm_diag_cde          CHARACTER(8),
    prin_diag_cde         CHARACTER(8),
    prin_icd_proc_cde     CHARACTER(8),
    prin_cpt_proc_cde     CHARACTER(8),
    ref_phyn_id           CHARACTER VARYING(16),
    fmly_phyn_id          CHARACTER VARYING(16),
    length_of_stay        TEXT,
    facility_id           CHARACTER(8),
    facility_zip          CHARACTER(10),
    encounter_num_primary BIGINT,
    enc_type_c            BIGINT,
    hosp_serv_c           BIGINT
) DISTRIBUTED BY (patient_num);

GRANT ALL ON TABLE pointer.pointer_encounters TO precise_manager;
GRANT SELECT ON TABLE pointer.pointer_encounters TO precise_user;

