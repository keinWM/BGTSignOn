**FREE
// ---------------------------------------------------------------
// Programa : BGTPWDEXP
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-18
// Objetivo : Validacion del Cambio de Clave - BGTSIGNON
// Proyecto : BGTSIGNON
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no);

dcl-f MSGINF Workstn;
dcl-f MSGCONF Workstn;
dcl-f CHGPWD Workstn;

dcl-pi *n;
  pUser char(10);
  pSysName char(10);
end-pi;

USER = pUser;
SYSNAME = pSysName;
DATE = %char(%date() : *dmy);
TIME = %char(%time() : *hms);

dow *on;

  RESP = 'Y';

  exfmt INFORMAT;

  if *in03;
    exfmt CONFIRM;

    if *in12;
      iter;
    elseif RESP = 'Y';
      leave;
    endif;

    iter;
  endif;

  exfmt CHANGEPWD;
enddo;

*inlr = *on;

return;