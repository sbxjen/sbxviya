data work.matm2;
	input ts_be ts_ei cl_n;
datalines;
1 5 1
6 8 2
9 10 3
;
run;

data work.crm3_pv;
	do i = 0 to 101;
		d100 = i;
		ts_registratie = .1 + i*.1;
		output;
	end;
	drop i;
run;
                               

data work.crm3plusKeysKeyCols;
    if _n_ = 1 then do;
    	set work.crm3_pv;
		ts_ei = .;
		*put "A: " ts_registratie= " " ts_be= " " ts_ei=;
	end;
	do while (ts_ei < ts_registratie);
		set work.matm2; /* ts_ei UP */
		*put "B: " ts_registratie= " " ts_be= " " ts_ei=;
	end;
	do while (ts_registratie <= ts_ei);
		if (ts_registratie >= ts_be) then output;
		set work.crm3_pv;  /* ts_registratie UP */
		*put "C: " ts_registratie=" " ts_be= " " ts_ei=;
	end;
	/* do while (ts_registratie <= ts_ei);
		output;
		set work.crm3_pv;
		put "D: " ts_registratie=" " ts_be= " " ts_ei=;
	end; */
	keep ts_be ts_ei cl_n ts_registratie d100;
run;
