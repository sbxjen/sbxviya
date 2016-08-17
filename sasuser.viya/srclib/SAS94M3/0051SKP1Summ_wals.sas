
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";

%let inputdsn=ousaslib.skp1walsplusKeys_PREP;
*%let inputdsn=ousaslib.skp1small;

/* NOTE: &KeyCols. are replaced with KeyCol */

/* Determine interval variables. */
/* TARGET column */
%let target=d524;
/* Key columns = BY variables: summarize 5" data per BY group */
%let KeyCols=cl_n bew_vn dch_n _deel;
%let INTERVAL=P_: &target. _x _pol;

/* Divide into INTERVAL and BINARY/NOMINAL variables.
   All bookkeeping, missing, unary variables (except for Key columns) should have been removed by now. */
data &inputdsn._NOINTERVAL(drop=&KeyCols. ts_registratie &INTERVAL. ts_be ts_ei _vars i) &inputdsn._INTERVAL(keep=KeyCol ts_registratie &INTERVAL.);
	length _vars $6000;
	_vars = "&target. _x _pol";
	set &inputdsn.;
	array _p{*} P_:;
	if _n_=1 then do;
	    do i = 1 to dim(_p);
	    	_vars = catx(" ", _vars, vname(_p{i}));
	    end;
	    call symputx("intlist", _vars);
    end;
	KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.), put(_deel,best.));
	output &inputdsn._NOINTERVAL &inputdsn._INTERVAL;
run;
%put &=intlist.;

proc sort data=&inputdsn._NOINTERVAL;
	by KeyCol;
run;
data &inputdsn._BASE;
	set &inputdsn._NOINTERVAL(keep=KeyCol); /* INTERVAL would have worked as well */
	by KeyCol;
	if first.KeyCol then output;
run;

/* Determine binary variables and collect them into binlist. */
%include '/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0042DetermineBINColumns.sas';
%put &=binlist.;

/* To get an exhaustive nomlist: */
%include '/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0043DetermineNOMColumns.sas';
%put &=nomlist.;

*options source2;

/*  Do some cool stuff with TSDR in SAS Enterprise Miner to summarize &inputdsn._INTERVAL.
/*  For now, 
    INTERVAL variables: Mean, Stddev
	BINARY 0/1: proportion 1's
	NOMINAL variables: mode
*/
%include '/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0050Summ_macrodef.sas';

%mergeMeansStddevsWInterval()
%mergePropsWBinary();	
%mergeModesWNominal();

/* end of program */