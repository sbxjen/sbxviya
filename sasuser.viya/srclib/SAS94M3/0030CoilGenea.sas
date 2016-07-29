*;
libname mysas "/tmp/viya/" access=readonly;
libname myownsas "/tmp/v94/";
*;

proc print data=myownsas.matm2(obs=2); run;
/*
cl_n		dch_n	bew_vn
51801325	9		1	
*/

proc sort data=mysas.matm2(keep=ts_be ts_ei 
										cl_n dch_n bew_vn 
										k_atp k_nm_atp k_afw k_tstmat knt_bb
										dl_n_bri dl_n_bru dl_n_lei dl_n_leu 
										hoog_dch n_dchvan n_dchtot a_dch
										ln_pr_vr ln_pr ln_pr_vl
										wrk_n)
			out=work.mycoil;
	where cl_n in ("51801325", "51801315");
	by cl_n dch_n bew_vn;
run;

proc print data=work.mycoil;
run;
	
/*
proc print data=myownsas.crm3allplusKeys(obs=2); run;
*/
