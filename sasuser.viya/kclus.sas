libname mycas cas;

proc casutil;
	load data=sashelp.class;
run;

proc kclus data=mycas.class distance=euclidean maxclusters=5;
	input Height;
run;
