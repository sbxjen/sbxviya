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

/* Sort skp1_pv by ts_registratie - SHOULD BE DONE */
*proc sort data=ousaslib.skp1allplusKeys;
*	by ts_registratie;
*run;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

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

data oucaslib.skp_cilinders;
	set oucaslib.skp_cilinders;
	ComponentDigits = input(substr(ComponentName,length(ComponentName)-1,2),2.0);
run;

proc ds2;
	data ousaslib.skp1allplusKeysplusCilinders(overwrite=yes);
	method run();
		set { select *
			  from ousaslib.skp1allplusKeys2 a /* 2 = only with BLUE */
      		  left join ousaslib.skp_cilinders b
      		  on ( 
      		  		(b.ComponentDigits=a.d417 or b.ComponentDigits=a.d418)
      		  and 	 
      		  		 b.einddatum <= a.ts_registratie <= b.einddatumskp 
      		  	 )
 			  order by a.cl_n, a.dch_n, a.bew_vn, a.ts_registratie 
			};
		if 1=1 then output ousaslib.skp1allplusKeysplusCilinders;
	    end;
	enddata;
	run;
quit;

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