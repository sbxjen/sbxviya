data work.class;
	set sashelp.class;
	if Name="Alfred" then Height=.;
run;

proc means data=work.class noprint;
	output out=var_means(drop=_freq_ _type_);
run;

proc transpose data=var_means out=trans_mean(keep=_NAME_ MEAN STD);
	id _stat_;
run;

%let dsn=work.class;

options mprint source2;

filename sascode temp;

data _null_;
	set trans_mean;
	file sascode;
PUT "data &dsn. ;";
PUT "	set &dsn. ;";	
PUT '	if ( ' _name_ '< ' MEAN '- 3.0* ' STD ') then ' _name_ '= ' MEAN '-3.0* ' STD ';';
PUT '	else if ( ' _name_ '> ' MEAN '+ 3.0* ' STD ') then ' _name_ '= ' MEAN '+3.0* ' STD ';';
PUT 'run;';
run;

%include sascode;

ods trace off;

%let varlist=Name Sex;

ods output OneWayFreqs=OneWayFreqs;
proc freq data=work.class;
	tables &varlist.;
run;

data OneWayFreqs;                                                                     
	length _NAME_ $32 VALUE $32;
	set OneWayFreqs;
	keep _NAME_ VALUE Percent;
	_NAME_ = scan(Table , 2, ' ');
	VALUE = trim(left(vvaluex(_NAME_ )));
run;

data _null_;
	set OneWayFreqs end=last;
	file sascode;
	if _n_=1 then do;
PUT "data &dsn. ;";
PUT "	set &dsn. ;";
	end;
	if (Percent < 1) then do;
PUT 'if ( ' _NAME_ '= "' VALUE +(-1) '") then ' _NAME_ '= "_OTHER_";';
	end;
	if last then do;
PUT 'run;';	
	end;
run;

%include sascode;
