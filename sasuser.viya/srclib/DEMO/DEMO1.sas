options cashost="sbxjen1.instance.openstack.sas.com" casport=5570 casuser="sasdemo";

cas casauto sessopts=(caslib="casuser"); 
/* "casauto" is the name of the CAS Session, "casuser" is the name of the active caslib */

/* This would have had the same effect, but is actually obsolete: */
caslib casuser datasource=(srctype="path") /* Create a new caslib named "casuser". Creating a caslib makes it the active caslib */
	path="&USERDIR.";

/* Associate a libref with the caslib "casuser", or with the active caslib if none specified */
libname mycas cas caslib="casuser";

/* List all caslibs. */
caslib _all_ list;

/* List all tables in the caslib "casuser" */
proc casutil incaslib="casuser"; 
	list tables; 
run;

/* List all files in the path associated with the caslib "casuser" */
proc casutil incaslib="casuser"; 
	list files; 
run;

/* Create an in-memory data table */
proc casutil outcaslib="casuser";
	load data=sashelp.class casout="class"; 
run;

 /* Show the table's contents */
proc casutil incaslib="casuser";
	contents casdata="class";
run;

/* Delete the table */
proc casutil incaslib="casuser";
	droptable casdata="class";  
run;