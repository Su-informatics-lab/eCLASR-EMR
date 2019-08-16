--------------------------------------------------------------------------------
-- Schema of POINTER Demo table
-- Authors: Jing Su
-- Date: Oct 2018
--
-- Copyright (C) 2018 Jing Su <Jing.Su.66@gmail.com>
-- This software may be modified and distributed under the terms
-- of the MIT license.  See the LICENSE file for details.
--------------------------------------------------------------------------------

-- Table: pointer.pointer_demo
-- Contents: demographical data
-- Tool to import: pointer_import.sh 
-- Headers of imput csv file:
-- "PATIENT_NUM","MR_NBR","VITAL_STATUS_CD","BIRTH_DATE","SEX_CD","LANGUAGE_CD","RACE_CD","MARITAL_STATUS_CD","RELIGION_CD","ZIP3","ETHNICITY_CD"

DROP TABLE IF EXISTS pointer.pointer_demo;

CREATE TABLE (
    patient_num    INTEGER,
    mrn            CHARACTER(10),
    vital_status   CHARACTER(1),
    birth_date     DATE,
    sex            CHARACTER(1),
    language       CHARACTER(12),
    race           CHARACTER(1),
    marital_status CHARACTER(1),
    religion       CHARACTER(4),
    zip3           CHARACTER(4),
    ethnicity      CHARACTER(1)
) DISTRIBUTED BY (patient_num);

GRANT ALL ON TABLE pointer.pointer_demo TO precise_manager;
GRANT SELECT ON TABLE pointer.pointer_demo TO precise_user;

