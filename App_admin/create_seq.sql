SET SERVEROUTPUT ON;

-- Sequence for CRS_TRAIN_INFO primary key (TRAIN_ID)
DECLARE
seq_count NUMBER;
BEGIN
SELECT COUNT(*)
INTO seq_count
FROM ALL_SEQUENCES
WHERE SEQUENCE_NAME = 'CRS_TRAIN_INFO_SEQ_PK'
  AND SEQUENCE_OWNER = USER;

IF seq_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE crs_train_info_seq_pk';
        DBMS_OUTPUT.PUT_LINE('Sequence "CRS_TRAIN_INFO_SEQ_PK" dropped successfully.');
END IF;

EXECUTE IMMEDIATE 'CREATE SEQUENCE crs_train_info_seq_pk START WITH 1 INCREMENT BY 1';
DBMS_OUTPUT.PUT_LINE('Sequence "CRS_TRAIN_INFO_SEQ_PK" created successfully.');
END;
/
------------------------------------------------------------

-- Sequence for CRS_DAY_SCHEDULE primary key (SCH_ID)
DECLARE
seq_count NUMBER;
BEGIN
SELECT COUNT(*)
INTO seq_count
FROM ALL_SEQUENCES
WHERE SEQUENCE_NAME = 'CRS_DAY_SCHEDULE_SEQ_PK'
  AND SEQUENCE_OWNER = USER;

IF seq_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE crs_day_schedule_seq_pk';
        DBMS_OUTPUT.PUT_LINE('Sequence "CRS_DAY_SCHEDULE_SEQ_PK" dropped successfully.');
END IF;

EXECUTE IMMEDIATE 'CREATE SEQUENCE crs_day_schedule_seq_pk START WITH 1 INCREMENT BY 1';
DBMS_OUTPUT.PUT_LINE('Sequence "CRS_DAY_SCHEDULE_SEQ_PK" created successfully.');
END;
/
------------------------------------------------------------

-- Sequence for CRS_TRAIN_SCHEDULE primary key (TSCH_ID)
DECLARE
seq_count NUMBER;
BEGIN
SELECT COUNT(*)
INTO seq_count
FROM ALL_SEQUENCES
WHERE SEQUENCE_NAME = 'CRS_TRAIN_SCHEDULE_SEQ_PK'
  AND SEQUENCE_OWNER = USER;

IF seq_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE crs_train_schedule_seq_pk';
        DBMS_OUTPUT.PUT_LINE('Sequence "CRS_TRAIN_SCHEDULE_SEQ_PK" dropped successfully.');
END IF;

EXECUTE IMMEDIATE 'CREATE SEQUENCE crs_train_schedule_seq_pk START WITH 1 INCREMENT BY 1';
DBMS_OUTPUT.PUT_LINE('Sequence "CRS_TRAIN_SCHEDULE_SEQ_PK" created successfully.');
END;
/
------------------------------------------------------------

-- Sequence for CRS_PASSENGER primary key (PASSENGER_ID)
DECLARE
seq_count NUMBER;
BEGIN
SELECT COUNT(*)
INTO seq_count
FROM ALL_SEQUENCES
WHERE SEQUENCE_NAME = 'CRS_PASSENGER_SEQ_PK'
  AND SEQUENCE_OWNER = USER;

IF seq_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE crs_passenger_seq_pk';
        DBMS_OUTPUT.PUT_LINE('Sequence "CRS_PASSENGER_SEQ_PK" dropped successfully.');
END IF;

EXECUTE IMMEDIATE 'CREATE SEQUENCE crs_passenger_seq_pk START WITH 1 INCREMENT BY 1';
DBMS_OUTPUT.PUT_LINE('Sequence "CRS_PASSENGER_SEQ_PK" created successfully.');
END;
/
------------------------------------------------------------

-- Sequence for CRS_RESERVATION primary key (BOOKING_ID)
DECLARE
seq_count NUMBER;
BEGIN
SELECT COUNT(*)
INTO seq_count
FROM ALL_SEQUENCES
WHERE SEQUENCE_NAME = 'CRS_RESERVATION_SEQ_PK'
  AND SEQUENCE_OWNER = USER;

IF seq_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE crs_reservation_seq_pk';
        DBMS_OUTPUT.PUT_LINE('Sequence "CRS_RESERVATION_SEQ_PK" dropped successfully.');
END IF;

EXECUTE IMMEDIATE 'CREATE SEQUENCE crs_reservation_seq_pk START WITH 1 INCREMENT BY 1';
DBMS_OUTPUT.PUT_LINE('Sequence "CRS_RESERVATION_SEQ_PK" created successfully.');
END;
/