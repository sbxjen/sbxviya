options cashost="sbxjen1.instance.openstack.sas.com" casport=5570 casuser="sasdemo";
cas casauto sessopts=(caslib="casuser"); 
libname mycas cas caslib="casuser";

proc casutil outcaslib="casuser";
	load data=sashelp.baseball replace; /* no difference: orderby=(Height) */
run;

data mycas.baseball;
	set mycas.baseball(orderby=(nHome));
run;

proc print data=mycas.baseball; run; /* doesn't work */

data mycas.baseball(partition=(Div) orderby=(nHome));
	set mycas.baseball;
run;

proc print data=mycas.baseball; run; /* works */