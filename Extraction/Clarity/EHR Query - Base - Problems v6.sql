SELECT DISTINCT
     patenc.PAT_ID              "Patient ID"           
    ,patenc.PAT_ENC_CSN_ID      "Encounter ID"
    ,patenc.CONTACT_DATE        "Encounter Date"
    ,edg2.CURRENT_ICD9_LIST     "ICD9 Code"
    ,edg2.CURRENT_ICD10_LIST    "ICD10 Code"
    ,edg2.DX_NAME               "Problem Name"
    ,lpl.NOTED_DATE             "Noted Date"
    
FROM 
    PAT_ENC patenc
    INNER JOIN PATIENT pat on patenc.PAT_ID = pat.PAT_ID
    INNER JOIN ZC_PATIENT_STATUS zcptsta on pat.PAT_STATUS_C = zcptsta.PATIENT_STATUS_C
    INNER JOIN Doc_information docinfo on docinfo.DOC_PT_ID = pat.PAT_ID
    INNER JOIN ZC_DOC_STAT docstat on docstat.doc_stat_c = docinfo.doc_stat_C
    INNER JOIN ZC_DISP_ENC_TYPE enctype on enctype.disp_enc_type_C = patenc.enc_type_C
    INNER JOIN PAT_ENC_DX pedx ON patenc.PAT_ENC_CSN_ID = pedx.PAT_ENC_CSN_ID
    INNER JOIN CLARITY_EDG edg1 ON pedx.DX_ID = edg1.DX_ID
    INNER Join Problem_List lpl on lpl.pat_id = pat.pat_id
    INNER Join Clarity_EDG edg2 on edg2.dx_id = lpl.dx_id

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
    
    --Logic
    --Filter on only active problems
    --1 = active 2=resolved 3=deleted
    And lpl.PROBLEM_STATUS_C = 1
    
ORDER BY patenc.PAT_ID
;
  