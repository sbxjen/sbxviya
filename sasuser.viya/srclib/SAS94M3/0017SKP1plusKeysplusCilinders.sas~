*;
libname mysas "/tmp/viya/" access=readonly;
libname myownsas "/tmp/v94/";
*;

/* Sort skp_cilinders by ts_be */
*proc sort 	data=mysas.skp_cilinders
*			out=myownsas.skp_cilinders; /* All unique, cf. 0007AreCilinderKeysUnique.sas */ 
*	by einddatum einddatumskp; /* The logs should be non-overlapping, so actually, einddatumskp is obsolete here. */ 
*run;

/* Sort skp1_pv by ts_registratie - SHOULD BE DONE */
*proc sort data=myownsas.skp1_pv_all;
*	by ts_registratie;
*run;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* At this point, both skp_cilinders and skp1_pv_all should be sorted by timestamp.
   Obs in skp_cilinders start in 2010, those in skp1_pv_all start in 2015. */
data myownsas.skp1allplusKeysplusCilinders;
	if _n_ = 1 then do; 
		set myownsas.skp1_pv_all;
		einddatumskp = .; /* not really needed */
	end;
	do while (einddatumskp < ts_registratie);
		set myownsas.skp_cilinders; /* ts_ei UP */
	end;
	do while (ts_registratie <= einddatumskp);
		if (ts_registratie >= einddatum) then output;
		set myownsas.skp1_pv_all;  /* ts_registratie UP */
	end;
	*keep ts_be ts_ei cl_n dch_n bew_vn ts_registratie d100; /* only KeyCols */
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */