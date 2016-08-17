/* INTERVAL */
%macro mergeMeansStddevsWInterval();
	
	data &inputdsn._SUMM;
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
<<<<<<< HEAD:sasuser.viya/srclib/SAS94M3/0050Summ_macrodef.sas

/*
1          OPTIONS NONOTES NOSTIMER NOSOURCE NOSYNTAXCHECK;
 55         
 56         data _null_;
 57         retain x;
 58         set ousaslib.crm3allplusKeys_PREP_NOINTERVAL(keep=KeyCol) end=eof;
 59         by KeyCol;
 60         if first.KeyCol then i = 0;
 61         i+1;
 62         if last.KeyCol then do;
 63         if i > x then x=i;
 64         end;
 65         if eof then put x=;
 66         run;
 
 x=35926
 NOTE: There were 7629411 observations read from the data set OUSASLIB.CRM3ALLPLUSKEYS_PREP_NOINTERVAL.
 NOTE: DATA statement used (Total process time):
       real time           14.20 seconds
       cpu time            14.22 seconds
*/

=======
		
>>>>>>> 662b72f64fa548b59a7b1a4037bf7d3a2326b982:sasuser.viya/srclib/SAS94M3/0050SKP1Summ_wals.sas
		data Means(drop=&int. Mean stddev x: i j);
			array x{36000}; 
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
  		data &inputdsn._SUMM;
  			merge &inputdsn._SUMM Means;
  			by KeyCol;
  		run;
  		
  		proc datasets library=work nolist;
 			delete tmp Means / memtype=data;
 		run;
 		quit;
  		
  	%end;

%mend;

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

/* end of program */
