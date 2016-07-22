cas casauto;
libname mycas cas;

proc casutil outcaslib="casuser";
	load data=sashelp.baseball replace; * no difference: orderby=(Height);
run;

data mycas.baseball;
	set mycas.baseball(orderby=(nHome));
run;
proc print data=mycas.baseball; run; /* doesn't work */

data mycas.baseball(partition=(v) orderby=(nHome));
	v='v';
	set mycas.baseball;
run;
proc print data=mycas.baseball; run /* works */