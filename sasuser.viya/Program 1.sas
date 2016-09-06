*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

<<<<<<< HEAD
proc print data=ousaslib.crm3allplusKeys_PREP_INTERVAL(obs=1000); run;

data ousaslib.skp1walsplusKeys_TARGET(keep=KeyCol ts_registratie d524 d324 d512 d513 d421 d012-d024 d063 d065 d075 d160);
	set ousaslib.skp1walsplusKeys_ORIG;
	KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.), put(_deel,best.));
run;

proc print data=ousaslib.skp1pluscrm3pluskeys(keep=KeyCol_deel norm_dd_x where=(norm_dd_x>0.12)); run;

*0.12143;

proc print data=insaslib.skp1_sigdef; run;

data ousaslib.skp1small_PREP_ALL;
	set &inputdsn._PREP_ALL(obs=100);
run;

proc contents data=ousaslib.skp1walsplusKeys_ORIG; run;

data ousaslib.skp1pluscrm3pluskeys_TARG_NZ;
	set ousaslib.skp1pluscrm3pluskeys(keep=KeyCol_deel norm_dd_x where=(norm_dd_x ne 0));
run;

proc print data=ousaslib.skp1pluscrm3pluskeys(keep=KeyCol KeyCol_deel obs=10); run;

data work.tmp;
	input KeyCol x;
datalines;
1 -1 
2 0 
2 0 
3 0 
3 0 
3 1
;
run;

data work.tmp;
	input x y z;
datalines;
1 0 0 
0 2 0
0 0 3
;
run;

%let ivar=2;
%put &=k.;
%put &=list.;

proc print data=ousaslib.skp1walsplusKeys_PREP_INTERVAL(keep=KeyCol P_d003 obs=100); run;

proc contents data=ousaslib.skp1small_prep_base; run;

data ousaslib.skp1small_PREP_INTERVAL;
	set ousaslib.skp1walsplusKeys_PREP_INTERVAL(obs=20000);
=======
data ousaslib.skp1small;
	set ousaslib.skp1walsplusKeys_PREP(obs=2000);
<<<<<<< HEAD
>>>>>>> 662b72f64fa548b59a7b1a4037bf7d3a2326b982
=======
>>>>>>> 662b72f64fa548b59a7b1a4037bf7d3a2326b982
	*keep cl_n bew_vn dch_n ts_registratie d324 d382 d522 d523 d524 _deel _x _pol KeyCol;
	*KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.), put(_deel,best.));
	*drop &intlist.;
run;

data ousaslib.skp1walsplusKeys2; 
	set ousaslib.skp1walsplusKeys;
run;

proc print data=ousaslib.crm3allplusKeys_PREP_INTERVAL(keep=KeyCol obs=3000); run;

proc print data=insaslib.skp1_sigdef; run;

data ousaslib.crm3allplusKeys_PREP;
	set ousaslib.crm3allplusKeys(drop=d251 d252 d254 d256 d262 d282 d283 d351 d359 d379);
run;	

proc print data=ousaslib.skp1walsplusKeys_PREP_TSDR(obs=35 keep=KeyCol _pol:); run;
proc print data=ousaslib.skp1walsplusKeys_ORIG(obs=200 keep=cl_n dch_n bew_vn _deel ts_registratie _pol); run;

proc print data=ousaslib.skp1allplusKeysplusCilinders1(obs=2); run;

proc print data=ousaslib.skp1walsplusKeys(obs=10); * keep=	cl_n bew_vn dch_n ts_registratie 
																	ts_be ts_ei 
																	teinddatum teinddatumskp
																	beinddatum beinddatumskp
																	d417 d418
																	tComponentName bComponentName); run;
																	
proc print data=ousaslib.skp1small(keep=cl_n dch_n bew_vn _deel); run;

proc print data=ousaslib.crm3allplusKeys(obs=20); run;

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


data _null_;
	retain x;
	set ousaslib.crm3allplusKeys_PREP_NOINTERVAL(keep=KeyCol) end=eof; /* INTERVAL would have worked as well */
	by KeyCol;
	if first.KeyCol then i = 0;
	i+1;
	if last.KeyCol then do;
		if i > x then x=i;
	end;
	if eof then put x=;
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