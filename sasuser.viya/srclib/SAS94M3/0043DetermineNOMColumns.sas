data _null_;
	if _n_=1 then set &inputdsn._NOINTERVAL(drop=&binlist. obs=1);
	length _vars $6000;
	array _n _numeric_ _dumn; 
	array _c _character_ _dumc; 
	do i = 1 to dim(_n)-1;       /* -1 because of dummy _dumn */
    	_vars = catx(" ", _vars, vname(_n{i}));
    end;
	do i = 1 to dim(_c)-1;       /* -1 because of dummy _dumc */
    	if not (vname(_c{i})="KeyCol" or vname(_c{i})="_vars") then _vars = catx(" ", _vars, vname(_c{i}));
    end;
	call symputx("nomlist", _vars);
run;

/* end of program */