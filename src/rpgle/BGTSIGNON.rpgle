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

dcl-pr BGTUSRCHK extpgm('BGTUSRCHK');
  pUser char(10);
  pResult char(1);
end-pr;
dcl-pr BGTAUTH extpgm('BGTAUTH');
  pUser char(10);
  pPass char(10);
  pResult char(1);
end-pr;
dcl-pr RTVSYS extpgm('RTVSIGNON');
  pSys char(10);
end-pr;

dcl-s UserExists char(1);
dcl-s AuthResult char(1);

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

  BGTUSRCHK(USER : UserExists);
  if UserExists <> '1';
    MSGTXT = 'El Usuario no Existe.';
    iter;
  endif;

  BGTAUTH(USER : PASS : AuthResult);
  if AuthResult <> '1';
    MSGTXT = 'Usuario o Contrase¦a Incorrectos.';
    iter;
  endif;
  MSGTXT = 'Autenticación Exitosa';
  iter;

enddo;
// BUCLE PRINCIPAL

*inlr = *on;

return;