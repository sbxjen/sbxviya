/* Define the connection parameters for SAS/Connect. */
/* The SAS/Connect Spawner is listening on port 37551. */
%let myserver=sbxintern16.sbx.sas.com 37551;
options remote=myserver;

/* Initial Connect session with credentials. */
signon user=sasuser passwd=Orion123;
/* NOTE: Remote signon to MYSERVER complete. */

rsubmit;

/* Display the contents of the CARS dataset in Connect. */
proc contents data=sashelp.cars;
run;

data carssub;
	set sashelp.cars;
	if cylinders < 8;
run;

/* Print subsetted results. */
proc print data=carssub;
run;

endrsubmit;

signoff;
/* NOTE: Remote signoff from MYSERVER complete. */


/***
/* Allocate CAS library – MYCAS as sasuser. */
%let caslibname=mycas;
libname &caslibname cas caslib="casuser";

/* Connect to the SAS 9.4 server and rsubmit code to */
/* download the HEART dataset from remote SASHELP. */
%let myserver=sbxintern16.sbx.sas.com 7551;
options remote=myserver;

signon user="sastest" passwd="Orion123!";
rsubmit;

/* Download HEART dataset from SAS 9.4 SASHELP to CAS library. */
proc download data=sashelp.heart out=mycas.heart94;
run;

endrsubmit;

proc contents data=mycas.heart94;

/* Create basic statistics using PROC MDSUMMARY; write output to CAS. */
proc mdsummary data=mycas.heart94;
	groupby deathcause;
	var cholesterol systolic diastolic ;
	output out=mycas.heartsum94; 
run;

/* View datasets loaded to CAS */
proc datasets lib=mycas; run;

signoff ;