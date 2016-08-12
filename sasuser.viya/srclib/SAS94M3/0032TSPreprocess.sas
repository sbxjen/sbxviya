*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

/* Define some 'global' macro variables. */

/* Input data set (e.g. ousaslib.skp1walsplusKeys) */
*%let inputdsn=ousaslib.skp1small;
*%let inputdsn=ousaslib.skp1walsplusKeys;
%let inputdsn=ousaslib.crm3allplusKeys;

/* Key columns in inputdsn: BY variables for PROC EXPAND, PROC TRANSREG ... */
%let KeyCols=cl_n bew_vn dch_n; *_deel;
*%let KeyCols=cl_n bew_vn dch_n;
/* time ID in inputdsn for PROC EXPAND, PROC TRANSREG ... */
%let t=ts_registratie;
/* TARGET column */
%let target=d524;
/* ID columns AND TARGET variable in inputdsn: these are not treated as ordinary interval variables here. */
%let IDCols=("ts_registratie", "cl_n", "bew_vn", "dch_n", "ts_be", "ts_ei", "&target.");

/*proc format;
	value missfmt . ='Missing' other='Not Missing';
run;*/

*data ousaslib.skp1small;
	*set ousaslib.skp1walsplusKeys(obs=2000);
	*keep cl_n bew_vn dch_n ts_registratie d324 d382 d522 d523 d524 _deel _x _pol KeyCol;
	*KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.), put(_deel,best.));
*run;

/* Preprocess the signal y in a pass- or coil-based data set dsn (e.g. ousaslib.skp1walsplusKeys).
   A smoothed version P_y of the signal y is added to this data set dsn on return. */ 
%macro preprocess(dsn=, y=, KeyCol=);
	/* 1. Remove outliers. */
	proc univariate data=&dsn. noprint;
		by &KeyCol.;
		var &y.;
		output out=work.tmp q1=q1 q3=q3 qrange=iqr;
	run;
	data work.out;
		merge &dsn. work.tmp;
		by &KeyCol.;
		if ((&y.<q1-1.5*iqr) or (&y.>q3+1.5*iqr)) then &y.=.;	
	run;
	
	/* 2. Apply moving average filter. */
	proc expand data=work.out out=work.avg method=none;
		by &KeyCol.;
		id &t.;
		convert &y. = &y.f / transformout=(movave 3);
	run;
	proc datasets library=work nolist;
 		delete tmp out / memtype=data;
 	run;

	/* 3. Remove outliers again, but now based on stddev. */
	data work.avg;
		set work.avg; /* contains &y.f now */
		_delta_&y. = &y. - &y.f; /* NOTE: Missing values were generated as a result of performing an operation on missing values (in &y.). */
	run;
	proc univariate data=work.avg noprint;
		by &KeyCol.;
		var _delta_&y.;
		output out=work.tmp std=stddev;
	run;
	data work.out;
		merge work.avg work.tmp;
		by &KeyCol.;
		if (abs(&y. - &y.f) > 2*stddev) then &y.=.;
		drop _delta_&y. &y.f;
	run;
	proc datasets library=work nolist;
 		delete tmp avg / memtype=data;
 	run;
	
	/* 4. Fit a cubic spline. */
	/* First, handle missing values */
	proc expand data=work.out out=work.full method=spline;
		by &KeyCol.;
		id &t.;
		convert &y. = &y.f; /* WARNING: The variable d025 has only 0 nonmissing observations, which is too few to apply the conversion method. The result series 
          is set to missing. */
	run;
	/*proc freq data=work.full;
		by &KeyCol.;
		format _numeric_ missfmt.;
		tables &y. &y.f / missing missprint nocum nopercent;
	run;*/

/*  For INPUT variables */
	data &dsn.;
		merge &dsn. work.full(keep=&KeyCol. &t. &y.f rename=(&y.f=P_&y.));
		by &KeyCol. &t.;
	run;

/*  For TARGET variable */
/*	options nonotes;
	proc transreg data=work.full noprint plots=none;
		by &KeyCol.;
		model identity(&y.f) = spline(&t. / degree=3);
		output out=work.spline predicted;
	run;
	options notes;
	data &dsn.;
		merge &dsn. work.spline(drop=_TYPE_ _NAME_ &y.f T&y.f Intercept TIntercept	T&t. rename=(P&y.f=P_&y.));
		by &KeyCol. &t.;
		if (P_&y.=0) then P_&y.=&y.;
	run; */
	proc datasets library=work nolist;
 		delete out full /*spline*/ / memtype=data;
 	run;
	quit;
%mend;
/* end of macro */

/* Preprocess all interval variables in a pass- or coil-based data set. */
%macro preprocess_all();

	proc sort data=&inputdsn.;
		by &KeyCols. &t.;
	run;

	/* Determine interval variables. */
	%include '/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0041DetermineIntColumns.sas';
	%put &=intlist.; /* interval variables */

	%let nvar=%sysfunc(countw(&intlist.,%str( )));
	
	%do ivar=1 %to &nvar.;
		%let yvar=%scan(&intlist.,&ivar.);
		%preprocess(dsn=&inputdsn., y=&yvar., KeyCol=&KeyCols.);
	%end;

%mend;
/* end of macro */

*options source2;

/* For INPUT variables */
%preprocess_all();

/* For TARGET variable */
*%preprocess(dsn=&inputdsn., y=&target., KeyCol=&KeyCols.);

data $inputdsn._PREP;
	set &inputdsn.(drop=&intlist.);
run;

/* end of program */
