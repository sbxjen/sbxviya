/* Create libref on remote session 					*/
libname mysas "/sastest/EMProjects/Aperam/DataSources";
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
	class &class_inputs.; /* NO split */
	model norm_dd_x=&class_inputs. &interval_inputs. / 
		selection=elasticnet(choose=aic);
run;