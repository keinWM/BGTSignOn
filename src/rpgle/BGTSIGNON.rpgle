**FREE
// ---------------------------------------------------------------
// Programa : BGTSIGNON
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-11
// Objetivo : Inicio de Sesion al QSYGETPH - BGTSIGNON
// Proyecto : BGTSIGNON
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no);

// Declaracion Vistas
dcl-f BGTSIGNON workstn;
dcl-f CHGPWD workstn;
dcl-f MSGCONF workstn;
dcl-f MSGINF workstn;
dcl-f PWDRULES workstn;
// Declaracion Vistas

// Declaracion Prototipos
dcl-pr BGTAUTH extpgm('BGTAUTH'); // RPGLE
  pUser char(10);
  pPass char(10);
  pResult char(1);
end-pr;
dcl-pr BGTGETPRF extpgm('BGTGETPRF'); // CLLE
  pUser char(10);
  pInlPgm char(10);
  pInlMnu char(10);
end-pr;
dcl-pr BGTSIGNLOG extpgm('BGTSIGNLOG'); // RPGLE
  pUser char(10);
  pDate char(08);
  pTime char(08);
  pJobName char(10);
  pResult char(20) const;
end-pr;
dcl-pr BGTUSRSTS extpgm('BGTUSRSTS');
  pUser char(10);
  pPreSignOn char(19);
  pPassChgDate char(19);
  pDatePassExp char(19);
  pDaysExp char(2);
  pPassExp char(3);
  pStatus char(8);
  pSignOnInvalid char(1);
end-pr;
dcl-pr RTVSIGN extpgm('RTVSIGNON'); // CLLE
  pSysName char(10);
  pJobName char(10);
  PSubSys char(10);
end-pr;
dcl-pr QCMDEXC extpgm('QCMDEXC'); // API de IBM i
  Command char(3000) const options(*varsize);
  Length packed(15:5) const;
end-pr;
// Declaracion Prototipos

// Declaracion Variables
dcl-s AuthResult char(1);
dcl-s InlPgm char(20);
dcl-s InlMnu char(10);
dcl-s Cmd char(50);
// Declaracion Variables

dcl-s pPreSignOn timestamp;
dcl-s pPassChgDate timestamp;
dcl-s pDaysExp zoned(3:0);
dcl-s pPassExp char(3);
dcl-s pStatus char(10);
dcl-s pSignOnInvalid zoned(3:0);

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

// BGTUSRSTS(USER : pPreSignOn : pPassChgDate : pDaysExp : pPassExp: pStatus : pSignOnInvalid);
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

  // Limpiar Variables MSGTXT
  clear MSGTXT;

  // Validar Campos Vacíos
  if %trim(USER) = *blanks and %trim(PASS) = *blanks;
    MSGTXT = 'Se Requiere Información de Inicio de Sesión.';
    iter;
  elseif %trim(USER) = *blanks;
    MSGTXT = 'Debe Ingresar un Usuario.';
    iter;
  elseif %trim(PASS) = *blanks;
    MSGTXT = 'Debe Ingresar una Contrase¦a.';
    iter;
  endif;
  // Validar Campos Vacíos

  // Validacion de Usuario y Contraseña
  BGTAUTH(USER : PASS : AuthResult);

  BGTUSRSTS(USER : pPreSignOn : pPassChgDate : pDaysExp : pPassExp: pStatus : pSignOnInvalid);

  select;
    when AuthResult = '1';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'SUCCESS');
    when AuthResult = '3';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'PROFILE_DISABLED');
      MSGTXT = 'Perfil Deshabilitado';
      iter;
    when AuthResult = '4';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'PASSWORD_EXPIRED');

      dow *on;
        RESP = 'Y';

        exfmt INFORMAT;

        if *in03;
          *in03 = *off;

          exfmt CONFIRM;

          if *in12;
            *in12 = *off;
            iter;
          elseif RESP = 'Y';
            leave;
          endif;
        endif;

        clear PASS;

        exfmt CHANGEPWD;
      enddo;
      
      iter;
    other;
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'FAIL');
      MSGTXT = 'Usuario o Contrase¦a Incorrectos.';
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

  QCMDEXC(Cmd : %len(%trim(Cmd)));

  leave;

enddo;
// Bucle Principal

*inlr = *on;

return;