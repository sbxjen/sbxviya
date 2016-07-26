libname mylib "/tmp/viya/";

proc print data=mylib.skp1_sigdef; run;

data work.test;
	retain nzero count 0;
	set mylib.skp1_pv(obs=100000 keep=d341 d342 d522 d523) end=last;
	if (d341 ne d522) or (d342 ne d523) then count = count + 1;
	if sum(of d:) ne 0 then nzero = nzero + 1;
	if last then output;
	keep count nzero;
run;

proc print data=mylib.skp1_pv(firstobs=1000 obs=1000); run;

proc univariate data=mylib.skp1_pv(keep=d524 d525 d526) noprint;
	histogram d:;
run;

proc contents data=mylib.matm2; run;

proc print data=mylib.matm2(obs=1); run; 
