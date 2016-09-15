/* Create a copy of HEART in the SAS 9.4 WORK library. */
proc copy in=sashelp out=work ;
	select heart;
run;

/* Connect to the Viya server and rsubmit the code to upload */
/* the test file created above. */
%let myserver=sbxintern16.sbx.sas.com 37551;
options remote=myserver;

/* Initiate signon to Connect to the server in the Viya environment */
signon user=sasuser passwd=Orion123;

rsubmit;

/* Allocate CAS library – mycas as sasuser. */
options casuser=sasuser;
libname mycas cas caslib="casuser" host="sbxintern16.sbx.sas.com" port=5570;

/* Upload the HEART dataset from the SAS 9.4 WORK to the CAS library. */
proc upload data=heart out=mycas.heart94; 
run;

/* Perform some simple CAS analytics. */
proc mdsummary data=mycas.heart94;
	groupby deathcause;
	var cholesterol systolic diastolic;
	output out=mycas.heartsum94; 
run;

/* Verify the CAS datasets in the CAS library */
proc datasets lib=mycas; 
run;

proc print data=mycas.heartsum94; 
run;

endrsubmit;

signoff;