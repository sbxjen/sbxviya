*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

/* skp1allplusKeys2 should exist by now */
proc contents data=ousaslib.skp1allplusKeys2; run;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* k_tstmat */
proc freq data=ousaslib.skp1allplusKeys2(keep=k_tstmat);
	tables k_tstmat;
run;

/* first coil with nonzero d524 only */
data _null_;
	set ousaslib.skp1allplusKeys2(obs=1);
	call symput('coil',cl_n);
run;

%put &coil.;

/* Summary statistics for d524 */
proc univariate data=ousaslib.skp1allplusKeys2(where=(k_tstmat like '2B%')) noprint;
	by notsorted cl_n dch_n bew_vn k_tstmat d417 d418 ;
	var d524;
	output out=_skp1allplusKeys_meand524 mean=d524;
run;

data work.coil;
	set ousaslib.skp1allplusKeys2(keep=cl_n ts_registratie d524 d324 d382);
	where cl_n=put(&coil.,8.);
run;

/* Plot Blauwwaarde for first coil with nonzero d524 only */

ods _all_ close;
ods graphics on /
	height=512px width=640px
	border=off;
ods html path="/home/sastest/html/"  gpath="/home/sastest/png" file="TimeSeries-Blauwwaarde.html" style=HTMLBlue;

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



ods html path="/home/sastest/html/"  gpath="/home/sastest/png" file="Histogram-Blauwwaarde.html" style=HTMLBlu;

proc sort data=_skp1allplusKeys_meand524;
	by k_tstmat;
	*by d417 d418;
run;
title "Per coil Blauwwaarde";
proc sgplot data=_skp1allplusKeys_meand524;
	histogram d524;
	density d524 / type=Normal;
	by k_tstmat;
	*by d417 d418;
	xaxis values=(0.0 to 1.0 by 0.1) label='Blauwwaarde';
run;

ods html path="/home/sastest/html/"  gpath="/home/sastest/png" file="BoxPlot-Blauwwaarde.html" style=HTMLBlue;

proc sort data=_skp1allplusKeys_meand524;
	by k_tstmat;
	*by d417 d418;
run;
title "Per coil Blauwwaarde";
proc sgplot data=_skp1allplusKeys_meand524;
	vbox d524 / category=k_tstmat;
	yaxis grid values=(0.0 to 1.0 by 0.1) label='Blauwwaarde';
	xaxis display=(nolabel);
run;

ods html close;
ods listing;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );




/* end of program */