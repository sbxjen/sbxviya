libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";

%let inputdsn=ousaslib.skp1walsplusKeys_PREP_INTERVAL;
*%let inputdsn=ousaslib.skp1small_PREP_INTERVAL;

proc sort data=&inputdsn.;
	by KeyCol ts_registratie;
run;

data &inputdsn(drop=_t0 i);
	retain _t0 i;
	set &inputdsn.;
	by KeyCol;
	if first.KeyCol then do; 
		_t0=ts_registratie;
		i=0;
	end;
	else i+1;
	ts_registratie = _t0+i;
run;

/* end of program */
