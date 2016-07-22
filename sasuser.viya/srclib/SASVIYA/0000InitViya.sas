%let viyadir = "/tmp/viya/";

/* Reference the CAS library in Viya. */
cas casauto;
caslib aperam datasource=(srctype="path") sessref=casauto
	path=&viyadir.;
%let caslibname = mycas;
libname &caslibname. cas caslib="aperam";