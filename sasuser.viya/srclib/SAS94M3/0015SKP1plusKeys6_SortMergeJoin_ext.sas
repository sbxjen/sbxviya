*;
libname mysas "/tmp/viya/";
libname myownsas "/tmp/v94/";
*;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* Sort matm2 by ts_be */
proc sort data=mysas.matm2(keep=ts_be ts_ei cl_n dch_n bew_vn k_tstmat a_dch dl_n_lei dl_n_leu ln_pr 
		where=(a_dch=0 and ln_pr='SKP1')) 
		/* where=((dl_n_lei = dl_n_leu) and ln_pr='SKP1') */
		out=myownsas.matm2(drop=a_dch ln_pr dl_n_lei dl_n_leu); /* All unique, cf. 0005AreMATm2KeysUnique.sas */ 
	by ts_be ts_ei; /* The coils should have been processed in a non-overlapping way, so actually, ts_ei is obsolete here. */ 
run;

/* Concatenate all skp1_pv* data sets */
data myownsas.skp1_pv_all;
	set mysas.skp1_pv_2015q1 mysas.skp1_pv_2015q2 mysas.skp1_pv_2015q3 mysas.skp1_pv_2015q4 mysas.skp1_pv;
run;

/* Sort skp1_pv by ts_registratie */
proc sort data=myownsas.skp1_pv_all;
	by ts_registratie;	
run;
data myownsas.skp1_pv_all;
	set myownsas.skp1_pv_all;
	by ts_registratie;
	if first.ts_registratie then output; /* Only output first observation of non-unique ones, cf. 0005Areskp1KeysUnique.sas */  
run;

/* At this point, both matm2 and skp1_pv_all should be sorted by timestamp.
   Obs in matm2 start in 2011, those in skp1_pv_all start in 2015. */
data myownsas.skp1allplusKeys;
	if _n_ = 1 then do; 
		set myownsas.skp1_pv_all;
		ts_ei = .; /* not really needed */
	end;
	do while (ts_ei < ts_registratie);
		set myownsas.matm2; /* ts_ei UP */
	end;
	do while (ts_registratie <= ts_ei);
		if (ts_registratie >= ts_be) then output;
		set myownsas.skp1_pv_all;  /* ts_registratie UP */
	end;
	*keep ts_be ts_ei cl_n dch_n bew_vn ts_registratie d100; /* only KeyCols */
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */