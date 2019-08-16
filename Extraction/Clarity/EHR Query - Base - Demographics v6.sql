SELECT DISTINCT
     patenc.PAT_ID          "Patient ID"
    ,pat.pat_mrn_id         "Patient MRN"
    ,pat.pat_name           "Patient Name"
    ,epm.payor_name         "Payor"
    ,pat.home_phone         "Home Phone"
    ,pat.add_line_1         "Address Line 1"
    ,pat.add_line_2         "Address Line 2"
    ,pat.city               "City"
    ,zcstate.name           "State"
    ,pat.zip                "Zip Code"
       
FROM 
    PAT_ENC patenc
    INNER JOIN PATIENT pat on patenc.PAT_ID = pat.PAT_ID
    INNER JOIN ZC_PATIENT_STATUS zcptsta on pat.PAT_STATUS_C = zcptsta.PATIENT_STATUS_C
    INNER JOIN Doc_information docinfo on docinfo.DOC_PT_ID = pat.PAT_ID
    LEFT OUTER JOIN ZC_DOC_STAT docstat on docstat.doc_stat_c = docinfo.doc_stat_C
    INNER JOIN ZC_DOC_INFO_TYPE doctype on docinfo.doc_info_type_c = doctype.doc_info_type_c
    INNER JOIN ZC_DISP_ENC_TYPE enctype on enctype.disp_enc_type_C = patenc.enc_type_C
    INNER JOIN ZC_STATE zcstate on pat.state_c = zcstate.state_c
    LEFT OUTER JOIN COVERAGE cov on patenc.coverage_id = cov.COVERAGE_ID
    LEFT OUTER JOIN CLARITY_EPM epm on cov.payor_id = epm.payor_id
          
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
    AND patenc.APPT_STATUS_C in ('2')
    
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
    
ORDER BY patenc.PAT_ID
;
  