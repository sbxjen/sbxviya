%let viyadir = "/tmp/viya/";

%let tables = 	matm2
				ba_all_skp_ont
				crm3_pv_2015Q1 crm3_pv_2015Q2 crm3_pv_2015Q3 crm3_pv_2015Q4 crm3_pv crm3_sigdef 
				crm3_allcil_coil crm3_werkcil_pas crm3pasm crm3_data_coil crm3_flat2
/* 				coil_bandvervolging_bal1 sectiedef_bal1 signaallog_bal1 signaallog_bal1_past2 bal1_sigdef bal1scad */
				skp1_pv_2015Q1 skp1_pv_2015Q2 skp1_pv_2015Q3 skp1_pv_2015Q4 skp1_pv skp1_sigdef skp_cilinders;

cas casauto;

caslib aperam datasource=(srctype="path") 
	path=&viyadir.;

/* Create a CAS engine libref. */
%let caslibname = mycas;
libname &caslibname. cas caslib="aperam";

/* Load server-side files in-memory. */
%macro casload(tab=);
%let n=%sysfunc(countw(&tab,%str( )));
%do i = 1 %to &n;
	%let dsn=%scan(&tab, &i);
	proc casutil;
		load casdata="&dsn..sas7bdat" replace
		casout="&dsn";
	run;
	proc contents data=&caslibname..&dsn;
	run;
%end;
%mend;

%casload(tab=&tables);