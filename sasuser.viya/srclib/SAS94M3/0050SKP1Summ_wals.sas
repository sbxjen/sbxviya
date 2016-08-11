*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

*%let inputdsn=ousaslib.skp1walsplusKeys;
%let inputdsn=ousaslib.skp1small;

/* NOTE: &KeyCols. are replaced with KeyCol */

/* Determine interval variables. */
/* ID columns AND target variable in inputdsn: these are not treated as interval variables. */
%let IDCols=('ts_registratie', 'cl_n', 'bew_vn', 'dch_n', 'ts_be', 'ts_ei', 'd524');
%include '/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0041DetermineINTColumns.sas';
%put &=intlist.; /* same interval variables as in 0032TSPreprocess.sas *:

/* Key columns = BY variables: summarize 5" data per BY group */
%let KeyCols=cl_n bew_vn dch_n _deel;
%let INTERVAL=&intlist. d524 _x _pol;

/* Divide into INTERVAL and BINARY/NOMINAL variables.
   All bookkeeping, missing, unary variables (except for Key columns) should have been removed by now. */
data &inputdsn._NOINTERVAL(drop=&KeyCols. ts_registratie &INTERVAL. ts_be ts_ei) &inputdsn._INTERVAL(keep=KeyCol ts_registratie &INTERVAL.);
	set &inputdsn.;
	KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.), put(_deel,best.));
	output &inputdsn._NOINTERVAL &inputdsn._INTERVAL;
run;



/***

 	Do some cool stuff to summarize &inputdsn._INTERVAL with SAS EM.

***/



/* For now, 
	binary 0/1: proportion 1
	nominal variables: mode
*/

proc sort data=&inputdsn._NOINTERVAL;
	by KeyCol;
run;
data &inputdsn._BASE;
	set &inputdsn._NOINTERVAL(keep=KeyCol);
	by KeyCol;
	if first.KeyCol then output;
run;

/* Determine binary variables. */
%include '/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0042DetermineBINColumns.sas';
%put &=binlist.;

%let bin=d066;

/* BINARY */
data &inputdsn._NOINTERVAL;
	set &inputdsn._NOINTERVAL;
	one=1;
run;

data &inputdsn._BINARY;
	set &inputdsn._BASE;
run;

ods output Summary=t;
proc means data=&inputdsn._NOINTERVAL(keep=KeyCol &bin. one) n completetypes;
  class KeyCol &bin.;
run;
ods output OneWayFreqs=onewayfreq;
proc freq data=t;
	by KeyCol;
	tables &bin.;
	weight one_N / zeros;
run;
/* This DATA step reshapes the output data set onewayfreq to a more tabular format. */    
data onewayfreq;                                                                     
   length Variable $32 Value $32;
   set _BINARY_onewayfreq;
   keep KeyCol Variable Value Percent;
   Variable = scan(Table , 2, ' ');
   Value = trim(left(vvaluex(Variable)));
run;
proc sort data=onewayfreq;
	by KeyCol Variable Value;
run;
data onewayfreq;
	set onewayfreq;
	by KeyCol Variable Value;
	/* Make sure to use the same reference level consistently over all Obs */
	if first.Variable then output;
run;
proc transpose data=onewayfreq
		out=work._BINARY
		name=Percent;
	by KeyCol;
	id Variable;
run;
data &inputdsn._BINARY;
	merge &inputdsn._BINARY work._BINARY(drop=Percent);
	by KeyCol;
run;
proc datasets library=work nolist;
 	delete t onewayfreq _BINARY / memtype=data;
run;


/* NOMINAL */
/* To get an exhaustive nomlist: */
data _null_;
	if _n_=1 then set &inputdsn._NOINTERVAL(drop=&KeyCols. ts_registratie &binlist. obs=1);
	length _vars $6000;
	array _a _all_ _dum;
	do i = 1 to dim(_a)-1;       /* -1 because of dummy _dum */
    	if not (vname(_a{i})="KeyCol") then catx(" ", _vars, vname(_a{i}) );
    end;
	call symputx("nomlist", _vars);
run;
%put &=nomlist.;

%macro mergeModesWNominal();
	
	data &inputdsn._NOMINAL;
  		set &inputdsn._BASE;
  	run;
	
	/* Again, loop over all variables in nomlist... */
	%let nvar=%sysfunc(countw(&nomlist.,%str( )));
	%do ivar=1 %to &nvar.;
		%let nom=%scan(&nomlist.,&ivar.);
		
		/* Calculate modes. */
		data work.tmp;
			set &inputdsn._NOINTERVAL(keep=KeyCol &nom.);
		run;
		proc sort data=work.tmp;
			by KeyCol &nom.;
		run;
		
		data Modes(drop=freq maxfreq mode);
  		do until (last.KeyCol);
    		set work.tmp;
    		by KeyCol &nom.;
    		if first.&nom. then freq=0;
    		freq+1;
    		maxfreq=max(freq,maxfreq);
    		if freq=maxfreq then mode=&nom.;
 		end;
 		/* The second loop outputs the values along with the mode from the first loop. */
  		&nom.=mode;
  		output Modes;
  		run;
  		
  		/* Then merge. */
  		data &inputdsn._NOMINAL;
  			merge &inputdsn._NOMINAL Modes;
  			by KeyCol;
  		run;
  		
  		proc datasets library=work nolist;
 			delete tmp Modes / memtype=data;
 		run;
  		
  	%end;

%mend;

options source2;		
%mergeModesWNominal();

/* end of program */

