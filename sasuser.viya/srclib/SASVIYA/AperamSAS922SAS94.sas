/* Convert the SAS 9.x Data Sets */
%let datadir = "/tmp/srcdata/";
%let viyadir = "/tmp/viya/";

libname mysasv9 cvp &datadir.;
libname mysas &viyadir.;

/* List the TABLES you want to convert */
%let tables = 	coil_bandvervolging_bal1;
/*				matm2
				ba_all_skp_ont
				crm3_pv_2015Q1 crm3_pv_2015Q2 crm3_pv_2015Q3 crm3_pv_2015Q4 crm3_pv crm3_sigdef 
				crm3_allcil_coil crm3_werkcil_pas crm3pasm crm3_data_coil crm3_flat2
/* 				coil_bandvervolging_bal1 sectiedef_bal1 signaallog_bal1 signaallog_bal1_past2 signaaldef_bal1 bal1scad */
/*				skp1_pv_2015Q1 skp1_pv_2015Q2 skp1_pv_2015Q3 skp1_pv_2015Q4 skp1_pv skp1_sigdef skp_cilinders;

/* Copy.
   Using the NOCLONE option results in a copy with the data representation of the output data library. */
proc copy in=mysasv9 out=mysas noclone; 	
	select &tables;
run;