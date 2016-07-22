cas casauto sessopts=(caslib="casuser"); *** "casauto" is the name of the CAS Session, "casuser" is the name of the active caslib. ;

/* This would have the same effect, but is obsolete:
caslib casuser datasource=(srctype="path") * Create a new caslib named "casuser". Creating a caslib makes it the active caslib;
	path="/home/casuser"; */

/* Associate a libref (alias) with the caslib "casuser", or with the active caslib if not specified. */
libname mycas cas caslib="casuser";

/* List all caslibs. */
caslib _all_ list;

/* List all files in the path associated with the caslib "casuser". */
proc casutil incaslib="casuser"; 
	list files; 
run;

/* Create an in-memory data table. */
proc casutil outcaslib="casuser";
	load data=sashelp.class casout="class"; 
run;

 /* Show the table's contents. */
proc casutil incaslib="casuser";
	contents casdata="class";
run;

/* Delete the table. */
proc casutil incaslib="casuser";
	droptable casdata="class";  
run;

/* Create an in-memory data table. */
data mycas.class;
	set sashelp.class; 
run;
/*  The output data is loaded to CAS, but the statements within
the DATA step are processed locally, in the client session, prior to the data loading.
By default, a valid DATA step automatically runs in CAS when the following
conditions are true:
1. All librefs in the DATA step are CAS engine librefs to the same CAS session.
2. All statements in the DATA step are supported by the CAS DATA step. 
*/

/* CAS in-memory tables can be manipulated by (several) SAS data set commands. See examples on p. 20 and 21 of casdataam.pdf. */

data mycas.test;
	length x varchar(10); *** However this DATA step is processed locally, the VARCHAR type can be used.;
	set sashelp.class;
	x = "abc";
	put "Running on node # " _RANKID_;
run;

/* The VARCHAR data type uses character length semantics and the CHAR data type uses byte length semantics. */

proc casutil;
	contents casdata="test";
run;
/* is identical to
proc contents data=mycas.test;
run;
* but the latter runs locally. */