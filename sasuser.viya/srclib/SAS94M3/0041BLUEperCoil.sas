/* SEE ALSO: BLUEPerCoil in SASVIYA / rdcgrd */

*;
libname mysas "/tmp/viya/" access=readonly;
libname myownsas "/tmp/v94/";
*;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());

/* Summary statistics for d524 */
proc univariate data=myownsas.skp1allplusKeys2(where=(k_tstmat like '2B%')) noprint;
	by notsorted cl_n dch_n bew_vn k_tstmat d417 d418 ;
	var d524;
	output out=_skp1allplusKeys2_univariate mean=d524;
run;

%put ### Time to load file: %sysevalf( %sysfunc(datetime()) - &t. );
%let t = %sysfunc(datetime());

/* Summary statistics for d524 */
proc univariate data=myownsas.skp1allplusKeys2(where=(k_tstmat like '2B%')) noprint;
	by notsorted cl_n dch_n bew_vn k_tstmat d417 d418 ;
	var d524;
	output out=_skp1allplusKeys2_univariate mean=d524;
run;

%put ### Time to load file: %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */