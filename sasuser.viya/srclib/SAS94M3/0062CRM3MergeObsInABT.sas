libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";

/* First make sure that the data sets have the same number of Obs */
/* Then: */

%let inputdsn=ousaslib.crm3allplusKeys;

data &inputdsn._PREP_ALL;
	merge 	&inputdsn._PREP_BINARY 
			&inputdsn._PREP_NOMINAL
			&inputdsn._PREP_SUMM 
			&inputdsn._PREP_TSDR;
	by Keycol;
run;
proc sql feedback stimer _method noprint;
	create table &inputdsn. as
	select a.*, 	
					b.cl_n, b.bew_vn, b.dch_n, 	
					b.dch_n_vr,
					b.a_dch, b.dl_n_lei, b.dl_n_leu, b.dl_n_bri, b.dl_n_bru,
					b.ln_pr
 	from &inputdsn._PREP_ALL 		a
      	 left join ousaslib.matm2 	b
 	on a.KeyCol = b.KeyCol 
 	order by a.KeyCol;
quit;

/* Let's check ... */
data _null_;
	retain n 0;
	set &inputdsn. end=last;
	if upcase(ln_pr) ne "CRM3" then 
		do;
			put ln_pr=;
			n+1;
		end;
	if last then put n=;
run;

/* end of program */