libname mysas "/sastest/EMProjects/Aperam/DataSources";

proc contents data=mysas.POST_VALIDATE; run;

proc means data=mysas.POST_VALIDATE;
	var IMP_REP_STD_SKP1_P_d282_Stddev;
run;