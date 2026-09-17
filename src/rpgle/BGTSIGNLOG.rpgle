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
  pDate char(10);
  pTime char(10);
  pDspName char(11);
  pResult char(1);
end-pi;

USER = pUser;
LOGDATE = pDate;
LOGTIME = pTime;
DSPNAME = pDspName;
RESULT = pResult;

write SIGNONR;

*inlr = *on;

return;