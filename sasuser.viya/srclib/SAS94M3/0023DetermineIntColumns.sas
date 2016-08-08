/* To be called from another program */	
%let IDCols=('ts_registratie', 'cl_n', 'bew_vn', 'dch_n', 'ts_be', 'ts_ei');

ods output Nlevels=Nlevels;
proc freq data=&inputdsn.(obs=2000) nlevels noprint; /* 2,000 should be enough to give a reliable indication */
	tables _numeric_;
run;

data _null_;
	set Nlevels(keep=TableVar NLevels) end=last;
	length _vars $6000;
	retain _vars;
	if NLevels > 20 then do; /* ---------- to be changed ---------- */
		if (TableVar not in &IDCols.) and (substr(left(TableVar),1,1) ne '_') then do; /* reject ID variables and calculated variables */
			_vars = catx(" ", _vars, TableVar);
		end;
	end;
	if last then do;
	    call symputx("intlist", _vars);
    end;
run;

/* end of program */