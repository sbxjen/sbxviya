libname mycas cas;


/*** MACROS                                         */
/*** -----------------------------------------------*/

/* Macro to save in-memory tables as SASHDAT files. */
%macro cassave(tables=);
%let n=%sysfunc(countw(&tables,%str( )));
%do i = 1 %to &n;
	%let dsn=%scan(&tables, &i);
	proc casutil;
		save casdata="&dsn" replace;
	run;
%end;
%mend;

/* Macro to plot multiple series. */
%macro plotseries(vars=);
%let n=%sysfunc(countw(&vars,%str( )));
%do i = 1 %to &n;
	%let v=%scan(&vars, &i);
	series x=nrows y=&v;
%end;
%mend;


/*** Dynamic source code.                           */
/*** -----------------------------------------------*/
data work.romans;
	do i=1 to 3;
		filepath = cats("/home/sasuser/roman", strip(put(i,8.)), ".sashdat");
		output;
	end;
run;

filename myfile temp;

data _null_;
 	set work.romans end=eof;
 	file myfile;				*** Direct to temporary file;
	if _N_=1 then do; 
PUT 'data work.temp;'; 
PUT 'nrows = &nrows;'; 
	end; 
PUT '	filename fileref' i+(-1) ' disk "' filepath+(-1) '";'    				;
PUT '	fid' i+(-1) '=fopen(cats("fileref", trim(left(put(' i+(-1)',8.)))));'	;
PUT '	roman' i+(-1) '=input(finfo(fid' i+(-1)' , "File Size (bytes)"), 20.);' ;
	if eof then do; 
PUT 'keep nrows roman1-roman3; 
	 run;'; 
end;
run;


/*** Main.                           				*/
/*** -----------------------------------------------*/
%macro main;

%do k = 10 %to 12;
	%let nrows=2**&k;
	
	/* Create a VARCHAR(32) data type in CAS. */
	data mycas.roman1;
		length vc32 varchar(32);
		do i = 1 to &nrows;
			vc32 = put(i, roman.);
			output;
		end;
		drop i;
	run;
	
	/* Create a CHAR(32) data type in CAS. */
	data mycas.roman2;
		length vc32 $32;
		do i = 1 to &nrows;
			vc32 = put(i, roman.);
			output;
		end;
		drop i;
	run;
	
	/* Convert the VARCHAR(32) to a CHAR(4*32) data type. */
	data work.roman3;
		set mycas.roman1;
	run;
	proc casutil;
		load data=work.roman3 replace;
	run;
	
	/* Mind converting VARCHAR(*) to a CHAR data type! It uses 32767 bytes by default. */ 
	
	/* proc casutil;
		list tables;
	run; */
	
	/* Save a .SASHDAT copy. */
	%cassave(tables=roman1 roman2 roman3);
	
	/* proc datasets lib=mycas;
	run; */
	
	/* The results. */
	options source2;
	%include myfile;
	
	proc datasets;
   		append base=work._varchar
      	data=work.temp;
    run;

%end;
%mend;


/* Let's run this. */
%main;

proc sgplot data=work._varchar;
	title "File Size of Roman character data sets";
	%plotseries(vars=roman1 roman2 roman3);
	label 	nrows='Number of Roman characters'
			roman1='VARCHAR(32)' roman2='CHAR(32)' roman3='CHAR to VARCHAR'; 
    xaxis type=log logbase=2;
	yaxis type=log logbase=2 label='File Size (bytes)';
run;