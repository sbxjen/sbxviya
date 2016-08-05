%let height=5;
%let width=5;

data work.image;
	input d1-d25;
datalines;
0 0 1 0 0 
0 1 0 1 0 
1 0 0 0 1 
1 0 0 0 1 
1 1 1 1 1 
;
run;

data work.long;
	array d{25};
	set work.image;
	do i=1 to &height.;
		y = &height.-i;
		do j=1 to &width.;
			x = j-1;
			k = (i-1)*&width.+j;
			if (d{k} gt 0) then output;
		end;
	end;
	keep x y;
run;

ods graphics on / scale=on;
title "The MNIST Data";
proc sgplot data=work.long; 
	scatter x=x y=y /
		markerattrs=(size=3.75pt symbol=circlefilled)
		transparency=0.3;
	xaxis display=none; yaxis display=none; 
run;
ods _all_ close;

