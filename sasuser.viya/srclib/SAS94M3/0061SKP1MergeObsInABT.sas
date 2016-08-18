libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";


/* This list was generated based on the Appendix: Predictor blocks and variables 
   from Predictive Modelling for a Quality Target Based on High-Dimensional High-Frequency Data 
   and common sense. */
%let material_specific=br di le k_atp k_nm_atp k_afw knt_bb aust_fer wrk_n g g_in;

data ousaslib.matm2(keep=	KeyCol 
							cl_n bew_vn dch_n 	
							dch_n_vr 
							a_dch dl_n_lei dl_n_leu dl_n_bri dl_n_bru
							ln_pr
							&material_specific.);
	set insaslib.matm2;
	KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.));
run;


/* First make sure that the data sets have the same number of Obs */
/* Then: */

%let inputdsn=ousaslib.skp1walsplusKeys; /* also TARGET */

data &inputdsn._PREP_ALL;
	merge 	&inputdsn._PREP_TARGET
			&inputdsn._PREP_BINARY 
			&inputdsn._PREP_NOMINAL
			&inputdsn._PREP_SUMM 
			&inputdsn._PREP_TSDR;
	by Keycol;
run;
data &inputdsn._PREP_ALL(drop=cl_n bew_vn dch_n);
	set &inputdsn._PREP_ALL;
	cl_n 	= scan(KeyCol,1,"_");
	bew_vn 	= scan(KeyCol,2,"_");
	dch_n 	= scan(KeyCol,3,"_");
	KeyCol_deel = KeyCol;
	KeyCol = catx("_", cl_n, bew_vn, dch_n);
run;
proc sql feedback stimer _method noprint;
	create table &inputdsn. as
	select a.*, b.*
 	from &inputdsn._PREP_ALL 		a
      	 left join ousaslib.matm2 	b
 	on a.KeyCol = b.KeyCol 
 	order by a.KeyCol_deel;
quit;

/* Let's check ... */
data _null_;
	retain n 0;
	set &inputdsn. end=last;
	if upcase(ln_pr) ne "SKP1" then 
		do;
			put ln_pr=;
			n+1;
		end;
	if last then put n=;
run;

/* end of program */