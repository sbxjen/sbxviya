libname EMPro "/sastest/EMProjects/Aperam/DataSources";
libname tmp "/tmp/v94/";

%let alldata = tmp.SKP1plusCRM3plusKeys;

/************************************************************************/
/* Create necessary data sets					                        */
/************************************************************************/

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

					   GRP_STD_SKP1_P_d324_Mean GRP_STD_SKP1_P_d324_Stddev
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
			   
%let SKP1interval	   = P_d324 P_d325 P_d326 P_d327 P_d342 
						 P_d343 P_d344 P_d345 P_d378 P_d400 
						 P_d402 P_d447 P_d448 P_d449 P_d451 
						 P_d458 P_d462 P_d463 P_d464 P_d469
						 P_d486 P_d487 P_d521 P_d522 P_d523;

/* Keep only selected variables */
data tmp.skp1walsplusKeysforGRP;
	set tmp.skp1walsplusKeys_ORIG(keep=cl_n bew_vn dch_n _deel ts_registratie &SKP1interval.);
	KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.), put(_deel,best.));
	drop cl_n bew_vn dch_n _deel;
run;

%macro preprocess();
	*proc stdize data=tmp.skp1walsplusKeysforGRP out=tmp.skp1walsplusKeysforGRP method=std;
	*	var &SKP1interval_Col.;
	*run;

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

	*%let N=%sysfunc(countw(&SKP1interval_Col.,%str( )));
	*%do i=1 %to &N.;
	*	%let y=%scan(&SKP1interval_Col.,&i.);
	*	
		/* Fit a cubic spline. */
	*	options nonotes;
	*	proc transreg data=tmp.skp1walsplusKeysforGRP noprint plots=none;
	*		by KeyCol_deel;
	*		model identity(&y.) = spline(ts_registratie / degree=3);
	*		output out=work.spline predicted;
	*	run;
	*	options notes;
	*	data tmp.skp1walsplusKeysforGRP;
	*		merge tmp.skp1walsplusKeysforGRP work.spline(drop=_TYPE_ _NAME_ &y. T&y. Intercept TIntercept Tts_registratie);
	*		by KeyCol ts_registratie;
	*		if (P&y.=0) then P&y.=&y.;
	*	run;
	*	proc datasets library=work nolist;
 	*		delete spline / memtype=data;
 	*	run;
	*	quit;
		
	%end;
%mend;

/* This aligns all ts_registratie - don't do this if you want histograms showing how obs are distributed in Time */
%preprocess();

/* Move WOE GRP data to our usual ousaslib */
data tmp.post_grp_all;
	set EMPro.post_grp_train; *EMPro.post_grp_train EMPro.post_grp_validate;
run;

/* Retain unique KeyCol_deels only */
proc sort data=tmp.post_grp_all;
	by KeyCol_deel;
run;
data tmp.post_grp_all;
	set tmp.post_grp_all;
	by KeyCol_deel;
	if first.KeyCol_deel;
run;

/* You can take a sample before plotting */
*proc surveyselect data=tmp.post_grp_all
*   method=srs n=500 out=SampleSRS;
*run;

proc sql noprint;
	create table tmp.skp1walsplusKeysplusGRP as
	select a.*, b.*
 	from SampleSRS					  		  a
      	 left join tmp.skp1walsplusKeysforGRP b
 	on a.KeyCol_deel = b.KeyCol
 	order by a.KeyCol_deel;
quit;



%let _panel_ = GRP_STD_SKP1_P_d324_Col1;
%let _input_ = d324;

/************************************************************************/
/* Histogram of norm_dd_x (INTERVAL TARGET)           					*/
/************************************************************************/	

proc univariate data=&alldata.(where=(norm_dd_x ne 0)) noprint;
	histogram norm_dd_x / gamma(theta=0);
run;


/************************************************************************/
/* Plots for TSDR Input		                        					*/
/************************************************************************/	

data tmp.skp1walsplusKeysplusGRP;
	set tmp.skp1walsplusKeysplusGRP;
	time_registratie = timepart(ts_registratie);
run;

ods graphics / reset imagemap antialiasmax=22700 width=300px height=300px;
*title "Interval Input Time Series by WOE Attribute";
proc sgpanel data=tmp.skp1walsplusKeysplusGRP;*(where=(ts_registratie < '08oct2015:00:00:00'dt));
	panelby &_panel_. / layout=columnlattice spacing=5;
	colaxis label="Time" tickvalueformat=time.;
	rowaxis label="&_input_." grid;
	label &_panel_.="GRP";
	series x=time_registratie y=P_&_input_. / group=KeyCol_deel transparency=0.3 lineattrs=(color="Blue" thickness=2);
run;

title;
ods graphics / reset;


/************************************************************************/
/* How are	"Bandsnelheid (Col1)" and "Stroom Haspel1 (Col1)" related?  */
/************************************************************************/

ods graphics / reset imagemap antialiasmax=22700 width=500px height=500px border=off;
proc sgpanel data=tmp.skp1walsplusKeysplusGRP;*(where=(ts_registratie < '08oct2015:00:00:00'dt));
	panelby GRP_STD_SKP1_P_d324_Col1 GRP_STD_SKP1_P_d343_Col1 / layout=lattice;
	colaxis label="Time" tickvalueformat=time.;
	rowaxis grid;
	label GRP_STD_SKP1_P_d324_Col1="Bandsnelheid (Col1) GRP" GRP_STD_SKP1_P_d343_Col1="Stroom Haspel1 (Col1) GRP";
	series x=time_registratie y=P_d324 / group=KeyCol_deel transparency=0.3 lineattrs=(color="Blue" thickness=2);
	series x=time_registratie y=P_d343 / group=KeyCol_deel transparency=0.3 lineattrs=(color="PowderBlue" thickness=2);
run;

title;
ods graphics / reset;


/************************************************************************/
/* Show how obs are distributed between different WOE Attributes        */
/************************************************************************/

proc sort data=tmp.post_grp_all;
	by &_panel_.;
run;

ods output OneWayFreqs=OneWayFreqs;
proc freq data=tmp.post_grp_all;
	tables &_panel_.;
run;

ods graphics / reset imagemap width=400px height=400px;
title 'Proportion _deel obs for each "Bandsnelheid" WOE Attribute';
proc sgplot data=OneWayFreqs;
	vbar &_panel_. / response=Percent stat=Mean transparency=0.3 fillattrs=(color="PowderBlue");
	label &_panel_.="GRP";
	yaxis label="Percentage" grid;
run;

title;
ods graphics / reset;

data tmp.skp1walsplusKeysplusGRP;
	set tmp.skp1walsplusKeysplusGRP;
	day_registratie = datepart(ts_registratie);
run;

ods graphics / reset imagemap width=300px height=300px;
proc sgpanel data=tmp.skp1walsplusKeysplusGRP;
	panelby &_panel_. / layout=columnlattice spacing=5;
	colaxis label="Time" notimesplit fitpolicy=rotatethin interval=quarter tickvalueformat=date.;
	rowaxis label="Percentage" grid;
	label &_panel_.="GRP";
	histogram day_registratie / nbins=10 transparency=0.3 fillattrs=(color="PowderBlue");
run;

ods graphics / reset;


/************************************************************************/
/* Show the Effect of the MovaAve Window Size on d327                  */
/************************************************************************/	

data MovAve;
	set tmp.skp1walsplusKeysplusGRP(where=(ts_registratie < '04jun2015:00:00:00'dt));
	keep ts_registratie P_d327;
run;

proc sort data=MovAve;
	by ts_registratie ;
run;

proc expand data=MovAve out=MovAve method=none;
	id ts_registratie ;
	convert P_d327 = P_d327_3 / transformout=(movave 3);
	convert P_d327 = P_d327_5 / transformout=(movave 5);
run;

ods graphics / reset imagemap width=400px height=400px;
title 'Effect of the Moving Average Window Size on "Verlenging Omkeerrollen" (1 _deel)';
proc sgplot data=MovAve;
	xaxis label="Time" tickvalueformat=datetime.;
	yaxis label="Verlenging Omkeerrollen" grid;
	label P_d327="Original Time Series" P_d327_3="Window Size = 3" P_d327_5="Window Size = 5";
	series x=ts_registratie y=P_d327 / lineattrs=(color=CX176ae6 thickness=2);
	series x=ts_registratie y=P_d327_3 / lineattrs=(color=CXff00a1 thickness=1);
	series x=ts_registratie y=P_d327_5 / lineattrs=(color=CXff0000 thickness=1);
run;

ods graphics / reset;
title;


/************************************************************************/
/* Plot for Interval Input						                        */
/************************************************************************/

proc contents data=&alldata.; run;

%let _input_ = SKP1_d383;

ods graphics / reset imagemap;
title "Scatter Plot for Original NOMINAL Input";
proc sgplot data=&alldata.;
	xaxis label="Dikte coil ingang istw (mm)";
	yaxis grid;
	scatter x=&_input_. y=norm_dd_x / transparency=0.3 markerattrs=(color="Blue" symbol=CircleFilled);
	*reg x=&_input_. y=norm_dd_x / transparency=0.7;
run;

ods graphics / reset;
title;


/************************************************************************/
/* Plot for Categorical Input						                    */
/************************************************************************/

proc contents data=&alldata.; run;

%let _input_ = K_ATP;

ods graphics / reset imagemap;
title "Box Plot for Original NOMINAL Input";
proc sgplot data=&alldata.;
	xaxis label="K_ATP" fitpolicy=splitrotate;
	yaxis grid;
	vbox norm_dd_x / category=&_input_. fillattrs=(color="PowderBlue");
run;

ods graphics / reset;
title;

/* end of program */