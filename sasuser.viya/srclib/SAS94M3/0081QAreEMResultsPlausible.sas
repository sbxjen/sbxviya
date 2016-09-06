libname mysas "/sastest/EMProjects/Aperam/DataSources";

proc contents data=mysas.POST_GEN_TRAIN; run;

proc print data=mysas.POST_LOG_TRAIN(obs=2); run;

proc means data=mysas.POST_GEN_VALIDATE;
	var STD_REP_IMP_CRM3_P_d251_Col1;
run;

proc means data=mysas.POST_GEN_TRAIN;
	var norm_dd_x ;
run;

proc univariate data=mysas.POST_GEN_TRAIN(where=(norm_dd_x ne 0)) noprint;
	histogram norm_dd_x / gamma(theta=0);
run;

proc freq data=mysas.POST_GEN_TRAIN;
	tables IMP_bBolvorm TG_SKP1_d421;
run;

ods graphics / reset imagemap;
proc sgplot data=MYSAS.POST_GEN_TRAIN;
	vbox norm_dd_x / category=SKP1_d491;
	yaxis grid;
ods graphics / reset;

ods graphics / reset imagemap;
proc sgplot data=MYSAS.POST_TRAIN;
	scatter x=STD_REP_G_IN y=norm_dd_x / transparency=0.0 name='Scatter';
	xaxis grid;
	yaxis grid;
run;
ods graphics / reset;