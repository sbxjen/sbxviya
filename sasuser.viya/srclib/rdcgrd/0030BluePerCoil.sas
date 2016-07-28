/* Make the connection to CAS */
%include "/home/sasuser/sbxviya/sasuser.viya/srclib/rdcgrd/0000ConnectToCAS.sas";

%let v94dir = /tmp/v94/;

options fullstimer;

proc casutil outcaslib="casuser";
	load file="&v94dir./skp1allpluskeys2.sas7bdat" casout="skp1" promote;
run;

/* Summary statistics for d524 */
proc mdsummary data=mycas.skp1(where=(k_tstmat like '2B%'));
	var d524;
	groupby cl_n dch_n bew_vn k_tstmat d417 d418 ;
	output out=mycas._skp1_mdsummary;
run;

%let firstcoils=51613316 51657554 51958960 51658768 52200237;

/* Print the same results as in SAS 9.4 */
proc print data=mycas._skp1_mdsummary(where=(cl_n in (	"51613316", 
														"51657554", 
														"51958960", 
														"51658768", 
														"52200237"))); run;
														
proc casutil;
	save casdata="skp1" outcaslib="casuser" replace;
run;
/* ERROR: The action stopped due to errors.
   Probably not enough memory. */