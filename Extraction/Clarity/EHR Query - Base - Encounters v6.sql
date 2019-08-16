SELECT DISTINCT
     patenc.PAT_ID          "Patient ID"
    ,pat.BIRTH_DATE         "Date of Birth"
    ,pat.sex_C              "Sex"
    ,zcrace.name            "Race" 
    ,pat.home_phone         "Home Phone"
    ,patenc.PAT_ENC_CSN_ID  "Encounter ID"
    ,enctype.name           "Encounter Type"
    ,patenc.CONTACT_DATE    "Encounter Date"
    ,dep.DEPARTMENT_NAME    "Department Name"
    ,physloc.name           "Wake Network Location"
    ,patenc.LOS_PROC_CODE   "Level of Service"
    ,patenc.BMI             "Body Mass Index"
    ,patenc.WEIGHT/16       "Weight"
    ,patenc.HEIGHT          "Height"
    ,patenc.BP_SYSTOLIC     "Systolic Blood Pressure"
    ,patenc.BP_DIASTOLIC    "Diastolic Blood Pressure"
    ,smoke.name             "Tobacco Use"
    ,edg.CURRENT_ICD10_LIST "Diagnosis Code"
    ,pedx.LINE              "Diagnosis LINE"
    ,edg.DX_NAME            "Diagnosis"
    ,ser.Prov_name          "Patient PCP"
    ,dep2.department_name   "PCP Department"
    ,visitprov.prov_name    "Visit Provider"
    ,visitdep.department_name   "Visit Department"
    
FROM 
    PAT_ENC patenc
    INNER JOIN PATIENT pat on patenc.PAT_ID = pat.PAT_ID
    INNER JOIN ZC_PATIENT_STATUS zcptsta on pat.PAT_STATUS_C = zcptsta.PATIENT_STATUS_C
    --INNER JOIN Doc_information docinfo on docinfo.DOC_PT_ID = pat.PAT_ID
    --LEFT OUTER JOIN ZC_DOC_STAT docstat on docstat.doc_stat_c = docinfo.doc_stat_C
    --INNER JOIN ZC_DOC_INFO_TYPE doctype on docinfo.doc_info_type_c = doctype.doc_info_type_c
    INNER JOIN Clarity_DEP dep on dep.DEPARTMENT_ID = patenc.DEPARTMENT_ID
    INNER JOIN ZC_DISP_ENC_TYPE enctype on enctype.disp_enc_type_C = patenc.enc_type_C
    INNER JOIN zc_physical_loc physloc on physloc.physical_loc_c = dep.physical_loc_c
    INNER JOIN PAT_ENC_DX pedx ON patenc.PAT_ENC_CSN_ID = pedx.PAT_ENC_CSN_ID
    INNER JOIN CLARITY_EDG edg ON pedx.DX_ID = edg.DX_ID
    INNER JOIN Patient_race race on pat.pat_id = race.pat_id
    INNER JOIN ZC_Patient_Race zcrace on race.PATIENT_RACE_C= zcrace.PATIENT_RACE_C
    LEFT OUTER JOIN Social_hx social on social.pat_id = pat.pat_id
    INNER JOIN ZC_SMOKING_TOB_USE smoke on smoke.smoking_tob_use_c = social.smoking_tob_use_c
    LEFT OUTER JOIN Clarity_SER ser on pat.CUR_PCP_PROV_ID = ser.prov_id
    LEFT OUTER JOIN Clarity_SER_2 ser2 on ser.prov_id = ser2.prov_id
    LEFT OUTER JOIN Clarity_DEP dep2 on ser2.primary_dept_id = dep2.department_id
    INNER JOIN CLARITY_SER visitprov on patenc.visit_prov_id = visitprov.prov_id
    INNER JOIN CLARITY_DEP visitdep on patenc.department_id = visitdep.department_id
          
WHERE
    -- pull data for all clinics, not just Cornerstone
    -- Filter patients above the age of 65
    (FLOOR (SYSDATE - pat.BIRTH_DATE) / 365.25) >= 63
    
    --Logic #2
    --Filter date range of contact dates for 2 years (730 days) backwards from the system date
    AND patenc.CONTACT_DATE BETWEEN (SYSDATE - 730) AND (SYSDATE)    
    
    --Logic
    --Filter Encounter types, 3 - Hospital Encounter, 31 - PCP/Clinic Change, 50 - Appointment, 101 - Office Visit, 106 - Hospital, 210527 - Lab, 1000 - Initial Consult, 210524 - Return Patient, 2102524 - Urgent
    --EPT 30
    --Can add/subtract encounter types as needed
    AND patenc.ENC_TYPE_C in ('3','31','50','101','106','210527','1000','210524','2102524')
    
    --Logic
    --Filter for alive patients
    --Epic Released Entries:
    --1 - Alive
    --2 - Deceased
    AND zcptsta.PATIENT_STATUS_C = '1'

    --Logic
    --Filters for Completed appointments. Categorical values include: 
    --EPT 7020
    --2 - Completed
    AND patenc.APPT_STATUS_C = '2'
    
    --Logic
    --Filter by English language speakers
    --EPT 155
    --22 - English
    AND pat.LANGUAGE_C = '22'
    
    --Logic
    --Filter by Interpreter need
    --Yes = 1, No = 2
    AND pat.INTRPTR_NEEDED_YN <> '1' 
    
    --Logic
    --Filter by Advance Directive Doc Type Not Received
    --And (docinfo.doc_info_type_c = '10' and docstat.DOC_STAT_C = '11')
    
    --AND
   --pat.PAT_MRN_ID = '711065'
    
ORDER BY patenc.PAT_ID
;
  