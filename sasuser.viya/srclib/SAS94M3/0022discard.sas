/* Quick and dirty: discard empty and constant columns in all data sets of interest. */

*;
libname ousaslib "/tmp/v94/";
*;

options nosymbolgen;

/*data ousaslib.temp;
	length a $8;
	infile datalines missover;
	input a b c d e;
	datalines;
z 0 1 2 
z 0 2 4 
z 0 4 8
z 0 8 16
;
run;*/

%macro discard(tables=);
%let n=%sysfunc(countw(&tables.,%str( )));
%do i = 1 %to &n;
	%let inputdswemptycols = ousaslib.%scan(&tables., &i);
	%include '/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0020DiscardEmptyColumns.sas';
	%let inputdswconstcols = &inputdswemptycols.;
	%include '/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0021DiscardConstantColumns.sas';
%end;
%mend;

*%discard(tables=temp);

*%discard(tables=skp1allPlusKeysplusCilinders crm3allPlusKeys);


/*
WARNING: The variable tCilinderDiameterEindeA in the DROP, KEEP, or RENAME list has never been referenced.
WARNING: The variable tSlijpsteenComponentTyp in the DROP, KEEP, or RENAME list has never been referenced.
WARNING: The variable bCilinderDiameterEindeA in the DROP, KEEP, or RENAME list has never been referenced.
*/
/* Cause: variable names have become too long, so we manually account for this here. */
data ousaslib.skp1allPlusKeysplusCilinders;
	set ousaslib.skp1allPlusKeysplusCilinders;
	drop 	tCilinderDiameterEindeAutoLinks bCilinderDiameterEindeAutoLinks
			tCilinderDiameterEindeAutoRechts bCilinderDiameterEindeAutoRechts
			tSlijpsteenComponentTypeId bSlijpsteenComponentTypeId;
run;


/* Drop all uninformative time variables */
proc contents data=ousaslib.skp1allPlusKeysplusCilinders ; run;
data ousaslib.skp1allPlusKeysplusCilinders ;
	set ousaslib.skp1allPlusKeysplusCilinders ;
	drop 	tBeginDatum bBeginDatum
			tEindDatum bEindDatum
			tHistoryTime bHistoryTime 
			teinddatumskp beinddatumskp;
run;

/* end of program */