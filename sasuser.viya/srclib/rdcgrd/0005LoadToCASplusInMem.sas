/* Make the connection to CAS */
%include "/home/sasuser/sbxviya/sasuser.viya/srclib/rdcgrd/0000ConnectToCAS.sas";

options fullstimer;

%let dir=/temp/viya/;
libname mysas "&dir.";
%let dsn=skp1allpluskeys;

/* Load client-side tables (In memory) */
proc casutil outcaslib="&mycaslib.";
	load data=mysas.&dsn. casout="&dsn." promote;
run;

/* Save server-side SASHDAT files */
proc casutil incaslib="&mycaslib.";
	save casdata="&dsn.";
run;

%include "/home/sasuser/sbxviya/sasuser.viya/srclib/rdcgrd/0001CloseConn.sas";
/* end of program */