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
  pMsgId char(7);
end-pi;

dcl-pr QSYCHGPW extpgm('QSYCHGPW');
  UserId char(10) const;
  CurrentPass char(10) const;
  NewPass char(10) const;
  ErrorCode likeDS(APIERROR);
end-pr;

dcl-ds APIERROR qualified;
  BytesProv int(10) inz(%size(APIERROR));
  BytesAvail int(10) inz(0);
  MsgId char(7);
  Reserved char(1);
  MsgData char(128);
end-ds;

clear APIERROR;

APIERROR.BytesProv = %size(APIERROR);

QSYCHGPW('*CURRENT' : pPass : pPassNew : APIERROR);

dsply ('MsgId = ' + APIERROR.MsgId);

*inlr = *on;

return;