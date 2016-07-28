/* ~/.authinfo is used to connect to CAS */
options cashost="rdcgrd001.unx.sas.com" casport=47885 casuser="europe\sbxjen";
cas mysess sessopts=(nworkers=100) uuidmac=uuid;
/* %put &uuid.; */

/* Reference the CAS library */
%let caslibname = mycas;
libname &caslibname. cas caslib="casuser";

/* end of program */

%put &uuid.;