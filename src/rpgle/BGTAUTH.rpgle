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

dcl-pi *n; // pi - Procedure Interface
  pUser char(10);
  pPass char(10);
  pResult char(1);
end-pi;

dcl-ds QUSEC qualified;
  BytesProv int(10) inz(%size(QUSEC));
  BytesAvail int(10) inz(0);
  MsgId char(7);
  Reserved char(1);
  MsgData char(128);
end-ds;

dcl-pr QSYGETPH extpgm('QSYGETPH');
  UserId char(10) const;
  Password char(10) const;
  ProfileHdl char(12);
  ErrorCode likeDS(QUSEC);
  PasswordLen int(10) const;
  CCSID int(10) const;
end-pr;

dcl-pr QSYRLSPH extpgm('QSYRLSPH');
  ProfileHdl char(12);
  ErrorCode likeDS(QUSEC);
end-pr;

dcl-s ProfileHandle char(12);
dcl-s PasswordLen int(10);
dcl-s CCSID int(10) inz(37);

PasswordLen = 10;

QSYGETPH(pUser : pPass : ProfileHandle : QUSEC : PasswordLen : CCSID);

dsply ('HANDLE=' + ProfileHandle);

if QUSEC.BytesAvail > 0;
  pResult = '0'; // ERROR
else;
  pResult = '1'; // OK

  clear QUSEC;
  QUSEC.BytesProv = %size(QUSEC);

  QSYRLSPH(ProfileHandle : QUSEC);

  dsply ('RLSPH ERR=' + %char(QUSEC.BytesAvail));
  dsply ('RLSPH MSG=' + QUSEC.MsgId);
endif;

*inlr = *on; // lr - Last Record

return; // Para regresar al programa que lo llamo