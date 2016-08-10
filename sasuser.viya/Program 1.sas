*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

data ousaslib.skp1small;
	set ousaslib.skp1walsplusKeys(obs=2000);
	keep cl_n bew_vn dch_n ts_registratie d324 d382 d522 d523 d524 _deel _x _pol KeyCol;
	KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.), put(_deel,best.));
run;

proc print data=insaslib.skp1_sigdef; run;