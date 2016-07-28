*;
libname mysas "/tmp/viya/";
libname myownsas "/tmp/v94/";
*;

/* skp1allplusKeys2 should exist by now */
proc contents data=myownsas.skp1allplusKeys2; run;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* k_tstmat */
proc freq data=myownsas.skp1allplusKeys2(keep=k_tstmat);
	tables k_tstmat;
run;

/* first coil with nonzero d524 only */
data _null_;
	set myownsas.skp1allplusKeys2(obs=1);
	call symput('coil',cl_n);
run;

%put &coil.;

/* Summary statistics for d524 */
proc univariate data=myownsas.skp1allplusKeys(where=(k_tstmat like '2B%'));
	by notsorted cl_n dch_n bew_vn k_tstmat d417 d418 ;
	var d524;
	output out=_skp1allplusKeys_meand524 mean=d524;
run;

data work.coil;
	set myownsas.skp1allplusKeys2(keep=cl_n ts_registratie d524 d324 d382);
	where cl_n=put(&coil.,8.);
run;

/* Plot Blauwwaarde for first coil with nonzero d524 only */
ods listing close;

ods graphics on /
	height=1024px width=1280px
	border=off;
ods html file="/home/sastest/html/TimeSeries-Blauwwaarde.html" style=HTMLBlue gpath="/home/sastest/html";

title "Coil &coil.";

proc sgplot data=work.coil;
	series x=ts_registratie y=d524 / lineattrs=(color=red);
	xaxis grid label="t";
	yaxis grid label="Blauwwaarde";
run;
proc sgplot data=work.coil;
	series x=ts_registratie y=d324 / lineattrs=(color=blue);
	xaxis grid label="t";
	yaxis grid label="Bandsnelheid";
run;
proc sgplot data=work.coil;
	band x=ts_registratie lower=0 upper=d382 / fillattrs=(color=blue);
	xaxis label="t";
	yaxis grid label="Mode Polijsten";
run;

title;

ods html close;

/*ods html file="/home/sastest/html/Histogram-Blauwwaarde.html" style=HTMLBlue gpath="/home/sastest/html";

title "Per coil Blauwwaarde";

proc sgplot data=work.coil;
	histogram k_tstmat;
	
run;*/

ods listing;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */