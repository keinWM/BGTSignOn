**FREE
// ---------------------------------------------------------------
// Programa : BGTSIGNON
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-11
// Objetivo : Inicio de Sesion al IBM i - BGTSIGNON
// Proyecto : BGTSIGNON
// Version  : 1.0
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no);

dcl-f BGTSIGNON workstn;

dcl-pr RTVSYS extpgm('RTVSIGNON');
  pSys char(10);
end-pr;

RTVSYS(SYSNAME);
DATED = '16/09/2026';
HOUR = '12:00';
SUBSYS = 'QINTER';
SCREEN = 'QPADEV002F';

dou *in03 or *in12;
  
  USER = *blanks;
  PASS = *blanks;

  exfmt MENU01;

  if *in03 or *in12;
    leave;
  endif;

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

enddo;

*inlr = *on;

return;