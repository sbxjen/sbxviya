*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

data ousaslib.skp1small;
	set ousaslib.skp1walsplusKeys(obs=2000);
	*keep cl_n bew_vn dch_n ts_registratie d324 d382 d522 d523 d524 _deel _x _pol KeyCol;
	*KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.), put(_deel,best.));
	drop &intlist.;
run;

data ousaslib.skp1walsplusKeys2; 
	set ousaslib.skp1walsplusKeys;
run;

proc print data=insaslib.skp1_sigdef; run;

proc print data=ousaslib.skp1allplusKeysplusCilinders1(obs=2); run;

proc print data=ousaslib.skp1walsplusKeys(obs=10); * keep=	cl_n bew_vn dch_n ts_registratie 
																	ts_be ts_ei 
																	teinddatum teinddatumskp
																	beinddatum beinddatumskp
																	d417 d418
																	tComponentName bComponentName); run;
																	
proc print data=ousaslib.skp1small(keep=cl_n dch_n bew_vn _deel); run;

proc contents data=ousaslib.skp1small_INTERVAL; run;

data ousaslib.skp1smaller_INTERVAL;
	set ousaslib.skp1small_INTERVAL;
	where strip(KeyCol)="41453524_22_3_1";
run;

proc contents data=ousaslib.skp1walsplusKeys_PREP; run;

proc print data=ousaslib.skp1small_BASE;

%let inputdsn=ousaslib.skp1small;

proc sort data=&inputdsn._INTERVAL;
	by KeyCol;
run;
data &inputdsn._BASE;
	set &inputdsn._INTERVAL(keep=KeyCol);
	by KeyCol;
	if first.KeyCol then output;
run;

data work.class(drop=Sex);
	set sashelp.class;
	KeyCol = Sex;
run;

proc sort data=work.class;
	by KeyCol;
run;

data work.class_INTERVAL;
	set work.class;
run;

data work.class_NOINTERVAL;
	set work.class;
run;

data &inputdsn._BASE;
	set &inputdsn._NOINTERVAL(keep=KeyCol);
	by KeyCol;
	if first.KeyCol then output;
run;

%put &=KeyCol.;
%let inputdsn=work.class;
%let interval=Age Weight Height;

proc means data=work.class;
	var Age;
	by KeyCol;
run;
%let int=%scan(&INTERVAL.,1);