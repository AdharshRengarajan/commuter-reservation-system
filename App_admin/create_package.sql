CREATE OR REPLACE PACKAGE BODY PKG_CRS_RESERVATION AS

  c_status_confirmed   CONSTANT VARCHAR2(12) := 'CONFIRMED';
  c_status_waitlisted  CONSTANT VARCHAR2(12) := 'WAITLISTED';
  c_status_cancelled   CONSTANT VARCHAR2(12) := 'CANCELLED';

  c_class_fc           CONSTANT VARCHAR2(5)  := 'FC';
  c_class_econ         CONSTANT VARCHAR2(5)  := 'ECON';

  c_max_confirmed      CONSTANT PLS_INTEGER  := 40;
  c_max_waitlist       CONSTANT PLS_INTEGER  := 5;
  c_max_advance_days   CONSTANT PLS_INTEGER  := 7;

  FUNCTION get_schedule_id_for_date (
    p_travel_date IN DATE
  ) RETURN CRS_DAY_SCHEDULE.sch_id%TYPE IS
    v_dow    VARCHAR2(10);
    v_sch_id CRS_DAY_SCHEDULE.sch_id%TYPE;
  BEGIN
    v_dow := UPPER(TRIM(TO_CHAR(TRUNC(p_travel_date),
                                'DAY',
                                'NLS_DATE_LANGUAGE=ENGLISH')));

    SELECT sch_id
      INTO v_sch_id
      FROM CRS_DAY_SCHEDULE
     WHERE UPPER(day_of_week) = v_dow;

    RETURN v_sch_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20100,'No schedule mapping found for day ' || v_dow);
  END get_schedule_id_for_date;

  PROCEDURE book_ticket (
    p_passenger_id IN CRS_RESERVATION.passenger_id%TYPE,
    p_train_number IN CRS_TRAIN_INFO.train_number%TYPE,
    p_travel_date  IN DATE,
    p_seat_class   IN CRS_RESERVATION.seat_class%TYPE,
    o_booking_id   OUT CRS_RESERVATION.booking_id%TYPE,
    o_seat_status  OUT CRS_RESERVATION.seat_status%TYPE,
    o_waitlist_pos OUT CRS_RESERVATION.waitlist_position%TYPE
  ) IS
    v_travel_date       DATE := TRUNC(p_travel_date);
    v_today             DATE := TRUNC(SYSDATE);

    v_passenger_count   PLS_INTEGER;
    v_train_id          CRS_TRAIN_INFO.train_id%TYPE;
    v_train_count       PLS_INTEGER;

    v_sch_id            CRS_DAY_SCHEDULE.sch_id%TYPE;
    v_service_count     PLS_INTEGER;

    v_seat_class        VARCHAR2(5);

    v_confirmed_count   PLS_INTEGER;
    v_waitlist_count    PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_passenger_count FROM CRS_PASSENGER WHERE passenger_id = p_passenger_id;
    IF v_passenger_count = 0 THEN RAISE_APPLICATION_ERROR(-20001,'Passenger not found.'); END IF;

    SELECT COUNT(*) INTO v_train_count FROM CRS_TRAIN_INFO WHERE train_number = p_train_number;
    IF v_train_count = 0 THEN RAISE_APPLICATION_ERROR(-20002,'Invalid train number.'); END IF;

    SELECT train_id INTO v_train_id FROM CRS_TRAIN_INFO WHERE train_number = p_train_number;

    v_seat_class := UPPER(TRIM(p_seat_class));
    IF v_seat_class NOT IN (c_class_fc, c_class_econ) THEN
      RAISE_APPLICATION_ERROR(-20003,'Invalid seat class. Allowed values: FC, ECON.');
    END IF;

    IF v_travel_date < v_today THEN RAISE_APPLICATION_ERROR(-20004,'Travel date cannot be in the past.'); END IF;
    IF v_travel_date > v_today + c_max_advance_days THEN RAISE_APPLICATION_ERROR(-20005,'Only one week advance booking is allowed.'); END IF;

    v_sch_id := get_schedule_id_for_date(v_travel_date);

    SELECT COUNT(*) INTO v_service_count
      FROM CRS_TRAIN_SCHEDULE
     WHERE train_id = v_train_id
       AND sch_id = v_sch_id
       AND is_in_service = 'Y';

    IF v_service_count = 0 THEN RAISE_APPLICATION_ERROR(-20006,'Train is not in service on the selected date.'); END IF;

    SELECT COUNT(*) INTO v_confirmed_count
      FROM CRS_RESERVATION
     WHERE train_id = v_train_id
       AND travel_date = v_travel_date
       AND seat_class = v_seat_class
       AND seat_status = c_status_confirmed;

    SELECT COUNT(*) INTO v_waitlist_count
      FROM CRS_RESERVATION
     WHERE train_id = v_train_id
       AND travel_date = v_travel_date
       AND seat_class = v_seat_class
       AND seat_status = c_status_waitlisted;

    IF v_confirmed_count < c_max_confirmed THEN
      INSERT INTO CRS_RESERVATION (
        booking_id, passenger_id, train_id, travel_date, booking_date,
        seat_class, seat_status, waitlist_position
      ) VALUES (
        CRS_RESERVATION_SEQ_PK.NEXTVAL, p_passenger_id, v_train_id, v_travel_date,
        SYSDATE, v_seat_class, c_status_confirmed, NULL
      ) RETURNING booking_id INTO o_booking_id;

      o_seat_status := c_status_confirmed;
      o_waitlist_pos := NULL;

    ELSIF v_waitlist_count < c_max_waitlist THEN
      o_waitlist_pos := v_waitlist_count + 1;

      INSERT INTO CRS_RESERVATION (
        booking_id, passenger_id, train_id, travel_date, booking_date,
        seat_class, seat_status, waitlist_position
      ) VALUES (
        CRS_RESERVATION_SEQ_PK.NEXTVAL, p_passenger_id, v_train_id, v_travel_date,
        SYSDATE, v_seat_class, c_status_waitlisted, o_waitlist_pos
      ) RETURNING booking_id INTO o_booking_id;

      o_seat_status := c_status_waitlisted;

    ELSE
      RAISE_APPLICATION_ERROR(-20007,'No seats or waitlist slots available.');
    END IF;

  END book_ticket;

  PROCEDURE cancel_ticket (
    p_booking_id IN CRS_RESERVATION.booking_id%TYPE
  ) IS
    v_train_id     CRS_RESERVATION.train_id%TYPE;
    v_travel_date  CRS_RESERVATION.travel_date%TYPE;
    v_seat_class   CRS_RESERVATION.seat_class%TYPE;
    v_old_status   CRS_RESERVATION.seat_status%TYPE;

    v_promote_booking_id  CRS_RESERVATION.booking_id%TYPE;
  BEGIN
    SELECT train_id, travel_date, seat_class, seat_status
      INTO v_train_id, v_travel_date, v_seat_class, v_old_status
      FROM CRS_RESERVATION
     WHERE booking_id = p_booking_id;

    IF v_old_status = c_status_cancelled THEN
      RAISE_APPLICATION_ERROR(-20008,'Ticket is already cancelled.');
    END IF;

    UPDATE CRS_RESERVATION
       SET seat_status = c_status_cancelled,
           waitlist_position = NULL
     WHERE booking_id = p_booking_id;

    IF v_old_status = c_status_confirmed THEN
      BEGIN
        SELECT booking_id INTO v_promote_booking_id
          FROM (
                SELECT booking_id
                  FROM CRS_RESERVATION
                 WHERE train_id = v_train_id
                   AND travel_date = v_travel_date
                   AND seat_class = v_seat_class
                   AND seat_status = c_status_waitlisted
                 ORDER BY waitlist_position
               )
         WHERE ROWNUM = 1;

        UPDATE CRS_RESERVATION
           SET seat_status = c_status_confirmed,
               waitlist_position = NULL
         WHERE booking_id = v_promote_booking_id;

      EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      END;

      DECLARE
        v_new_pos PLS_INTEGER := 0;
      BEGIN
        FOR r IN (
          SELECT booking_id
            FROM CRS_RESERVATION
           WHERE train_id = v_train_id
             AND travel_date = v_travel_date
             AND seat_class = v_seat_class
             AND seat_status = c_status_waitlisted
           ORDER BY waitlist_position
        ) LOOP
          v_new_pos := v_new_pos + 1;
          UPDATE CRS_RESERVATION
             SET waitlist_position = v_new_pos
           WHERE booking_id = r.booking_id;
        END LOOP;
      END;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20009,'Booking ID not found.');
  END cancel_ticket;

END PKG_CRS_RESERVATION;
/

CREATE OR REPLACE PACKAGE PKG_CRS_PASSENGER AS
  FUNCTION get_passenger_category (p_date_of_birth IN DATE) RETURN VARCHAR2;

  PROCEDURE add_passenger (
    p_first_name    IN CRS_PASSENGER.first_name%TYPE,
    p_middle_name   IN CRS_PASSENGER.middle_name%TYPE,
    p_last_name     IN CRS_PASSENGER.last_name%TYPE,
    p_date_of_birth IN CRS_PASSENGER.date_of_birth%TYPE,
    p_address_line1 IN CRS_PASSENGER.address_line1%TYPE,
    p_address_city  IN CRS_PASSENGER.address_city%TYPE,
    p_address_state IN CRS_PASSENGER.address_state%TYPE,
    p_address_zip   IN CRS_PASSENGER.address_zip%TYPE,
    p_email         IN CRS_PASSENGER.email%TYPE,
    p_phone         IN CRS_PASSENGER.phone%TYPE,
    o_passenger_id  OUT CRS_PASSENGER.passenger_id%TYPE
  );
END PKG_CRS_PASSENGER;
/

CREATE OR REPLACE PACKAGE BODY PKG_CRS_PASSENGER AS

  FUNCTION get_age_years (p_dob IN DATE) RETURN NUMBER IS
    v_years NUMBER;
  BEGIN
    v_years := TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), TRUNC(p_dob)) / 12);
    RETURN v_years;
  END get_age_years;

  FUNCTION get_passenger_category (p_date_of_birth IN DATE) RETURN VARCHAR2 IS
    v_age NUMBER;
  BEGIN
    v_age := get_age_years(p_date_of_birth);
    IF v_age < 18 THEN RETURN 'MINOR';
    ELSIF v_age < 60 THEN RETURN 'ADULT';
    ELSE RETURN 'SENIOR';
    END IF;
  END get_passenger_category;

  PROCEDURE add_passenger (
    p_first_name    IN CRS_PASSENGER.first_name%TYPE,
    p_middle_name   IN CRS_PASSENGER.middle_name%TYPE,
    p_last_name     IN CRS_PASSENGER.last_name%TYPE,
    p_date_of_birth IN CRS_PASSENGER.date_of_birth%TYPE,
    p_address_line1 IN CRS_PASSENGER.address_line1%TYPE,
    p_address_city  IN CRS_PASSENGER.address_city%TYPE,
    p_address_state IN CRS_PASSENGER.address_state%TYPE,
    p_address_zip   IN CRS_PASSENGER.address_zip%TYPE,
    p_email         IN CRS_PASSENGER.email%TYPE,
    p_phone         IN CRS_PASSENGER.phone%TYPE,
    o_passenger_id  OUT CRS_PASSENGER.passenger_id%TYPE
  ) IS
  BEGIN
    INSERT INTO CRS_PASSENGER (
      passenger_id, first_name, middle_name, last_name, date_of_birth,
      address_line1, address_city, address_state, address_zip, email, phone
    ) VALUES (
      CRS_PASSENGER_SEQ_PK.NEXTVAL, p_first_name, p_middle_name, p_last_name,
      p_date_of_birth, p_address_line1, p_address_city, p_address_state,
      p_address_zip, p_email, p_phone
    ) RETURNING passenger_id INTO o_passenger_id;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20001,'Passenger with same email or phone exists.');
  END add_passenger;

END PKG_CRS_PASSENGER;
/

CREATE OR REPLACE PACKAGE PKG_CRS_RESERVATION AS
  PROCEDURE book_ticket (
    p_passenger_id IN CRS_RESERVATION.passenger_id%TYPE,
    p_train_number IN CRS_TRAIN_INFO.train_number%TYPE,
    p_travel_date  IN DATE,
    p_seat_class   IN CRS_RESERVATION.seat_class%TYPE,
    o_booking_id   OUT CRS_RESERVATION.booking_id%TYPE,
    o_seat_status  OUT CRS_RESERVATION.seat_status%TYPE,
    o_waitlist_pos OUT CRS_RESERVATION.waitlist_position%TYPE
  );

  PROCEDURE cancel_ticket (
    p_booking_id IN CRS_RESERVATION.booking_id%TYPE
  );
END PKG_CRS_RESERVATION;
/