*;
libname mysas "/tmp/viya/";
libname myownsas "/tmp/v94/";
*;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* Blue BY k_tstmat */
ods listing gpath="/home/sastest/png";
title "Histogram of Blauwwaarde by k_tstmat";
proc freq data=myownsas.skp1allplusKeys(keep=d524 k_tstmat) noprint;
	histogram d524;
	by k_tstmat;
run;
title;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */