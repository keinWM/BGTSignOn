**FREE
// ---------------------------------------------------------------
// Programa : BGTSIGNON
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-11
// Objetivo : Inicio de Sesion al IBM i - BGTSIGNON
// Proyecto : AdminSBS
// Version  : 1.0
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no);

dcl-f BGTSIGNON workstn;

dou *in03;

  exfmt MENU01;

enddo;

*inlr = *on;

return;