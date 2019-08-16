SELECT DISTINCT 
     patenc.PAT_ID              "Patient ID"            
    ,patenc.PAT_ENC_CSN_ID      "Encounter ID"
    ,patenc.contact_date        "Date"
    ,meas.flo_meas_id           "FLO_MEAS_ID"
    ,flo.disp_name              "Display Name"
    ,meas.meas_value            "Value"
    
FROM 
    PAT_ENC patenc
    JOIN PATIENT pat on patenc.PAT_ID = pat.PAT_ID
    JOIN ZC_PATIENT_STATUS zcptsta on pat.PAT_STATUS_C = zcptsta.PATIENT_STATUS_C
    JOIN Doc_information docinfo on docinfo.DOC_PT_ID = pat.PAT_ID
    JOIN ZC_DOC_STAT docstat on docstat.doc_stat_c = docinfo.doc_stat_C
    JOIN Clarity_DEP dep on dep.DEPARTMENT_ID = patenc.DEPARTMENT_ID
    JOIN ZC_DISP_ENC_TYPE enctype on enctype.disp_enc_type_C = patenc.enc_type_C
    JOIN PAT_ENC_DX pedx ON patenc.PAT_ENC_CSN_ID = pedx.PAT_ENC_CSN_ID
    JOIN CLARITY_EDG edg ON pedx.DX_ID = edg.DX_ID
    JOIN IP_FLWSHT_REC fsd ON patenc.INPATIENT_DATA_ID = fsd.INPATIENT_DATA_ID
    JOIN IP_FLWSHT_MEAS meas ON fsd.FSD_ID = meas.FSD_ID
    JOIN IP_FLO_GP_DATA flo  ON meas.FLO_MEAS_ID = flo.FLO_MEAS_ID
          
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

    
    --Logic
    --Show only data where AWV data is entered
    --Includes rows from Flowsheet Template (FLT) 254 - Medicare 2  
    And meas.FLO_MEAS_ID in ('7442','7443','7564','7592','7628','7629','7990','7489','7287','7492','7493','7494','7495','7366','7376','7508','10932','7509','7510','7512','7513','7514','7516',
    '7271','2104003','7503','7294','2104007','2104008','2104010','2104011','7224','2104012','2104013','210414','2104016','2104018','2104019','2104020','2104021','7312','7231','7556','2104017',
    '2104023','2104024','7805','7483','7382','2104027','7645','7237','2104031','2104032','7281','7240','2104034','7491','2104033','7313','7378','7393','8717','8715','8719','9874','9415','8714','9276',
    '8716','7660','7673','7806')


Order By
patenc.PAT_ID
,patenc.PAT_ENC_CSN_ID
;
  