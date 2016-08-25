libname ousaslib "/tmp/v94/";

%let inputdswemptyobs=ousaslib.skp1pluscrm3plusKeys;

data _null_;
	dsid = open("&inputdswemptyobs."); 
	_nVars = attrn(dsid,"NVARS");
	call symputx("nVars", _nVars);
run;

%put &=nVars.;

data &inputdswemptyobs.(drop=_dumn _dumc nMissing i);
	set &inputdswemptyobs.;
	array _n _numeric_   _dumn;
	array _c _character_ _dumc;
	nMissing = 0;
	do i = 1 to dim(_n) - 1;       /* -1 because of dummy _dumn */
    	if missing(_n{i}) then nMissing+1;
    end;
	do i = 1 to dim(_c) - 1;       /* -1 because of dummy _dumc */
    	if missing(_c{i}) then nMissing+1;
    end;
    if (nMissing > .75 * &nVars.) then delete;
run;

/* end of program */