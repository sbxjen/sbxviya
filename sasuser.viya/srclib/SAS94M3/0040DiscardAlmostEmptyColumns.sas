*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

%let inputdswemptycols=ousaslib.skp1allPlusKeys;

%let KeyColumns=cl_n bew_vn dch_n;
%let LastKeyColumn=%sysfunc(scan(&KeyColumns.,-1));

proc sort data=&inputdswemptycols.;
	by &KeyColumns.;
run;

/* Delete all variables that have 75+% missing values for at least 850% of the coils. */
data _null_;
	set &inputdswemptycols. end=last;
	array _n 			_numeric_ _dumn;
	array _c 			_character_ _dumc;
	/*  temporary array: array elements are retained automatically */
	array _nn{2,3000} 	_temporary_ 	(3000*0 3000*0);
	array _nc{2,3000} 	_temporary_		(3000*0 3000*0);
	retain Nobs 0 Ncoils 0;
	if first.&LastKeyColumn. then do;
		Ncoils = Ncoils + 1;
		do i = 1 to dim(_n)-1;	/* -1 because of dummy _dumn */
			if ( _nn{2,i}/NObs > .75 ) then _nn{1,i} = _nn{1,i} + 1;
			_nn{2,i} = 0;
		end;
		do i = 1 to dim(_c)-1;	/* -1 because of dummy _dumc */
			if ( _nc{2,i}/NObs > .75 ) then _nc{1,i} = _nc{1,i} + 1;
			_nc{2,i} = 0;
		end;
		NObs = 0;
	end;
	do i = 1 to dim(_n)-1;       /* -1 because of dummy _dumn */
    	if missing(_n{i}) then _nn{i} = _nn{i} + 1;
    end;
    do i = 1 to dim(_c)-1;       /* -1 because of dummy _dumc */
    	if missing(_c{i}) then _nc{i} = _nc{i} + 1;
    end;
	length _vars $6000;
	if last then do;
	    do i = 1 to dim(_n)-1;
	        if ( _nn{1,i}/NCoils > .5 ) then _vars = catx(" ", _vars, vname(_n{i}));
	    end;
	    do i = 1 to dim(_c)-1;
	        if ( _nc{1,i}/NCoils > .5 ) then _vars = catx(" ", _vars, vname(_c{i}));
	    end;
	    call symputx("droplist", _vars);
    end;
run;

%put &=droplist.;

data &inputdswemptycols.;
	_dummy = 0; /* In case the drop list is empty */
	set &inputdswemptycols.;
	drop &droplist _dummy;
run;

/* end of program */