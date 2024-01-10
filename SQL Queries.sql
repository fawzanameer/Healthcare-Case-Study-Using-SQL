CREATE DATABASE healthcare_db ;

USE healthcare_db ;

-- FACT TABLE CREATION

CREATE TABLE fact_table(
FactTablePK INT,
dimPatientPK INT,
dimPhysicianPK INT,
dimDatePostPK INT,
dimDateServicePK INT,
dimCPTCodePK INT,
dimPayerPK INT,
dimTransactionPK INT,
dimLocationPK INT,
PatientNumber INT,
dimDiagnosisCodePK INT,
CPTUnits DOUBLE,
GrossCharge DOUBLE,
Payment DOUBLE,
Adjustment DOUBLE,
AR DOUBLE) ;

SELECT * FROM fact_table;
SELECT * FROM dim_cptcode;
SELECT * FROM dim_date;


--
CREATE TABLE dim_cptCode(
dimCPTCodePK INT,
CptCode CHAR(20),
CptDesc CHAR(100),
CptGrouping CHAR(100)
) ; 


-- dimDate TABLE

CREATE TABLE dim_Date(
dimDatePostPK INT,
Date DATE,
Year INT,
Month CHAR(20),
MonthPeriod INT,
MonthYear CHAR(20),
Day INT,
DayName CHAR(20)
) ;


-- dimDiagnosisCode TABLE

CREATE TABLE dim_DiagnosisCode(
dimDiagnosisCodePK INT,
DiagnosisCode CHAR(20),
DiagnosisCodeDescription CHAR(200),
DiagnosisCodeGroup CHAR(200)
) ;

-- dimPatient

CREATE TABLE dim_Patient(
dimPatientPK INT,
PatientNumber INT,
FirstName CHAR(50),
LastName CHAR(50),
Email CHAR(50),
PatientGender CHAR(20),
PatientAge INT,
City CHAR (100),
State CHAR(20)
) ;

-- dimPhyscian

CREATE TABLE dim_physcian(
dimPhysicianPK INT,
ProviderNpi DOUBLE,
ProviderName CHAR(100),
ProviderSpecialty CHAR(100),
ProviderFTE DOUBLE
) ;

-- dimTransaction

CREATE TABLE dim_transaction(
dimTransactionPK INT,
TransactionType CHAR(50),
`Transaction` CHAR(150),
AdjustmentReason CHAR(50)
) ;

-- ----------------------------

SELECT * FROM fact_table;
SELECT * FROM dim_location;
SELECT * FROM dim_payer ; 


-- Q.1 physcians & patients count by hospitals
SELECT 
    LocationName,
    COUNT(DISTINCT (PatientNumber)) AS patient_count,
    COUNT(DISTINCT (ProviderNpi)) AS physciant_count
FROM
    fact_table f
        INNER JOIN
    dim_location l ON f.dimLocationPK = l.dimLocationPK
		INNER JOIN 
	dim_physcian p ON f.dimPhysicianPK = p.dimPhysicianPK
GROUP BY 1
ORDER BY 2 DESC;


-- Q.2 Department wise physciants count in each hospital

SELECT 
    LocationName,
    ProviderSpecialty,
    COUNT(DISTINCT (ProviderNpi)) AS phy_count
FROM
    fact_table f
        INNER JOIN
    dim_location l ON f.dimLocationPK = l.dimLocationPK
        INNER JOIN
    dim_physcian p ON f.dimPhysicianPK = p.dimPhysicianPK
GROUP BY 1 , 2
ORDER BY 1 , 3 DESC;


-- Q3. Top 5 Most consulted departments

SELECT 
    ProviderSpecialty,
    COUNT(f.FactTablePK) AS consultation_count
FROM
    fact_table f
        INNER JOIN
    dim_physcian p ON f.dimPhysicianPK = p.dimPhysicianPK
WHERE
    ProviderSpecialty NOT REGEXP "nurse|midwife|student"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Q4. Top 5 least consulted departments

SELECT 
    ProviderSpecialty,
    COUNT(f.FactTablePK) AS consultation_count
FROM
    fact_table f
        INNER JOIN
    dim_physcian p ON f.dimPhysicianPK = p.dimPhysicianPK
WHERE
    ProviderSpecialty NOT REGEXP "nurse|midwife|student"
GROUP BY 1
ORDER BY 2 ASC
LIMIT 5;


-- Q5. Monthly counsultations count

SELECT 
    d.Year,
    d.month,
    MONTH(date) AS month_num,
    COUNT(*) AS tot_consultations
FROM
    fact_table f
        INNER JOIN
    dim_date d ON f.dimDatePostPK = d.dimDatePostPK
GROUP BY 1 , 2 , 3
ORDER BY 1 , 3;


-- Q6. Checking out the most common daignosis in dec & jan

SELECT 
    DiagnosisCode,
    DiagnosisCodeDescription AS `description`,
    count(*)
FROM
    fact_table f
        INNER JOIN
    dim_diagnosiscode d ON f.dimDiagnosisCodePK = d.dimDiagnosisCodePK
        INNER JOIN
    dim_date dt ON f.dimDatePostPK = dt.dimDatePostPK
WHERE dt.date BETWEEN "2019-12-01" AND "2020-01-31"
GROUP BY 1, 2 
ORDER BY 3 DESC
LIMIT 10 ;

-- Q.7 Rarely used diagnosis codes all time

SELECT 
    DiagnosisCode,
    DiagnosisCodeDescription AS `description`,
    COUNT(*)
FROM
    fact_table f
        INNER JOIN
    dim_diagnosiscode d ON f.dimDiagnosisCodePK = d.dimDiagnosisCodePK
GROUP BY 1 , 2
ORDER BY 3 ASC
LIMIT 10;


-- Q.8 Most used claim code

SELECT c.dimCPTCodePK,
    c.CptCode,
    c.Cptdesc AS description,
    count(*)
FROM
    fact_table f
        INNER JOIN
    dim_cptcode c ON f.dimCPTCodePK = c.dimCPTCodePK
GROUP BY 1, 2 ,3
ORDER BY 4 DESC
LIMIT 10 ;


SELECT 
    c.CptCode,
    c.CptDesc,
    count(*)
FROM
    fact_table f
        INNER JOIN
    dim_cptcode c ON f.dimCPTCodePK = c.dimCPTCodePK
where c.CptGrouping <> "medicine"
GROUP BY 1, 2 
ORDER BY 3 DESC
LIMIT 10 ;
