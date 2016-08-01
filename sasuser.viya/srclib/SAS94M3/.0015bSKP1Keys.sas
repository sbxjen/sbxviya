*;
libname insaslib "/tmp/viya/";
libname ousaslib "/tmp/v94/";
*;

/* Measure real time */
options fullstimer;
%let t = %sysfunc(datetime());


/* Select Unique Coil Keys WHERE skp_bpw_lauwwaarde = d524 ne .  - now also included in 0015SKP1plusKeys6_SortMergeJoin_ext.sas */
proc sort 	data=ousaslib.skp1allplusKeys(keep=cl_n dch_n bew_vn d524)
			out=ousaslib.skp1CoilKeys;
	where (d524 ne .);
	by cl_n dch_n bew_vn;
	if first.bew_vn;
	drop d524;
run;

%put ### %sysevalf( %sysfunc(datetime()) - &t. );

/* end of program */