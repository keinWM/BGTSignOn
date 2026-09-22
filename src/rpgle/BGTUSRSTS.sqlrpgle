**FREE
// ---------------------------------------------------------------
// Programa : BGTUSRSTS
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-21
// Objetivo : Validar el estado del usuario - BGTSIGNON
// Proyecto : BGTSIGNON
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no);

exec sql
  include sqlca;

dcl-pi *n;
  pUser char(10);            // AUTHORIZATION_NAME
  pPreSignOn timestamp;      // PREVIOUS_SIGNON
  pPassChgDate timestamp;    // PASSWORD_CHANGE_DATE
  pDaysExp zoned(3:0);       // DAYS_EXPIRATION
  pPassExp char(3);          // SET_PASSWORD_TO_EXPIRE
  pStatus char(10);           // STATUS
  pSignOnInvalid zoned(3:0);  // SIGN_ON_ATTEMPTS_NOT_VALID
end-pi;

exec sql
  select 
    PREVIOUS_SIGNON,
    PASSWORD_CHANGE_DATE,
    COALESCE(DAYS(DATE_PASSWORD_EXPIRES) - DAYS(CURRENT_DATE), 0),
    SET_PASSWORD_TO_EXPIRE,
    STATUS,
    SIGN_ON_ATTEMPTS_NOT_VALID
  into
    :pPreSignOn,
    :pPassChgDate,
    :pDaysExp,
    :pPassExp,
    :pStatus,
    :pSignOnInvalid
  from QSYS2.USER_INFO
  where AUTHORIZATION_NAME = :pUser;

*inlr = *on;

return;