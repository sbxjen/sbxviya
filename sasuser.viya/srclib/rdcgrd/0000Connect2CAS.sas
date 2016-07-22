
/* ~/.authinfo is used to connect to CAS */
options cashost='rdcgrd001.unx.sas.com' casport=47884 sessopts=(nworkers=100);
/*
=== CAS rdcgrd001.unx.sas.com:47884 (139) http://rdcgrd001.unx.sas.com:57884 ===
ERROR: Access denied.
*/

cas mysess;

/* Reference the CAS library */
%let caslibname = mycas;
libname &caslibname. cas caslib="casuser";

/* end of program */