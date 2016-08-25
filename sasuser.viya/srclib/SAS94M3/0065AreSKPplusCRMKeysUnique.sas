libname mysas "/tmp/v94/";

%let dsn=SKP1plusCRM3plusKeys2;

proc freq data=mysas.&dsn. noprint;
	tables KeyCol_deel / missing out=work.&dsn._pvcount;
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