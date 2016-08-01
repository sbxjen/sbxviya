/* Make the connection to CAS */
%include "/home/sasuser/sbxviya/sasuser.viya/srclib/rdcgrd/0000ConnectToCAS.sas";

options fullstimer;

proc casutil outcaslib="&mycaslib.";
	load casdata="user/sbxjen/skp1allplusKeys.sas7bdat" casout="skp1allpluskeys" promote;
run;

/* Summary statistics for d524 */
proc casutil;
	list tables incaslib="&mycaslib.";
run;

%put %sysfunc(getsessopt(mysess,nworkers));
%let t = %sysfunc(datetime());

/* Summary statistics for d524 */
proc mdsummary data=mycas.skp1allpluskeys(where=(k_tstmat like '2B%') ondemand=yes);
	var d524;
	groupby cl_n dch_n bew_vn k_tstmat d417 d418 ;
	output out=mycas._skp1allplusKeys_MDSUMMARY;
run;

%put ### Time need by MDSUMMARY to return descriptive summary statistics: %sysevalf( %sysfunc(datetime()) - &t. );
%let t = %sysfunc(datetime());

/* After warm-up, run a second time */
proc mdsummary data=mycas.skp1allpluskeys(where=(k_tstmat like '2B%') ondemand=yes);
	var d524;
	groupby cl_n dch_n bew_vn k_tstmat d417 d418 ;
	output out=mycas._skp1allplusKeys_MDSUMMARY;
run;

%put ### Time need by MDSUMMARY to return descriptive summary statistics: %sysevalf( %sysfunc(datetime()) - &t. );
																					
/* end of program */