/* To be called from another program */	
*%let IDCols=('ts_registratie', 'cl_n', 'bew_vn', 'dch_n', 'ts_be', 'ts_ei');

ods output Nlevels=Nlevels;
proc freq data=&inputdsn._NOINTERVAL nlevels;
run;

data _null_;
	set Nlevels(keep=TableVar NLevels) end=last;
	length _vars $6000;
	retain _vars;
	if NLevels = 2 then do; /* ---------- to be changed ---------- */
		if (substr(left(TableVar),1,1) ne '_') then do; /* reject calculated variables */
			_vars = catx(" ", _vars, TableVar);
		end;
	end;
	if last then do;
	    call symputx("binlist", _vars);
    end;
run;

/* end of program */