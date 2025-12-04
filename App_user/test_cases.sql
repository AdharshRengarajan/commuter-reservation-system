
SET SERVEROUTPUT ON;

SELECT booking_id,
       passenger_id,
       train_id,
       TO_CHAR(travel_date,'YYYY-MM-DD') AS travel_date,
       seat_class,
       seat_status,
       waitlist_position
FROM CRS_RESERVATION
ORDER BY travel_date, train_id, seat_class, booking_id;


DECLARE
v_pid         NUMBER;
  v_booking_id  NUMBER;
  v_status      VARCHAR2(20);
  v_wait_pos    NUMBER;
  v_travel_date DATE := TRUNC(SYSDATE) + 1;
BEGIN
  CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
    p_first_name    => 'TC1',
    p_middle_name   => NULL,
    p_last_name     => 'User',
    p_date_of_birth => DATE '1990-01-01',
    p_address_line1 => '1 Test St',
    p_address_city  => 'Boston',
    p_address_state => 'MA',
    p_address_zip   => '02115',
    p_email         => 'tc1.user@example.com',
    p_phone         => '100-000-0001',
    o_passenger_id  => v_pid
  );

  DBMS_OUTPUT.PUT_LINE('TC1 Passenger ID = ' || v_pid);

  CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
    p_passenger_id => v_pid,
    p_train_number => '2001',
    p_travel_date  => v_travel_date,
    p_seat_class   => 'ECON',
    o_booking_id   => v_booking_id,
    o_seat_status  => v_status,
    o_waitlist_pos => v_wait_pos
  );

  DBMS_OUTPUT.PUT_LINE('TC1 Booking ID = ' || v_booking_id ||
                       ', Status = ' || v_status ||
                       ', Waitlist Pos = ' || NVL(TO_CHAR(v_wait_pos),'N/A'));
END;
/

DECLARE
v_pid1 NUMBER;
  v_pid2 NUMBER;
BEGIN
  CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
    p_first_name    => 'TC2',
    p_middle_name   => NULL,
    p_last_name     => 'User1',
    p_date_of_birth => DATE '1995-05-05',
    p_address_line1 => '2 Test St',
    p_address_city  => 'Boston',
    p_address_state => 'MA',
    p_address_zip   => '02115',
    p_email         => 'tc2.user@example.com',
    p_phone         => '100-000-0002',
    o_passenger_id  => v_pid1
  );
  DBMS_OUTPUT.PUT_LINE('TC2 First passenger ID = ' || v_pid1);

BEGIN
    CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
      p_first_name    => 'TC2',
      p_middle_name   => NULL,
      p_last_name     => 'User2',
      p_date_of_birth => DATE '1995-05-05',
      p_address_line1 => '3 Test St',
      p_address_city  => 'Boston',
      p_address_state => 'MA',
      p_address_zip   => '02115',
      p_email         => 'tc2.user@example.com',
      p_phone         => '100-000-0002',
      o_passenger_id  => v_pid2
    );
    DBMS_OUTPUT.PUT_LINE('ERROR: Duplicate allowed (should not happen).');
EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('TC2 Expected error: ' || SQLERRM);
END;
END;
/

DECLARE
v_pid         NUMBER;
  v_booking_id  NUMBER;
  v_status      VARCHAR2(20);
  v_wait_pos    NUMBER;
  v_travel_date DATE := TRUNC(SYSDATE) + 1;
BEGIN
  CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
    p_first_name    => 'TC3',
    p_middle_name   => NULL,
    p_last_name     => 'User',
    p_date_of_birth => DATE '1992-02-02',
    p_address_line1 => '4 Test St',
    p_address_city  => 'Boston',
    p_address_state => 'MA',
    p_address_zip   => '02115',
    p_email         => 'tc3.user@example.com',
    p_phone         => '100-000-0003',
    o_passenger_id  => v_pid
  );

BEGIN
    CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
      p_passenger_id => v_pid,
      p_train_number => '9999',
      p_travel_date  => v_travel_date,
      p_seat_class   => 'FC',
      o_booking_id   => v_booking_id,
      o_seat_status  => v_status,
      o_waitlist_pos => v_wait_pos
    );
    DBMS_OUTPUT.PUT_LINE('ERROR: Invalid train was accepted!');
EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('TC3 Expected error: ' || SQLERRM);
END;
END;
/

DECLARE
v_pid         NUMBER;
  v_booking_id  NUMBER;
  v_status      VARCHAR2(20);
  v_wait_pos    NUMBER;
  v_sat_date    DATE;
BEGIN
  v_sat_date := NEXT_DAY(TRUNC(SYSDATE), 'SATURDAY');

  CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
    p_first_name    => 'TC4',
    p_middle_name   => NULL,
    p_last_name     => 'User',
    p_date_of_birth => DATE '1993-03-03',
    p_address_line1 => '5 Test St',
    p_address_city  => 'Boston',
    p_address_state => 'MA',
    p_address_zip   => '02115',
    p_email         => 'tc4.user@example.com',
    p_phone         => '100-000-0004',
    o_passenger_id  => v_pid
  );

BEGIN
    CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
      p_passenger_id => v_pid,
      p_train_number => '1001',
      p_travel_date  => v_sat_date,
      p_seat_class   => 'ECON',
      o_booking_id   => v_booking_id,
      o_seat_status  => v_status,
      o_waitlist_pos => v_wait_pos
    );
    DBMS_OUTPUT.PUT_LINE('ERROR: Train not in service but booking succeeded!');
EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('TC4 Expected error: ' || SQLERRM);
END;
END;
/

DECLARE
v_pid         NUMBER;
  v_booking_id  NUMBER;
  v_status      VARCHAR2(20);
  v_wait_pos    NUMBER;
  v_past_date   DATE := TRUNC(SYSDATE) - 1;
BEGIN
  CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
    p_first_name    => 'TC5',
    p_middle_name   => NULL,
    p_last_name     => 'User',
    p_date_of_birth => DATE '1994-04-04',
    p_address_line1 => '6 Test St',
    p_address_city  => 'Boston',
    p_address_state => 'MA',
    p_address_zip   => '02115',
    p_email         => 'tc5.user@example.com',
    p_phone         => '100-000-0005',
    o_passenger_id  => v_pid
  );

BEGIN
    CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
      p_passenger_id => v_pid,
      p_train_number => '2001',
      p_travel_date  => v_past_date,
      p_seat_class   => 'FC',
      o_booking_id   => v_booking_id,
      o_seat_status  => v_status,
      o_waitlist_pos => v_wait_pos
    );
    DBMS_OUTPUT.PUT_LINE('ERROR: Past date booking succeeded!');
EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('TC5 Expected error: ' || SQLERRM);
END;
END;
/

DECLARE
v_pid         NUMBER;
  v_booking_id  NUMBER;
  v_status      VARCHAR2(20);
  v_wait_pos    NUMBER;
  v_far_date    DATE := TRUNC(SYSDATE) + 8;
BEGIN
  CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
    p_first_name    => 'TC6',
    p_middle_name   => NULL,
    p_last_name     => 'User',
    p_date_of_birth => DATE '1991-06-06',
    p_address_line1 => '7 Test St',
    p_address_city  => 'Boston',
    p_address_state => 'MA',
    p_address_zip   => '02115',
    p_email         => 'tc6.user@example.com',
    p_phone         => '100-000-0006',
    o_passenger_id  => v_pid
  );

BEGIN
    CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
      p_passenger_id => v_pid,
      p_train_number => '2001',
      p_travel_date  => v_far_date,
      p_seat_class   => 'ECON',
      o_booking_id   => v_booking_id,
      o_seat_status  => v_status,
      o_waitlist_pos => v_wait_pos
    );
    DBMS_OUTPUT.PUT_LINE('ERROR: >7 days advance booking succeeded!');
EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('TC6 Expected error: ' || SQLERRM);
END;
END;
/

DECLARE
v_pid         NUMBER;
  v_booking_id  NUMBER;
  v_status      VARCHAR2(20);
  v_wait_pos    NUMBER;
  v_travel_date DATE := TRUNC(SYSDATE) + 1;
BEGIN
  CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
    p_first_name    => 'TC7',
    p_middle_name   => NULL,
    p_last_name     => 'User',
    p_date_of_birth => DATE '1990-07-07',
    p_address_line1 => '8 Test St',
    p_address_city  => 'Boston',
    p_address_state => 'MA',
    p_address_zip   => '02115',
    p_email         => 'tc7.user@example.com',
    p_phone         => '100-000-0007',
    o_passenger_id  => v_pid
  );

BEGIN
    CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
      p_passenger_id => v_pid,
      p_train_number => '2001',
      p_travel_date  => v_travel_date,
      p_seat_class   => 'BUSINESS',
      o_booking_id   => v_booking_id,
      o_seat_status  => v_status,
      o_waitlist_pos => v_wait_pos
    );
    DBMS_OUTPUT.PUT_LINE('ERROR: Invalid seat class accepted!');
EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('TC7 Expected error: ' || SQLERRM);
END;
END;
/

DECLARE
v_travel_date DATE := TRUNC(SYSDATE) + 2;
  v_pid         NUMBER;
  v_booking_id  NUMBER;
  v_status      VARCHAR2(20);
  v_wait_pos    NUMBER;
  i             PLS_INTEGER;
BEGIN
DELETE FROM CRS_RESERVATION
WHERE train_id = (SELECT train_id
                  FROM CRS_TRAIN_INFO
                  WHERE train_number = '2001')
  AND travel_date = v_travel_date
  AND seat_class  = 'ECON';
COMMIT;

FOR i IN 1..45 LOOP
    CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
      p_first_name    => 'TC8',
      p_middle_name   => NULL,
      p_last_name     => 'User' || i,
      p_date_of_birth => DATE '1990-01-01',
      p_address_line1 => 'TC8 St',
      p_address_city  => 'Boston',
      p_address_state => 'MA',
      p_address_zip   => '02115',
      p_email         => 'tc8.user' || i || '@example.com',
      p_phone         => '108-000-' || TO_CHAR(1000 + i),
      o_passenger_id  => v_pid
    );

    CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
      p_passenger_id => v_pid,
      p_train_number => '2001',
      p_travel_date  => v_travel_date,
      p_seat_class   => 'ECON',
      o_booking_id   => v_booking_id,
      o_seat_status  => v_status,
      o_waitlist_pos => v_wait_pos
    );

    DBMS_OUTPUT.PUT_LINE('TC8 Booking #' || i ||
                         ' -> ID=' || v_booking_id ||
                         ', Status=' || v_status ||
                         ', WL Pos=' || NVL(TO_CHAR(v_wait_pos),'N/A'));
END LOOP;

BEGIN
    CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
      p_first_name    => 'TC8',
      p_middle_name   => NULL,
      p_last_name     => 'User46',
      p_date_of_birth => DATE '1990-01-01',
      p_address_line1 => 'TC8 St',
      p_address_city  => 'Boston',
      p_address_state => 'MA',
      p_address_zip   => '02115',
      p_email         => 'tc8.user46@example.com',
      p_phone         => '108-000-2046',
      o_passenger_id  => v_pid
    );

    CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
      p_passenger_id => v_pid,
      p_train_number => '2001',
      p_travel_date  => v_travel_date,
      p_seat_class   => 'ECON',
      o_booking_id   => v_booking_id,
      o_seat_status  => v_status,
      o_waitlist_pos => v_wait_pos
    );
    DBMS_OUTPUT.PUT_LINE('ERROR: 46th booking succeeded (should fail)!');
EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('TC8 Expected error for 46th booking: ' || SQLERRM);
END;
END;
/

DECLARE
v_travel_date DATE := TRUNC(SYSDATE) + 3;
  v_pid_conf    NUMBER;
  v_pid_wl1     NUMBER;
  v_pid_wl2     NUMBER;

  v_bk_conf     NUMBER;
  v_bk_wl1      NUMBER;
  v_bk_wl2      NUMBER;

  v_status      VARCHAR2(20);
  v_wait_pos    NUMBER;
BEGIN
DELETE FROM CRS_RESERVATION
WHERE train_id = (SELECT train_id
                  FROM CRS_TRAIN_INFO
                  WHERE train_number = '2001')
  AND travel_date = v_travel_date
  AND seat_class  = 'FC';
COMMIT;

CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
    p_first_name    => 'TC9',
    p_middle_name   => NULL,
    p_last_name     => 'Conf',
    p_date_of_birth => DATE '1990-01-01',
    p_address_line1 => 'TC9 St',
    p_address_city  => 'Boston',
    p_address_state => 'MA',
    p_address_zip   => '02115',
    p_email         => 'tc9.conf@example.com',
    p_phone         => '109-000-0001',
    o_passenger_id  => v_pid_conf
  );

  CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
    p_first_name    => 'TC9',
    p_middle_name   => NULL,
    p_last_name     => 'WL1',
    p_date_of_birth => DATE '1990-01-01',
    p_address_line1 => 'TC9 St',
    p_address_city  => 'Boston',
    p_address_state => 'MA',
    p_address_zip   => '02115',
    p_email         => 'tc9.wl1@example.com',
    p_phone         => '109-000-0002',
    o_passenger_id  => v_pid_wl1
  );

  CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
    p_first_name    => 'TC9',
    p_middle_name   => NULL,
    p_last_name     => 'WL2',
    p_date_of_birth => DATE '1990-01-01',
    p_address_line1 => 'TC9 St',
    p_address_city  => 'Boston',
    p_address_state => 'MA',
    p_address_zip   => '02115',
    p_email         => 'tc9.wl2@example.com',
    p_phone         => '109-000-0003',
    o_passenger_id  => v_pid_wl2
  );

  DECLARE
v_pid_dummy  NUMBER;
    v_bid_dummy  NUMBER;
    v_stat_dummy VARCHAR2(20);
    v_wl_dummy   NUMBER;
    i            PLS_INTEGER;
BEGIN
FOR i IN 1..40 LOOP
      CRS_ADMIN.PKG_CRS_PASSENGER.add_passenger(
        p_first_name    => 'TC9D',
        p_middle_name   => NULL,
        p_last_name     => 'User' || i,
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => 'TC9D',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02115',
        p_email         => 'tc9d.user' || i || '@example.com',
        p_phone         => '109-100-' || TO_CHAR(2000 + i),
        o_passenger_id  => v_pid_dummy
      );

      CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
        p_passenger_id => v_pid_dummy,
        p_train_number => '2001',
        p_travel_date  => v_travel_date,
        p_seat_class   => 'FC',
        o_booking_id   => v_bid_dummy,
        o_seat_status  => v_stat_dummy,
        o_waitlist_pos => v_wl_dummy
      );
END LOOP;
END;

  CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
    p_passenger_id => v_pid_conf,
    p_train_number => '2001',
    p_travel_date  => v_travel_date,
    p_seat_class   => 'FC',
    o_booking_id   => v_bk_conf,
    o_seat_status  => v_status,
    o_waitlist_pos => v_wait_pos
  );
  DBMS_OUTPUT.PUT_LINE('TC9 Confirmed booking id = ' || v_bk_conf ||
                       ', status=' || v_status ||
                       ', wl=' || NVL(TO_CHAR(v_wait_pos),'N/A'));

  CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
    p_passenger_id => v_pid_wl1,
    p_train_number => '2001',
    p_travel_date  => v_travel_date,
    p_seat_class   => 'FC',
    o_booking_id   => v_bk_wl1,
    o_seat_status  => v_status,
    o_waitlist_pos => v_wait_pos
  );
  DBMS_OUTPUT.PUT_LINE('TC9 WL1 booking id = ' || v_bk_wl1 ||
                       ', status=' || v_status ||
                       ', wl=' || NVL(TO_CHAR(v_wait_pos),'N/A'));

  CRS_ADMIN.PKG_CRS_RESERVATION.book_ticket(
    p_passenger_id => v_pid_wl2,
    p_train_number => '2001',
    p_travel_date  => v_travel_date,
    p_seat_class   => 'FC',
    o_booking_id   => v_bk_wl2,
    o_seat_status  => v_status,
    o_waitlist_pos => v_wait_pos
  );
  DBMS_OUTPUT.PUT_LINE('TC9 WL2 booking id = ' || v_bk_wl2 ||
                       ', status=' || v_status ||
                       ', wl=' || NVL(TO_CHAR(v_wait_pos),'N/A'));

  CRS_ADMIN.PKG_CRS_RESERVATION.cancel_ticket(p_booking_id => v_bk_conf);
  DBMS_OUTPUT.PUT_LINE('TC9 Cancelled booking id = ' || v_bk_conf ||
                       ' -> should promote WL1 to CONFIRMED');

  DBMS_OUTPUT.PUT_LINE('--- After cancellation ---');
FOR r IN (
    SELECT booking_id,
           seat_status,
           waitlist_position
      FROM CRS_RESERVATION
     WHERE train_id = (SELECT train_id
                         FROM CRS_TRAIN_INFO
                        WHERE train_number = '2001')
       AND travel_date = v_travel_date
       AND seat_class  = 'FC'
       AND booking_id IN (v_bk_conf, v_bk_wl1, v_bk_wl2)
     ORDER BY booking_id
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Booking ' || r.booking_id ||
                         ': status=' || r.seat_status ||
                         ', wl=' || NVL(TO_CHAR(r.waitlist_position),'N/A'));
END LOOP;
END;
/

DECLARE
BEGIN
BEGIN
    CRS_ADMIN.PKG_CRS_RESERVATION.cancel_ticket(p_booking_id => -1);
    DBMS_OUTPUT.PUT_LINE('ERROR: Non-existing booking cancel succeeded!');
EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('TC10 Expected error (non-existing): ' || SQLERRM);
END;

  DECLARE
v_cancelled_id CRS_RESERVATION.booking_id%TYPE;
BEGIN
SELECT booking_id
INTO v_cancelled_id
FROM CRS_RESERVATION
WHERE seat_status = 'CANCELLED'
  AND ROWNUM = 1;

BEGIN
      CRS_ADMIN.PKG_CRS_RESERVATION.cancel_ticket(p_booking_id => v_cancelled_id);
      DBMS_OUTPUT.PUT_LINE('ERROR: Re-cancel succeeded!');
EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('TC10 Expected error (already cancelled): ' || SQLERRM);
END;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('TC10 Note: No cancelled bookings yet to test re-cancel.');
END;
END;
/

