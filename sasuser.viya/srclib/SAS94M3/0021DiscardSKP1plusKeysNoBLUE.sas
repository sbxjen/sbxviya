/* SEE ALSO: UPDATE in 0015SKP1plusKeys6_SortMergeJoin_ext.sas */

*;
libname mysas "/tmp/viya/";
libname myownsas "/tmp/v94/";
*;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());


/* Select Unique Coil Keys WHERE skp_pw_blauwwaarde = d524 ne . (cf. 0015SKP1plusKeys6_SortMergeJoin_ext.sas) */
data myownsas.skp1allplusKeys2;
	set myownsas.skp1allplusKeys;
	where not (d524 = .);
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */