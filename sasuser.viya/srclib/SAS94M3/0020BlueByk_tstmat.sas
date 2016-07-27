*;
libname mysas "/tmp/viya/";
libname myownsas "/tmp/v94/";
*;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* Blue BY k_tstmat */
proc freq data=myownsas.skp1allplusKeys(keep= k_tstmat);
	tables k_tstmat;
run;



ods listing gpath="/home/sastest/png";
title "Histogram of Blauwwaarde by k_tstmat";
proc univariate data=myownsas.skp1allplusKeys(keep=d524 k_tstmat where=(k_tstmat like '2B%')) noprint;
	class k_tstmat;
	histogram d524 / nrows = 2;
run;
title;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */