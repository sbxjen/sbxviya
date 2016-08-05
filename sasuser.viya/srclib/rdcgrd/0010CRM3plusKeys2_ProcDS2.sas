/* Make the connection to CAS */
/* %include "/home/sasuser/sbxviya/sasuser.viya/srclib/rdcgrd/0000ConnectToCAS.sas";

/* Load client-side tables (In memory) on CASHOST */
/* This could take a while. */
/* proc casutil outcaslib="&mycaslib.";
	load file="/tmp/viya/matm2.sas7bdat" casout="matm2" promote;
	load file="/tmp/v94/crm3_pv_all.sas7bdat" casout="crm3_pv_all" promote;
run; */

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* Load (server-side) files In memory */
proc casutil incaslib="&mycaslib.";
	load casdata="matm2.sashdat" casout="matm2" promote;
	load casdata="crm3_pv_all.sashdat" casout="crm3_pv_all" promote;
run;

/* Duplicate over all worker nodes */
data mycas.matm2(duplicate=yes);
	set mycas.matm2(keep=	ts_be ts_ei cl_n dch_n bew_vn 
							ln_pr 
							dl_n_lei dl_n_leu dl_n_bri dl_n_bru);
	where (dl_n_lei = dl_n_leu) and (dl_n_bri = dl_n_bru) and (ln_pr='CRM3');
	drop ln_pr dl_n_lei dl_n_leu dl_n_bri dl_n_bru;
run;

%let nworkers=%sysfunc(getsessopt(mysess,nworkers)); /* 100 */
%put &nworkers=;

/* Partition over all worker nodes */
data mycas.crm3_pv_all(partition=(x)); /* orderby=(ts_registratie)) not longer needed */;
	length x $2;
	set mycas.crm3_pv_all;
	x = strip(put(mod(ts_registratie,&nworkers.),2.));
run;

proc ds2;
	data mycas.crm3allplusKeys;
    method run();
		set	{	select	a.*, b.*
				from	mycas.crm3_pv_all a,
      					mycas.matm2    b
 				where 	a.ts_registratie between b.ts_be and b.ts_ei 
				order by b.cl_n, b.dch_n, b.bew_vn a.ts_registratie 
           	};
    if 1=1 then output mycas.crm3allplusKeys;
    end;
  	enddata;
run;
quit;

/* Save the join result */
proc casutil incaslib="&mycaslib." outcaslib="&mycaslib.";
	save casdata="crm3allplusKeys" replace;
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* Shutdown CAS session */
%include "/home/sasuser/sbxviya/sasuser.viya/srclib/rdcgrd/0001CloseConn.sas";
/* end of program */