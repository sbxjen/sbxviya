*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

*%let inputdswconstcols=ousaslib.skp1allPlusKeys;
*%let inputdswconstcols=ousaslib.skp1allPlusKeysplusCilinders;
*%let inputdswconstcols=ousaslib.crm3allPlusKeys;

/* numeric */
ods output summary=work.summ;
proc means data=&inputdswconstcols. std;
	var _numeric_;
run;
data _null_;
	set work.summ;
	length _vars $6000;
	array _n _numeric_ _dumn;
	do i = 1 to dim(_n)-1;
		if (substr(vname(_n{i}), length(vname(_n{i}))-6, 7) = "_StdDev" and _n{i}=0)
		then do;
			_vars = catx(" ", _vars, substr(vname(_n{i}), 1, length(vname(_n{i}))-7));
		end;
	end;
	call symputx("droplist_n", _vars);
run;

%put &=droplist_n.;

/* character */
data &inputdswconstcols.;
	set &inputdswconstcols.;
	_dumc = '_dumc';
run;

ods output nlevels=work.nlevels;
proc freq data=&inputdswconstcols. nlevels;
	tables _character_ _dumc / noprint;
run;

data _null_;
	set work.nlevels end=last;
	length _vars $6000;
	retain _vars;
	if not (NLevels > 1) then _vars = catx(" ", _vars, TableVar);
	if last then call symputx("droplist_c", _vars);
run;

%put &=droplist_c.;

proc datasets library=work nolist;
	delete summ 	/ memtype=data; run;
	delete nlevels	/ memtype=data; run;
quit;

data &inputdswconstcols.;
	_dummy = 0; /* In case the drop list is empty */
	set &inputdswconstcols.;
	drop &droplist_n &droplist_c _dummy;
run;

/* end of program */