*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

options nosymbolgen;

%let inputdsn=ousaslib.skp1walsplusKeys;
%let KeyColumns=cl_n bew_vn dch_n _deel;

data &inputdsn.;
	set &inputdsn.;
	KeyCol = catx("_", cl_n, put(bew_vn,best.), put(dch_n,best.), put(_deel,best.));
run;
proc sort data=&inputdsn.;
	by KeyCol;
run;
data work._deel;
	set &inputdsn.(keep=KeyCol);
run;
data work._deel;
  	set work._deel;
  	by KeyCol;
  	if first.KeyCol then count=0;
  	count+1;
  	if last.KeyCol then do;
  		if (count < 6) then output;
  	end;
  	drop count;
run;
data &inputdsn.;
	merge &inputdsn.(in=a) work._deel(in=b);
	by KeyCol;
	if not b;
	drop KeyCol;
run; 

/* end of program */