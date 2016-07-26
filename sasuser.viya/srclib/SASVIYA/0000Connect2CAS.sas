
/* ~/.authinfo is used to connect to CAS */
options cashost='sbxintern16.sbx.sas.com' casport=5570;
options set=authinfo='/home/sasuser/.authinfo';
options set=casclientdebug=1;

cas mysess;

/* Reference the CAS library */
%let viyadir = "/tmp/viya/";

caslib aperam datasource=(srctype="path") sessref=mysess
	path=&viyadir.;

%let caslibname = mycas;
libname &caslibname. cas caslib="aperam";

/* end of program */