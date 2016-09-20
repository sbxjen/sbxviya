options cashost="sbxjen1.instance.openstack.sas.com" casport=5570 casuser="sasdemo";
cas casauto sessopts=(caslib="casuser"); 
libname mycas cas caslib="casuser";

/* Create an in-memory data table */
data mycas.class;
	set sashelp.class; 
run;

/* 
The output data is loaded to CAS, but the statements within
the DATA Step are processed locally, in the client session, prior to the data loading. 
*/

/*
By default, a valid DATA Step automatically runs in CAS when the following
conditions are true:
1. All librefs in the DATA Step are CAS engine librefs to the same CAS session.
2. All statements in the DATA Step are supported by the CAS DATA Step. 
*/

data mycas.test;
	length x varchar(10); /* However this DATA Step is processed locally, the VARCHAR type can be used */;
	set sashelp.class;
	x = "abc";
	put "Running on node " _hostname_;
run;

/* The VARCHAR data type uses character length semantics and the CHAR data type uses byte length semantics */
proc casutil;
	contents casdata="test";
run;