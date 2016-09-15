libname insaslib "/tmp/viya/" access=readonly;
libname mysas "&USERDIR.";

data Gradboost_varimp;
	set mysas.Gradboost_varimp;
	where Variable like "%SKP1%";
	keep Variable Importance;
run;

data skp1_sigdef;
	set insaslib.skp1_sigdef;
	label signaal='Variable' eenheid='Unit';
	keep signaal_nr signaal eenheid;
run;

proc sql noprint;
	create table varimp as
	select a.*, b.*
 	from Gradboost_varimp	a,
      	 skp1_sigdef 		b
 	where a.Variable contains strip(b.signaal_nr)
 	order by a.Importance;
quit;

proc sort data=varimp(where=(signaal ne ""));
	by descending Importance signaal_nr;
run;

data varimp;
	set varimp;
	by descending Importance signaal_nr;
	if first.signaal_nr then output;
	keep Importance signaal eenheid;
run;

proc print data=varimp label; run;