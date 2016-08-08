*;
libname insaslib "/tmp/viya/";
libname ousaslib "/tmp/v94/";
*;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* Sort matm2 by ts_be */
proc sort data=insaslib.matm2(keep=ts_be ts_ei cl_n dch_n bew_vn a_dch ln_pr 
		where=(a_dch=0 and ln_pr='CRM3')) 
		out=ousaslib.matm2(drop=a_dch ln_pr); /* All unique, cf. 0005AreMATm2KeysUnique.sas */ 
	by ts_be ts_ei; /* The coils should have been processed in a non-overlapping way, so actually, ts_ei is obsolete here. */ 
run;

/* Sort crm3_pv by ts_registratie */
proc sort data=insaslib.crm3_pv out=ousaslib.crm3_pv;
	by ts_registratie;
	drop ts_registratie_gmt;
run;
data ousaslib.crm3_pv;
	set ousaslib.crm3_pv;
	by ts_registratie;
	if first.ts_registratie then output; /* Only output first observation of non-unique ones, cf. 0005AreCRM3KeysUnique.sas */  
run;

/* At this point, both matm2 and crm3_pv should be sorted by timestamp.
   Obs in matm2 start in 2011, those in crm3_pv start in 2016. */
data ousaslib.crm3plusKeysKeyCols;
	if _n_ = 1 then do; 
		set ousaslib.crm3_pv;
		ts_ei = .; /* not really needed */
	end;
	do while (ts_ei < ts_registratie);
		set ousaslib.matm2; /* ts_ei UP */
	end;
	do while (ts_registratie <= ts_ei);
		if (ts_registratie >= ts_be) then output;
		set ousaslib.crm3_pv;  /* ts_registratie UP */
	end;
	*keep ts_be ts_ei cl_n dch_n bew_vn ts_registratie d100; /* only KeyCols */
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */