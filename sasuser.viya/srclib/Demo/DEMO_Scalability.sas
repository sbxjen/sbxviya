options cashost="sbxjen1.instance.openstack.sas.com" casport=5570 casuser="sasdemo";

cas mysess sessopts=(caslib="casuser" nworkers=2) uuidmac=uuid;
libname mycas cas caslib="casuser";

/* Specify a folder path to write the temporary output files */
%let outdir = &USERDIR.; 
libname mysas "&outdir.";

/* The DROPTABLE statement is used to free the memory resources that are used for the data from the client-side SAS7BDAT file. */
%let casdata=post_log_test;
*proc casutil outcaslib="casuser";
*	droptable casdata="&casdata.";
*run;

/* Now load casdata in memory (again), but as promoted. */
proc casutil outcaslib="casuser";
	load file="&outdir./&casdata..sas7bdat" casout="&casdata." promote;
run;

proc casutil incaslib="casuser";
	list files;
	list tables;
run;

proc mdsummary data=mycas.&casdata.;
	var norm_dd_x;
	output out=mycas._&casdata._mdsummary;
run;

proc casutil;
	save casdata="&casdata." replace;
run;