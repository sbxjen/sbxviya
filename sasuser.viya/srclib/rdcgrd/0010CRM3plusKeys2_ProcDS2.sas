/* Make the connection to CAS */
%include "/home/sasuser/sbxviya/sasuser.viya/srclib/rdcgrd/0000ConnectToCAS.sas";

/* Load client-side tables (In memory) on CASHOST */
/* This could take a while. */
proc casutil outcaslib="casuser";
	load file="&viyadir./matm2.sas7bdat" casout="matm2";
	load file="&viyadir./crm3_pv_be.sas7bdat" casout="crm3_pv";
run;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

data mycas.matm2(duplicate=yes);
	set mycas.matm2(keep=ts_be ts_ei cl_n dch_n bew_vn a_dch ln_pr);
	where a_dch=0 and ln_pr='CRM3';
	drop a_dch ln_pr;
run;

%let nworkers=%sysfunc(getsessopt(mysess,nworkers)); /* 100 */
%put &nworkers=;

data mycas.crm3_pv(partition=(x)); /* orderby=(ts_registratie)) not longer needed */;
	length x $2;
	set mycas.crm3_pv;*(orderby=(ts_registratie)); /*  NOTE: Partitioning and ordering information is only relevant for output data sets. */
	x = strip(put(mod(ts_registratie,&nworkers.),2.));
	by ts_registratie; /* It is not necessary for the input data set to be sorted first */
	if first.ts_registratie then output; /* Only output first observation of non-unique ones.; */
run;

data _null_;
	if 0  then set mycas.matm2 nobs=lookupnobs;
 	call symput('lookupnobs', strip(put(lookupnobs,12.))); /* Highly efficient way to count nobs without reading a single observation. */
	stop; 
run;

data work.matm2index; matm2start=1; matm2end=&lookupnobs.; output; run;
data mycas.matm2index(duplicate=yes);
	set work.matm2index;
run;
 
data mycas.crm3plusKeysKeyCols(drop=x matm2start matm2end);
	if _n_ = 1 then set mycas.matm2index;
 	set mycas.crm3_pv;
 	do pointer = matm2start to matm2end;
  		set work.matm2(point=pointer); /* Invalid option name POINT. */
  		if ts_be <= ts_registratie <= ts_ei then output; end;
 	end;
run;

/* Save the join result */
proc casutil incaslib="casuser" outcaslib="casuser";
	save casdata="crm3plusKeysKeyCols" replace;
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* Shutdown CAS session */
cas mysess disconnect; cas mysess terminate;

/* end of program */