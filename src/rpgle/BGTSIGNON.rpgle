**FREE
// ---------------------------------------------------------------
// Programa : BGTSIGNON
// Autor    : Kelvin J. Infante E.
// Fecha    : 2026-09-11
// Objetivo : Inicio de Sesion al QSYGETPH - BGTSIGNON
// Proyecto : BGTSignOn
// ---------------------------------------------------------------

ctl-opt dftactgrp(*no);

// Declaracion Vistas
dcl-f BGTSIGNON workstn;
dcl-f CHGPWD workstn;
dcl-f MSGCONF workstn;
dcl-f MSGINF workstn;
dcl-f PWDRULES workstn;
dcl-f MSGACTJOB workstn;
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
  pPreSignOn timestamp;
  pPassChgDate timestamp;
  pDaysExp zoned(3:0);
  pPassExp char(3);
  pStatus char(10);
  pSignOnInvalid zoned(3:0);
end-pr;
dcl-pr BGTACTJOB extpgm('BGTACTJOB');
  pUser char(10);
  pCurrentJob char(10);
  pActSess packed(2:0);
  pLimitSess char(10);
  pJobNA char(30);
end-pr;
dcl-pr BGTCHGPWD extpgm('BGTCHGPWD');
  pUser char(10);
  pPass char(10);
  pPassnew char(10);
  pPassnewV char(10);
  pResult char(1);
  pMsgId char(128);
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

dcl-s pPreSignOn timestamp;
dcl-s pPassChgDate timestamp;
dcl-s pDaysExp zoned(3:0);
dcl-s pPassExp char(3);
dcl-s pStatus char(10);
dcl-s pSignOnInvalid zoned(3:0);
dcl-s DummyPass char(10);

dcl-s LimitSess char(10);

dcl-s MaxSess packed(2:0);

dcl-s Result char(1);
dcl-s MsgId char(128);
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

  // Limpiar Variables
  clear PASS;
  clear MSGTXT;
  
  exfmt SIGNON;

  // Salir del Sign On al presionar F3 o F12
  if *in03 or *in12;
    leave;
  endif;


  // Validar Campos Vacíos
  if %trim(USER) = *blanks and %trim(PASS) = *blanks;
    MSGTXT = 'Se requiere información de inicio de sesión.';
    iter;
  elseif %trim(USER) = *blanks;
    MSGTXT = 'Debe ingresar un usuario.';
    iter;
  elseif %trim(PASS) = *blanks;
    DummyPass = 'xxxxxxxxxx';
    BGTAUTH(USER : DummyPass : AuthResult); // Validacion de Usuario y Contraseña
    BGTUSRSTS(USER : pPreSignOn : pPassChgDate : pDaysExp : pPassExp: pStatus : pSignOnInvalid); // Validacion de Estatus de Usuario

    if AuthResult = '3';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'PROFILE_DISABLED');
      MSGTXT = 'Perfil de usuario ' + %trim(USER) + ' deshabilitado.';
    elseif pStatus = '*DISABLED';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'ACCOUNT_LOCKED');
      MSGTXT = 'Perfil de usuario ' + %trim(USER) + ' deshabilitado.';
    elseif %char(pSignOnInvalid) = '2';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'PASSWORD_BLANK');
      MSGTXT = 'Proximo intento inválido, se deshabilitara.';
    else;
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'PASSWORD_BLANK');
      MSGTXT = 'Debe ingresar una contrase¦a.';
    endif;

    iter;
  endif;
  // Validar Campos Vacíos
  
  BGTAUTH(USER : PASS : AuthResult); // Validacion de Usuario y Contraseña
  BGTUSRSTS(USER : pPreSignOn : pPassChgDate : pDaysExp : pPassExp: pStatus : pSignOnInvalid); // Validacion de Estatus de Usuario

  select;
    when AuthResult = '1';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'SUCCESS');

      clear MaxSess;

      BGTACTJOB(USER : JOBNAME : ACTSESS : LimitSess : CURJOB);

      if %trim(LimitSess) <> *blanks;
        if %trim(LimitSess) = '*YES';
          if ACTSESS > 1;
            MSGTXT = 'Tienes permitido 1 sesión simultaneas';
            iter;
          endif;
        elseif %check('0123456789' : %trim(LimitSess)) = 0;
          MaxSess = %dec(%trim(LimitSess): 2:0);

          if MaxSess > 0;
            if ACTSESS > MaxSess;
              MSGTXT = 'Tienes permitido ' + %trim(LimitSess) + ' sesión simultaneas.';
              iter;
            endif;
          endif;
        endif;
      endif;

      if ACTSESS > 1;
        exfmt ACTIVEJOB;
      endif;

    when AuthResult = '3';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'PROFILE_DISABLED');
      MSGTXT = 'Perfil de usuario ' + %trim(USER) + ' deshabilitado';
      iter;

    when AuthResult = '4';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'PASSWORD_EXPIRED');

      LCHGPWD = %char(%date(pPassChgDate):*dmy);  // Ultimo Cambio de Clave
      SIGNDL = %char(%date(pPreSignOn):*dmy);     // Fecha de Ultimo Inicio
      SIGNTL = %char(%time(pPreSignOn):*hms);     // Hora de Ultimo Inicio

      dow *on;
        exfmt INFORMAT;

        if *in03;
          *in03 = *off;

          RESP = 'Y';

          exfmt CONFIRM;

          if *in12;
            *in12 = *off;

            iter;
          elseif RESP = 'N';
            iter;
          elseif RESP = 'Y';
            leave;
          endif;
        endif;

        dow *on;

          clear PASS;
          clear PASSNEW;
          clear PASSNEWV;

          exfmt CHANGEPWD;

          if *in03 or *in12;
            *in03 = *off;
            *in12 = *off;

            leave;
          elseif *in09;
            dow *on;
              exfmt PASSRULES;

              if *in03 or *in12;
                *in03 = *off;
                *in12 = *off;

                leave;
              endif;
            enddo;
          endif;

          if %trim(PASS) = *blanks and %trim(PASSNEW) = *blanks and %trim(PASSNEWV) = *blanks;
            MSGTXT = 'Tiene que llenar todos los campos.';
            iter;
          elseif %trim(PASSNEW) = *blanks and %trim(PASSNEWV) = *blanks;
            MSGTXT = 'Debes de colocar la nueva contrase¦a.';
            iter;
          elseif %trim(PASSNEWV) = *blanks;
            MSGTXT = 'Debes confirmar la nueva contrase¦a.';
            iter;
          endif;

        enddo;
      enddo;
      
      iter;
    
    when AuthResult = '5';
      BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'NOT_PASSWORD');
      MSGTXT = 'No es posible iniciar sesión con este perfil.';
      iter;
    
    other;
      if pStatus = '*DISABLED';
        BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'ACCOUNT_LOCKED');
        MSGTXT = 'Perfil de usuario ' + %trim(USER) + ' deshabilitado';
      elseif %char(pSignOnInvalid) = '2';
        BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'FAIL');
        MSGTXT = 'Proximo intento inválido, se deshabilitara';
      else ;
        BGTSIGNLOG(USER : DATE : TIME : JOBNAME : 'FAIL');
        MSGTXT = 'Usuario o contrase¦a incorrectos.';
      endif;    

      iter;
  endsl;

  // Validacion del Programa o Menu Inicial del Usuario
  BGTGETPRF(USER : InlPgm : InlMnu);

  if %trim(InlPgm) <> '*NONE';
    Cmd = 'CALL ' + %trim(InlPgm);
  else;
    Cmd = 'GO ' + %trim(InlMnu);
  endif;

  QCMDEXC(Cmd : %len(%trim(Cmd)));
  // Validacion del Programa o Menu Inicial del Usuario

  leave;

enddo;
// Bucle Principal

*inlr = *on;

return;