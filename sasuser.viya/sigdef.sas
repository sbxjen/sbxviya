libname insaslib "/tmp/viya/" access=readonly;

%let SKP1_inputs = ('d325', 'd326', 'd327', 'd402', 'd462', 'd463', 'd464', 
					'd486', 'd487', 'd521', 'd521', 'd324', 'd325', 'd326', 
					'd342', 'd343', 'd344', 'd345', 'd378', 'd400', 'd447', 
					'd448', 'd449', 'd451', 'd458', 'd464', 'd469', 'd522',
					'd523', 'd331', 'd332', 'd335', 'd383', 'd384', 'd437', 
					'd443', 'd467', 'd510', 'd519', 'd520', 'd084', 'd088', 
					'd268', 'd338', 'd404', 'd452', 'd492', 'd498'); 
					   
%let CRM3_inputs = ('d071', 'd121', 'd246', 'd267', 'd269', 'd319', 'd367', 'd373');

proc contents data=insaslib.skp1_sigdef; run;

data skp1_sigdef;
	set insaslib.skp1_sigdef;
	where strip(signaal_nr) in &SKP1_inputs.;
	label signaal_nr='d' signaal='Signal' eenheid='Unit';
	keep signaal_nr signaal eenheid;
run;

proc sort data=skp1_sigdef;
	by signaal_nr;
run;

proc print data=skp1_sigdef label; run;