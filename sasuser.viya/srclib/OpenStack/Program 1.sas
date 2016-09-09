cas mysess sessopts=(caslib="casuser" nworkers=2) uuidmac=uuid;
libname mycas cas caslib="casuser";

%put &=uuid.;

%let casdata=post_gen_train;
proc casutil outcaslib="casuser";
	load casdata="&casdata..sas7bdat" casout="&casdata." promote;
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