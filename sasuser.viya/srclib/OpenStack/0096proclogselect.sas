/* Specify a folder path to write the temporary output files */
%let outdir = &USERDIR.; 

/* Specify the data set names */                    
%let casdata          = mycas.post_log_train;            
%let partitioned_data = mycas.post_log_part; 

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
					   WOE_STD_IMP_bSlijpsteenDiameter WOE_STD_SKP1_P_d324_Col1 
					   WOE_STD_SKP1_P_d324_Col2 WOE_STD_SKP1_P_d324_Mean WOE_STD_SKP1_P_d324_Stddev 
					   WOE_STD_SKP1_P_d325_Col1 WOE_STD_SKP1_P_d325_Col2 WOE_STD_SKP1_P_d326_Col1 
					   WOE_STD_SKP1_P_d326_Mean WOE_STD_SKP1_P_d342_Stddev WOE_STD_SKP1_P_d343_Col1 
					   WOE_STD_SKP1_P_d343_Col2 WOE_STD_SKP1_P_d343_Mean WOE_STD_SKP1_P_d343_Stddev 
					   WOE_STD_SKP1_P_d344_Col1 WOE_STD_SKP1_P_d344_Col2 WOE_STD_SKP1_P_d344_Stddev 
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
					   WOE_SKP1_d498; 
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
	
	/*
	%let class_inputs	= CRM3_d084 CRM3_d088 TG_CRM3_d268 
						  TG_IMP_bCodeSlijpReden IMP_bComponentDigits IMP_tCodeSlijpReden 
						  TG_K_ATP SKP1_d338 TG_SKP1_d404 TG_SKP1_d452 TG_SKP1_d492 TG_SKP1_d498;
	%let interval_inputs= STD_REP_CRM3_d071 STD_REP_CRM3_d121 
						  STD_REP_CRM3_d246 STD_REP_CRM3_d267 STD_REP_CRM3_d269 STD_REP_CRM3_d319 
						  STD_REP_CRM3_d367 STD_REP_CRM3_d373 STD_REP_G STD_REP_G_IN 
						  STD_REP_IMP_SKP1_P_d325_Stddev STD_REP_IMP_SKP1_P_d326_Stddev 
						  STD_REP_IMP_SKP1_P_d327_Mean STD_REP_IMP_SKP1_P_d402_Mean 
						  STD_REP_IMP_SKP1_P_d462_Stddev STD_REP_IMP_SKP1_P_d463_Stddev 
						  STD_REP_IMP_SKP1_P_d464_Stddev STD_REP_IMP_SKP1_P_d486_Stddev 
						  STD_REP_IMP_SKP1_P_d487_Mean STD_REP_IMP_SKP1_P_d521_Mean 
						  STD_REP_IMP_SKP1_P_d521_Stddev STD_REP_IMP_bSlijpTijd 
						  STD_REP_IMP_bSlijpsteenDiameter STD_REP_SKP1_P_d324_Col1 
						  STD_REP_SKP1_P_d324_Col2 STD_REP_SKP1_P_d324_Mean STD_REP_SKP1_P_d324_Stddev 
						  STD_REP_SKP1_P_d325_Col1 STD_REP_SKP1_P_d325_Col2 STD_REP_SKP1_P_d326_Col1 
						  STD_REP_SKP1_P_d326_Mean STD_REP_SKP1_P_d342_Stddev STD_REP_SKP1_P_d343_Col1 
						  STD_REP_SKP1_P_d343_Col2 STD_REP_SKP1_P_d343_Mean STD_REP_SKP1_P_d343_Stddev 
						  STD_REP_SKP1_P_d344_Col1 STD_REP_SKP1_P_d344_Col2 STD_REP_SKP1_P_d344_Stddev 
						  STD_REP_SKP1_P_d345_Col1 STD_REP_SKP1_P_d345_Col2 STD_REP_SKP1_P_d345_Mean 
						  STD_REP_SKP1_P_d345_Stddev STD_REP_SKP1_P_d378_Col1 STD_REP_SKP1_P_d378_Col2 
						  STD_REP_SKP1_P_d378_Stddev STD_REP_SKP1_P_d400_Col1 STD_REP_SKP1_P_d400_Col2 
						  STD_REP_SKP1_P_d447_Col1 STD_REP_SKP1_P_d447_Col2 STD_REP_SKP1_P_d447_Stddev 
						  STD_REP_SKP1_P_d448_Col1 STD_REP_SKP1_P_d448_Col2 STD_REP_SKP1_P_d448_Col3 
						  STD_REP_SKP1_P_d448_Mean STD_REP_SKP1_P_d448_Stddev STD_REP_SKP1_P_d449_Col1 
						  STD_REP_SKP1_P_d449_Mean STD_REP_SKP1_P_d449_Stddev STD_REP_SKP1_P_d451_Col4 
						  STD_REP_SKP1_P_d451_Mean STD_REP_SKP1_P_d451_Stddev STD_REP_SKP1_P_d458_Col2 
						  STD_REP_SKP1_P_d458_Stddev STD_REP_SKP1_P_d464_Col1 STD_REP_SKP1_P_d464_Col2 
						  STD_REP_SKP1_P_d464_Mean STD_REP_SKP1_P_d469_Col1 STD_REP_SKP1_P_d469_Col2 
						  STD_REP_SKP1_P_d522_Col2 STD_REP_SKP1_P_d522_Mean STD_REP_SKP1_P_d522_Stddev 
						  STD_REP_SKP1_P_d523_Col1 STD_REP_SKP1_d331 STD_REP_SKP1_d332 
						  STD_REP_SKP1_d335 STD_REP_SKP1_d383 STD_REP_SKP1_d384 STD_REP_SKP1_d437 
						  STD_REP_SKP1_d443 STD_REP_SKP1_d467 STD_REP_SKP1_d510 STD_REP_SKP1_d519 
						  STD_REP_SKP1_d520;
	
	ods output SelectionSummary=mysas.SelectionSummary;
	proc glmselect data=mysas.post_selection namelen=32;
		class &class_inputs.;
		model norm_dd_x = &class_inputs. &interval_inputs. / selection=elasticnet(choose=aic);
	run;
	*/
	
	/* Download results to CAS library */
	proc download data=mysas.SelectionSummary
    	out=mycas.post_SelectionSummary;
	run;
	
endrsubmit;
signoff;

proc contents data=mycas.post_SelectionSummary; run;

/************************************************************************/
/* Build a predictive model using Logistic Regression                   */
/************************************************************************/
proc logselect data=&partitioned_data. alpha=0.05;
	partition role=_role_(validate='validation' train='training');
	model &target.(event='0')= &interval_inputs. / link=logit clb;
	selection method=forward
        (select=sbc stop=sbc choose=validate) hierarchy=none;
	freq _freq_;
	code file="&outdir./logselect.sas";
run;

/************************************************************************/
/* Build a predictive model using Gradient Boosting                     */
/************************************************************************/

/************************************************************************/
/* Score the data using the generated model                             */
/************************************************************************/
data mycas._scored_logselect;
	set mycas.post_gen_test;
	%include "&outdir./logselect.sas";
	p_&target.1 = 1-p_&target.0;
run;


/************************************************************************/
/* Assess model performance                                             */
/************************************************************************/
/* TO DO: macro */
proc assess data=mycas._scored_logselect;
	input p_bad1;
	target &target. / level=nominal event='0';
	fitstat pvar=p_bad0 / pevent='0';
	by _partind_;
	ods output fitstat  = forest_fitstat 
	           rocinfo  = forest_rocinfo 
	           liftinfo = forest_liftinfo;
run;

