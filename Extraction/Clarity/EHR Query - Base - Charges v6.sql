SELECT DISTINCT
     patenc.PAT_ID          "Patient ID"
    ,pat.BIRTH_DATE         "Date of Birth"
    ,loseap.PROC_CODE       "LOS Procedure Code"
    ,loseap.PROC_NAME       "LOS Procedure Name"
    ,addeap.PROC_CODE       "Additional Procedure Code"
    ,addeap.PROC_NAME       "Additional Procedure Name"
    ,ucleap.PROC_CODE       "Charge Capture Code"
    ,ucleap.PROC_NAME       "Charge Capture Name"

FROM 
    PAT_ENC patenc
    INNER JOIN PATIENT pat on patenc.PAT_ID = pat.PAT_ID
    INNER JOIN ZC_PATIENT_STATUS zcptsta on pat.PAT_STATUS_C = zcptsta.PATIENT_STATUS_C
    LEFT OUTER JOIN ADDITIONAL_EM_CODE addcode on patenc.pat_enc_csn_id = addcode.pat_enc_csn_id
    LEFT OUTER JOIN CLARITY_EAP loseap on patenc.LOS_PRIME_PROC_ID = loseap.PROC_ID 
    LEFT OUTER JOIN CLARITY_EAP addeap on addcode.EM_CODE_ADDL_ID = addeap.PROC_ID
    LEFT OUTER JOIN CLARITY_UCL ucl on patenc.pat_enc_csn_id = ucl.ept_csn
    LEFT OUTER JOIN CLARITY_EAP ucleap on ucl.PROCEDURE_ID = ucleap.PROC_ID
          
WHERE
    -- pull data for all clinics, not just Cornerstone
    -- Filter patients above the age of 65
    (FLOOR (SYSDATE - pat.BIRTH_DATE) / 365.25) >= 63
    
    --Filter date range of contact dates for 2 years (730 days) backwards from the system date
    AND patenc.CONTACT_DATE BETWEEN (SYSDATE - 730) AND (SYSDATE)    
    
    --Filter Encounter types, 3 - Hospital Encounter, 31 - PCP/Clinic Change, 50 - Appointment, 101 - Office Visit, 106 - Hospital, 210527 - Lab, 1000 - Initial Consult, 210524 - Return Patient, 2102524 - Urgent
    --EPT 30
    --Can add/subtract encounter types as needed
    AND patenc.ENC_TYPE_C in ('3','31','50','101','106','210527','1000','210524','2102524')
    
    --Filter for alive patients
    --Epic Released Entries:
    --1 - Alive
    --2 - Deceased
    AND zcptsta.PATIENT_STATUS_C = '1'

    --Filters for Completed appointments. Categorical values include: 
    --EPT 7020
    --2 - Completed
    AND patenc.APPT_STATUS_C = '2'
    
    --Filter by English language speakers
    --EPT 155
    --22 - English
    AND pat.LANGUAGE_C = '22'
    
    --Filter by Interpreter need
    --Yes = 1, No = 2
    AND pat.INTRPTR_NEEDED_YN <> '1' 
    
    --Filter by LOS proc Code
    AND (patenc.los_prime_proc_id in ('100080','100082') 
     OR addcode.em_code_addl_id in ('100080','100082')
     OR ucl.procedure_id in ('100080','100082'))
         
ORDER BY patenc.PAT_ID
;
  