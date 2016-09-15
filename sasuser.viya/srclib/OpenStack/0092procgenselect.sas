proc genselect data=mycas.post_gen_train(where=(norm_dd_x ne 0)); *lassorho=0.8 fconv=1e-4 gconv=1e-4 xtol=1e-4;
	class &class.;
	model norm_dd_x = &int. &class. / distribution=gamma link=log;
	*selection method=forward(choose=aic);
	selection method=lasso(choose=aic);
run;