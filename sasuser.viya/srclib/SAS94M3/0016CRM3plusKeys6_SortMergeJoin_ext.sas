*;
libname insaslib "/tmp/viya/";
libname ousaslib "/tmp/v94/";
*;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* Sort the resulting matm2 by ts_be */
proc sort data=insaslib.matm2(keep=ts_be ts_ei cl_n dch_n bew_vn a_dch dl_n_lei dl_n_leu dl_n_bri dl_n_bru ln_pr 
		/* where=(a_dch=0 and ln_pr='CRM3')) */
		where=((dl_n_lei = dl_n_leu) and (dl_n_bri = dl_n_bru) and  ln_pr='CRM3'))
		out=ousaslib.matm2(drop=a_dch ln_pr dl_n_lei dl_n_leu dl_n_bri dl_n_bru); /* All unique, cf. 0005AreMATm2KeysUnique.sas */ 
	by ts_be ts_ei; /* The coils should have been processed in a non-overlapping way, so actually, ts_ei is obsolete here. */ 
run;

/* Concatenate all crm3_pv* data sets */
data ousaslib.crm3_pv_all;
	set insaslib.crm3_pv_2015q1 insaslib.crm3_pv_2015q2 insaslib.crm3_pv_2015q3 insaslib.crm3_pv_2015q4 insaslib.crm3_pv;
	drop ts_registratie_gmt datum_reg guid;
run;

/* Sort crm3_pv by ts_registratie */
proc sort data=ousaslib.crm3_pv_all;
	by ts_registratie;	
run;
data ousaslib.crm3_pv_all;
	set ousaslib.crm3_pv_all;
	by ts_registratie;
	if first.ts_registratie then output; /* Only output first observation of non-unique ones, cf. 0005AreCRM3KeysUnique.sas */  
run;

/* At this point, both matm2 and crm3_pv_all should be sorted by timestamp.
   Obs in matm2 start in 2011, those in crm3_pv_all start in 2015. */
data ousaslib.crm3allplusKeys;
	if _n_ = 1 then do; 
		set ousaslib.crm3_pv_all;
		ts_ei = .; /* not really needed */
	end;
	do while (ts_ei < ts_registratie);
		set ousaslib.matm2; /* ts_ei UP */
	end;
	do while (ts_registratie <= ts_ei);
		if (ts_registratie >= ts_be) then output;
		set ousaslib.crm3_pv_all;  /* ts_registratie UP */
	end;
	*keep ts_be ts_ei cl_n dch_n bew_vn ts_registratie d100; /* only KeyCols */
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */