*;
libname insaslib "/tmp/viya/";
libname ousaslib "/tmp/v94/";
*;

/* The first method only works for joining skp1 with matm2, not for joining skp1 with skp1_cilinders. */

/* Sort skp_cilinders by ts_be */
*proc sort 	data=insaslib.skp_cilinders
*			out=ousaslib.skp_cilinders; /* All unique, cf. 0007AreCilinderKeysUnique.sas */ 
*	by einddatum einddatumskp; /* The logs should be non-overlapping, so actually, einddatumskp is obsolete here. */ 
*run;

/* Sort skp1_pv by ts_registratie */
*proc sort data=ousaslib.skp1allplusKeys;
*	by ts_registratie;
*run;

/* At this point, both skp_cilinders and skp1_pv_all should be sorted by timestamp.
   Obs in skp_cilinders start in 2010, those in skp1_pv_all start in 2015. */
*data ousaslib.skp1allplusKeysplusCilinders;
*	if _n_ = 1 then do; 
*		set ousaslib.skp1allplusKeys;
*		einddatumskp = .; /* not really needed */
*	end;
*	do while (einddatumskp < ts_registratie);
*		set ousaslib.skp_cilinders; /* ts_ei UP */
*	end;
*	do while (ts_registratie <= einddatumskp);
*		if (ts_registratie >= einddatum) then output;
*		set ousaslib.skp1allplusKeys;  /* ts_registratie UP */
*	end;
	*keep ts_be ts_ei cl_n dch_n bew_vn ts_registratie d100; /* only KeyCols */
*run;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

data ousaslib.skp_cilinders;
	set insaslib.skp_cilinders;
	ComponentDigits = input(substr(ComponentName,length(ComponentName)-1,2),2.0);
run;

/* Create macros to rename variables in skp_cilinders for T (top) and B (bottom) side. */
proc contents data=ousaslib.skp_cilinders out=varnames; 
data _null_;
	length _Tvars $6000 _Bvars $6000;
	retain _Tvars _Bvars ;
	set varnames end=last;
	_Tvars = catx( " ", _Tvars, catx( "=", name, catx('_', name, 'T') ) ) ; 
	_Bvars = catx( " ", _Bvars, catx( "=", name, catx('_', name, 'B') ) ) ; 
	if last then do;
		call symputx("toplist", _Tvars);			call symputx("bottomlist", _Bvars);
	end;
run;

data ousaslib.skp_cilinders_T(rename=(&toplist.)) ousaslib.skp_cilinders_B(rename=(&bottomlist.));
	set ousaslib.skp_cilinders;
run;

proc ds2;
	data ousaslib.skp1allplusKeysplusCilinders1(overwrite=yes);
	method run();
		set { select *
			  from ousaslib.skp1allplusKeys a
      		  left join ousaslib.skp_cilinders_T b
      		  on ( 
      		  		(b.ComponentDigits_T = a.d417)
      		  and 	 
      		  		(b.einddatum_T <= a.ts_registratie <= b.einddatumskp_T) 
      		  	 )
 			  order by a.cl_n, a.bew_vn, a.dch_n, a.ts_registratie 
			};
		if 1=1 then output ousaslib.skp1allplusKeysplusCilinders1;
	    end;
	enddata;
	run;
quit;

proc ds2;
	data ousaslib.skp1allplusKeysplusCilinders(overwrite=yes);
	method run();
		set { select *
			  from ousaslib.skp1allplusKeysplusCilinders1 a
      		  left join ousaslib.skp_cilinders_B b
      		  on ( 
      		  		(b.ComponentDigits_B = a.d418)
      		  and 	 
      		  		(b.einddatum_B <= a.ts_registratie <= b.einddatumskp_B) 
      		  	 )
 			  order by a.cl_n, a.bew_vn, a.dch_n, a.ts_registratie 
			};
		if 1=1 then output ousaslib.skp1allplusKeysplusCilinders;
	    end;
	enddata;
	run;
quit;

proc datasets library=ousaslib nolist;
	delete skp_cilinders_T skp_cilinders_B skp1allplusKeysplusCilinders1 / memtype=data;
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */

/* test code */

/*
data work.cil;
	length ComponentName $ 45;
	input ComponentName $30.;
	ComponentDigits = input(substr(ComponentName,length(ComponentName)-1,2),2.0);
datalines;
POSB10
PUE62
;
run;

data work.skp
	length d417;
	input d417 9.2;
datalines;
0.0
0.0
10.0
62.0
48.0
62.0
;
run;

proc ds2;
	data work.merged(overwrite=yes);
	method run();
		set { select *
			  from work.skp a
      		  left join work.cil b
      		  on b.ComponentDigits = a.d417 
			};
		if 1=1 then output work.merged;
	    end;
	enddata;
	run;
quit;
*/