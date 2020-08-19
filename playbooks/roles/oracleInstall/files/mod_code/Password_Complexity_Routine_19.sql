REM Uncomment the check for special characters and modifiy to not permit  @  /  and  &.  The functions should check
REM to see if these characters are used and if used raise an error - "Special characters @, /, and & are not permitted".
REM 
REM Password Complexity Routine
Rem
Rem   -- This script installs the necessary functions and profiles to 
Rem      implement LM Policy IMP-004.
REM
REM      These functions must be created in SYS schema.
REM      connect sys/<password> as sysdba before running the script.
REM       
REM      Please copy this routine to the server where it is to be used
REM      then review and modify to implement.   
Rem
Rem    NAME
Rem     password_complexity_routine.sql - LM script for Policy IMP-004 implementation.
Rem
Rem    DESCRIPTION
Rem      This is a script for installing profiles and enabling the 
Rem      password management features by setting the default password
Rem      resource limits.
Rem
Rem    NOTES
Rem      This file contains default profiles for priviledged, nonpriviledged,
Rem      and batch (service) 
Rem      users and functions for minimum checking of password complexity for
Rem      each of these type users in conformance with Policy IMP-004.
Rem
Rem    MODIFIED   (MM/DD/YY)
REM                12/12/19 CUTLER   - Remove IMPERVA and OPENUSER reference 
REM                10/24/19 CUTLER   - Modified to use with multi-tentant database (cdb/pdb)
REM                01/02/18 BARTON   - Updates per IMP107. Consolidated FUNCTIONS under SERVICE_IDS FUNCTION.
REM                                    Updates for password lenght to 12 and expiration to 180 days.
REM
/* -- This script creates default profiles 
-- for priviledged, nonpriviledged, and batch (service) users.
-- This script sets the default password resource parameters
-- for priviledged, nonpriviledged, and batch (service) users.
-- This script needs to be run to enable the password features.
-- However the default resource parameters can be changed based 
-- on the need.
-- Default password complexity functions are also provided
-- for priviledged, nonpriviledged, and batch (service) users.
-- These function make the minimum complexity checks like
-- the minimum length of the password, password not same as the
-- username, etc. The user may enhance this function according to
-- the need. */
-----------------------------------------------
CREATE OR REPLACE FUNCTION SERVICE_IDS
(username varchar2,
  password varchar2,
  old_password varchar2)
  RETURN boolean IS 
   n boolean;
   m integer;
   differ integer;
   isdigit boolean;
   ischar  boolean;
   ispunct boolean;
   digitarray varchar2(20);
   punctarray varchar2(25);
   chararray varchar2(52);
   min_pw_len integer;

BEGIN 
   min_pw_len:= 12;
   digitarray:= '0123456789';
   chararray:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
   punctarray:='!"#$%()``*+,-:;<=>?_.';

   -- Check if the password is same as the username
   IF NLS_LOWER(password) = NLS_LOWER(username) THEN
     raise_application_error(-20001, 'Password same as or similar to user');
   END IF;

   -- Check for the minimum length of the password
   IF length(password) < min_pw_len THEN
      raise_application_error(-20002, 'Password length less than min_pw_len = 12');
   END IF;

   -- Check if the password is too simple. A dictionary of words may be
   -- maintained and a check may be made so as not to allow the words
   -- that are too simple for the password.
   -- added sap specific words
   IF NLS_LOWER(password) IN ('database', 'password', 'initpass', 'manager', 'change_on_install') THEN
      raise_application_error(-20004, 'Password failed password dictionary test');
   END IF;

   -- Check if the password contains at least one letter, one digit and one
   -- punctuation mark.
   -- 1. Check for the digit
   isdigit:=FALSE;
   m := length(password);
   FOR i IN 1..10 LOOP 
      FOR j IN 1..m LOOP 
         IF substr(password,j,1) = substr(digitarray,i,1) THEN
            isdigit:=TRUE;
             GOTO findchar;
         END IF;
      END LOOP;
   END LOOP;
   IF isdigit = FALSE THEN
      raise_application_error(-20005, 'Password should contain at least one digit, one character and one punctuation');
   END IF;
   -- 2. Check for the character
   <<findchar>>
   ischar:=FALSE;
   FOR i IN 1..length(chararray) LOOP 
      FOR j IN 1..m LOOP 
         IF substr(password,j,1) = substr(chararray,i,1) THEN
            ischar:=TRUE;
             GOTO findpunct;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one digit, one character and one punctuation');
   END IF;
   -- 3. Check for the punctuation
   <<findpunct>>
   ispunct:=FALSE;
   FOR i IN 1..length(punctarray) LOOP 
      FOR j IN 1..m LOOP 
         IF substr(password,j,1) = substr(punctarray,i,1) THEN
            ispunct:=TRUE;
             GOTO endsearch;
         END IF;
      END LOOP;
   END LOOP;
   IF ispunct = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one digit, one character and one punctuation');
   END IF;

   <<endsearch>>
   -- Check if the password differs from the previous password by at least
   -- 3 letters
   IF old_password = '' THEN
      raise_application_error(-20004, 'Old password is null');
   END IF;
   -- Everything is fine; return TRUE ;   
   differ := length(old_password) - length(password);

   IF abs(differ) < 3 THEN
      IF length(password) < length(old_password) THEN
         m := length(password);
      ELSE
         m := length(old_password);
      END IF;
      differ := abs(differ);
      FOR i IN 1..m LOOP
          IF substr(password,i,1) != substr(old_password,i,1) THEN
             differ := differ + 1;
          END IF;
      END LOOP;
      IF differ < 3 THEN
          raise_application_error(-20004, 'Password should differ by at least 3 characters');
      END IF;
   END IF;
   -- Everything is fine; return TRUE ;   
   RETURN(TRUE);
END;
/


CREATE OR REPLACE FUNCTION PROFILE_EXISTS(PROF_NAME VARCHAR2)
 RETURN BOOLEAN 
 IS NUM_PROFILES number := 0;
BEGIN
      SELECT COUNT(DISTINCT PROFILE) INTO NUM_PROFILES FROM DBA_PROFILES WHERE PROFILE = PROF_NAME;
      DBMS_OUTPUT.PUT_LINE ('NUM_PROFILES = '|| TO_CHAR(NUM_PROFILES));
      IF NUM_PROFILES > 0 THEN
       RETURN(TRUE); 
      ELSE
       RETURN(FALSE);
      END IF;
END;
/

SET SERVEROUTPUT ON FORMAT WRAPPED

EXECUTE DBMS_OUTPUT.PUT_LINE ('Begin Create Procedure "DEFINE_PROFILES".');

CREATE OR REPLACE PROCEDURE DEFINE_PROFILES 
  IS
   NUM_USERS NUMBER := 0;
   NUM_PROFILES NUMBER :=0;
BEGIN
    DBMS_OUTPUT.PUT_LINE ('Begin profile block');

    IF PROFILE_EXISTS('VERIFY_PW_NONPRIVILEGED') = TRUE THEN
       DBMS_OUTPUT.PUT_LINE ('Before VERIFY_PW_NONPRIVILEGED DROP PROFILE');
       EXECUTE IMMEDIATE 'DROP PROFILE VERIFY_PW_NONPRIVILEGED CASCADE';
       DBMS_OUTPUT.PUT_LINE ('After VERIFY_PW_NONPRIVILEGED DROP PROFILE');
    END IF;
    EXECUTE IMMEDIATE 'CREATE PROFILE VERIFY_PW_NONPRIVILEGED
          LIMIT SESSIONS_PER_USER   UNLIMITED
          CPU_PER_SESSION           UNLIMITED
          CPU_PER_CALL              UNLIMITED
          CONNECT_TIME              UNLIMITED
          IDLE_TIME                 15
          LOGICAL_READS_PER_SESSION UNLIMITED
          LOGICAL_READS_PER_CALL    UNLIMITED
          COMPOSITE_LIMIT           UNLIMITED
          PRIVATE_SGA               UNLIMITED
          PASSWORD_LIFE_TIME        166
          PASSWORD_GRACE_TIME       14
          PASSWORD_REUSE_TIME       180
          PASSWORD_REUSE_MAX        12
          FAILED_LOGIN_ATTEMPTS     5
          PASSWORD_LOCK_TIME        1/96
          PASSWORD_VERIFY_FUNCTION  SERVICE_IDS';

    IF PROFILE_EXISTS('VERIFY_PW_PRIVILEGED') = TRUE THEN
       DBMS_OUTPUT.PUT_LINE ('Before VERIFY_PW_PRIVILEGED DROP PROFILE');
       EXECUTE IMMEDIATE 'DROP PROFILE VERIFY_PW_PRIVILEGED CASCADE';
       DBMS_OUTPUT.PUT_LINE ('After VERIFY_PW_PRIVILEGED DROP PROFILE');
    END IF;
    EXECUTE IMMEDIATE 'CREATE PROFILE VERIFY_PW_PRIVILEGED
          LIMIT SESSIONS_PER_USER   UNLIMITED
          CPU_PER_SESSION           UNLIMITED
          CPU_PER_CALL              UNLIMITED
          CONNECT_TIME              UNLIMITED
          IDLE_TIME                 15
          LOGICAL_READS_PER_SESSION UNLIMITED
          LOGICAL_READS_PER_CALL    UNLIMITED
          COMPOSITE_LIMIT           UNLIMITED
          PRIVATE_SGA               UNLIMITED
          PASSWORD_LIFE_TIME        166
          PASSWORD_GRACE_TIME       14
          PASSWORD_REUSE_TIME       180
          PASSWORD_REUSE_MAX        12
          FAILED_LOGIN_ATTEMPTS     5
          PASSWORD_LOCK_TIME        1/96
          PASSWORD_VERIFY_FUNCTION  SERVICE_IDS';

    IF PROFILE_EXISTS('VERIFY_PW_SERVICE') = TRUE THEN
       DBMS_OUTPUT.PUT_LINE ('Before VERIFY_PW_SERVICE DROP PROFILE');
       EXECUTE IMMEDIATE 'DROP PROFILE VERIFY_PW_SERVICE CASCADE';
       DBMS_OUTPUT.PUT_LINE ('After VERIFY_PW_SERVICE DROP PROFILE');
    END IF;
    EXECUTE IMMEDIATE 'CREATE PROFILE VERIFY_PW_SERVICE
          LIMIT SESSIONS_PER_USER   UNLIMITED
          CPU_PER_SESSION           UNLIMITED
          CPU_PER_CALL              UNLIMITED
          CONNECT_TIME              UNLIMITED
          IDLE_TIME                 15
          LOGICAL_READS_PER_SESSION UNLIMITED
          LOGICAL_READS_PER_CALL    UNLIMITED
          COMPOSITE_LIMIT           UNLIMITED
          PRIVATE_SGA               UNLIMITED
          PASSWORD_LIFE_TIME        351
          PASSWORD_GRACE_TIME       14
          PASSWORD_REUSE_TIME       180
          PASSWORD_REUSE_MAX        12      
          FAILED_LOGIN_ATTEMPTS     5
          PASSWORD_LOCK_TIME        1/96
          PASSWORD_VERIFY_FUNCTION  SERVICE_IDS';

    IF PROFILE_EXISTS('VERIFY_PW_OPS') = TRUE THEN
       DBMS_OUTPUT.PUT_LINE ('Before VERIFY_PW_OPS DROP PROFILE');
       EXECUTE IMMEDIATE 'DROP PROFILE VERIFY_PW_OPS CASCADE';
       DBMS_OUTPUT.PUT_LINE ('After VERIFY_PW_OPS DROP PROFILE');
    END IF;
    EXECUTE IMMEDIATE 'CREATE PROFILE VERIFY_PW_OPS
          LIMIT SESSIONS_PER_USER   UNLIMITED
          CPU_PER_SESSION           UNLIMITED
          CPU_PER_CALL              UNLIMITED
          CONNECT_TIME              UNLIMITED
          IDLE_TIME                 15
          LOGICAL_READS_PER_SESSION UNLIMITED
          LOGICAL_READS_PER_CALL    UNLIMITED
          COMPOSITE_LIMIT           UNLIMITED
          PRIVATE_SGA               UNLIMITED
          FAILED_LOGIN_ATTEMPTS     5
          PASSWORD_LIFE_TIME        351       
          PASSWORD_REUSE_TIME       180
          PASSWORD_REUSE_MAX        12
          PASSWORD_LOCK_TIME        1/96
          PASSWORD_GRACE_TIME       14
          PASSWORD_VERIFY_FUNCTION  SERVICE_IDS';

    IF PROFILE_EXISTS('VERIFY_PW_LOCKED') = TRUE THEN
       DBMS_OUTPUT.PUT_LINE ('Before VERIFY_PW_LOCKED DROP PROFILE');
       EXECUTE IMMEDIATE 'DROP PROFILE VERIFY_PW_LOCKED CASCADE';
       DBMS_OUTPUT.PUT_LINE ('After VERIFY_PW_LOCKED DROP PROFILE');
    END IF;
    EXECUTE IMMEDIATE 'CREATE PROFILE VERIFY_PW_LOCKED
          LIMIT SESSIONS_PER_USER   UNLIMITED
          CPU_PER_SESSION           UNLIMITED
          CPU_PER_CALL              UNLIMITED
          CONNECT_TIME              UNLIMITED
          IDLE_TIME                 15
          LOGICAL_READS_PER_SESSION UNLIMITED
          LOGICAL_READS_PER_CALL    UNLIMITED
          COMPOSITE_LIMIT           UNLIMITED
          PRIVATE_SGA               UNLIMITED
          PASSWORD_LIFE_TIME        351
          PASSWORD_GRACE_TIME       14
          PASSWORD_REUSE_TIME       180
          PASSWORD_REUSE_MAX        12
          FAILED_LOGIN_ATTEMPTS     5
          PASSWORD_LOCK_TIME        1/96
          PASSWORD_VERIFY_FUNCTION SERVICE_IDS';

    DBMS_OUTPUT.PUT_LINE ('End profile block');

    DBMS_OUTPUT.PUT_LINE ('Username SAP% check');

    SELECT COUNT(1) INTO NUM_USERS FROM DBA_USERS WHERE USERNAME LIKE 'SAP%';
 
    IF NUM_USERS > 0 THEN
      DBMS_OUTPUT.PUT_LINE ('Begin SAP only block');
      IF PROFILE_EXISTS('SAP_PROFILE') = TRUE THEN
         DBMS_OUTPUT.PUT_LINE ('Begin SAP only DROP PROFILE');
         EXECUTE IMMEDIATE 'DROP PROFILE SAP_PROFILE CASCADE';
         DBMS_OUTPUT.PUT_LINE ('After SAP only DROP PROFILE');
      END IF;

      EXECUTE IMMEDIATE 'CREATE PROFILE SAP_PROFILE
          LIMIT SESSIONS_PER_USER   UNLIMITED
          CPU_PER_SESSION           UNLIMITED
          CPU_PER_CALL              UNLIMITED
          CONNECT_TIME              UNLIMITED
          IDLE_TIME                 15
          LOGICAL_READS_PER_SESSION UNLIMITED
          LOGICAL_READS_PER_CALL    UNLIMITED
          COMPOSITE_LIMIT           UNLIMITED
          PRIVATE_SGA               UNLIMITED
          PASSWORD_LIFE_TIME        351
          PASSWORD_GRACE_TIME       14
          PASSWORD_REUSE_TIME       180
          PASSWORD_REUSE_MAX        12
          FAILED_LOGIN_ATTEMPTS     5
          PASSWORD_LOCK_TIME        1/96
          PASSWORD_VERIFY_FUNCTION  SERVICE_IDS';
      DBMS_OUTPUT.PUT_LINE ('End SAP only block'); 
    ELSE 
      DBMS_OUTPUT.PUT_LINE ('Begin EHS only block');

    IF PROFILE_EXISTS('VERIFY_PW_NG_SERVICE') = TRUE THEN
       DBMS_OUTPUT.PUT_LINE ('Before VERIFY_PW_NG_SERVICE DROP PROFILE');
       EXECUTE IMMEDIATE 'DROP PROFILE VERIFY_PW_NG_SERVICE CASCADE';
       DBMS_OUTPUT.PUT_LINE ('After VERIFY_PW_NG_SERVICE DROP PROFILE');
    END IF;
      EXECUTE IMMEDIATE 'CREATE PROFILE VERIFY_PW_NG_SERVICE
          LIMIT SESSIONS_PER_USER   UNLIMITED
          CPU_PER_SESSION           UNLIMITED
          CPU_PER_CALL              UNLIMITED
          CONNECT_TIME              UNLIMITED
          IDLE_TIME                 15
          LOGICAL_READS_PER_SESSION UNLIMITED
          LOGICAL_READS_PER_CALL    UNLIMITED
          COMPOSITE_LIMIT           UNLIMITED
          PRIVATE_SGA               UNLIMITED
          PASSWORD_LIFE_TIME        365
          PASSWORD_GRACE_TIME       0
          PASSWORD_REUSE_TIME       180
          PASSWORD_REUSE_MAX        12
          FAILED_LOGIN_ATTEMPTS     5
          PASSWORD_LOCK_TIME        1/96
          PASSWORD_VERIFY_FUNCTION  SERVICE_IDS';

    IF PROFILE_EXISTS('VERIFY_PW_NG_NONPRIVILEGED') = TRUE THEN
       DBMS_OUTPUT.PUT_LINE ('Begin VERIFY_PW_NG_NONPRIVILEGED DROP PROFILE');
       EXECUTE IMMEDIATE 'DROP PROFILE VERIFY_PW_NG_NONPRIVILEGED CASCADE';
       DBMS_OUTPUT.PUT_LINE ('After VERIFY_PW_NG_NONPRIVILEGED DROP PROFILE');
    END IF;
      EXECUTE IMMEDIATE 'CREATE PROFILE VERIFY_PW_NG_NONPRIVILEGED
          LIMIT SESSIONS_PER_USER   UNLIMITED
          CPU_PER_SESSION           UNLIMITED
          CPU_PER_CALL              UNLIMITED
          CONNECT_TIME              UNLIMITED
          IDLE_TIME                 15
          LOGICAL_READS_PER_SESSION UNLIMITED
          LOGICAL_READS_PER_CALL    UNLIMITED
          COMPOSITE_LIMIT           UNLIMITED
          PRIVATE_SGA               UNLIMITED
          PASSWORD_LIFE_TIME        180 
          PASSWORD_GRACE_TIME       0
          PASSWORD_REUSE_TIME       180
          PASSWORD_REUSE_MAX        12
          FAILED_LOGIN_ATTEMPTS     5
          PASSWORD_LOCK_TIME        1/96
          PASSWORD_VERIFY_FUNCTION  SERVICE_IDS';

    IF PROFILE_EXISTS('VERIFY_PW_NG_PRIVILEGED') = TRUE THEN
       DBMS_OUTPUT.PUT_LINE ('Begin VERIFY_PW_NG_PRIVILEGED DROP PROFILE');
       EXECUTE IMMEDIATE 'DROP PROFILE VERIFY_PW_NG_PRIVILEGED CASCADE';
       DBMS_OUTPUT.PUT_LINE ('After VERIFY_PW_NG_PRIVILEGED DROP PROFILE');
    END IF;
      EXECUTE IMMEDIATE 'CREATE PROFILE VERIFY_PW_NG_PRIVILEGED
          LIMIT SESSIONS_PER_USER   UNLIMITED
          CPU_PER_SESSION           UNLIMITED
          CPU_PER_CALL              UNLIMITED
          CONNECT_TIME              UNLIMITED
          IDLE_TIME                 15
          LOGICAL_READS_PER_SESSION UNLIMITED
          LOGICAL_READS_PER_CALL    UNLIMITED
          COMPOSITE_LIMIT           UNLIMITED
          PRIVATE_SGA               UNLIMITED
          PASSWORD_LIFE_TIME        180 
          PASSWORD_GRACE_TIME       0
          PASSWORD_REUSE_TIME       180
          PASSWORD_REUSE_MAX        12
          FAILED_LOGIN_ATTEMPTS     5
          PASSWORD_LOCK_TIME        1/96
          PASSWORD_VERIFY_FUNCTION  SERVICE_IDS';

    IF PROFILE_EXISTS('VERIFY_PW_NOEXPIRE') = TRUE THEN
       DBMS_OUTPUT.PUT_LINE ('Begin VERIFY_PW_NOEXPIRE DROP PROFILE');
       EXECUTE IMMEDIATE 'DROP PROFILE VERIFY_PW_NOEXPIRE CASCADE';
       DBMS_OUTPUT.PUT_LINE ('After VERIFY_PW_NOEXPIRE DROP PROFILE');
    END IF;
      EXECUTE IMMEDIATE 'CREATE PROFILE VERIFY_PW_NOEXPIRE
          LIMIT SESSIONS_PER_USER   UNLIMITED
          CPU_PER_SESSION           UNLIMITED
          CPU_PER_CALL              UNLIMITED
          CONNECT_TIME              UNLIMITED
          IDLE_TIME                 15
          LOGICAL_READS_PER_SESSION UNLIMITED
          LOGICAL_READS_PER_CALL    UNLIMITED
          COMPOSITE_LIMIT           UNLIMITED
          PRIVATE_SGA               UNLIMITED
          PASSWORD_LIFE_TIME        UNLIMITED
          PASSWORD_GRACE_TIME       0
          PASSWORD_REUSE_TIME       UNLIMITED
          PASSWORD_REUSE_MAX        UNLIMITED
          FAILED_LOGIN_ATTEMPTS     5
          PASSWORD_LOCK_TIME        1/96
          PASSWORD_VERIFY_FUNCTION  SERVICE_IDS';

     DBMS_OUTPUT.PUT_LINE ('End EHS only block');
   END IF;
END DEFINE_PROFILES;
/
EXECUTE DBMS_OUTPUT.PUT_LINE ('About to execute "DEFINE_PROFILES" Procedure.');
EXECUTE DEFINE_PROFILES;
----
ALTER USER ANONYMOUS  IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER APPQOSSYS  IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER CTXSYS     IDENTIFIED BY "January_2019" PROFILE VERIFY_PW_LOCKED;
ALTER USER DBSNMP     IDENTIFIED BY "January_2019" PROFILE VERIFY_PW_SERVICE;
ALTER USER DIP        IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER ORACLE_OCM IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER OUTLN      IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER SYS        IDENTIFIED BY "January_2019" PROFILE VERIFY_PW_SERVICE;
ALTER USER SYSTEM     IDENTIFIED BY "January_2019" PROFILE VERIFY_PW_SERVICE;
ALTER USER XDB        IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_SERVICE;

-- Added on 05/04/16 for 12c accounts
ALTER USER AUDSYS IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER GSMADMIN_INTERNAL IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER GSMCATUSER IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER GSMUSER IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER OJVMSYS IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER SYSBACKUP IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_SERVICE;
ALTER USER SYSDG IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_SERVICE;
ALTER USER SYSKM IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_SERVICE;
ALTER USER SYSRAC IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_SERVICE;

-- Added on 10/24/19 for 19 accounts
ALTER USER DBSFWUSER IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER DVF IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER DVSYS IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER GGSYS IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER GSMROOTUSER IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER LBACSYS IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER MDDATA IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER MDSYS IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER OLAPSYS IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER ORDDATA IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER ORDPLUGINS IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER ORDSYS IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER REMOTE_SCHEDULER_AGENT IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER SI_INFORMTN_SCHEMA IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER SYS$UMF IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;
ALTER USER WMSYS IDENTIFIED BY "IPM107_Jan19" PROFILE VERIFY_PW_LOCKED;

SELECT USERNAME, PROFILE, ACCOUNT_STATUS, EXPIRY_DATE FROM DBA_USERS;
