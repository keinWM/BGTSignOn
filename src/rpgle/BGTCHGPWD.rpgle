**FREE
// ---------------------------------------------------------------
// Programa : BGTCHGPWD
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-25
// Objetivo : Cambio de contraseña - BGTSIGNON
// Proyecto : BGTSignOn
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no);

dcl-pi *n;
  pUser char(10);
  pPass char(10);
  pPassnew char(10);
  pPassnewV char(10);
  pResult char(1);
  pMsgId char(128);
end-pi;


*inlr = *on;

return;