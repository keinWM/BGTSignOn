**FREE
// ---------------------------------------------------------------
// Programa : BGTSIGNON
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-11
// Objetivo : Inicio de Sesion al QSYGETPH - BGTSIGNON
// Proyecto : BGTSIGNON
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no);

dcl-f BGTSIGNON workstn;

// Declaracion Prototipos
dcl-pr BGTAUTH extpgm('BGTAUTH'); // RPGLE
  pUser char(10);
  pPass char(10);
  pResult char(1);
end-pr;
dcl-pr BGTGETPRF extpgm('BGTGETPRF'); // CLLE
  pUser char(10);
  pInlPgm char(20);
  pInlMnu char(10);
end-pr;
dcl-pr BGTSIGNLOG extpgm('BGTSIGNLOG'); // RPGLE
  pUser char(10);
  pDate char(08);
  pTime char(08);
  pDspName char(11);
  pResult char(20) const;
end-pr;
dcl-pr RTVSIGN extpgm('RTVSIGNON'); // CLLE
  pSysName char(10);
  pJobName char(11);
  PSubSys char(10);
end-pr;
dcl-pr BGTPWDEXP extpgm('BGTPWDEXP');
  pUser char(10);
end-pr;
dcl-pr QCMDEXC extpgm('QCMDEXC'); // API de IBM i
  Command char(3000) const options(*varsize);
  Length packed(15:5) const;
  DBCS char(3) const options(*nopass);
end-pr;
// Declaracion Prototipos

// Declaracion Variables
dcl-s AuthResult char(1);
dcl-s InlPgm char(20);
dcl-s InlMnu char(10);
dcl-s Cmd char(50);
// Declaracion Variables

// Informacion de IBM (dinámica)
RTVSIGN(SYSNAME : JOBNAME : SUBSYS);

select;
  when %subst(SYSNAME:1:1) = 'P';
    ENVIRON = 'PRODUCCION';
  when %subst(SYSNAME:1:1) = 'Q';
    ENVIRON = 'CALIDAD';
  when %subst(SYSNAME:1:1) = 'D';
    ENVIRON = 'DESARROLLO';
endsl;

DATE = %char(%date() : *dmy);
TIME = %char(%time() : *hms);
// Informacion de IBM (dinámica)


// Bucle Principal
dou *in03 or *in12;

  // Limpiar Campo de Contraseña
  PASS = *blanks;
  
  exfmt SIGNON;

  // Salir del Sign On al presionar F3 o F12
  if *in03 or *in12;
    leave;
  endif;
  // Salir del Sign On al presionar F3 o F12

  clear MSGTXT;

  // Validar Campos Vacíos
  if %trim(USER) = *blanks and %trim(PASS) = *blanks;
    MSGTXT = 'Se Requiere Información de Inicio de Sesión.';
    iter;
  elseif %trim(USER) = *blanks;
    MSGTXT = 'Debe Ingresar un Usuario.';
    iter;
  elseif %trim(PASS) = *blanks;
    MSGTXT = 'Debe Ingresar una Contraseña.';
    iter;
  endif;
  // Validar Campos Vacíos

  // Validacion de Usuario y Contraseña
  BGTAUTH(USER : PASS : AuthResult);
  select;
    when AuthResult = '1';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'SUCCESS');
    when AuthResult = '3';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'PROFILE_DISABLED');
      MSGTXT = 'Perfil Deshabilitado';
      iter;
    when AuthResult = '4';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'PASSWORD_EXPIRED');

      BGTPWDEXP(USER);

      clear USER;
      
      iter;
    other;
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'FAIL');
      MSGTXT = 'Usuario o Contraseña Incorrectos.';
      iter;
  endsl;
  // Validacion de Usuario y Contraseña

  // Validacion del Programa o Menu Inicial del Usuario
  BGTGETPRF(USER : InlPgm : InlMnu);
  if %trim(InlPgm) <> '*NONE';
    Cmd = 'CALL ' + %trim(InlPgm);
  else;
    Cmd = 'GO ' + %trim(InlMnu);
  endif;
  // Validacion del Programa o Menu Inicial del Usuario

  QCMDEXC(Cmd : %len(%trim(Cmd)) : ' ');

  leave;

enddo;
// Bucle Principal

*inlr = *on;

return;