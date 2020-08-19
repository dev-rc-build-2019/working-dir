REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
REM * Filename:    audit_system.sql
REM * Author:      Andy Schmersahl
REM * Description: This script implements system-level auditing.
REM *
REM * Date       Name            Description
REM * ---------- --------------- ---------------------------------------------
REM * 05/01/2017 Renee Cutler    Add new audit requirements for DAVS 
REM * 08/22/2016 Renee Cutler    Add new audit requirements for DAVs
REM * 09/05/2004 Andy Schmersahl Created.
REM *
REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
SET DEFINE OFF
SET ECHO ON
REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
AUDIT ADMINISTER DATABASE TRIGGER;
AUDIT ALTER ANY CLUSTER;
AUDIT ALTER ANY DIMENSION;
AUDIT ALTER ANY INDEX;
AUDIT ALTER ANY INDEXTYPE;
AUDIT ALTER ANY LIBRARY;
AUDIT ALTER ANY OPERATOR;
AUDIT ALTER ANY OUTLINE;
AUDIT ALTER ANY PROCEDURE;
AUDIT ALTER ANY ROLE;
AUDIT ALTER ANY SEQUENCE;
AUDIT ALTER ANY SNAPSHOT;
AUDIT ALTER ANY TABLE;
AUDIT ALTER ANY TRIGGER;
AUDIT ALTER ANY TYPE;
AUDIT ALTER DATABASE;
AUDIT ALTER PROFILE;
AUDIT ALTER RESOURCE COST;
AUDIT ALTER SESSION;
AUDIT ALTER SYSTEM;
AUDIT ALTER USER;
AUDIT ANALYZE ANY;
AUDIT AUDIT ANY;
AUDIT BACKUP ANY TABLE;
AUDIT BECOME USER;
AUDIT COMMENT ANY TABLE;
AUDIT CREATE ANY CLUSTER;
AUDIT CREATE ANY CONTEXT;
AUDIT CREATE ANY DIMENSION;
AUDIT CREATE ANY DIRECTORY;
AUDIT CREATE ANY INDEX;
AUDIT CREATE ANY INDEXTYPE;
AUDIT CREATE ANY JOB;
AUDIT CREATE ANY LIBRARY;
AUDIT CREATE ANY OPERATOR;
AUDIT CREATE ANY OUTLINE;
AUDIT CREATE ANY PROCEDURE;
AUDIT CREATE ANY SEQUENCE;
AUDIT CREATE ANY SNAPSHOT;
AUDIT CREATE ANY SYNONYM;
AUDIT CREATE ANY TABLE;
AUDIT CREATE ANY TRIGGER;
AUDIT CREATE ANY TYPE;
AUDIT CREATE ANY VIEW;
AUDIT CREATE DATABASE LINK;
AUDIT CREATE DIMENSION;
AUDIT CREATE INDEXTYPE;
AUDIT CREATE LIBRARY;
AUDIT CREATE OPERATOR;
AUDIT CREATE PROCEDURE;
AUDIT CREATE ROLE;
AUDIT CREATE SESSION;
AUDIT CREATE SNAPSHOT;
AUDIT CREATE USER;
AUDIT DROP ANY CLUSTER;
AUDIT DROP ANY CONTEXT;
AUDIT DROP ANY DIMENSION;
AUDIT DROP ANY DIRECTORY;
AUDIT DROP ANY INDEX;
AUDIT DROP ANY LIBRARY;
AUDIT DROP ANY OPERATOR;
AUDIT DROP ANY OUTLINE;
AUDIT DROP ANY PROCEDURE;
AUDIT DROP ANY ROLE;
AUDIT DROP ANY SEQUENCE;
AUDIT DROP ANY SNAPSHOT;
AUDIT DROP ANY SYNONYM;
AUDIT DROP ANY TABLE;
AUDIT DROP ANY TRIGGER;
AUDIT DROP ANY TYPE;
AUDIT DROP ANY VIEW;
AUDIT DROP USER;
AUDIT DEBUG PROCEDURE;
AUDIT EXEMPT ACCESS POLICY;
AUDIT FORCE ANY TRANSACTION;
AUDIT GLOBAL QUERY REWRITE;
AUDIT GRANT ANY OBJECT PRIVILEGE BY ACCESS;
AUDIT GRANT ANY PRIVILEGE;
AUDIT GRANT ANY ROLE;
AUDIT MANAGE TABLESPACE;
AUDIT PUBLIC DATABASE LINK;
AUDIT QUERY REWRITE;
AUDIT RESTRICTED SESSION;
AUDIT UNLIMITED TABLESPACE;
