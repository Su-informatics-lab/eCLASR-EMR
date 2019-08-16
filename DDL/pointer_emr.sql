--------------------------------------------------------------------------------
-- Schema of POINTER EMR table
-- Authors: Jing Su
-- Date: Oct 2018
--
-- Copyright (C) 2018 Jing Su <Jing.Su.66@gmail.com>
-- This software may be modified and distributed under the terms
-- of the MIT license.  See the LICENSE file for details.
--------------------------------------------------------------------------------

-- Table: pointer.pointer_emr
-- Content: all EMR records
-- Tool to import: pointer_import.sh 
-- Headers of imput csv file:
-- "PATIENT_NUM","ENCOUNTER_NUM","PROVIDER_ID","START_DATE","END_DATE","CONCEPT_CD","MODIFIER_CD","TVAL_CHAR","NVAL_NUM","UNITS_CD"

DROP TABLE IF EXISTS pointer.pointer_emr;

CREATE TABLE pointer.pointer_emr (
    patient_num   BIGINT,
    encounter_num BIGINT,
    provider_id   TEXT,
    start_date    TIMESTAMP WITHOUT TIME ZONE,
    end_date      TIMESTAMP WITHOUT TIME ZONE,
    concept       TEXT,
    modifier      TEXT,
    tval          TEXT,
    nval          DOUBLE PRECISION,
    units         TEXT
) DISTRIBUTED BY (patient_num);

GRANT ALL ON TABLE pointer.pointer_emr TO precise_manager;
GRANT SELECT ON TABLE pointer.pointer_emr TO precise_user;

