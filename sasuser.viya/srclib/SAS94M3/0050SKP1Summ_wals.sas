*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

%let inputdsn=ousaslib.skp1walsplusKeys_PREP;
*%let inputdsn=ousaslib.crm3allplusKeys_PREP;
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
data &inputdsn._NOINTERVAL(drop=&KeyCols. ts_registratie &INTERVAL. ts_be ts_ei _vars) &inputdsn._INTERVAL(keep=KeyCol ts_registratie &INTERVAL. _vars);
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



proc sort data=&inputdsn._NOINTERVAL;
	by KeyCol;
run;
data &inputdsn._BASE;
	set &inputdsn._NOINTERVAL(keep=KeyCol); /* INTERVAL would have worked as well */
	by KeyCol;
	if first.KeyCol then output;
run;



/*  Do some cool stuff with TSDR in SAS Enterprise Miner to summarize &inputdsn._INTERVAL.
	OR:
*/
/* INTERVAL */
%macro mergeMeansStddevsWInterval();
	
	data &inputdsn._TSDR;
  		set &inputdsn._BASE;
  	run;
	
	/* Again, loop over all variables in INTERVAL... */
	%let nvar=%sysfunc(countw(&intlist.,%str( )));
	%do ivar=1 %to &nvar.;
		%let int=%scan(&intlist.,&ivar.);
		
		/* Calculate means and stddevs. */
		/* The easiest way to structure this is without the use of PROC MEANS */
		data work.tmp;
			set &inputdsn._INTERVAL(keep=KeyCol &int.);
		run;
		proc sort data=work.tmp;
			by KeyCol;
		run;
		
		data Means(drop=&int. Mean stddev x: i j);
			array x{3000}; 
	  		do until (last.KeyCol);
	    		set work.tmp;
	    		by KeyCol;
	    		if first.KeyCol then i=0;
	    		i+1;
	    		x{i}=&int.; 
	 		end;
	 		Mean = mean(of x:); stddev = std(of x:);
	 		do j=1 to dim(x); x{j}=.; end;
	  		&int._Mean = Mean; &int._Stddev = stddev; 
	  		output Means;
  		run;
  		
  		/* Then merge. */
  		data &inputdsn._TSDR;
  			merge &inputdsn._TSDR Means;
  			by KeyCol;
  		run;
  		
  		proc datasets library=work nolist;
 			delete tmp Means / memtype=data;
 		run;
 		quit;
  		
  	%end;

%mend;



/* For now, 
	BINARY 0/1: proportion 1's
	NOMINAL variables: mode
*/

/* Determine binary variables and collect them into binlist. */
%include '/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0042DetermineBINColumns.sas';
%put &=binlist.;

/* To get an exhaustive nomlist: */
data _null_;
	if _n_=1 then set &inputdsn._NOINTERVAL(drop=&binlist. obs=1);
	length _vars $6000;
	array _n _numeric_ _dumn; 
	array _c _character_ _dumc; 
	do i = 1 to dim(_n)-1;       /* -1 because of dummy _dumn */
    	_vars = catx(" ", _vars, vname(_n{i}));
    end;
	do i = 1 to dim(_c)-1;       /* -1 because of dummy _dumc */
    	if not (vname(_c{i})="KeyCol" or vname(_c{i})="_vars") then _vars = catx(" ", _vars, vname(_c{i}));
    end;
	call symputx("nomlist", _vars);
run;
%put &=nomlist.;


/* BINARY */
%macro mergePropsWBinary();
	
	data &inputdsn._NOINTERVAL;
		set &inputdsn._NOINTERVAL;
		one=1;
	run;
	data &inputdsn._BINARY;
		set &inputdsn._BASE;
	run;
	
	/* Again, loop over all variables in binlist... */
	%let nvar=%sysfunc(countw(&binlist.,%str( )));
	%do ivar=1 %to &nvar.;
		%let bin=%scan(&binlist.,&ivar.);

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
		   set onewayfreq;
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
		quit;
		
	%end;

%mend;


/* NOMINAL */
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
 		quit;
  		
  	%end;

%mend;

*options source2;

%mergeMeansStddevsWInterval()
%mergePropsWBinary();	
%mergeModesWNominal();

/* end of program */

