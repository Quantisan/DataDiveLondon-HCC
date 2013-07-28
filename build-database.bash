#!/bin/bash
# 
# This shell script builds a database that might be used for analysis
# It uses
#	qryAnonymisedDataSET_LSOA.txt
# and the sheets of SAPFLSOAbyage2010-2019.xls saved out as CSV files
# with the leading text removed and with District and "LSOA Name" removed.
# 	
# It runs under Linux with bash and PostgreSQL but you might be able to run
# it on Windows using Cygwin tools.
#
# Bob Kemp, DataKindUK data dive, 27th July 2013
# 

DATA_DIR=$PWD
WORK_DIR=$PWD

dbase() {
  psql -Upostgres ds -c "$(cat)"
}

create_pupil_sen_data() {
  dbase <<EOF

    DROP TABLE pupil_sen_data;

    CREATE TABLE pupil_sen_data (
      PUPIL_ID	VARCHAR(255),
      YearOfBirth	VARCHAR(255),
      YearOfSENID	VARCHAR(255),
      AlternativeDesc	VARCHAR(255),
      AlternativeNeedCode	VARCHAR(255),
      LLSOA	VARCHAR(255),
      MOSAIC	VARCHAR(255)
    );
EOF
}

upload_pupil_sen_data() {
  dbase <<EOF

    COPY pupil_sen_data FROM 
      '${DATA_DIR}/qryAnonymisedDataSET_LSOA.txt'
      WITH CSV;

EOF
}


aggregate_sen_data() {
  dbase <<EOF

    DROP TABLE aggregate_sen_data;

    CREATE TABLE aggregate_sen_data AS
    select
      count(*) AS number_diagnosed,
      psd.yearOfSenId,
      psd.llsoa as lsoa
    from pupil_sen_data psd
    group by psd.yearOfSenId, lsoa
    ;

EOF
}

create_pop_by_age() {
  dbase <<EOF

    DROP TABLE pop_by_age;

    CREATE TABLE pop_by_age (
      year VARCHAR(255) NULL,
      LSOA_Code  VARCHAR(255),
      Aged_0 VARCHAR(255),
      Aged_1 VARCHAR(255),
      Aged_2 VARCHAR(255),
      Aged_3 VARCHAR(255),
      Aged_4 VARCHAR(255),
      Aged_5 VARCHAR(255),
      Aged_6 VARCHAR(255),
      Aged_7 VARCHAR(255),
      Aged_8 VARCHAR(255),
      Aged_9 VARCHAR(255),
      Aged_10 VARCHAR(255),
      Aged_11 VARCHAR(255),
      Aged_12 VARCHAR(255),
      Aged_13 VARCHAR(255),
      Aged_14 VARCHAR(255),
      Aged_15 VARCHAR(255),
      Aged_16 VARCHAR(255),
      Aged_17 VARCHAR(255),
      Aged_18 VARCHAR(255),
      Aged_19 VARCHAR(255),
      Aged_20_24 VARCHAR(255),
      Aged_25_29 VARCHAR(255),
      Aged_30_34 VARCHAR(255),
      Aged_35_39 VARCHAR(255),
      Aged_40_44 VARCHAR(255),
      Aged_45_49 VARCHAR(255),
      Aged_50_54 VARCHAR(255),
      Aged_55_59 VARCHAR(255),
      Aged_60_64 VARCHAR(255),
      Aged_65_69 VARCHAR(255),
      Aged_70_74 VARCHAR(255),
      Aged_75_79 VARCHAR(255),
      Aged_80_84 VARCHAR(255),
      Aged_85 VARCHAR(255),
      Total VARCHAR(255)
    )

EOF
}

upload_pop_by_age() {
  for yr in 201{0,1,2,3,4,5,6,7,8,9}; do

    sed -e 's/^/year, /' ${DATA_DIR}/pop-by-age-${yr}.csv >scratch.csv

    dbase <<EOF

      COPY pop_by_age FROM 
	'${DATA_DIR}/scratch.csv'
	WITH CSV;

      update pop_by_age SET year = '${yr}' where year = 'year';

EOF
  done

    dbase <<EOF
      update pop_by_age set lsoa_code = trim(both from lsoa_code);
EOF
}

create_training_data() {
  dbase <<EOF

    DROP TABLE training_data;

    CREATE TABLE training_data (
      age	VARCHAR(255),
      population	VARCHAR(255),
      yearOfSenId	VARCHAR(255),
      lsoa	VARCHAR(255),
      number_diagnosed	VARCHAR(255)
    )
EOF
}


upload_training_data() {
  for age in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19; do
    dbase <<EOF
      INSERT INTO training_data
      select
	'${age}' as age,
	p.aged_${age} as population,
	s.yearOfSenId,
	s.lsoa,
	number_diagnosed
      from pop_by_age p, aggregate_sen_data s
      where 1 = 1
      AND p.year = s.yearOfSenId
      AND p.lsoa_code = s.lsoa
EOF
  done
}

download_training_data() {

    ## Ensure Postgresql has write access
    chmod o+rwx $WORK_DIR

    dbase <<EOF
      COPY training_data TO
	'${WORK_DIR}/training_data.csv'
	WITH CSV HEADER;
EOF

    ## Presumably "other" doesn't normally have full access
    chmod o-rwx $WORK_DIR
}

## create_pupil_sen_data
## upload_pupil_sen_data

## aggregate_sen_data

## create_pop_by_age
## upload_pop_by_age

## create_training_data
## upload_training_data

download_training_data

exit


