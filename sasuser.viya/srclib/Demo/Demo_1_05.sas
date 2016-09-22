options cashost="sbxjen1.instance.openstack.sas.com" casport=5570 casuser="sasdemo";
cas casauto sessopts=(caslib="casuser"); 
libname mycas cas caslib="casuser";

data mycas.class;
	set sashelp.class;
run;

data mycas.class2(ondemand=yes); /* obs by obs; increases latency, but reduces memory usage */
	set mycas.class;
	bmi = weight / (.01*height)**2;
run;

data _null_;
   file "/home/sasuser/mypgm.sas";
   put "bmi = weight / (.01*height)**2;";
   put "a = weight + height;";
   put "b = weight * height;";
run;
 
filename newcols "/home/sasuser/mypgm.sas";

/* Only the variables listed in the TEMPNAMES= option are added to the input table */
proc mdsummary data=mycas.class(tempnames=(bmi a) script=newcols); /* in this way, we don't have to create a new data set of temps */
	var weight height bmi;
	output out=mycas.mdsumstat;
run;

proc print data=mycas.class(obs=5); run;