cas mysess sessopts=(caslib="casuser" nworkers=2) uuidmac=uuid;
libname mycas cas caslib="casuser";

/* List files and tables available in caslib */
proc casutil incaslib="casuser";
	list files;
	list tables;
run;

/* Load a server-side file as an in-memory data table */
%macro load(tables=);
	%let n=%sysfunc(countw(&tables,%str( )));
	%do i=1 %to &n;
	%let casdata=%scan(&tables,&i);
	proc casutil outcaslib="casuser";
		load casdata="&casdata..sas7bdat" casout="&casdata."; /* promote */
	run;
	%end;
%mend;

%load(tables=post_log_train post_log_validate post_log_test);


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

proc contents data=mycas.post_log_part; run;

proc casutil;
	contents casdata="post_log_part";
run;

data mycas.post_log_test;
	set mycas.post_log_test;
	_freq_ = 10 * _freq_;
run;