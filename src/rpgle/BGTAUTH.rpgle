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

// pi - Procedure Interface
dcl-pi *n;
  pUser char(10);
  pPass char(10);
  pResult char(2);
end-pi;
// pi - Procedure Interface

// API Error
dcl-ds QUSEC qualified;
  BytesProv int(10) inz(%size(QUSEC));
  BytesAvail int(10) inz(0);
  MsgId char(7);
  Reserved char(1);
  MsgData char(128);
end-ds;
// API Error

// API Prototypes
dcl-pr QSYGETPH extpgm('QSYGETPH'); // Validar USER, PASS y obtener Handle
  UserId char(10) const;
  Password char(10) const;
  ProfileHdl char(12);
  ErrorCode likeDS(QUSEC);
  PasswordLen int(10) const;
  CCSID int(10) const;
end-pr;
dcl-pr QWTSETP extpgm('QWTSETP'); // Adopta el perfil por medio del Handle obtenido
  ProfileHdl char(12);
  ErrorCode likeDS(QUSEC);
end-pr;
dcl-pr QSYRLSPH extpgm('QSYRLSPH'); // Liberar el Handle
  ProfileHdl char(12);
  ErrorCode likeDS(QUSEC);
end-pr;
// API Prototypes

// Variables
dcl-s ProfileHandle char(12) inz(*blanks);
dcl-s PasswordLen int(10);
dcl-s CCSID int(10) inz(37);

// Longitud de contraseña
PasswordLen = %len(%trim(pPass));

clear QUSEC;
QUSEC.BytesProv = %size(QUSEC);

QSYGETPH(pUser : pPass : ProfileHandle : QUSEC : PasswordLen : CCSID);

if QUSEC.BytesAvail > 0;
  select;
    when QUSEC.MsgId = 'CPF22E3'; // PROFILE_DISABLED
      pResult = 'E3';
    when QUSEC.MsgId = 'CPF22E4'; // PASSWORD_EXPIRED
      pResult = 'E4';
    when QUSEC.MsgId = 'CPF22E5'; // NOT_PASSWORD
      pResult = 'E5';
    other;
      pResult = '00'; // FAIL
  endsl;
else;
  clear QUSEC;
  QUSEC.BytesProv = %size(QUSEC);

  QWTSETP(ProfileHandle : QUSEC);

  if QUSEC.BytesAvail > 0;
    pResult = '00'; // FAIL
  else;
    pResult = '01'; // SUCCESS
  endif;
endif;

// Liberar Profile Handle
if ProfileHandle <> *blanks;
  clear QUSEC;
  QUSEC.BytesProv = %size(QUSEC);

  QSYRLSPH(ProfileHandle : QUSEC);

  clear ProfileHandle;
endif;

*inlr = *on; // lr - Last Record

return; // Para regresar al programa que lo llamo