proc copy in=sashelp out=work;
	select heart;
run;

%let myserver=sbxjen1.instance.openstack.sas.com 37551;
options remote=myserver;

/* Initiate signon to Connect to the server in the Viya environment */
signon user=sasdemo passwd=Orion123;

rsubmit;

	/* Allocate CAS library – mycas as sasdemo */
	options casuser="sasdemo";
	libname mycas cas caslib="casuser" host="sbxjen1.instance.openstack.sas.com" port=5570;
	
	/* Upload the HEART dataset from the SAS 9.4 WORK to the CAS library. */
	proc upload data=work.heart94 out=mycas.heart94; 
	run;
	
	/* Perform some simple CAS analytics. */
	proc mdsummary data=mycas.heart94;
		groupby deathcause;
		var cholesterol systolic diastolic;
		output out=mycas.heartsum94; 
	run;
	
	/* Upload the HEART dataset from the SAS 9.4 WORK to the CAS library. */
	proc download data=mycas.heartsum94 out=work.heartsum94; 
	run;

endrsubmit;

signoff;