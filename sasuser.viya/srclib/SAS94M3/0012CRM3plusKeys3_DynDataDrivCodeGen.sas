libname APERAM "/home/EUROPE/sbxkok/srcdata" access=readonly;
libname  mylib "/sastest/data94M3";
options CPUCOUNT=4 THREADS;
options mprint nosymbolgen nomlogic source2;

data   work.MATm2; 
 set aperam.MATm2
    (keep = CL_N DCH_N BEW_VN SJR_CL LN_PR TS_BE TS_EI);
 where LN_PR = 'CRM3';
run;
 
data   work.crm3_pv;
 set aperam.crm3_pv(keep=TS_Registratie d100);
run;

filename sascode CLEAR;
filename sascode temp;
 
data _NULL_;
 set work.MATm2 end=last;
 file sascode;
 if _N_=1 then do;
PUT 'data work.CRM3plusKeysKeyCols; ';
PUT 'LENGTH SJR_CL $ 4 CL_N $ 8 DCH_N 8 BEW_VN 8 LN_PR $ 4'; 
PUT '       TS_Registratie 8 TS_BEGIN 8 TS_EINDE 8;       ';
PUT ' set work.crm3_pv;             ';
PUT " retain LN_PR 'CRM3';          ";
 end;
PUT ' TS_BEGIN = "' TS_BE +(-1) '"dt;'; 
PUT ' TS_EINDE = "' TS_EI +(-1) '"dt;';
PUT ' if ((TS_Registratie >= TS_BEGIN) AND (TS_Registratie <= TS_EINDE)) then ';
PUT 'DO;                            ';
PUT ' SJR_CL   = "' SJR_CL +(-1) '";';
PUT ' CL_N     = "' CL_N   +(-1) '";';
PUT ' DCH_N    = ' DCH_N  ';        ';
PUT ' BEW_VN   = ' BEW_VN ';        ';
PUT 'output; END;                   ';
 if last then do;
PUT ' format TS_BEGIN TS_EINDE 25.3;'; 
PUT 'run;';
 end;
run;

%INCLUDE sascode;
filename sascode CLEAR;

proc sort data=work.CRM3plusKeysKeyCols;
 by TS_Registratie SJR_CL CL_N DCH_N BEW_VN;
run;

PROC SQL feedback stimer _METHOD noprint;
 create table mylib.CRM3plusKeysKeyCols as
 select a.* , b.*
 from     work.CRM3plusKeysKeyCols  a
      , aperam.crm3_pv              b
 where a.TS_Registratie = b.TS_Registratie 
 order by a.TS_Registratie , a.SJR_CL , a.CL_N  , a.DCH_N , a.BEW_VN;
quit;
 
proc means data=mylib.CRM3plusKeysKeyCols min max nway noprint;
 class LN_PR;
 var TS_Registratie TS_BE TS_EI;
 output out=mylib.CRM3DateRangeData min= max= / autoname;
run;

data mylib.CRM3DateRangeData;
 set mylib.CRM3DateRangeData;
 format TS_: datetime25.3;
run;
/* end of program */ 
