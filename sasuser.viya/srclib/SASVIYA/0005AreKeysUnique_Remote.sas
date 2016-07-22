/* RSUBMIT all DATA steps that should run in SAS 9.4. */

/* Connect to the SAS 9.4 server ... */
%let myserver=sbxintern16.sbx.sas.com 7551;
options remote=myserver;

/* Initial Connect session with credentials. */
signon user=sastest passwd="Orion123!";

/* ... and rsubmit code. */ 
%syslput viyadir=&viyadir.;

rsubmit;

	libname mysas &viyadir.;
	
	%include "/home/sastest/sasuser.viya/srclib/SAS94M3/0005QAreMATm2KeysUnique.sas";
	%include "/home/sastest/sasuser.viya/srclib/SAS94M3/0005QAreCRM3KeysUnique.sas";

endrsubmit;

signoff;
/* NOTE: Remote signoff from MYSERVER complete. */