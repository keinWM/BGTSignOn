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
  pJobNA char(30);
end-pi;

dcl-s SQLCount packed(3:0) inz(0);

clear pActSess;
clear pJobNA;

exec sql
  SELECT COUNT (*)
  INTO :SQLCount
  FROM TABLE(QSYS2.ACTIVE_JOB_INFO())
  WHERE AUTHORIZATION_NAME = :pUser
    AND JOB_TYPE = 'INT';

if SQLCODE = 0;
  pActSess = SQLCount;
endif;

exec sql
  SELECT JOB_NAME
  INTO   :pJobNA
  FROM TABLE(QSYS2.ACTIVE_JOB_INFO())
  WHERE AUTHORIZATION_NAME = :pUser
    AND JOB_TYPE = 'INT'
    AND JOB_NAME_SHORT = :pCurrentJob
  FETCH FIRST 1 ROW ONLY;

if SQLCODE <> 0;
  clear pJobNA;
endif;

*inlr = *on;

return;