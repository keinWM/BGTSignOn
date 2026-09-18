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
end-pi;

dcl-pr QCMDEXC extpgm('QCMDEXC'); // API de IBM i
  Command char(3000) const options(*varsize);
  Length packed(15:5) const;
end-pr;

dcl-s Cmd char(50);

dow *on;

  RESP = 'Y';
  
  exfmt MENU02;

  if *in03;
    exfmt MENU03;

    if *in12;
      iter;
    elseif RESP = 'Y';
      leave;
    endif;

    iter;
  endif;

  dsply pUser;

  exfmt MENU04;
enddo;

*inlr = *on;

return;