options cashost="sbxjen1.instance.openstack.sas.com" casport=5570 casuser="sasdemo";

cas mysess sessopts=(caslib="casuser" nworkers=1);
libname mycas cas caslib="casuser";

/* List files and tables available in caslib */
proc casutil incaslib="casuser";
	list files;
	list tables;
run;

cas mysess disconnect; 
cas mysess terminate;