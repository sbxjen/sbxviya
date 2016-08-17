libname ousaslib "/tmp/v94/";
%let inputdsn=ousaslib.skp1walsplusKeys_PREP;

/* 	inputdsn contains 2 target variables: d524 (raw) and P_d524 (smoothed).
	We take sqrt(||d(P_d524)/d(_x)||_2^2 / N) as our target in the cross-sectional data set.
*/
data &inputdsn._TARGET;
	set &inputdsn._INTERVAL(keep=KeyCol ts_registratie _x P_d524);
run;

proc sort data=&inputdsn._TARGET;
	by KeyCol;
run;

proc expand data=&inputdsn._TARGET out=&inputdsn._TARGET method=none;
	by KeyCol;
	id ts_registratie;
	convert P_d524=dif_P_d524 / transformout=(dif 1);
	convert _x=dif_x / transformout=(dif 1);
run;

data &inputdsn._TARGET(keep=KeyCol dd_x);
	set &inputdsn._TARGET; /* . = $-\infty$ */
	dd_x=max(0, dif_P_d524/dif_x);
run;

data &inputdsn._TARGET(keep=KeyCol norm_dd_x);
	retain norm_dd_x N 0;
	set &inputdsn._TARGET;
	by KeyCol;

	if first.Keycol then
		do;
			N=0;
			norm_dd_x=0;
		end;
	N + 1;
	norm_dd_x + dd_x**2;

	if last.KeyCol then
		do;
			norm_dd_x = sqrt(norm_dd_x/N);
			output;
		end;
run;

/* Retain positive and zero values, but rescale the target so that it becomes of an interpretable order of magnitude. */
proc stdize data=&inputdsn._TARGET out=&inputdsn._TARGET method=euclen; 
	var norm_dd_x;
run;

/* end of program */