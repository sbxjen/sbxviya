proc regselect data=mycas.&casdata.;
	class &class. / param=glm split;
	*display / trace;
	model norm_dd_x = &int. &class.; /* / noint; /* All standardized */
	selection method=forward(choose=aic) stophorizon=1;
run;