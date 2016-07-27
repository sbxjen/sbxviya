/*
DATA Step, PROC FORMAT and PROC DS2 are CAS enabled (16w20, 16w33).
PROC SQL, PROC SORT, PROC COPY and PROC APPEND are not (16w20, 16w33).

Some OPTIONS don't work; see below.
A DO LOOP is enabled in CAS.
*/


options cashost="sbxintern16.sbx.sas.com" casport=5570 casuser="sasuser";
cas mysess;

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

data mycas.merged; /* DOES NOT WORK AS DESCRIBED IN THE USER'S GUIDE */
	merge mycas.animal1 mycas.plant1;
	by Common Number;
run;



data mycas.animal1(duplicate=yes); /* duplicated on every worker */
	set mycas.animal1;
run;

data mycas.plant1(partition=(Number)); /* partitioned: 2 obs per workers, 3 workers */
	set mycas.plant1;
run;
data mycas.plant1;
	set mycas.plant1;
	put _hostname_;
run;


/* DynDataDrivCodeGen */

filename sascode temp;

proc datasets library=mycas nolist;
 delete abc: / memtype=data; run;
 delete def / memtype=data; run;
quit;

data _null_;
	file sascode;
 	do i=1 to 6;
PUT 'data mycas.abc' i ';'; /*(append=yes) makes the DATA step run in SAS */
PUT ' set mycas.plant1;'; /*(firstobs=' i ' obs=' i ') makes the DATA step run in SAS */
PUT ' do i=1 to 6;';
PUT ' set mycas.animal1;';
PUT ' output;';
PUT ' end;';
PUT 'run;';
/*PUT 'proc append base=mycas.def data=mycas.abc' i ';'; /* does not work in CAS */
PUT 'run;';*/
 end;
run;

options source2;
%include sascode;	