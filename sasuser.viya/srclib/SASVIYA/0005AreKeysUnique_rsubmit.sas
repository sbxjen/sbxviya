/* RSUBMIT all DATA steps that should run in SAS 9.4. */

/* Connect to the SAS 9.4 server ... */
%let myserver=sbxintern16.sbx.sas.com 7551;
options remote=myserver;

/* Initial Connect session with credentials. */
signon user=sastest passwd="Orion123!";

/* ... and rsubmit code. */ 
%syslput viyadir=&viyadir.;

rsubmit;

	/* Reference the library */
	libname mysas &viyadir.;
	
	%include "/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0005QAreMATm2KeysUnique.sas";
	
	%macro pv(tables=);
	%let n=%sysfunc(countw(&tables.,%str( )));
	%do i = 1 %to &n.;
		%let dsn=%scan(&tables., &i.);
		%include "/home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0005QArePVKeysUnique.sas";
	%end;
	%mend;
	
	%pv(tables=	crm3_pv crm3_pv_2015q1 crm3_pv_2015q2 crm3_pv_2015q3 crm3_pv_2015q4
				skp1_pv skp1_pv_2015q1 skp1_pv_2015q2 skp1_pv_2015q3 skp1_pv_2015q4);
				
endrsubmit;

signoff;
/* NOTE: Remote signoff from MYSERVER complete. */

/* end of program */