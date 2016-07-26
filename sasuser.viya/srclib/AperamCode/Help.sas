libname mylib "/tmp/viya/";

proc print data=mylib.skp1_sigdef; run;

proc print data=mylib.skp1_pv(obs=100); run;

proc contents data=mylib.matm2; run;

proc print data=mylib.matm2(obs=1); run; 
