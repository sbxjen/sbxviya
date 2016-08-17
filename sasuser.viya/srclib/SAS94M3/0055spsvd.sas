/* 	
	1. stdize
	2. coo
	3. spsvd
*/
	
libname ousaslib "/tmp/v94/";

*%let inputdsn=ousaslib.skp1small_PREP;
%let inputdsn=ousaslib.skp1walsplusKeys_PREP;
*%let inputdsn=ousaslib.crm3plusKeys_PREP;

/* 	inputdsn contains 2 target variables: d524 (raw) and P_d524 (smoothed).
	0054SKP1Summ_target.sas creates a cross-sectional target variable, so we can drop these 2 variables here.
	Also _pol is a constant per cross-sectional observation. 
 */
%let todrop=d524 P_d524 _pol _x;
data &inputdsn._INTERVAL;
	set &inputdsn._INTERVAL(drop=&todrop.);
run;
	
/* Determine interval variables (This is the last time - I promise!). */
data _null_;
	set &inputdsn._INTERVAL(obs=1);
	array _p{*} P_:;
	length _vars $6000;
	_vars = ""; * _vars="_x";
	if _n_=1 then do;
	    do i = 1 to dim(_p);
	    	_vars = catx(" ", _vars, vname(_p{i}));
	    end;
	    call symputx("intlist", _vars);
    end;
run;
%put &=intlist.;

/* 1. stdize */
proc stdize data=&inputdsn._INTERVAL out=&inputdsn._INTERVAL method=std;
	var &intlist.;
run;

%macro spsvd();

	/* Like in 0051/0052, start from &inputdsn._BASE */
	data &inputdsn._TSDR;
		set &inputdsn._BASE;
  	run;
  	
	%let nvar=%sysfunc(countw(&intlist.,%str( )));
	%do ivar=1 %to &nvar.;
		%let int=%scan(&intlist.,&ivar.);
		
		data work.tmp;
			set &inputdsn._INTERVAL(keep=KeyCol &int.);
		run;
		proc sort data=work.tmp;
			by KeyCol;
		run;
		/* work.tmp represents a flattened m x T table with m different KeyCols and T Time IDs. 
		
		/* 2. coo */
		/* Create a table in COO format for each interval variable. */
		data work.spsvdIn(keep=row col entry);
			set work.tmp;
			by KeyCol;
			retain col row 0;
			if first.KeyCol then do;
				row+1;
				col=0;
			end;
			col+1;
			entry=&int.;
			if not (entry eq 0 or entry eq .) then output;
		run;
		
		/* 3. spsvd */
		proc spsvd data=work.spsvdIn
			local=none max_k=10 res=low; /* global = weight equal to 1 */ /* In practice, no more then k=10 will be needed. */
			output S=S ROWPRO=ROWPRO;
		run;
		
		/* Determine k */
		data _null_;
			retain _k 0;
			set work.S(keep=KEEP);
			if not KEEP then do;
				call symputx('k', _k);
				stop;
			end;
			else _k+1;
		run;
		
		/* Combine */
		data &inputdsn._TSDR;
			merge &inputdsn._TSDR work.ROWPRO(keep=Col1-Col&k. rename=(Col1-Col&k.=&int._Col1-&int._Col&k.));
		run;
		
		proc datasets library=work nolist;
		 	delete tmp spsvdIn ROWPRO S / memtype=data;
		run;
		quit;
		
	%end;

%mend;

%spsvd();

/* end of program */
