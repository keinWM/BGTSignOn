**FREE
// ---------------------------------------------------------------
// Programa : BGTSIGNON
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-11
// Objetivo : Inicio de Sesion al QSYGETPH - BGTSIGNON
// Proyecto : BGTSIGNON
// Version  : 1.0
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no);

dcl-f BGTSIGNON workstn;

dcl-pr BGTAUTH extpgm('BGTAUTH');
  pUser char(10);
  pPass char(10);
  pResult char(1);
end-pr;
dcl-pr BGTGETPRF extpgm('BGTGETPRF');
  pUser char(10);
  pInlPgm char(20);
  pInlMnu char(10);
end-pr;
dcl-pr QCMDEXC extpgm('QCMDEXC');
  Command char(3000) const options(*varsize);
  Length packed(15:5) const;
end-pr;
dcl-pr RTVSYS extpgm('RTVSIGNON');
  pSys char(10);
end-pr;

dcl-s AuthResult char(1);
dcl-s InlPgm char(20);
dcl-s InlMnu char(10);
dcl-s Cmd char(50);

RTVSYS(SYSNAME);
DATED = '16/09/2026';
HOUR = '12:00';
SUBSYS = 'QINTER';
SCREEN = 'QPADEV002F';

// BUCLE PRINCIPAL
dou *in03 or *in12;

  PASS = *blanks;
  
  exfmt MENU01;

  if *in03 or *in12;
    leave;
  endif;

  clear MSGTXT;

  if %trim(USER) = *blanks and %trim(PASS) = *blanks;
    MSGTXT = 'Se requiere información de inicio de sesión.';
    iter;
  elseif %trim(USER) = *blanks;
    MSGTXT = 'Debe Ingresar Usuario.';
    iter;
  elseif %trim(PASS) = *blanks;
    MSGTXT = 'Debe Ingresar Contrase¦a.';
    iter;
  endif;

  BGTAUTH(USER : PASS : AuthResult);
  if AuthResult <> '1';
    MSGTXT = 'Usuario o Contrase¦a Incorrectos.';
    iter;
  endif;

  BGTGETPRF(USER : InlPgm : InlMnu);
  if %trim(InlPgm) <> '*NONE';
    Cmd = 'CALL ' + %trim(InlPgm);
    QCMDEXC(Cmd : %len(%trim(Cmd)));
  else;
    Cmd = 'GO ' + %trim(InlMnu);
    QCMDEXC(Cmd : %len(%trim(Cmd)));
  endif;

  leave;

enddo;
// BUCLE PRINCIPAL

*inlr = *on;

return;