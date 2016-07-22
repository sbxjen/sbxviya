proc freq data=mysas.matm2(where=(a_dch=0)) noprint;
	tables cl_n * dch_n * bew_vn / missing out=work.matm2count;
run;

data work.matm2count;
	set work.matm2count;
	where count >= 2;
run;

data _null_;
	if 0 then set work.matm2count nobs=countnuk;  			/* Highly efficient way to count nobs without reading a single observation */
	call symput('NonUniqueKeys', strip(put(countnuk,8.)));  /* strip = trim(left(.)) */
	stop;
run;

%put The number of non-unique keys in matm2 equals &NonUniqueKeys..;

/* end of program */