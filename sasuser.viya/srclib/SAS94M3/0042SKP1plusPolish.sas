*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

/* (Unit) test DATA set */
%let coil=51801325;
data work.coil;
	set ousaslib.skp1allplusKeys2;
	where cl_n="&coil.";
run;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

%let polijsten = d382=1 and d324 ge 100; /* Mode polijsten = 1 and Bandsnelheid [m/min] > 100 */
%let midden = d325 ge 150 and d325 le (le/1000-150); /* Midden coil = between 150m and length-150m */

*%let dsn=ousaslib.skp1allPlusKeys2;
%let dsn=work.coil;

proc sort data=&dsn.;
	by cl_n dch_n bew_vn ts_be ts_registratie;
run;

data ousaslib.skp1allPlusKeysplusPolish;

	set &dsn.;
	by cl_n dch_n bew_vn ts_be ts_registratie;

	retain s001 s002;
	label s001="Polijsttijd [s]" s002="Polijsttijd midden coil [s]";

	/* New coil */
	if first.ts_be then do; 
		s001 = 0; s002 = 0;
	end;
		
	if &polijsten. then do;
		s001 = s001+ 5; /* + 5" */
		/*  NOTE: Variable le is uninitialized. 
			We need more than only KeyCols here */
		if &midden. then s002 = s002 + 5; /* + 5" */
	end;
	
run;

/* Plot Blauwwaarde for first coil with nonzero d524 only */
proc means data=ousaslib.skp1allPlusKeysplusPolish max noprint;
	var s001;
	output out=temp max=_MAX_;
run;
data _null_;
	set temp;
	call symput('_max_',_MAX_);
run;
proc datasets library=work nolist;
	delete temp / memtype=data; 
run;
quit;
%put &_max_.;
data work.coil(replace=yes);
	set ousaslib.skp1allPlusKeysplusPolish;
	y = &_max_. * d382;
run;

ods _all_ close;
ods graphics on /
	height=512px width=640px
	border=off;
ods html path="/home/sastest/html/"  gpath="/home/sastest/png" file="TimeSeries-Polijsten.html" style=HTMLBlue;

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
	band x=ts_registratie lower=0 upper=y / fillattrs=(color=blue) legendlabel="Mode Polijsten";
	series x=ts_registratie y=s001 / lineattrs=(color=black) legendlabel="CUMULATIVE Polijsttijd [s]";
	xaxis label="t";
	yaxis grid display=(nolabel);
run;
title;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */