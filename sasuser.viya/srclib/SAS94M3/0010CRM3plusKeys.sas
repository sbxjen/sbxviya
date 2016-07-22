*;
libname mysas "/tmp/viya/";
libname myownsas "/tmp/v94/";
*;

proc sort data=mysas.matm2(keep=ts_be ts_ei cl_n dch_n bew_vn a_dch ln_pr where=(a_dch=0 and ln_pr='CRM3')) out=myownsas.matm2(drop=a_dch ln_pr); *** All unique.; 
	by ts_be;
run;

proc sort data=mysas.crm3_pv out=myownsas.crm3_pv;
	by ts_registratie;	
run;
data myownsas.crm3_pv;
	set myownsas.crm3_pv;
	by ts_registratie;
	if first.ts_registratie then output; *** Only output first observation of non-unique ones.; 
run;

data myownsas.crm3plusKeysKeyCols;
	if _n_ = 1 then do; set myownsas.crm3_pv; set myownsas.matm2; end;
	do while (ts_registratie > ts_ei);
		set myownsas.matm2;
	end;
	do while (ts_registratie < ts_be);
		set myownsas.crm3_pv;
	end;
	do while (ts_registratie <= ts_ei);
		output;
		set myownsas.crm3_pv;
	end;
	keep ts_be ts_ei cl_n dch_n bew_vn ts_registratie d100;
run;

/* end of program */