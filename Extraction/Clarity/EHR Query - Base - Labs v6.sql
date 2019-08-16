SELECT DISTINCT 
     patenc.PAT_ID              "Patient ID"
    ,patenc.pat_enc_csn_id      "Encounter ID"
    ,patenc.CONTACT_DATE        "Encounter Date"
    ,ordres.component_id        "Lab ID"
    ,clrcomp.name               "Lab Name"
    ,ordres.ord_value           "Lab Result"
    ,ordres.reference_unit      "Units"
    
FROM 
    PAT_ENC patenc
    INNER JOIN PATIENT pat on patenc.PAT_ID = pat.PAT_ID
    INNER JOIN ZC_PATIENT_STATUS zcptsta on pat.PAT_STATUS_C = zcptsta.PATIENT_STATUS_C
    INNER JOIN Doc_information docinfo on docinfo.DOC_PT_ID = pat.PAT_ID
    INNER JOIN ZC_DOC_STAT docstat on docstat.doc_stat_c = docinfo.doc_stat_C 
    INNER JOIN PAT_ENC_DX pedx on pedx.PAT_ENC_CSN_ID = patenc.PAT_ENC_CSN_ID
    INNER JOIN ORDER_PROC op on patenc.pat_enc_csn_id = op.Pat_enc_csn_id
    INNER JOIN CLARITY_EDG edg on pedx.DX_ID = edg.DX_ID
    INNER JOIN ORDER_RESULTS ordres ON op.ORDER_PROC_ID = ordres.ORDER_PROC_ID
    INNER JOIN CLARITY_COMPONENT clrcomp ON ordres.COMPONENT_ID = clrcomp.COMPONENT_ID


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
    --10 = Advanced Directive Doc Type and 11 = Not Received
    --And (docinfo.doc_info_type_c = '10' and docstat.DOC_STAT_C = '11')
    
    --Logic
    --Filter by Diagnoses in Groupers.
    --Groupers 21003051801, 108308, 21003051802, 108312, 108313, 21003051803, 21003051804, and 21003051805 are diagnoses related to Physical Impairment
    --Groupers 2103051806, 21003051807, 21003051808, 21003051809, 21003051810, and 21003051812 are diagnoses related to Cognitive Impairment
    --AND grpdx.GROUPER_ID IN ('2103051806','21003051807','21003051808','21003051809','21003051810','21003051812','21003051801',
    --'108308','21003051802','108312','108313','21003051803','21003051804','21003051805')
    ;