*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

*proc contents data=insaslib.matm2; run;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* Sort matm2 by ts_be */
proc sort data=insaslib.matm2(keep=ts_be ts_ei cl_n dch_n bew_vn k_tstmat a_dch dl_n_lei dl_n_leu dl_n_bri dl_n_bru ln_pr 
		/* where=(a_dch=0 and ln_pr='SKP1'))  */
		where=((dl_n_lei = dl_n_leu) and (dl_n_bri = dl_n_bru) and ln_pr='SKP1'))
		out=ousaslib.matm2(drop=a_dch ln_pr dl_n_lei dl_n_leu dl_n_bri dl_n_bru); /* All unique, cf. 0005AreMATm2KeysUnique.sas */ 
	by ts_be ts_ei; /* The coils should have been processed in a non-overlapping way, so actually, ts_ei is obsolete here. */ 
run;

/* Concatenate all skp1_pv* data sets */
data ousaslib.skp1_pv_all;
	set insaslib.skp1_pv_2015q1 insaslib.skp1_pv_2015q2 insaslib.skp1_pv_2015q3 insaslib.skp1_pv_2015q4 insaslib.skp1_pv;
	/* UPDATE: not skp_pw_blauwwaarde = d524 = . */
	where not (d524=.);
	drop ts_registratie_gmt datum_reg guid;
run;

/* Sort skp1_pv by ts_registratie */
proc sort data=ousaslib.skp1_pv_all;
	by ts_registratie;
run;
data ousaslib.skp1_pv_all;
	set ousaslib.skp1_pv_all;
	by ts_registratie;
	if first.ts_registratie then output; /* Only output first observation of non-unique ones, cf. 0005Areskp1KeysUnique.sas */  
run;

/* At this point, both obs in matm2 and skp1_pv_all should be sorted by timestamp.
   Obs in matm2 start in 2011, those in skp1_pv_all start in 2015.
   Obs in matm2 can only be mothers. */
data ousaslib.skp1allplusKeys;
	if _n_ = 1 then do; 
		set ousaslib.skp1_pv_all;
		ts_ei = .; /* not really needed */
	end;
	do while (ts_ei < ts_registratie);
		set ousaslib.matm2; /* ts_ei UP */
	end;
	do while (ts_registratie <= ts_ei);
		if (ts_registratie >= ts_be) then output;
		set ousaslib.skp1_pv_all;  /* ts_registratie UP */
	end;
	*keep ts_be ts_ei cl_n dch_n bew_vn ts_registratie d100; /* only KeyCols */
run;

/* No predictive value in these ID variables */
data ousaslib.skp1allplusKeys;
	set ousaslib.skp1allplusKeys;
	drop ts_registratie_gmt datum_reg guid;
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */
