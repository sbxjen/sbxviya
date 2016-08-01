/* dsn should be set */

proc freq data=mysas.&dsn. noprint;
	tables ts_registratie / missing out=work.&dsn._pvcount;
run;

data work.&dsn._pvcount;
	set work.&dsn._pvcount;
	where count >= 2;
run;

data _null_;
	if 0 then set work.&dsn._pvcount nobs=countnuk;  		/* Highly efficient way to count nobs without reading a single observation */
	call symput('NonUniqueKeys', strip(put(countnuk,8.)));  /* strip = trim(left(.)) */
	stop;
run;

%put The number of non-unique keys in &dsn. equals &NonUniqueKeys..;

/* end of program */