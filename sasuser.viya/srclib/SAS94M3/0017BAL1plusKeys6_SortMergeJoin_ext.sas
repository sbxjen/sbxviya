*;
libname insaslib "/tmp/viya/";
libname ousaslib "/tmp/v94/";
*;

/* Measure real time */
options fullstimer source2;
%let t = %sysfunc(datetime());

/* Sort the resulting matm2 by ts_be */
proc sort data=insaslib.matm2(keep=ts_be ts_ei cl_n dch_n bew_vn a_dch dl_n_lei dl_n_leu dl_n_bri dl_n_bru ln_pr 
		where=((dl_n_lei = dl_n_leu) and (dl_n_bri = dl_n_bru) and  ln_pr='BAL1'))
		out=ousaslib.matm2(drop=a_dch ln_pr dl_n_lei dl_n_leu dl_n_bri dl_n_bru); /* All unique, cf. 0005AreMATm2KeysUnique.sas */ 
	by ts_be ts_ei; /* The coils should have been processed in a non-overlapping way, so actually, ts_ei is obsolete here. */ 
run;

/* Concatenate all bal1* data sets */
filename sascode temp;
data _null_;
	set insaslib.signaaldef_bal1(keep=signaal_nr signaal where=(signaal_nr in ('d074', 'd109', 'd110', 'd111', 'd443', 'd476', 'd477')));
	file sascode;
	put "label " signaal_nr "= '" signaal+(-1)" ';";
run;	
data ousaslib.bal1_pv_all(keep=ts_registratie d074 d109 d110 d111 d443 d476 d477); /* d074 d109 d110 d111 = Dauw, d443 d476 d477 = temp */
	set insaslib.signaallog_bal1_past2 insaslib.signaallog_bal1;
	%include sascode;
run;

/* Sort bal1 by ts_registratie */
proc sort data=ousaslib.bal1_pv_all;
	by ts_registratie;	
run;
data ousaslib.bal1_pv_all;
	set ousaslib.bal1_pv_all;
	by ts_registratie;
	if first.ts_registratie then output; /* Only output first observation of non-unique ones, cf. 0005AreBAL1KeysUnique.sas */  
run;

/* At this point, both matm2 and bal1_pv_all should be sorted by timestamp. */
data ousaslib.bal1allplusKeys;
	if _n_ = 1 then do; 
		set ousaslib.bal1_pv_all;
		ts_ei = .; /* not really needed */
	end;
	do while (ts_ei < ts_registratie);
		set ousaslib.matm2; /* ts_ei UP */
	end;
	do while (ts_registratie <= ts_ei);
		if (ts_registratie >= ts_be) then output;
		set ousaslib.bal1_pv_all;  /* ts_registratie UP */
	end;
	*keep ts_be ts_ei cl_n dch_n bew_vn ts_registratie d100; /* only KeyCols */
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */