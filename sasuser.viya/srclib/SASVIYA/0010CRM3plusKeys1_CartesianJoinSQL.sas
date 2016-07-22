/* List Tables (in-memory) and Files (in Datasource) */
proc casutil; 
	list tables incaslib="aperam"; 
	list files incaslib="aperam"; 
run;

/* Load data in-memory. */
proc casutil outcaslib="aperam";
	load casdata="matm2.sas7bdat" casout="matm2";
	load casdata="crm3_pv.sas7bdat" casout="crm3_pv";
run;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

data mycas.matm2(duplicate=yes);
	set mycas.matm2(keep=ts_be ts_ei cl_n dch_n bew_vn a_dch ln_pr);
	where a_dch=0 and ln_pr='CRM3';
	drop a_dch ln_pr;
run;

/*
%let nworkers=%sysfunc(getsessopt("mysess", "nworkers"));
%put &nworkers=;
*/
%let nworkers=10;

data mycas.crm3_pvb(partition=(x) orderby=(ts_registratie));
	set mycas.crm3_pv(orderby=(ts_registratie));
	length x $1;
	x = strip(put(mod(ts_registratie, input(&nworkers,best.)),$1.));
	by ts_registratie;
	if first.ts_registratie then output; /* Only output first observation of non-unique ones.; */
run;


data _null_;
	if 0 then set work.matm2 nobs=lookupnobs;
 	call symput('lookupnobs', strip(put(lookupnobs,12.))); /* Highly efficient way to count nobs without reading a single observation. */
	stop; 
run;

data work.matm2index; matm2start=1; matm2end=&lookupnobs.; output; run;
data mycas.matm2index duplicate=yes;
	set work.matm2index;
run;
 
data mycas.crm3plusKeysKeyCols(drop=ts_be ts_ei mon matm2start matm2end);
	if _n_ = 1 then set mycas.matm2index;
 	set mycas.crm3_pv;
 	do pointer = matm2start to matm2end;
  		set work.matm2(firstobs=pointer obs=pointer+1); /* Is point=pointer possible? */
  		if ts_be <= ts_registratie <= ts_ei then output; end;
 	end;
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* Shutdown CAS session */
caslib _all_ drop;
cas mysess disconnect; cas mysess terminate;

/* end of program */