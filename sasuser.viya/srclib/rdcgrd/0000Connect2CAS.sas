
/* ~/.authinfo is used to connect to CAS */
options cashost='rdcgrd001.unx.sas.com' casport=47885;
options set=authinfo='/home/sasuser/.authinfo';
options set=casclientdebug=1;

cas mysess;  *sessopts=(nworkers=100);

/*
=== CAS rdcgrd001.unx.sas.com:47884 (139) http://rdcgrd001.unx.sas.com:57884 ===
ERROR: Access denied.
*/

/* Reference the CAS library */
%let caslibname = mycas;
libname &caslibname. cas caslib="casuser";

/* end of program */