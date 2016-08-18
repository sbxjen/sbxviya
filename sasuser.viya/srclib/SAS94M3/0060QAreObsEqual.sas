libname ousaslib "/tmp/v94/";

*%let inputdsn=ousaslib.skp1walsplusKeys;
%let inputdsn=ousaslib.crm3allplusKeys;

/* Make sure data sets have the same number of Obs */
data _null_;
	if 0 then set &inputdsn._PREP_BASE nobs=countncil;
	call symputx('Unique', strip(put(countncil,8.)));
	stop;
run;

%put &=Unique.;

%macro QAreObsEqual(tables=);
	%let n=%sysfunc(countw(&tables.,%str( )));
	%do i=1 %to &n.;
		%let dsn=%scan(&tables.,&i.);
		data _null_;
			if 0 then set &inputdsn._&dsn. nobs=countncil;
			Equal = (countncil=&Unique.);
			put Equal=;
		run;
	%end;
%mend;

%QAreObsEqual(tables=PREP_BINARY PREP_NOMINAL PREP_SUMM PREP_TSDR); 

/* end of program */