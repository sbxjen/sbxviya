options cashost="sbxjen1.instance.openstack.sas.com" casport=5570 casuser="sasdemo";
cas mysess sessopts=(caslib="casuser" nworkers=2) uuidmac=uuid;
libname mycas cas caslib="casuser";

%let datadir = "/tmp/srcdata/";
%let viyadir = "/tmp/viya/";

libname mysas &datadir.;

/* Create an in-memory data set */
proc casutil incaslib="casuser" outcaslib="casuser";
	load data=mysas.matm2;
run;

proc casutil incaslib="casuser";
	droptable casdata="matm2";
run;

libname mysas;

/* Let's try again */

libname mysasv9 cvp &datadir.;
libname mysas &viyadir.;

/* Copy. Using the NOCLONE option results in a copy with the data representation of the output data library. */
proc copy in=mysasv9 out=mysas noclone; 	
	select matm2;
run;

/* Create an in-memory data set */
proc casutil incaslib="casuser" outcaslib="casuser";
	load data=mysas.matm2;
run;