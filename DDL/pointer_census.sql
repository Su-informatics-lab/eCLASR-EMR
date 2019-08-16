--------------------------------------------------------------------------------
-- Schema of POINTER Census table
-- Authors: Jing Su
-- Date: Oct 2018
--
-- Copyright (C) 2018 Jing Su <Jing.Su.66@gmail.com>
-- This software may be modified and distributed under the terms
-- of the MIT license.  See the LICENSE file for details.
--------------------------------------------------------------------------------

-- Table: pointer.pointer_encounters
-- Contents: GIS data with census blocks
-- Tool to import: pointer_import.sh 
-- Headers of imput csv file:
-- "PATIENT_NUM","MR_NBR","COORDINATES","CENSUS_BLOCK"

DROP TABLE IF EXISTS pointer.pointer_encounters;

CREATE TABLE pointer.pointer_census (
    patient_num  INTEGER,
    mrn          INTEGER,
    coordinates  TEXT,
    census_block INTEGER
) DISTRIBUTED BY (patient_num);

GRANT ALL ON TABLE pointer.pointer_census TO precise_manager;
GRANT SELECT ON TABLE pointer.pointer_census TO precise_user;

