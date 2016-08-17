libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";

<<<<<<< HEAD
<<<<<<< HEAD
%let inputdsn=ousaslib.crm3allplusKeys_PREP_INTERVAL;
*%let inputdsn=ousaslib.skp1walsplusKeys_PREP_INTERVAL;
*%let inputdsn=ousaslib.skp1small_PREP_INTERVAL;
=======
%let inputdsn=ousaslib.skp1walsplusKeys_INTERVAL;
>>>>>>> 662b72f64fa548b59a7b1a4037bf7d3a2326b982
=======
%let inputdsn=ousaslib.skp1walsplusKeys_INTERVAL;
>>>>>>> 662b72f64fa548b59a7b1a4037bf7d3a2326b982

proc sort data=&inputdsn.;
	by KeyCol ts_registratie;
run;

<<<<<<< HEAD
<<<<<<< HEAD
data &inputdsn(drop=_t0 i);
	retain _t0 i;
	set &inputdsn.;
	by KeyCol;
	if first.KeyCol then do; 
		i=0;
	end;
	else i+1;
	ts_registratie = i;
run;

/* end of program */
=======
=======
>>>>>>> 662b72f64fa548b59a7b1a4037bf7d3a2326b982
data &inputdsn.2(drop=_t0);
	set &inputdsn.;
	by KeyCol;
	if first.KeyCol then _t0=ts_registratie;
	ts_registratie = ts_registratie - _t0;
run;
<<<<<<< HEAD
>>>>>>> 662b72f64fa548b59a7b1a4037bf7d3a2326b982
=======
>>>>>>> 662b72f64fa548b59a7b1a4037bf7d3a2326b982
