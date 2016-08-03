*proc freq data=mysas.skp_cilinders noprint;
*	tables historyid / missing out=work.skp_cilinderscount;
*run;
*
*data work.skp_cilinderscount;
*	set work.skp_cilinderscount;
*	where count >= 2;
*run;
*
*data _null_;
*	if 0 then set work.skp_cilinderscount nobs=countnuk;  			/* Highly efficient way to count nobs without reading a single observation */
*	call symput('NonUniqueKeys', strip(put(countnuk,8.)));  /* strip = trim(left(.)) */
*	stop;
*run;
*
*%put The number of non-unique keys in skp_cilinders equals &NonUniqueKeys..;

/* Second question: How many different cilinders are used with one coil at the SKP? */
/* This question can only be answered as soon as skp1allplusKeys has been created. */
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";

proc sort 	data=ousaslib.skp1allplusKeys(keep=cl_n bew_vn dch_n ts_registratie ts_be d417 d418)
			out=work.skp_cilinderscount;
	by ts_be d417 d418;
run;
data work.skp_cilinderscount;
	set work.skp_cilinderscount;
	by ts_be d417 d418;
	if ( (first.d417 or first.d418) and (not first.ts_be) ) then output;
run;

data _null_;
	if 0 then set work.skp_cilinderscount nobs=countncil;  			/* Highly efficient way to count nobs without reading a single observation */
	call symput('NonUnique', strip(put(countncil,8.)));  	/* strip = trim(left(.)) */
	stop;
run;

%put A new cilinder was used &NonUnique. times.;
/* A new cilinder was used 500 times. */

/* end of program */