*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

/* Let's look at some interesting coils, and put them in work.mycoils */
proc print data=insaslib.matm2(firstobs=90000 obs=90100); run;

proc sort data=insaslib.matm2(keep=
										cl_n dch_n bew_vn 
										dch_n_vr dch_n_vl
										k_tstmat knt_bb
										hoog_dch n_dchvan n_dchtot a_dch
										ln_pr_vr ln_pr ln_pr_vl
								)
			out=work.mycoils;
	*where cl_n = "50603615";
	where cl_n in ("50603615", "50609621", "52010933");
	by cl_n dch_n bew_vn;
run;

/* DDCG? */

options mprint source2;
filename sascode temp;

data _null_;
	file sascode;	
run;

/* Select a KEY to work with, e.g. from skp1allplusKeys (WHERE (a_dch=0)) */ 
data matm2OnlyThisCoil;
	set work.mycoils(firstobs=8 obs=8 keep=cl_n dch_n_vr bew_vn);
	call symputx("_cl_n",		cl_n);
	call symputx("_dch_n_vr",	dch_n_vr);
	call symputx("_bew_vn",		bew_vn);
run;
/* Select the coil corresponding with matm2OnlyThisCoil */
proc sort 	data=insaslib.matm2(keep=cl_n dch_n bew_vn dch_n_vr dch_n_vl
								where=(cl_n=put(&_cl_n.,8.) and bew_vn<&_bew_vn.)
								)
			out=matm2PossiblyOnlyThisCoil;
	by descending bew_vn; /* DESCENDING = backwards in (process) time */
run;
data matm2OnlyThisCoil2;
	retain _dch_n_vr0 _bew_vn0; /* retain from one DATA step to another */
	
	 /* Initialize */
	if _n_=1 then do;
		_dch_n_vr0=&_dch_n_vr.; _bew_vn0=&_bew_vn.; *bew_vn = _bw_vn0;
		set matm2PossiblyOnlyThisCoil;
	end;
	
	*if bew_vn < _bew_vn0-2 then do; * matm2 does not contain sufficient information - UNLESS dch_n didn't change;
	*	if dch_n = 0;
	*	put bew_vn= _bew_vn0= "so I stopped";
	*	stop;
	*end;
	
	else do;
		*put  bew_vn= _bew_vn0= "so I did not stop";
		_bew_vn0 = bew_vn; /* first time: trivial */
		*put "new" _bew_vn0=;
		/* Loop over all coils with the same bew_vn, and ouput (maximum) one */
		do while (bew_vn = _bew_vn0); /* first time: trivial */
			*put dch_n= bew_vn=;
			if (dch_n = _dch_n_vr0) then do; /* a match! */
				*put "Output!"; 
				_dch_n_vr0 = dch_n_vr; /* update */
				output;
			end;
			set matm2PossiblyOnlyThisCoil(firstobs=2);
		end;
	end;
	
	/* Keep keys only */
	keep cl_n dch_n bew_vn; 
	
run;
proc append base=matm2OnlyThisCoil data=matm2OnlyThisCoil2; run;
proc datasets library=work nolist;
	delete matm2OnlyThisCoil2 / memtype=data; run;
	delete mycoils / memtype=data; run;
quit;
