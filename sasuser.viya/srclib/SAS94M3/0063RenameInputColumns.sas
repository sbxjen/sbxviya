libname ousaslib "/tmp/v94/";

options noprintmsglist;

%macro rename(inputdsn=,ln_pr=);
	data _null_;
		length _rename $32767; 										/* length = Maximum character length */
		set &inputdsn.(obs=1 keep=d0: d1: d2: d3: P_:); 			/* Only rename d AND P_ variables; add d4: d5: for ln_pr="SKP1" */
		array _n{*} _numeric_ 	_dumn;
		array _c{*} _character_ _dumc;
		do i=1 to dim(_n)-1;
			_rename = catx(" ", _rename, vname(_n{i})||"="||&ln_pr.||"_"||vname(_n{i}));
		end;
		do i=1 to dim(_c)-1;
			if (upcase(vname(_c{i})) ne "_RENAME") then			/* mind _rename itself */
				_rename = catx(" ", _rename, vname(_c{i})||"="||&ln_pr.||"_"||vname(_c{i}));
		end;
		call symputx("rename", _rename);
	run;
	data &inputdsn.;
		set &inputdsn.(rename=(&rename.));
	run;
%mend;

*%rename(inputdsn=ousaslib.skp1walsplusKeys,ln_pr="SKP1");
*proc contents data=ousaslib.skp1walsplusKeys;

%rename(inputdsn=ousaslib.crm3allplusKeys,ln_pr="CRM3");
proc contents data=ousaslib.crm3allplusKeys;