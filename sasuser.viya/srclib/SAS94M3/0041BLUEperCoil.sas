/* SEE ALSO: BLUEPerCoil in SASVIYA / rdcgrd */

*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

proc contents data=ousaslib.skp1allplusKeys; run;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* Summary statistics for d524 */
proc univariate data=ousaslib.skp1allplusKeys(where=(k_tstmat like '2B%')) noprint;
	by notsorted cl_n dch_n bew_vn k_tstmat d417 d418 ;
	var d524;
	output out=_skp1allplusKeys_UNIVARIATE mean=d524;
run;

%put ### Time to load file: %sysevalf( %sysfunc(datetime()) - &t. );
%let t = %sysfunc(datetime());

/* Summary statistics for d524 */
proc univariate data=ousaslib.skp1allplusKeys(where=(k_tstmat like '2B%')) noprint;
	by notsorted cl_n dch_n bew_vn k_tstmat d417 d418 ;
	var d524;
	output out=_skp1allplusKeys2_UNIVARIATE mean=d524;
run;

%put ### Time to load file: %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */