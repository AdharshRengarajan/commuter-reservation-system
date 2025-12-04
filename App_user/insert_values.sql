SET SERVEROUTPUT ON;

--------------------------------------------------------
-- 1) INSERT DAY SCHEDULE
--------------------------------------------------------
INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end)
VALUES (crs_day_schedule_seq_pk.NEXTVAL, 'MONDAY', 'N');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end)
VALUES (crs_day_schedule_seq_pk.NEXTVAL, 'TUESDAY', 'N');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end)
VALUES (crs_day_schedule_seq_pk.NEXTVAL, 'WEDNESDAY', 'N');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end)
VALUES (crs_day_schedule_seq_pk.NEXTVAL, 'THURSDAY', 'N');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end)
VALUES (crs_day_schedule_seq_pk.NEXTVAL, 'FRIDAY', 'N');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end)
VALUES (crs_day_schedule_seq_pk.NEXTVAL, 'SATURDAY', 'Y');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end)
VALUES (crs_day_schedule_seq_pk.NEXTVAL, 'SUNDAY', 'Y');

COMMIT;


--------------------------------------------------------
-- 2) INSERT TRAIN INFO
--------------------------------------------------------
INSERT INTO CRS_TRAIN_INFO (
    train_id, train_number, source_station, dest_station,
    total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare
) VALUES (
             crs_train_info_seq_pk.NEXTVAL,
             '1001', 'BOSTON', 'NEW_YORK', 40, 40, 150.00, 80.00
         );

INSERT INTO CRS_TRAIN_INFO (
    train_id, train_number, source_station, dest_station,
    total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare
) VALUES (
             crs_train_info_seq_pk.NEXTVAL,
             '1002', 'BOSTON', 'CHICAGO', 40, 40, 200.00, 110.00
         );

INSERT INTO CRS_TRAIN_INFO (
    train_id, train_number, source_station, dest_station,
    total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare
) VALUES (
             crs_train_info_seq_pk.NEXTVAL,
             '2001', 'SAN_FRANCISCO', 'LOS_ANGELES', 40, 40, 120.00, 70.00
         );

COMMIT;


--------------------------------------------------------
-- 3) INSERT TRAIN SCHEDULE
--------------------------------------------------------
DECLARE
v_train_id_1001 NUMBER;
    v_train_id_1002 NUMBER;
    v_train_id_2001 NUMBER;
BEGIN
SELECT train_id INTO v_train_id_1001 FROM CRS_TRAIN_INFO WHERE train_number='1001';
SELECT train_id INTO v_train_id_1002 FROM CRS_TRAIN_INFO WHERE train_number='1002';
SELECT train_id INTO v_train_id_2001 FROM CRS_TRAIN_INFO WHERE train_number='2001';

-- WEEKDAY schedule for 1001
FOR r IN (SELECT sch_id FROM CRS_DAY_SCHEDULE
              WHERE day_of_week IN ('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY'))
    LOOP
        INSERT INTO CRS_TRAIN_SCHEDULE (tsch_id, sch_id, train_id, is_in_service)
        VALUES (crs_train_schedule_seq_pk.NEXTVAL, r.sch_id, v_train_id_1001, 'Y');
END LOOP;

    -- WEEKEND schedule for 1002
FOR r IN (SELECT sch_id FROM CRS_DAY_SCHEDULE
              WHERE day_of_week IN ('SATURDAY','SUNDAY'))
    LOOP
        INSERT INTO CRS_TRAIN_SCHEDULE (tsch_id, sch_id, train_id, is_in_service)
        VALUES (crs_train_schedule_seq_pk.NEXTVAL, r.sch_id, v_train_id_1002, 'Y');
END LOOP;

    -- ALL DAYS for 2001
FOR r IN (SELECT sch_id FROM CRS_DAY_SCHEDULE)
    LOOP
        INSERT INTO CRS_TRAIN_SCHEDULE (tsch_id, sch_id, train_id, is_in_service)
        VALUES (crs_train_schedule_seq_pk.NEXTVAL, r.sch_id, v_train_id_2001, 'Y');
END LOOP;

END;
/
COMMIT;


--------------------------------------------------------
-- 4) INSERT PASSENGERS
--------------------------------------------------------
INSERT INTO CRS_PASSENGER (
    passenger_id,
    first_name, middle_name, last_name,
    date_of_birth,
    address_line1, address_city, address_state, address_zip,
    email,
    phone
) VALUES (
             crs_passenger_seq_pk.NEXTVAL,
             'John', 'ABC', 'Doe',
             DATE '1990-05-10',
             '123 Main St', 'Boston', 'MA', '02115',
             'john@example.com',
             '999-111-2222'
         );

INSERT INTO CRS_PASSENGER (
    passenger_id,
    first_name, middle_name, last_name,
    date_of_birth,
    address_line1, address_city, address_state, address_zip,
    email,
    phone
) VALUES (
             crs_passenger_seq_pk.NEXTVAL,
             'Emma', 'L', 'Watson',
             DATE '1989-04-15',
             '45 River Rd', 'Cambridge', 'MA', '02139',
             'emma@example.com',
             '999-333-4444'
         );

INSERT INTO CRS_PASSENGER (
    passenger_id,
    first_name, middle_name, last_name,
    date_of_birth,
    address_line1, address_city, address_state, address_zip,
    email,
    phone
) VALUES (
             crs_passenger_seq_pk.NEXTVAL,
             'Mike', 'P', 'Ross',
             DATE '2001-02-11',
             '88 Elm St', 'Somerville', 'MA', '02143',
             'mike@example.com',
             '999-555-6666'
         );

COMMIT;


--------------------------------------------------------
-- 5) INSERT RESERVATION (lookup passenger + train)
--------------------------------------------------------
DECLARE
v_train_id      CRS_TRAIN_INFO.train_id%TYPE;
    v_passenger_id  CRS_PASSENGER.passenger_id%TYPE;
BEGIN
    -- get John by email (do NOT hard-code 1)
SELECT passenger_id
INTO v_passenger_id
FROM CRS_PASSENGER
WHERE email = 'john@example.com';

-- get train_id for 1001
SELECT train_id
INTO v_train_id
FROM CRS_TRAIN_INFO
WHERE train_number = '1001';

INSERT INTO CRS_RESERVATION (
    booking_id,
    passenger_id,
    train_id,
    travel_date,
    booking_date,
    seat_class,
    seat_status,
    waitlist_position
) VALUES (
             crs_reservation_seq_pk.NEXTVAL,
             v_passenger_id,
             v_train_id,
             TRUNC(SYSDATE) + 1,
             SYSDATE,
             'ECON',
             'CONFIRMED',
             NULL
         );

DBMS_OUTPUT.PUT_LINE(
        'Reservation inserted: passenger_id=' || v_passenger_id ||
        ', train_id=' || v_train_id
    );
END;
/
COMMIT;