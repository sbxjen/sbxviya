*;
libname mysas "/tmp/viya/";
libname myownsas "/tmp/v94/";
*;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());


/* Select Unique Coil Keys WHERE skp_bpw_lauwwaarde = d524 ne . (cf. 0015SKP1plusKeys6_SortMergeJoin_ext.sas) */
proc sort 	data=myownsas.skp1allplusKeys(keep=cl_n dch_n bew_vn)
			out=myownsas.skp1CoilKeys;
	by cl_n dch_n bew_vn;
	if first.bew_vn;
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */