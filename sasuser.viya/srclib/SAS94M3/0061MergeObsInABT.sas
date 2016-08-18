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


/* SKP1 */
%let inputdsn=ousaslib.skp1walsplusKeys; /* also TARGET */
%let inputdsn=ousaslib.skp1small;

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

/* A little check */
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


/* CRM3 */
%let inputdsn=ousaslib.crm3allplusKeys;
%let inputdsn=ousaslib.crm3small;

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

/* A little check */
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


options mprint source2;

filename sascode temp;

data _null_;
	set ousaslib.skp1walsplusKeys end=last;
 	file sascode;
	if _n_=1 then do;
PUT 'data ousaslib.SKP1plusCRM3plusKeys;';
PUT 'run'; 
PUT '';



PUT 'LENGTH SJR_CL $ 4 CL_N $ 8 DCH_N 8 BEW_VN 8 LN_PR $ 4'; 
PUT '       TS_Registratie 8 TS_BEGIN 8 TS_EINDE 8;       ';
PUT ' set work.crm3_pv;             ';
PUT " retain LN_PR 'CRM3';          ";
 end;
PUT ' TS_BEGIN = "' TS_BE +(-1) '"dt;'; 
PUT ' TS_EINDE = "' TS_EI +(-1) '"dt;';
PUT ' if ((TS_Registratie >= TS_BEGIN) AND (TS_Registratie <= TS_EINDE)) then ';
PUT 'DO;                            ';
PUT ' SJR_CL   = "' SJR_CL +(-1) '";';
PUT ' CL_N     = "' CL_N   +(-1) '";';
PUT ' DCH_N    = ' DCH_N  ';        ';
PUT ' BEW_VN   = ' BEW_VN ';        ';
PUT 'output; END;                   ';

proc append base=ousaslib.SKP1plusCRM3plusKeys
			data=work.oneCoilplusKeys;
run;


 if last then do;
PUT ' format TS_BEGIN TS_EINDE 25.3;'; 
PUT 'run;';
 end;
run;

%INCLUDE sascode;
filename sascode CLEAR;

data matm2OnlyThisCoil;
	set work.mycoils(firstobs=8 obs=8 keep=	cl_n dch_n bew_vn 
											dch_n_vr 
											a_dch dl_n_lei dl_n_leu dl_n_bri dl_n_bru);
	call symputx("_cl_n",		cl_n);
	call symputx("_dch_n_vr",	dch_n_vr);
	call symputx("_bew_vn",		bew_vn);
	drop dch_n_vr;
run;


/* end of program */