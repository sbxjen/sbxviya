/* Make the connection to CAS */
%include "/home/sasuser/sbxviya/sasuser.viya/srclib/rdcgrd/0000ConnectToCAS.sas";

options fullstimer;
%let t = %sysfunc(datetime());

proc casutil outcaslib="hps";
	load file="&v94dir./skp1allpluskeys2.sas7bdat" casout="skp1allpluskeys2";
run;

%put ### Time to load file: %sysevalf( %sysfunc(datetime()) - &t. );
%let t = %sysfunc(datetime());

/* Summary statistics for d524 */
proc mdsummary data=mycas.skp1allpluskeys2(where=(k_tstmat like '2B%') ondemand=yes);
	var d524;
	groupby cl_n dch_n bew_vn k_tstmat d417 d418 ;
	output out=mycas._skp1allpluskeys2_mdsummary;
run;

%put ### Time need by MDSUMMARY to return descriptive summary statistics: %sysevalf( %sysfunc(datetime()) - &t. );
%let t = %sysfunc(datetime());

/* After warm-up, run a second time */
proc mdsummary data=mycas.skp1allpluskeys2(where=(k_tstmat like '2B%') ondemand=yes);
	var d524;
	groupby cl_n dch_n bew_vn k_tstmat d417 d418 ;
	output out=mycas._skp1allpluskeys2_mdsummary;
run;

%put ### Time need by MDSUMMARY to return descriptive summary statistics: %sysevalf( %sysfunc(datetime()) - &t. );

/* %let firstcoils=51613316 51657554 51958960 51658768 52200237; */
/* Print the same results as in SAS 9.4 */
/* proc print data=mycas._skp1_mdsummary(where=(cl_n in (	"51613316", 
														"51657554", 
														"51958960", 
														"51658768", 
														"52200237"))); run; */