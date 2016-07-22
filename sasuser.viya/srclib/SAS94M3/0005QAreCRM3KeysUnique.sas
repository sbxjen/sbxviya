proc freq data=mysas.crm3_pv noprint;
	tables ts_registratie / missing out=work.crm3_pvcount;
run;

data work.crm3_pvcount;
	set work.crm3_pvcount;
	where count >= 2;
run;

data _null_;
	if 0 then set work.crm3_pvcount nobs=countnuk;  		*** Highly efficient way to count nobs without reading a single observation;
	call symput('NonUniqueKeys', strip(put(countnuk,8.)));  *** strip = trim(left(.));
	stop;
run;

%put The number of non-unique keys in crm3_pv equals &NonUniqueKeys..;

/* end of program */