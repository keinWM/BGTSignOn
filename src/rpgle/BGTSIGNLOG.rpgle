**FREE
// ---------------------------------------------------------------
// Programa : BGTSIGNLOG
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-17
// Objetivo : Llenar de el PF SIGNONLOG - BGTSIGNON
// Proyecto : BGTSIGNON
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no);

dcl-f SIGNONLOG usage(*output);

dcl-pi *n;
  pUser char(10);
  pResult char(1);
end-pi;

dcl-s Fecha char(10);
dcl-s Hora char(10);

Fecha = %char(%date());
Hora = %char(%time());

USER = pUser;
LOGDATE = Fecha;
LOGTIME = Hora;
DSPNAME = 'QPADEV002F';
RESULT = pResult;

write SIGNONR;

*inlr = *on;

return;