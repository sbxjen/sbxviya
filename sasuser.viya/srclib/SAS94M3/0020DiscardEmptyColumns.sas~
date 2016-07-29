*;
libname mysas "/tmp/viya/" access=readonly;
libname myownsas "/tmp/v94/";
*;

%let inputdswemptycols=myownsas.skp_cilinders;

data _null_;
	set &inputdswemptycols. end=last;
	array _n _numeric_   _dumn;
	array _c _character_ _dumc;
	array _nn{3000} _temporary_; /*  temporary array: array elements are retained automatically */
	array _nc{3000} _temporary_; /*  temporary array: array elements are retained automatically */
	do i = 1 to dim(_n)-1;       /* -1 because of dummy _dumn */
    	if not _nn{i} and not missing(_n{i}) then _nn{i} = 1;
    end;
	do i = 1 to dim(_c)-1;       /* -1 because of dummy _dumc */
    	if not _nc{i} and not missing(_c{i}) then _nc{i} = 1;
    end;
	length _vars $6000;
	if last then do;
	    do i = 1 to dim(_n)-1;
	        if not _nn{i} then _vars = catx(" ", _vars, vname(_n{i}));
	    end;
	    do i = 1 to dim(_c)-1;
	        if not _nc{i} then _vars = catx(" ", _vars, vname(_c{i}));
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
