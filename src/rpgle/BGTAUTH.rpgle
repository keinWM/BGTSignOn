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
dcl-pr QWTSETP extpgm('QWTSETP');
  ProfileHdl char(12);
  ErrorCode likeDS(QUSEC);
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

// dsply ('MSGID = ' + QUSEC.MsgId);

if QUSEC.BytesAvail > 0;

  select;
    when QUSEC.MsgId = 'CPF22E3'; // PROFILE_DISABLED
      pResult = '3';
    when QUSEC.MsgId = 'CPF22E4'; // PASSWORD_EXPIRED
      dsply ProfileHandle;
      pResult = '4';
    other;
      pResult = '0';
  endsl;

else;

  pResult = '1'; // OK

  clear QUSEC;

  QUSEC.BytesProv = %size(QUSEC);

  QWTSETP(ProfileHandle : QUSEC);

  if QUSEC.BytesAvail > 0;
    select;
      when QUSEC.MsgId = 'CPF22E3'; // PROFILE_DISABLED
        pResult = '3';
      when QUSEC.MsgId = 'CPF22E4'; // PASSWORD_EXPIRED
        pResult = '4';
      other;
        pResult = '0';
    endsl;
  else;
    pResult = '1';
  endif;

  // QSYRLSPH(ProfileHandle : QUSEC);
endif;

*inlr = *on; // lr - Last Record

return; // Para regresar al programa que lo llamo