proc freq data=mysas.skp_cilinders noprint;
	tables historyid / missing out=work.skp_cilinderscount;
run;

data work.skp_cilinderscount;
	set work.skp_cilinderscount;
	where count >= 2;
run;

data _null_;
	if 0 then set work.skp_cilinderscount nobs=countnuk;  			/* Highly efficient way to count nobs without reading a single observation */
	call symput('NonUniqueKeys', strip(put(countnuk,8.)));  /* strip = trim(left(.)) */
	stop;
run;

%put The number of non-unique keys in skp_cilinders equals &NonUniqueKeys..;

/* end of program */