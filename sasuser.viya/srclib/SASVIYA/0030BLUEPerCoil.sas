/* Make the connection to CAS */
%include "/home/sasuser/sbxviya/sasuser.viya/srclib/rdcgrd/0000ConnectToCAS.sas";

options fullstimer;
%let t = %sysfunc(datetime());

proc casutil;
	load file="skp1allpluskeys.sas7bdat";
run;

%put ### Time to load file: %sysevalf( %sysfunc(datetime()) - &t. );
%let t = %sysfunc(datetime());

/* Summary statistics for d524 */
proc mdsummary data=mycas.skp1allpluskeys(where=(k_tstmat like '2B%') ondemand=yes);
	var d524;
	groupby cl_n dch_n bew_vn k_tstmat d417 d418 ;
	output out=mycas._skp1allpluskeys2_mdsummary;
run;

%put ### Time need by MDSUMMARY to return descriptive summary statistics: %sysevalf( %sysfunc(datetime()) - &t. );
%let t = %sysfunc(datetime());

/* After warm-up, run a second time */
proc mdsummary data=mycas.skp1allpluskeys(where=(k_tstmat like '2B%') ondemand=yes);
	var d524;
	groupby cl_n dch_n bew_vn k_tstmat d417 d418 ;
	output out=mycas._skp1allpluskeys2_mdsummary;
run;

%put ### Time need by MDSUMMARY to return descriptive summary statistics: %sysevalf( %sysfunc(datetime()) - &t. );