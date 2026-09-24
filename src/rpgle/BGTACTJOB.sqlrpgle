**FREE
// ---------------------------------------------------------------
// Programa : BGTACTJOB
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-23
// Objetivo : Validar si el usuario tiene sesiones activas - BGTSIGNON
// Proyecto : BGTSignOn
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no) option(*srcstmt : *nodebugio);

exec sql
  set option commit = *none,
  closqlcsr = *endmod;

dcl-pi *n;
  pUser char(10);
  pCurrentJob char(10);
  pActSess packed(2:0);
  pLimitSess char(10);
  pJobNA char(30);
end-pi;

dcl-s SQLCount packed(2:0) inz(0);

clear pActSess;
clear pLimitSess;
clear pJobNA;

exec sql
  select COUNT (*)
  into :SQLCount
  from TABLE(QSYS2.ACTIVE_JOB_INFO())
  where AUTHORIZATION_NAME = :pUser
    and JOB_TYPE = 'INT';

if SQLCODE = 0;
  pActSess = SQLCount;
endif;

exec sql
  select LIMIT_DEVICE_SESSIONS
  into :pLimitSess
  from QSYS2.USER_INFO
  where AUTHORIZATION_NAME = :pUser;

if SQLCODE <> 0;
  clear pLimitSess;
endif;

exec sql
  select JOB_NAME
  into   :pJobNA
  from TABLE(QSYS2.ACTIVE_JOB_INFO())
  where AUTHORIZATION_NAME = :pUser
    and JOB_TYPE = 'INT'
    and JOB_NAME_SHORT = :pCurrentJob
  fetch FIRST 1 row only;

if SQLCODE <> 0;
  clear pJobNA;
endif;

*inlr = *on;

return;