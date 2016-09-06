
proc regselect data=mycas.&casdata.;
	class &class. / split;
	*display / trace;
	model norm_dd_x = &int. &class.; /* / noint; /* All standardized */
	*selection method=forward(choose=aic);
	*selection method=lasso(choose=aic);
	selection method=lasso(choose=validate);
	partition role=V(train='0' validate='1') 
run;