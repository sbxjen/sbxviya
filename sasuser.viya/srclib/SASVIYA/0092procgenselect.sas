/* PROC GENSELECT tends to give similar but "motivated" results. */
*proc varreduce data=mycas.post_train(where=(norm_dd_x ne 0) ondemand=no); /* With/without WHERE gives very similar results. */
*	class &class.;
*	reduce supervised norm_dd_x = &int. &class. / AIC; /* AIC tends to retain more variables than BIC. */ 
*run;

/* No elastic net, and LASSO doesn't work for numerical issues I guess... */
proc genselect data=mycas.post_train(where=(norm_dd_x ne 0)); *lassorho=0.8 fconv=1e-4 gconv=1e-4 xtol=1e-4;
	class &class.;
	model norm_dd_x = &int. &class. / distribution=gamma link=log;
	selection method=forward(choose=aic);
	*selection method=lasso(choose=aic);
run;


