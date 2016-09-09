cas mysess sessopts=(caslib="casuser" nworkers=2) uuidmac=uuid;
libname mycas cas caslib="casuser";

%put &=uuid.;

proc casutil incaslib="casuser";
	list files;
	list tables;
run;

%let casdata=mnist_validation;
proc casutil outcaslib="casuser";
	load casdata="&casdata..sashdat" casout="&casdata.";
run;

libname mysas "&USERDIR";

/*  I give you some fun code to plot this 2D image with the SGPLOT Procedure in SAS Studio. */
%let height=28;
%let width=28;

data work.long;
	array d{784} d0-d783;
	set mycas.mnist_train(drop=d784 obs=1);
	do i=1 to &height.;
		y = &height.-i;
		do j=1 to &width.;
			x = j-1;
			k = (i-1)*&width.+j;
			z = d{k};
			output;
		end;
	end;
	keep x y z;
run;

ods graphics on / scale=on;
title "The MNIST Data";
proc sgplot data=work.long; 
	scatter x=x y=y /
		colorresponse=z
		markerattrs=(size=30pt symbol=squarefilled)
		transparency=0.3;
	xaxis display=none; yaxis display=none;
	gradlegend / notitle;
run;
ods _all_ close;

/* To reduce the number of weights w and to alleviate the soon to follow calculations in CAS ... */
proc mdsummary data=mycas.mnist_train;
	output out=mycas.mnist_train_std_;
run;

data mycas.mnist_train_std_;
	length _vars $4000; /* 5*785 */
	retain _vars;
	set mycas.mnist_train_std_(keep=_Column_ _Std_ where=(_Std_ ne 0)) end=last;
	if (strip(_Column_) ne "d784") then _vars = catx("", _vars, _Column_);
	drop _vars;
	if last then call symputx("vars", _vars);
run;

%put &=vars.;

/* Another VDMML Procedure: PROC NNET */
ods output OptIterHistory=mysas.OptIterHistory;
proc nnet data=mycas.mnist_train standardize=std;
	target d784 / level=nom comb=linear act=softmax error=entropy;
	input &vars. / level=int;
	*architecture GLIM;
	hidden 2 / act=tanh;
	train outmodel=mycas.nnetModel seed=23451 validation=mycas.mnist_validation;
	optimization algorithm=lbfgs maxiters=250 RegL1=0.001 RegL2=0.001;
	score out=mycas.nnetScored;
	code file="&USERDIR./nnetModel.sas";
run;
ods _all_ close;

ods graphics on / scale=on;
title "Iteration History";
proc sgplot data=mysas.OptIterHistory;
	xaxis grid type=log; yaxis grid values=(0 to 7 by 1)  display=(nolabel);
	series x=Progress y=Loss / lineattrs=(color=gray pattern=2);
	series x=Progress y=Objective / lineattrs=(color=blue pattern=1);
run;

/* How well does our model do? */
proc nnet data=mycas.mnist_test inmodel=mycas.nnetModel;
   score out=mycas.nnetOut copyvars=d784;
run;