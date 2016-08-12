libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";

%let inputdsn=ousaslib.skp1walsplusKeys_INTERVAL;

proc sort data=&inputdsn.;
	by KeyCol ts_registratie;
run;

data &inputdsn.2(drop=_t0);
	set &inputdsn.;
	by KeyCol;
	if first.KeyCol then _t0=ts_registratie;
	ts_registratie = ts_registratie - _t0;
run;
