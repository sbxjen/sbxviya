options cashost="sbxjen1.instance.openstack.sas.com" casport=5570 casuser="sasdemo";

cas mysess sessopts=(caslib="casuser" nworkers=2) uuidmac=uuid;
libname mycas cas caslib="casuser";

%put &uuid.;

%put nworkers=%sysfunc(getsessopt(mysess, nworkers));

/* Specify a folder path where the temporary output files are */
%let outdir = &USERDIR.; 
libname mysas "&outdir.";

/* List files and tables available in caslib */
proc casutil incaslib="casuser";
	list files;
	list tables;
run;


/* The DROPTABLE statement is used to free the memory resources that are used for the data from the client-side SAS7BDAT file. */
%let casdata=post_log_test;
*proc casutil outcaslib="casuser";
*	droptable casdata="&casdata.";
*run;

/* Now load casdata in memory (again) */
proc casutil outcaslib="casuser";
	load file="&outdir./&casdata..sas7bdat" casout="&casdata." copies=2; /* promote */
run;

proc casutil incaslib="casuser";
	contents casdata="&casdata.";
run;


/* Score casdata using a generated Gradient Boosting model  */
data mycas.&casdata.;
	set mycas.&casdata.;
	_freq_ = 10 * _freq_;
run;

data mycas._scored_gradboost;
	set mycas.&casdata.;
	%include "&outdir./gradboost.sas";
	put 'Hello from thread # ' _threadid_= ' on ' _hostname_=; 
run;


/* Assess model performance */
%let target = BIN_norm_dd_x;
proc assess data=mycas._scored_gradboost ncuts=1000;
	input p_&target.1;
	target &target. / level=nominal event='1';
	freq _freq_;
	fitstat pvar=p_&target.0 / pevent='0';
	ods output  rocinfo = mysas.gradboost_ROCinfo
				liftinfo = mysas.gradboost_liftinfo;
run;

proc sgplot data=mysas.gradboost_ROCinfo noautolegend;
	title "ROC Curve";
	yaxis label="Sensitivity";
	xaxis label="False Positive Rate" grid;
	lineparm x=0 y=0 slope=1 / transparency=0.7;
	series x=fpr y=sensitivity;
run;


cas mysess disconnect; 
cas mysess terminate;