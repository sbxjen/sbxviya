options cashost="sbxintern16.sbx.sas.com" casport=5570 casuser="sasuser";
cas mysess sessopts=(caslib="casuser") uuidmac=uuid;
libname mycas cas caslib="casuser";

%put &uuid.;

proc casutil incaslib="casuser";
	list tables;
run;

proc contents data=mycas.mnist_train; run;

%let height=28;
%let width=28;

data work.mnist;
	set mycas.mnist(firstobs=1 obs=1);
	put d784=;
run;

data work.long;
	array d{784};
	set work.mnist(drop=d784);
	do i=1 to &height.;
		y = &height.-i;
		do j=1 to &width.;
			x = j-1;
			k = (i-1)*&width.+j;
			z = d{k};
			output;
			*if (z gt 0) then output;
		end;
	end;
	keep x y z;
run;

ods graphics on / scale=on;
title "The MNIST Data";
proc sgplot data=work.long; 
	scatter x=x y=y /
		colorresponse=z
		markerattrs=(size=30pt symbol=squarefilled)
		transparency=0.3;
	xaxis display=none; yaxis display=none;
	gradlegend / notitle;
run;
ods _all_ close;

