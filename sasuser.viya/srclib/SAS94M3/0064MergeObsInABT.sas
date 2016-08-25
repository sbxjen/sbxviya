libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";

options mprint; *source2;

filename sascode temp;

*%let pgmpath = %sysfunc(pathname(sascode ));
*%put &pgmpath;

data _null_;
	set ousaslib.SKP1walsplusKeys(keep=KeyCol_deel cl_n bew_vn dch_n_vr 
									rename=(KeyCol_deel=_KeyCol_deel cl_n=_cl_n bew_vn=_bew_vn dch_n_vr=_dch_n_vr));
	file sascode;	
	if _n_=1 then do;
PUT 'data ousaslib.SKP1plusCRM3plusKeys;';
PUT 'run;';
	end;
PUT 'data onlyThisCoil(drop=	KeyCol cl_n bew_vn dch_n dch_n_vr'; 
PUT '							a_dch dl_n_lei dl_n_leu dl_n_bri dl_n_bru';
PUT '							ln_pr);';
PUT '	set ousaslib.SKP1walsplusKeys(where=(strip(KeyCol_deel)= "' _KeyCol_deel +(-1) '"));';
PUT '	run;';
PUT 'proc sort 	data=ousaslib.CRM3allplusKeys(where=(cl_n=put( ' _cl_n ', 8.) and bew_vn< ' _bew_vn '))';
PUT '			out=possiblyOnlyForThisCoil;';
PUT '	by descending bew_vn descending dch_n;';
PUT 'run;';
PUT 'data onlyForThisCoil(drop=	cl_n dch_n dch_n_vr';
PUT '							a_dch dl_n_lei dl_n_leu dl_n_bri dl_n_bru';
PUT '							ln_pr';
PUT	'							_dch_n_vr0 _bew_vn0);';
PUT '	retain _dch_n_vr0 _bew_vn0;';
PUT '	if _n_=1 then';
PUT '		do;';
PUT '			_dch_n_vr0= ' _dch_n_vr ';';
PUT '			_bew_vn0= ' _bew_vn ';';
PUT '			set possiblyOnlyForThisCoil;';
PUT '		end;';
PUT '	_bew_vn0=bew_vn;';
PUT '	do while (bew_vn=_bew_vn0);';
PUT '		if (dch_n=_dch_n_vr0) then';
PUT '			do;';
PUT '				output;';
PUT '				put KeyCol=;';
PUT '				_dch_n_vr0=dch_n_vr;';
PUT '			end;';
PUT '		set possiblyOnlyForThisCoil(firstobs=2);';
PUT '	end;'; 
PUT 'run;';
PUT 'proc sort data=onlyForThisCoil;';
PUT '	by descending bew_vn;';
PUT 'run;';
PUT 'data onlyForThisCoil;';
PUT '	set onlyForThisCoil(obs=1 drop=bew_vn);';
PUT 'run;';
PUT 'proc sql;';
PUT '	create table SKP1plusCRM3oneCoilplusKeys as';
PUT '    	select onlyThisCoil.*, onlyForThisCoil.*';
PUT '		from onlyThisCoil, onlyForThisCoil;';
PUT 'quit;';
PUT 'data ousaslib.SKP1plusCRM3plusKeys;';
PUT '	set ousaslib.SKP1plusCRM3plusKeys work.SKP1plusCRM3oneCoilplusKeys;';
PUT 'run;';
PUT 'proc datasets library=work nolist;';
PUT 'delete onlyThisCoil onlyForThisCoil SKP1plusCRM3oneCoilplusKeys / memtype=data;';
PUT 'run;';
PUT 'quit;';
run;

%include sascode;

/* end of program */