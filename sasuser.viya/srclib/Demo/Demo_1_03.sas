options cashost="sbxjen1.instance.openstack.sas.com" casport=5570 casuser="sasdemo";
cas casauto sessopts=(caslib="casuser"); 
libname mycas cas caslib="casuser";

data animal1; /*2*/
	input Common $ Animal $ 3-7 Number 8-10;
	datalines;
a Ant  1
b Bird 2
c Cat  3
d Dog  4
e Eagle5
f Frog 6
;
run;

data plant1; /*3 */
	input Common $ Plant $ 3-10 Number 12-13;
	datalines;
a Grape    1
c Hazelnut 2
e Indigo   3
g Jicama   1
i Kale     2
k Lentil   3
;
run;

data merged;
	merge animal1 plant1;
	by Common Number;
run;

proc print data=merged; run;
title 'Animals and Plants Merged By Common and Number in SAS'; run;

libname mycas cas caslib="casuser" sessref=mysess;

proc casutil outcaslib="casuser";
	load data=animal1 replace;
	load data=plant1 replace;
run;

data mycas.merged; /* This does not work as described in the User's Guide */
	set mycas.animal1 mycas.plant1;
	by Common Number;
run;