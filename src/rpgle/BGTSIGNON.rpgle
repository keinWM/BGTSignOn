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
DATED = '11/09/2026';
HOUR = '12:00';
SUBSYS = 'QINTER';
SCREEN = 'QPADEV002F';

dou *in03 or *in12;

  exfmt MENU01;

enddo;

*inlr = *on;

return;