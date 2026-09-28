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
  pResult char(2);
end-pi;

dcl-ds APIERROR qualified;
  BytesProv int(10) inz(%size(APIERROR));
  BytesAvail int(10) inz(0);
  MsgId char(7);
  Reserved char(1);
  MsgData char(128);
end-ds;

dcl-pr QSYCHGPW extpgm('QSYCHGPW');
  UserId char(10) const;
  CurrentPass char(10) const;
  NewPass char(10) const;
  ErrorCode likeDS(APIERROR);
end-pr;

clear pResult;
clear APIERROR;

APIERROR.BytesProv = %size(APIERROR);

QSYCHGPW('*CURRENT' : pPass : pPassNew : APIERROR);

if APIERROR.BytesAvail > 0;
  select;
    when APIERROR.MsgId = 'CPF22E2'; // Password actual incorrecto
      pResult = 'E2';
    when APIERROR.MsgId = 'CPD2356'; // Password nueva igual al actual
      pResult = '56';
    when APIERROR.MsgId = 'CPF22C2'; // Menor a longitud mínima
      pResult = 'C2';
    when APIERROR.MsgId = 'CPF22C3'; // Mayor a longitud permitida
      pResult = 'C3';
    when APIERROR.MsgId = 'CPF22C4'; // Password utilizada anteriormente
      pResult = 'C4';
    when APIERROR.MsgId = 'CPF22C8'; // Misma posición de carácter que password actual
      pResult = 'C8';
    when APIERROR.MsgId = 'CPF22D0'; // Caracteres repetidos consecutivamente
      pResult = 'D0';
    other;
      pResult = '00'; // Error genérico
  endsl;
else;
  pResult = '01'; // Cambio exitóso
endif;

*inlr = *on;

return;