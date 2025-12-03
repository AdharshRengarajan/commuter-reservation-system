SET SERVEROUTPUT ON;

------------------------------------------------------------
-- 1. CREATE ROLE
------------------------------------------------------------
DECLARE
role_name VARCHAR2(30);
BEGIN
    role_name := 'CRS_APP_ROLE';

BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE ' || role_name;
DBMS_OUTPUT.PUT_LINE('Role ' || role_name || ' created successfully.');
EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1921 THEN
                DBMS_OUTPUT.PUT_LINE('Role ' || role_name || ' already exists. Skipping...');
ELSE
                RAISE;
END IF;
END;

    -- Grant CREATE SESSION to the role
EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO CRS_APP_ROLE';
DBMS_OUTPUT.PUT_LINE('Granted CREATE SESSION to CRS_APP_ROLE.');
END;
/

------------------------------------------------------------
-- 2. CREATE CRS_ADMIN USER 
------------------------------------------------------------
DECLARE
user_exists NUMBER := 0;
BEGIN
SELECT COUNT(*) INTO user_exists
FROM all_users WHERE username = 'CRS_ADMIN';

IF user_exists = 0 THEN
        EXECUTE IMMEDIATE '
            CREATE USER CRS_ADMIN IDENTIFIED BY "Password#123"
            DEFAULT TABLESPACE USERS
            TEMPORARY TABLESPACE TEMP
            QUOTA UNLIMITED ON USERS
        ';

EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO CRS_ADMIN';

EXECUTE IMMEDIATE '
GRANT CREATE TABLE,
CREATE VIEW,
CREATE SEQUENCE,
CREATE PROCEDURE,
CREATE TRIGGER,
CREATE SYNONYM
            TO CRS_ADMIN
';

DBMS_OUTPUT.PUT_LINE('User CRS_ADMIN created with full privileges.');
ELSE
        DBMS_OUTPUT.PUT_LINE('User CRS_ADMIN already exists. Skipping creation...');
END IF;
END;
/
------------------------------------------------------------


------------------------------------------------------------
-- 3. CREATE CRS_APP USER
------------------------------------------------------------
DECLARE
user_exists NUMBER := 0;
BEGIN
SELECT COUNT(*) INTO user_exists
FROM all_users WHERE username = 'CRS_APP';

IF user_exists = 0 THEN
        EXECUTE IMMEDIATE '
            CREATE USER CRS_APP IDENTIFIED BY "Password#123"
            DEFAULT TABLESPACE USERS
            TEMPORARY TABLESPACE TEMP
            QUOTA UNLIMITED ON USERS
        ';
        DBMS_OUTPUT.PUT_LINE('User CRS_APP created.');
ELSE
        DBMS_OUTPUT.PUT_LINE('User CRS_APP already exists. Skipping creation...');
END IF;

    -- Grant CRS_APP_ROLE to CRS_APP
EXECUTE IMMEDIATE 'GRANT CRS_APP_ROLE TO CRS_APP';
DBMS_OUTPUT.PUT_LINE('Granted CRS_APP_ROLE to CRS_APP.');

    -- Grant CREATE SYNONYM to CRS_APP
EXECUTE IMMEDIATE 'GRANT CREATE SYNONYM TO CRS_APP';
DBMS_OUTPUT.PUT_LINE('Granted CREATE SYNONYM to CRS_APP.');
END;
/