/* Specify a folder path to write the temporary output files */
%let outdir = &USERDIR.; 
libname mysas "&outdir.";

/* Specify the data set names */                    
%let casdata          = mycas.post_log_train;            
%let partitioned_data = mycas.post_log_part; 
%let extended_data 	  = mycas.post_log_ext;
%let sampled_data	  = mycas.post_log_sample;
%let testdata         = mycas.post_log_test;

/* Specify the data set inputs and target */
%let class_inputs    = ;
%let interval_inputs = WOE_STD_CRM3_d071 WOE_STD_CRM3_d121 
					   WOE_STD_CRM3_d246 WOE_STD_CRM3_d267 WOE_STD_CRM3_d269 WOE_STD_CRM3_d319 
					   WOE_STD_CRM3_d367 WOE_STD_CRM3_d373 WOE_STD_G WOE_STD_G_IN 
					   WOE_STD_IMP_SKP1_P_d325_Stddev WOE_STD_IMP_SKP1_P_d326_Stddev 
					   WOE_STD_IMP_SKP1_P_d327_Mean WOE_STD_IMP_SKP1_P_d402_Mean 
					   WOE_STD_IMP_SKP1_P_d462_Stddev WOE_STD_IMP_SKP1_P_d463_Stddev 
					   WOE_STD_IMP_SKP1_P_d464_Stddev WOE_STD_IMP_SKP1_P_d486_Stddev 
					   WOE_STD_IMP_SKP1_P_d487_Mean WOE_STD_IMP_SKP1_P_d521_Mean 
					   WOE_STD_IMP_SKP1_P_d521_Stddev WOE_STD_IMP_bSlijpTijd 
					   WOE_STD_IMP_bSlijpsteenDiameter 
					   WOE_STD_SKP1_P_d325_Col1 WOE_STD_SKP1_P_d325_Col2 WOE_STD_SKP1_P_d326_Col1 
					   WOE_STD_SKP1_P_d326_Mean WOE_STD_SKP1_P_d342_Stddev 
					   WOE_STD_SKP1_P_d345_Col1 WOE_STD_SKP1_P_d345_Col2 WOE_STD_SKP1_P_d345_Mean 
					   WOE_STD_SKP1_P_d345_Stddev WOE_STD_SKP1_P_d378_Col1 WOE_STD_SKP1_P_d378_Col2 
					   WOE_STD_SKP1_P_d378_Stddev WOE_STD_SKP1_P_d400_Col1 WOE_STD_SKP1_P_d400_Col2 
					   WOE_STD_SKP1_P_d447_Col1 WOE_STD_SKP1_P_d447_Col2 WOE_STD_SKP1_P_d447_Stddev 
					   WOE_STD_SKP1_P_d448_Col1 WOE_STD_SKP1_P_d448_Col2 WOE_STD_SKP1_P_d448_Col3 
					   WOE_STD_SKP1_P_d448_Mean WOE_STD_SKP1_P_d448_Stddev WOE_STD_SKP1_P_d449_Col1 
					   WOE_STD_SKP1_P_d449_Mean WOE_STD_SKP1_P_d449_Stddev WOE_STD_SKP1_P_d451_Col4 
					   WOE_STD_SKP1_P_d451_Mean WOE_STD_SKP1_P_d451_Stddev WOE_STD_SKP1_P_d458_Col2 
					   WOE_STD_SKP1_P_d458_Stddev WOE_STD_SKP1_P_d464_Col1 WOE_STD_SKP1_P_d464_Col2 
					   WOE_STD_SKP1_P_d464_Mean WOE_STD_SKP1_P_d469_Col1 WOE_STD_SKP1_P_d469_Col2 
					   WOE_STD_SKP1_P_d522_Col2 WOE_STD_SKP1_P_d522_Mean WOE_STD_SKP1_P_d522_Stddev 
					   WOE_STD_SKP1_P_d523_Col1 WOE_STD_SKP1_d331 WOE_STD_SKP1_d332 
					   WOE_STD_SKP1_d335 WOE_STD_SKP1_d383 WOE_STD_SKP1_d384 WOE_STD_SKP1_d437 
					   WOE_STD_SKP1_d443 WOE_STD_SKP1_d467 WOE_STD_SKP1_d510 WOE_STD_SKP1_d519 
					   WOE_STD_SKP1_d520 WOE_CRM3_d084 WOE_CRM3_d088 WOE_CRM3_d268 
					   WOE_IMP_bCodeSlijpReden WOE_IMP_bComponentDigits WOE_IMP_tCodeSlijpReden 
					   WOE_K_ATP WOE_SKP1_d338 WOE_SKP1_d404 WOE_SKP1_d452 WOE_SKP1_d492 
					   WOE_SKP1_d498
					   WOE_STD_SKP1_P_d344_Col1 WOE_STD_SKP1_P_d344_Col2 WOE_STD_SKP1_P_d344_Stddev
					   WOE_STD_SKP1_P_d324_Col1 WOE_STD_SKP1_P_d324_Col2 WOE_STD_SKP1_P_d324_Mean WOE_STD_SKP1_P_d324_Stddev 
					   WOE_STD_SKP1_P_d343_Col1 WOE_STD_SKP1_P_d343_Col2 WOE_STD_SKP1_P_d343_Mean WOE_STD_SKP1_P_d343_Stddev; 
%let target          = BIN_norm_dd_x;


/************************************************************************/
/* Identify variables that explain variance in the target               */
/************************************************************************/
/* We limit the number of variables to 70 */

/* Connect to the SAS 9.4 server and rsubmit code 		*/
%let myserver=sbxintern16.sbx.sas.com 7551;
options remote=myserver;

signon user="sastest" passwd="Orion123!";
rsubmit;

	/* Create libref on remote session 					*/
	libname mysas "/sastest/EMProjects/Aperam/DataSources";
	
endrsubmit;
signoff;


/************************************************************************/
/* Build a predictive model using Logistic Regression                   */
/************************************************************************/
proc logselect data=&partitioned_data. alpha=0.05;
	partition role=_role_(validate='validation' train='training');
	model &target.(event='0')= &interval_inputs. / link=logit clb;
    selection method=lasso
        (choose=validate) hierarchy=none details=summary; /* lasso = IV = gradboost */
	freq _freq_;
	code file="&outdir./logselect.sas";
run;

/************************************************************************/
/* Build a basic predictive model for Comparison purposes               */
/************************************************************************/
proc logselect data=&partitioned_data.;
	partition role=_role_(validate='validation' train='training');
	model &target.(event='0')= WOE_STD_SKP1_P_d324_Col1 WOE_STD_SKP1_P_d343_Col1 WOE_STD_SKP1_P_d344_Col1 / link=logit;
	freq _freq_;
	code file="&outdir./base.sas";
run;

/************************************************************************/
/* Build a predictive model using Gradient Boosting                     */
/************************************************************************/
/* Maybe using only 1 worker? */
data &extended_data.(drop=i);
	set &partitioned_data.;
	do i = 1 to round(_freq_,1);
		output;
	end;
run;

/* To set minleafsize to 0.05 * Number of Obs in post_(gen)_train */
*data _null_;
*	if 0 then set mycas.post_gen_train nobs=N;
*	call symput('N', strip(put(N,8.)));
*	stop;
*run;

ods output VariableImportance=mysas._gradboostVariableImportance;
proc gradboost data=&extended_data. 
		ntrees=60 maxdepth=4 samplingrate=0.5 vars_to_try=96 seed=23451 minleafsize=5 
		outmodel=mycas._gradboostModel; *minleafsize=0.05*&N. ntrees=200;
	partition role=_role_(validate='validation' train='training');
	target &target. / level=nominal;
	input &interval_inputs. / level=interval;
	code file="&outdir./gradboost.sas";
run;

/************************************************************************/
/* Bar chart with Variable Importance			                        */
/************************************************************************/
ods graphics on / reset imagemap height=512px width=2048px border=off;
ods html path="&outdir." gpath="&outdir." file="VariableImportance.html" style=HTMLBlue;

proc sgplot data=mysas._gradboostVariableImportance;
	title 'Variable Importance';
	vbar Variable / response=Importance fillattrs=(color=CX176ae6) categoryorder=respdesc 
		datalabel transparency=0.1 stat=Mean name='Bar';
	yaxis grid label='Importance';
run;

ods html close;
ods graphics / reset;
title;

/************************************************************************/
/* Build a predictive model on oversampled data		                    */
/************************************************************************/
proc partition data=&extended_data. event='1' eventprop=0.5 sampPctEvt=100;
	by BIN_norm_dd_x;
	output out=&sampled_data. freqname=freqname;
run;

proc gradboost data=&sampled_data. 
		ntrees=50 maxdepth=4 samplingrate=0.5 vars_to_try=96 seed=23451 minleafsize=5 
		outmodel=mycas._gradboostModel;
	partition role=_role_ (validate='validation' train='training');
	target &target. / level=nominal;
	input &interval_inputs. / level=interval;
	code file="&outdir./oversampling.sas";
run;


/************************************************************************/
/* Score the data using the generated model                             */
/************************************************************************/
data mycas._scored_logselect;
	set &testdata.;
	%include "&outdir./logselect.sas";
	p_&target.0 = p_&target.;
	p_&target.1 = 1-p_&target.;
run;

data mycas._scored_base;
	set &testdata.;
	%include "&outdir./base.sas";
	p_&target.0 = p_&target.;
	p_&target.1 = 1-p_&target.0;
run;

data mycas._scored_gradboost;
	set &testdata.;
	%include "&outdir./gradboost.sas";
run;

data mycas._scored_oversampling;
	set &testdata.;
	%include "&outdir./oversampling.sas";
run;


/****************************/
/* Assess model performance */
/****************************/
%macro assess_model(prefix=, var_evt=);
	proc assess data=mycas._scored_&prefix. ncuts=1000;
	input p_&target.1;
	target &target. / level=nominal event='1';
	freq _freq_;
	fitstat pvar=p_&target.0 / pevent='0';
	ods output  rocinfo = mysas.&prefix._ROCinfo
				liftinfo = mysas.&prefix._liftinfo;
	run;
%mend assess_model;

%assess_model(prefix=logselect);
%assess_model(prefix=base);
%assess_model(prefix=gradboost);
%assess_model(prefix=oversampling);


/*******************************************/
/* Analyze model using ROC and Lift charts */
/*******************************************/
data mysas.all_ROCinfo;
	set mysas.logselect_ROCinfo(keep=tp fp tn fn sensitivity fpr in=l)
		mysas.base_ROCinfo(keep=tp fp tn fn sensitivity fpr in=b)
		mysas.gradboost_ROCinfo(keep=tp fp tn fn sensitivity fpr in=g)
		mysas.oversampling_ROCinfo(keep=tp fp tn fn sensitivity fpr in=o)
	length model $ 32;
	select;
		when (l) model = 'Logistic Regression (LASSO) 2';
		when (b) model = 'Basic Model 2';
		when (g) model = 'Gradient Boosting 2';
		when (o) model = 'Gradient Boosting (oversampling) 2';
	end;
	misc = (fp+fn)/(tp+fp+tn+fn);
run;

/* Plot ROC Curves for All Models Together */
ods graphics on / reset imagemap;

proc sgplot data=mysas.all_ROCinfo;
	title "ROC Curve Models Overlain";
	yaxis label="Sensitivity";
	xaxis label="False Positive Rate" grid;
	lineparm x=0 y=0 slope=1 / transparency=0.7;
	series x=fpr y=sensitivity / group=model;
run;

/* Create lift charts */
data mysas.all_liftinfo;
	set mysas.logselect_liftinfo(keep=depth lift cumlift in=l)
		mysas.base_liftinfo(keep=depth lift cumlift in=b)
		mysas.gradboost_liftinfo(keep=depth lift cumlift in=g)
		mysas.oversampling_liftinfo(keep=depth lift cumlift in=o);
	length model $ 32;
	select;
		when (l) model = 'Logistic Regression (LASSO)';
		when (b) model = 'Basic Model';
		when (g) model = 'Gradient Boosting';
		when (o) model = 'Gradient Boosting (oversampling)';
	end;
run;

proc sgplot data=mysas.all_liftinfo;
	title "Lift Chart Models Overlain";
	yaxis label="Lift";
	xaxis label="Depth" grid;
	series x=depth y=cumlift / group=model markers markerattrs=(symbol=circlefilled);
run;

title;
ods graphics off;
