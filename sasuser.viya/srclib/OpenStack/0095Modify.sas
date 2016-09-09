cas mysess sessopts=(caslib="casuser" nworkers=2) uuidmac=uuid;
libname mycas cas caslib="casuser";

/* List files and tables available in caslib */
proc casutil incaslib="casuser";
	list files;
	list tables;
run;

%macro load(tables=);
	%let n=%sysfunc(countw(&tables,%str( )));
	%do i=1 %to &n;
	%let casdata=%scan(&tables,&i);
	proc casutil outcaslib="casuser";
		load casdata="&casdata..sas7bdat" casout="&casdata." promote; /* promote */
	run;
	%end;
%mend;

%load(tables=post_log_train post_log_validate post_log_test);

proc casutil;
	contents casdata="post_log_ext";
run;

/************************************************************************/
/* Partition the data into training and validation                      */
/************************************************************************/
data mycas.post_log_part(drop=t v);
	length _role_ $ 10;
	set mycas.post_log_train(in=t) mycas.post_log_validate(in=v);
	_freq_ = 10 * _freq_;
	select;
		when (t) _role_ = 'training';
		when (v) _role_ = 'validation';
	end;
run;

*proc partition data=&casdata partition samppct=70;
*	by bad;
*	output out=&partitioned_data copyvars=(_ALL_);
*run;