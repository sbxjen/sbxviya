libname APERAM "/home/EUROPE/sbxkok/srcdata" access=readonly;
libname  mylib "/sastest/data94M3";
options CPUCOUNT=4 THREADS;
options mprint nosymbolgen nomlogic source2;
options FULLSTIMER; /* keep trace of memory usage */
 
data   work.MATm2; 
 set aperam.MATm2
    (keep = CL_N DCH_N BEW_VN SJR_CL LN_PR TS_BE TS_EI);
 where LN_PR = 'CRM3';
 sleutel='1';
run;
 
data   work.crm3_pv;
 set aperam.crm3_pv(keep=TS_Registratie d100);
 sleutel='1';
run;
 
data work.CRM3plusKeysKeyCols ; 
 set work.crm3_pv ;
 by  sleutel      ;
 DateFound=0;

 /* At compile time, load 8 variables definitions from LOOKUP table and rename SJaaR_CL var          */
 if 0 then set work.MATm2(rename=(SJR_CL=SJaaR_CL)
                          keep=sleutel SJR_CL CL_N DCH_N BEW_VN LN_PR TS_BE TS_EI); 

 /* Load LOOKUP table in memory - check memsize value in options if out-of-memory messages in SASLOG */
 if _N_=1 then do;
   declare hash Lookup_HASH(dataset:'work.MATm2(rename=(SJR_CL=SJaaR_CL))' 
                            , ordered:'a',multidata:'y');
   Lookup_HASH.definekey('sleutel');
   Lookup_HASH.definedata('sleutel','TS_BE','TS_EI','SJaaR_CL','CL_N','DCH_N','BEW_VN','LN_PR');
   Lookup_HASH.definedone();
 end;  

 /* find info for this sleutel in lookup table */
 Search_rc = Lookup_HASH.find();

 if Search_rc ne 0 then do;
   putlog 'WARNING: ' sleutel= ' not Found in lookup table ' ; 
   return; /* stop to avoid running subsequent code */
 end;
 
 else do;
   /* otherwise lets loop through every TS_Registratie found in LOOKUP for this specific sleutel */
   do while(Search_rc = 0);
     if TS_Registratie >= TS_BE AND TS_Registratie <= TS_EI then do; DateFound=1; output; end;
     Search_rc = Lookup_HASH.find_next();
   end;
 end;
 
 /* If this TS_Registratie does not appear in LOOKUP, put a WARNING: */
 if NOT DateFound and Search_rc ne 0 then do; 
   call missing(SJaaR_CL);call missing(CL_N);call missing(DCH_N);call missing(BEW_VN);call missing(LN_PR);
   call missing(TS_BE);   call missing(TS_EI);
   *putlog 'WARNING: sleutel has no corresponding TS_Registratie in lookup table ' sleutel= TS_Registratie=;
   output; 
end;
/* Keeping  our house clean */
drop Search_rc DateFound;
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
 from     work.CRM3plusKeysKeyCols(where=(CL_N is not missing))  a
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
