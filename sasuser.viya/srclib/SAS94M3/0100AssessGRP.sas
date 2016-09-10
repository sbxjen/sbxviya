libname EMPro "/sastest/EMProjects/Aperam/DataSources";
libname tmp "/tmp/v94/";

/* Move WOE GRP data to our usual ousaslib */
data tmp.post_grp_all;
	set EMPro.post_grp_train; *EMPro.post_grp_train EMPro.post_grp_validate;
run;

/*----------*/
			   
/* 					   GRP_STD_SKP1_P_d324_Col1 GRP_STD_SKP1_P_d324_Col2  
					   GRP_STD_SKP1_P_d325_Col1 GRP_STD_SKP1_P_d325_Col2 
					   GRP_STD_SKP1_P_d326_Col1 
					   GRP_STD_SKP1_P_d343_Col1 GRP_STD_SKP1_P_d343_Col2 
					   GRP_STD_SKP1_P_d344_Col1 GRP_STD_SKP1_P_d344_Col2  
					   GRP_STD_SKP1_P_d345_Col1 GRP_STD_SKP1_P_d345_Col2  
					   GRP_STD_SKP1_P_d378_Col1 GRP_STD_SKP1_P_d378_Col2 
					   GRP_STD_SKP1_P_d400_Col1 GRP_STD_SKP1_P_d400_Col2 
					   GRP_STD_SKP1_P_d447_Col1 GRP_STD_SKP1_P_d447_Col2  
					   GRP_STD_SKP1_P_d448_Col1 GRP_STD_SKP1_P_d448_Col2 GRP_STD_SKP1_P_d448_Col3 
					   GRP_STD_SKP1_P_d449_Col1 
					   GRP_STD_SKP1_P_d451_Col4 
					   GRP_STD_SKP1_P_d458_Col2 
					   GRP_STD_SKP1_P_d464_Col1 GRP_STD_SKP1_P_d464_Col2 
					   GRP_STD_SKP1_P_d469_Col1 GRP_STD_SKP1_P_d469_Col2 
					   GRP_STD_SKP1_P_d522_Col2  
					   GRP_STD_SKP1_P_d523_Col1
*/

%let SKP1interval_Col	= P_d324 P_d325 P_d326 P_d343 P_d344 P_d345 P_d378 P_d400 P_d447 P_d448 P_d449 P_d451 P_d458 P_d464 P_d469 P_d522 P_d523;

/* Keep only selected variables */
data tmp.skp1walsplusKeysforGRP;
	set tmp.skp1walspluskeys_orig(keep=cl_n bew_vn dch_n _deel ts_registratie &SKP1interval_Col.);
	KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.), put(_deel,best.));
	drop cl_n bew_vn dch_n _deel;
run;

%macro preprocess();
	proc stdize data=tmp.skp1walsplusKeysforGRP out=tmp.skp1walsplusKeysforGRP method=std;
		var &SKP1interval_Col.;
	run;

	proc sort data=tmp.skp1walsplusKeysforGRP;
		by KeyCol ts_registratie;
	run;

	/* Align ts_registratie for visualization purposes */
	data tmp.skp1walsplusKeysforGRP(drop=i);
		retain i;
		set tmp.skp1walsplusKeysforGRP;
		by KeyCol;
		if first.KeyCol then do; 
			i=0;
		end;
		else i+1;
		ts_registratie = i;
	run;

	%let N=%sysfunc(countw(&SKP1interval_Col.,%str( )));
	%do i=1 %to &N.;
		%let y=%scan(&SKP1interval_Col.,&i.);
		
		/* Fit a cubic spline. */
		options nonotes;
		proc transreg data=tmp.skp1walsplusKeysforGRP noprint plots=none;
			by KeyCol_deel;
			model identity(&y.) = spline(ts_registratie / degree=3);
			output out=work.spline predicted;
		run;
		options notes;
		data tmp.skp1walsplusKeysforGRP;
			merge tmp.skp1walsplusKeysforGRP work.spline(drop=_TYPE_ _NAME_ &y. T&y. Intercept TIntercept Tts_registratie);
			by KeyCol ts_registratie;
			if (P&y.=0) then P&y.=&y.;
		run;
		proc datasets library=work nolist;
 			delete spline / memtype=data;
 		run;
		quit;
		
	%end;
%mend;

%preprocess();

/* Retain unique KeyCol_deels only */
proc sort data=tmp.post_grp_all;
	by KeyCol_deel;
run;
data tmp.post_grp_all;
	set tmp.post_grp_all;
	by KeyCol_deel;
	if first.KeyCol_deel;
run;

proc sql noprint;
	create table tmp.skp1walsplusKeysplusGRP as
	select a.*, b.*
 	from tmp.post_grp_all 					  a
      	 left join tmp.skp1walsplusKeysforGRP b
 	on a.KeyCol_deel = b.KeyCol
 	order by a.KeyCol_deel;
quit;

/*----------*/

/*					   GRP_STD_SKP1_P_d324_Mean GRP_STD_SKP1_P_d324_Stddev
					   GRP_STD_IMP_SKP1_P_d325_Stddev 
					   GRP_STD_SKP1_P_d326_Mean GRP_STD_IMP_SKP1_P_d326_Stddev 
					   GRP_STD_IMP_SKP1_P_d327_Mean
					   GRP_STD_SKP1_P_d342_Stddev 
					   GRP_STD_SKP1_P_d343_Mean GRP_STD_SKP1_P_d343_Stddev
					   GRP_STD_SKP1_P_d344_Stddev
					   GRP_STD_SKP1_P_d345_Mean GRP_STD_SKP1_P_d345_Stddev
					   GRP_STD_SKP1_P_d378_Stddev
					   GRP_STD_IMP_SKP1_P_d402_Mean
					   GRP_STD_SKP1_P_d447_Stddev 
					   GRP_STD_SKP1_P_d448_Mean GRP_STD_SKP1_P_d448_Stddev  
					   GRP_STD_SKP1_P_d449_Mean GRP_STD_SKP1_P_d449_Stddev
					   GRP_STD_SKP1_P_d451_Mean GRP_STD_SKP1_P_d451_Stddev
					   GRP_STD_SKP1_P_d458_Stddev
					   GRP_STD_IMP_SKP1_P_d462_Stddev 
					   GRP_STD_IMP_SKP1_P_d463_Stddev 
					   GRP_STD_SKP1_P_d464_Mean GRP_STD_IMP_SKP1_P_d464_Stddev 
					   GRP_STD_IMP_SKP1_P_d486_Stddev 
					   GRP_STD_IMP_SKP1_P_d487_Mean 
					   GRP_STD_IMP_SKP1_P_d521_Mean GRP_STD_IMP_SKP1_P_d521_Stddev
					   GRP_STD_SKP1_P_d522_Mean GRP_STD_SKP1_P_d522_Stddev
*/

%let SKP1interval	= P_d324 P_d325 P_d326 P_d327 P_d342 P_d343 P_d344 P_d345 P_d378 P_d402 
				  	  P_d447 P_d448 P_d449 P_d451 P_d458 P_d462 P_d463 P_d464 P_d486 P_d487 P_d521 P_d522;
					   
/*
					   GRP_STD_SKP1_d331 GRP_STD_SKP1_d332 
					   GRP_STD_SKP1_d335 GRP_STD_SKP1_d383 
					   GRP_STD_SKP1_d384 GRP_STD_SKP1_d437 
					   GRP_STD_SKP1_d443 GRP_STD_SKP1_d467 
					   GRP_STD_SKP1_d510 GRP_STD_SKP1_d519 
					   GRP_STD_SKP1_d520  
					   GRP_STD_CRM3_d071 GRP_STD_CRM3_d121 
					   GRP_STD_CRM3_d246 GRP_STD_CRM3_d267 
					   GRP_STD_CRM3_d269 GRP_STD_CRM3_d319 
					   GRP_STD_CRM3_d367 GRP_STD_CRM3_d373
					   GRP_SKP1_d338 GRP_SKP1_d404 
					   GRP_SKP1_d452 GRP_SKP1_d492 
					   GRP_SKP1_d498
					   GRP_CRM3_d084 GRP_CRM3_d088 GRP_CRM3_d268
					   GRP_STD_IMP_bSlijpsteenDiameter GRP_IMP_bCodeSlijpReden GRP_IMP_bComponentDigits GRP_IMP_tCodeSlijpReden GRP_STD_IMP_bSlijpTijd 
					   GRP_STD_G GRP_STD_G_IN GRP_K_ATP ;
*/

/*----------*/

/* Plots */

/*----------*/

%let _panel_ = GRP_STD_SKP1_P_d324_Col1;
%let _input_ = d343;

ods graphics / reset imagemap width=512px height=512px;
proc sgpanel data=tmp.skp1walsplusKeysplusGRP;
	panelby &_panel_. / layout=rowlattice spacing=5;
	rowaxis label="Time";
	colaxis label="&_input_." grid;
	series x=ts_registratie y=P_&_input_. / transparency=0.3 lineattrs=(color=CX176ae6);
run;

ods graphics / reset;

/*----------*/

proc contents data=EMPro.post_glm_train; run;
%let _input_ = STD_REP_SKP1_d383;

ods graphics / reset imagemap;
title 'Scatter Plot for Interval Inputs';
proc sgplot data=EMPro.post_glm_train;
	xaxis label="&_input_.";
	yaxis label="POST" grid;
	scatter x=&_input_. y=norm_dd_x / transparency=0.3 markerattrs=(color=CX176ae6);
run;

ods graphics / reset;
title;

/*----------*/

proc contents data=EMPro.post_glm_train; run;
%let _input_ = TG_K_ATP;

ods graphics / reset imagemap;
title 'Box Plot for Categorical Inputs';
proc sgplot data=EMPRO.POST_GLM_TRAIN;
	xaxis label="&_input_." fitpolicy=splitrotate;
	yaxis label="POST" grid;
	vbox norm_dd_x / category=&_input_. fillattrs=(color=CXCAD5E5);
run;

ods graphics / reset;
title;

/* end of program */