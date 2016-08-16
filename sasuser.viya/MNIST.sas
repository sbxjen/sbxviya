options cashost="sbxintern16.sbx.sas.com" casport=5570 casuser="sasuser";
cas mysess sessopts=(caslib="casuser") uuidmac=uuid;
libname mycas cas caslib="casuser";

%put &uuid.;

libname mysas "&USERDIR.";

proc casutil incaslib="casuser";
	list tables;
run;

proc contents data=mycas.mnist_train; run;

proc mdsummary data=mycas.mnist_train;
	output out=mycas.mnist_train_std_;
run;
proc print data=mycas.mnist_train_std_; run;
data mycas.mnist_train_std_;
	length _vars $4000; /* 5*785 */
	retain _vars;
	set mycas.mnist_train_std_(keep=_Column_ _Std_ where=(_Std_ ne 0)) end=last;
	if (strip(_Column_) ne "d784") then _vars = catx("", _vars, _Column_);
	drop _vars;
	if last then call symputx("vars", _vars);
run;

%put &=vars.;

ods output OptIterHistory=mysas.OptIterHistory;
proc nnet data=mycas.mnist_train standardize=std;
	target d784 / level=nom comb=linear act=softmax error=entropy;
	input &vars. / level=int;
	architecture MLP;
	hidden 75;
	train outmodel=mycas.nnetModel seed=23451 validation=mycas.mnist_validation;
	optimization algorithm=lbfgs maxiters=250 RegL1=0.001 RegL2=0.001;
	code file="&USERDIR./nnetModel.sas";
run;
ods _all_ close;

data mysas.nnetModel;
	set mycas.nnetModel;
run;

proc nnet data=mycas.mnist_test inmodel=mycas.nnetModel;
   score out=mycas.nnetOut copyvars=d784;
run;

proc contents data=mysas.OptIterHistory; run;

ods graphics on / scale=on;
title "Iteration History";

proc sgplot data=mysas.OptIterHistory;
	xaxis grid type=log; yaxis grid values=(0 to 7 by 1)  display=(nolabel);
	series x=Progress y=Loss / lineattrs=(color=gray pattern=2);
	series x=Progress y=Objective / lineattrs=(color=blue pattern=1);
run;

/*proc nnet data=mycas.mnist_train standardize=std;
	target d784 / level=nom comb=linear act=softmax error=entropy;
	input &vars. / level=int;;
	train outmodel=mycas.nnetModel1 seed=23451;
	autotune kfold=10;
	optimization algorithm=sgd maxiters=150;
run;*/

%let height=28;
%let width=28;

data work.mnist;
	set mycas.mnist(firstobs=1 obs=1);
	put d784=;
run;

data work.long;
	array d{784};
	set work.mnist(drop=d784);
	do i=1 to &height.;
		y = &height.-i;
		do j=1 to &width.;
			x = j-1;
			k = (i-1)*&width.+j;
			z = d{k};
			output;
			*if (z gt 0) then output;
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

