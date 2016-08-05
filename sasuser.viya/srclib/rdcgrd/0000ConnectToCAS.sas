/* ~/.authinfo is used to connect to CAS */
options cashost="rdcgrd001.unx.sas.com" casport=47886 casuser="europe\sbxjen";
cas mysess sessopts=(nworkers=100) uuidmac=uuid;
%put &uuid.;

/* Reference the CAS library */
%let mycaslib = casuserhdfs;
%let caslibname = mycas;
libname &caslibname. cas caslib="&mycaslib.";

proc casutil incaslib="&mycaslib.";
	list files;
run;

/* end of program */

/* Does this work? */
/* caslib aperam datasource=(srctype="path") path="/nas/scratch/jeroendestudent"; */
/* NOTE: Failed to resolve path /nas/scratch/jeroendestudent/ for caslib APERAM. */