*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;


%let inputdswemptycols=ousaslib.skp1allPlusKeys;

data _null_;
	set &inputdswemptycols. end=last;
	array _n _numeric_   _dumn;
	array _c _character_ _dumc;
	/*  temporary array: array elements are retained automatically */
	array _nn{3000} _temporary_ (3000*0); array _nnc{3,3000} _temporary_;
	array _nc{3000} _temporary_ (3000*0); array _ncc{3,3000} _temporary_;
	do i = 1 to dim(_n)-1;       /* -1 because of dummy _dumn */
    	if missing(_n{i}) then do;
    		 if not 	(		_nnc{1,i} = cl_n
    		 				and	_nnc{2,i} = bew_vn
    		 				and _nnc{3,i} = dch_n		) then do;
    		 		_nnc{1,i} = cl_n; _nnc{2,i} = bew_vn; _nnc{3,i} = dch_n;
    		 		_nn{i} = _nn{i}+1;
    end;
    do i = 1 to dim(_c)-1;       /* -1 because of dummy _dumn */
    	if missing(_c{i}) then do;
    		 if not 	(		_ncc{1,i} = cl_n
    		 				and	_ncc{2,i} = bew_vn
    		 				and _ncc{3,i} = dch_n		) then do;
    		 		_nnc{1,i} = cl_n; _nnc{2,i} = bew_vn; _nnc{3,i} = dch_n;
    		 		_nn{i} = _nn{i}+1;
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


/* _numeric_ */
proc means data=&inputdswemptycols.(obs=2000) n nway;
	var _numeric_; 
	class cl_n bew_vn dch_n;
	output out=work._n nmiss=;
run;
data work._n;
	array _n _all_ _dum;
	do i = 1 to dim(_n)-1;
		if 
		_nm{i} = _nm{i} / _freq_;
	end;
run;
	
/* _character_ */
proc sort data=&inputdswemptycols.(obs=2000)
			out=work._sorted;
	by cl_n bew_vn dch_n;
run;
ods output OneWayFreqs=work.OneWayFreqs;
proc freq data=work._sorted;
	tables _character_;
	by cl_n bew_vn dch_n;
run;
data work.OneWayFreqs;
	set work.OneWayFreqs;
	*by cl_n bew_vn dch_n;
	retain Table Column;
	keep cl_n bew_vn dch_n Table Column Frequency;
	Table = scan(Table, 2, ' ');                                                       
   	Column = trim(left(vvaluex(Table)));
run;
proc sort data=work.OneWayFreqs;
	by cl_n bew_vn dch_n;
run;
data work._c;


data work._allvars;
	merge 


data _null_;
	set work._n(keep;
	



proc sort data=&inputdswemptycols.(obs=2000)
			out=work.temp;
	by cl_n bew_vn dch_n;
run;
ods trace off;



proc sort data=sashelp.class out=work.temp;
	by Sex;
run;
ods output OneWayFreqs=work.OneWayFreqs;
proc freq data=temp;
	tables Age / missing; * out=work._c;
	by Sex;
	*output out=work._c n nmiss;
run;


proc print data=&inputdswemptycols.(obs=2); run;

data _null_;
	array _n{2} (2*10);
	put _n2=;
run;