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
 
data _NULL_;
 if 0 then set work.MATm2 nobs=lookupnobs;
 call symput('lookupnobs',strip(put(lookupnobs,12.)));
 STOP;
run;
 
data work.MATm2index; MATm2start=1; MATm2end=&lookupnobs.; output; run;
 
data work.CRM3plusKeysKeyCols   /*(drop=MATm2start MATm2end)*/ ;
 if _N_=1 then set work.MATm2index(keep=MATm2start MATm2end);
 set work.crm3_pv;
 do pointer = MATm2start to MATm2end;
  set work.MATm2 point=pointer;
  if TS_BE <= TS_Registratie <= TS_EI then do; output; end;
 end;
run;

proc sort data=work.CRM3plusKeysKeyCols;
 by TS_Registratie SJR_CL CL_N DCH_N BEW_VN ;
run;
 
/*  
PROC SQL feedback stimer _METHOD noprint;
 create table work.CRM3plusKeysKeyCols as
 select   b.CL_N  , b.DCH_N , b.BEW_VN , b.SJR_CL , b.LN_PR 
        , b.TS_BE , b.TS_EI , a.* 
 from   work.crm3_pv  a
      , work.MATm2    b
 where a.TS_Registratie between b.TS_BE and b.TS_EI 
 order by a.TS_Registratie , b.SJR_CL , b.CL_N  , b.DCH_N , b.BEW_VN;
quit;
*/ 

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
