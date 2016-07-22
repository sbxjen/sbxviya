/*BEREKENING SKP1_PV_PER_PAS_SUMMARY*/



/* AANPASSINGEN */
/* 25/09/2015 	Aanpassing van normale programma naar programma per pas */



/* ALLES VERNIEUWEN */
/* 1. helemaal in het begin: set pscad.Skp1_pv_summary (firstobs =  1 obs=1); */ 
/* 2. helemaal achteraan skp5 = de  nieuwe dataset */
/* 3. stop bij code uit stap 2; append niet runnen!!! */


/*bepaal de laatste observatie van pscad.Skp1_pv__per_pas_summary
  bepaal dan ts_be_skp hiervan en steek die in de macrovar*/

%let dsid=%sysfunc(open(pscad.Skp1_pv_per_pas_summary));
%let num=%sysfunc(attrn(&dsid,nlobs));
%let rc=%sysfunc(close(&dsid));
data laatste_observatie;
set pscad.Skp1_pv_per_pas_summary (firstobs =  &num obs=&num);
/*ALLES VERNIEUWEN STAP1*/ 
/*set pscad.Skp1_pv_summary (firstobs =  1 obs=1);*/
call symput('ts_last',ts_be_skp);
run;


/*TEST*/
/*%let ts_last = '01OCT2015:00:00:00'dt; %put &ts_last; */


/*alle signalen ophalen en eerste selectie maken
  selectie =
  ofwel mode polijsten = mode pol + snelheid GE 200
  ofwel walsen = mode pol=0 en snelheid GE 200 en druk GE 75
  ofwel inspectie = d457=0*/

data skp1 (drop = d:);
  set /*pscad.skp1_pv_2015q4
	 (keep=ts_registratie datum_reg
		d324-d334 d341-d345 d382 d385 d386 d401 d403 d405 d417 d418 d421 d451 d452 d457
		d433 d479-d488 d492-d495 d520-d526
		where= ( datum_reg GE datepart(&ts_last) AND 
				 ( (d382=1 and d324 GE 200) OR d457=0 OR (d382=0 and d324 GE 200 and (d341+d342) GE 150) ) ) 
	  )*/
	  pscad.skp1_pv 
	 (keep=ts_registratie datum_reg
		d324-d334 d341-d345 d382 d385 d386 d401 d403 d405 d417 d418 d421 d451 d452 d457
		d433 d479-d488 d492-d495 d520-d526
		where= ( datum_reg GE datepart(&ts_last) AND 
				 ( (d382=1 and d324 GE 200) OR d457=0 OR (d382=0 and d324 GE 200 and (d341+d342) GE 150) ) ) 
	  );

/*enkel nieuwe obs meenemen*/
if ts_registratie LE &ts_last then delete;

skp_bandsnelheid = d324;
skp_pasnr = d421;
skp_mode_pol = d382;
if d457 = 0 then skp_mode_insp=1; else skp_mode_insp=0;
skp_mode_wls=d433;
skp_LE_H1 = d325;
skp_LE_H2 = d326;

/*walsen*/
skp_wls_tractie_H1 = d328;
skp_wls_tractie_H2 = d329;
skp_wls_tractie_pap_in = d330;
skp_wls_tractie_pap_uit = d331+d332;
skp_wls_verlenging = d327;
skp_wls_verlenging_laser = d521;
skp_wls_druk_totaal = d341+d342;
skp_wls_druk_totaal_ton = d522+d523;
skp_wls_druk_totaal_soll = d520;
skp_wls_stroom_H1_teken = d343/abs(d343);
skp_wls_stroom_H1 = abs(d343);
skp_wls_stroom_wals = abs(d344);
skp_wls_stroom_H2 = abs(d345);
skp_wls_diam_cil_B = d385;
skp_wls_diam_cil_T = d386;
skp_wls_cil_B = d418;
skp_wls_cil_T = d417;

/*polijster tijdens walsen*/
skp_pw_debiet_lucht = d401;
skp_pw_kipdruk_r1 = d403;
skp_pw_kipdruk_r2 = d405;
skp_pw_snelheid = abs(d451);
skp_pw_kracht = d452;
skp_pw_bandpositie = d479;
skp_pw_voorspanning = d480;
skp_pw_polijstpositie = d481;
skp_pw_snelheid_soll = d482;
skp_pw_rest_M1 = d483;
skp_pw_rest_M2 = d484;
skp_pw_druk_totaal = d486+d487;
skp_pw_druk_deltaAZBZ = abs(d486) - abs(d487);
skp_pw_druk_RZ = d488;
skp_pw_v_motor_in = abs(d492);
skp_pw_v_motor_uit = abs(d493);
skp_pw_stroom_motor_in = abs(d494);
skp_pw_stroom_motor_uit = abs(d495);
skp_pw_blauwwaarde = d524;
skp_pw_blauwwaarde_corr = d525;
skp_pw_blauwwaarde_gradient = d526;

/*polijsten*/
skp_pol_debiet_lucht = d401;
skp_pol_kipdruk_r1 = d403;
skp_pol_kipdruk_r2 = d405;
skp_pol_snelheid = d451;
skp_pol_kracht = d452;
skp_pol_bandpositie = d479;
skp_pol_voorspanning = d480;
skp_pol_polijstpositie = d481;
skp_pol_snelheid_soll = d482;
skp_pol_rest_M1 = d483;
skp_pol_rest_M2 = d484;
skp_pol_druk_totaal = d486+d487;
skp_pol_druk_deltaAZBZ = abs(d486) - abs(d487);
skp_pol_druk_RZ = d488;
skp_pol_v_motor_in = abs(d492);
skp_pol_v_motor_uit = abs(d493);
skp_pol_stroom_motor_in = abs(d494);
skp_pol_stroom_motor_uit = abs(d495);
run;


/*matm hou enkel de refs van INgaande coils over*/

data matm0 (keep = sjr_cl cl_n bew_vn dch_n dch_n_vr di br le K_ATP K_nm_atp ts_be_skp ts_ei_skp ln_pr_vl);
format ts_be_skp ts_ei_skp datetime19.;
set qc.matm (where=(ln_pr = 'SKP1' and ts_be GT &ts_last AND (dl_n_lei = dl_n_leu) /*and K_tstmat="2BA"*/ ));
/*set qc.matm (where=(ln_pr = 'SKP1' and datepart(ts_be) = '03JUN2015'd  AND (dl_n_lei = dl_n_leu) and K_tstmat="2BA" ));*/
ts_be_skp = ts_be;
ts_ei_skp=ts_ei;
run;


/*linken*/
/*op 20/1/2016 volledig gerund op de server: duur 2uur44min*/
proc sql;
create table skp2 as select A.*, B.*
from matm0 A, skp1 B
where B.ts_registratie between A.ts_be_skp and A.ts_ei_skp;
 quit;


/*sorteren*/

proc sort data=skp2;
by sjr_cl cl_n dch_n ts_be_skp skp_pasnr ts_registratie;
run;


/*druk/tractie per mmbr en mm2 berekenen
  aantal seconden polijsten
  aantal inspecties per pas
  pxx + sd per mode en per pas */ 

data skp3;
set skp2;
by cl_n dch_n ts_be_skp skp_pasnr ts_registratie;
retain start reinsp reinsp_N reinsp_sec pol pol_middencoil;
if first.cl_n or first.dch_n or first.ts_be_skp or first.skp_pasnr then do; start=0; reinsp=0; reinsp_N=0; reinsp_sec=0; pol=0; pol_middencoil=0; end;
else do; 
  if skp_mode_pol = 1 and skp_bandsnelheid GE 100 then pol = pol+5;
  if skp_mode_pol = 1 and skp_bandsnelheid GE 100 and skp_LE_H1 GE 150 and skp_LE_H1 LE (le/1000-150) then pol_middencoil = pol_middencoil + 5;
  if start=1 and skp_mode_insp=1 and reinsp_N=4 then do; reinsp=reinsp+1; reinsp_sec=reinsp_sec +5; end;
  else if start=1 and skp_mode_insp=1 then reinsp_sec = reinsp_sec +5;
  if skp_mode_insp=1 then reinsp_N = reinsp_N + 1; else reinsp_N=0;
  if skp_bandsnelheid GE 200 and skp_mode_wls = 1 and skp_wls_druk_totaal GE 150 then start=1;
  end;
/*specifiek*/
skp_wls_trac_H1_mm2 =   skp_wls_tractie_H1/(di*br);
skp_wls_trac_H2_mm2 =   skp_wls_tractie_H2/(di*br);
skp_wls_druk_tot_mm2=   skp_wls_druk_totaal/(di*br);
skp_wls_druk_tot_mmbr = skp_wls_druk_totaal/br;
run;



/*percentielgroepen WALSEN berekenen*/

proc summary data=skp3 (keep = sjr_cl cl_n bew_vn dch_n ts_be_skp di br k_atp k_nm_atp
							   skp_pasnr skp_mode_wls skp_bandsnelheid
							   skp_wls: skp_pw:
							where=(skp_mode_wls=1 and skp_wls_druk_totaal GE 150 and skp_bandsnelheid GE 200)) noprint;
by sjr_cl cl_n dch_n bew_vn di br k_atp k_nm_atp ts_be_skp skp_pasnr;
var skp_bandsnelheid skp_wls: skp_pw: ;
output out=skp3_wls  (drop = skp_mode_wls ) mean= std = p1= P5= p10= median= P90= P95= P99=  /autoname;
run;


/*percentielgroepen POLIJSTEN berekenen*/
/*als er niet gepolijst wordt zitten die coils niet in deze tabel*/

proc summary data=skp3 (keep = sjr_cl cl_n bew_vn dch_n ts_be_skp di br k_atp k_nm_atp 
							   skp_pasnr skp_mode_pol skp_bandsnelheid 
							   pol pol_middencoil
							   skp_pol:
							where=(skp_mode_pol=1 and skp_bandsnelheid GE 200)) noprint;
by sjr_cl cl_n dch_n bew_vn di br k_atp k_nm_atp ts_be_skp skp_pasnr;
var pol pol_middencoil skp_pol: ;
output out=skp3_pol (drop=skp_mode_pol skp_bandsnelheid ) mean= std = p1= P5= p10= median= P90= P95= P99=  /autoname;
run;

/*tabellen samenzetten*/
/*missings bij pol op 0 zetten*/

proc sql;
create table skp4 as select A.*, B.* from skp3_wls A LEFT JOIN skp3_pol B
on A.sjr_cl = B.sjr_cl
and A.cl_n = B.cl_n
and A.dch_n = B.dch_n
and A.bew_vn = B.bew_vn
and A.skp_pasnr = B.skp_pasnr;
quit;
data skp41;
set skp4;
array pol pol_: ;
do over pol;
  if pol=. then pol=0;
end;

datum_skp=datepart(ts_be_skp);
run;
proc sort data=skp41;
by ts_be_skp;
run;


/*helling blauwwaardes berekenen*/
/*bereken helling van de blauwwaardes in elk punt*/
/*1. in elk punt*/
/*2. op basis van 5 punten y=ax+b --> a=[(x1-xg)(y1-yg)+...] / [(x1-xg)2+...]
     x_i = lengte op tijdstip i
     x_g = gemiddelde lengte
     y_i = blauwwaarde op tijd i
     y_g = gemiddelde blauwwaarde*/
/*3. op basis van 10 punten*/
/*we houden alleen de punten over waarin we de helling moeten berekenen
  we mogen de helling enkel berekenen voor punten op dezelfde helling*/
data skp3_helling_1;
set SKP2  (keep = cl_n dch_n ts_be_skp skp_pasnr ts_registratie skp_mode_wls skp_wls_druk_totaal_ton skp_bandsnelheid skp_pw_blauwwaarde
		   where=(skp_mode_wls=1 and skp_wls_druk_totaal_ton GE 150 and skp_bandsnelheid GE 200));
by cl_n dch_n ts_be_skp skp_pasnr ts_registratie;
retain delta_x deel xcount;   
skp_pw_blauw1000 = 1000*skp_pw_blauwwaarde; 
if (first.cl_n or first.dch_n or first.ts_be_skp or first.skp_pasnr)then do;
   blauwwaarde_helling = .; /*initialiseer blauwwaarde*/
   delta_x = 0; /*reset delta x*/
   deel = 1;
   xcount=0;
   end;
xcount=xcount+1;
delta_x = delta_x + skp_bandsnelheid / 60 * 5;
if ts_registratie - lag(ts_registratie) GE 12 then do; deel=deel+1; xcount=0; end;
else do;
    /* we berekenen alle lags: opgelet in het begin zijn die van de vorige coil!!!!!!*/
    x0=delta_x;
    x1=lag(delta_x);
	x2=lag2(delta_x); x3=lag3(delta_x); x4=lag4(delta_x); xg=mean(of x0-x4);
	x5=lag5(delta_x); x6=lag6(delta_x); x7=lag7(delta_x); x8=lag8(delta_x); x9=lag9(delta_x);xg10=mean(of x0-x9);
 	y0=skp_pw_blauw1000;
	y1=lag(skp_pw_blauw1000);
	y2=lag2(skp_pw_blauw1000); y3=lag3(skp_pw_blauw1000); y4=lag4(skp_pw_blauw1000); yg=mean(of y0-y4);
	y5=lag5(skp_pw_blauw1000); y6=lag6(skp_pw_blauw1000); y7=lag7(skp_pw_blauw1000); y8=lag8(skp_pw_blauw1000); y9=lag9(skp_pw_blauw1000); yg10=mean(of y0-y9);
 	blauwwaarde_helling = (y0-y1)/(x0-x1);
	if xcount GE 5 then do;
		teller = (x0-xg)*(y0-yg)+(x1-xg)*(y1-yg)+(x2-xg)*(y2-yg)+(x3-xg)*(y3-yg)+(x4-xg)*(y4-yg);
		noemer = (x0-xg)**2+(x1-xg)**2+(x2-xg)**2+(x3-xg)**2+(x4-xg)**2;
    	blauwwaarde_helling5 = teller/noemer;
		end;
	/*hier zorgen we ervoor - met xcount - dat we geen lags van de vorige coil meenemen*/
	if xcount GE 10 then do;
		teller = (x0-xg10)*(y0-yg10)+(x1-xg10)*(y1-yg10)+(x2-xg10)*(y2-yg10)+(x3-xg10)*(y3-yg10)+(x4-xg10)*(y4-yg10)+(x5-xg10)*(y5-yg10)
				+(x6-xg10)*(y6-yg10)+(x7-xg10)*(y7-yg10)+(x8-xg10)*(y8-yg10)+(x9-xg10)*(y9-yg10);
		noemer = (x0-xg10)**2+(x1-xg10)**2+(x2-xg10)**2+(x3-xg10)**2+(x4-xg10)**2+(x5-xg10)**2+(x6-xg10)**2+(x7-xg10)**2+(x8-xg10)**2+(x9-xg10)**2;
    	blauwwaarde_helling10 = teller/noemer;
		end;

    end;
run;
proc sql; 
create table skp3_helling_2 as select cl_n, ts_be_skp, skp_pasnr, deel, min(ts_registratie) as tmin format=datetime17., max(ts_registratie) as tmax format=datetime17.,
		                              avg(blauwwaarde_helling) as blauwwaarde_helling, avg(blauwwaarde_helling5) as blauwwaarde_helling5, avg(blauwwaarde_helling10) as blauwwaarde_helling10
from skp3_helling_1
group by  cl_n, ts_be_skp, skp_pasnr, deel;
quit;
proc sql; 
create table skp3_helling_3 as select cl_n, ts_be_skp, skp_pasnr, max(deel) as skp_aantaldelen,
		                              avg(blauwwaarde_helling) * 1000 as skp_pw_blauwwaarde_helling,
									  avg(blauwwaarde_helling5) * 1000 as skp_pw_blauwwaarde_helling5,
									  avg(blauwwaarde_helling10) * 1000 as skp_pw_blauwwaarde_helling10
from skp3_helling_1
group by  cl_n, ts_be_skp, skp_pasnr;
quit;

/*idem maar nu voor polijsten*/
data skp3_pol_helling_1;
set SKP2  (keep = cl_n dch_n ts_be_skp skp_pasnr ts_registratie skp_mode_pol skp_bandsnelheid skp_pw_blauwwaarde
		   where=(skp_mode_pol=1 and skp_bandsnelheid GE 200));
by cl_n dch_n ts_be_skp skp_pasnr ts_registratie;
retain delta_x deel xcount;     
skp_pw_blauw1000 = 1000*skp_pw_blauwwaarde; 
if (first.cl_n or first.dch_n or first.ts_be_skp or first.skp_pasnr )then do;
   blauwwaarde_helling = .; /*initialiseer blauwwaarde*/
   delta_x = 0; /*reset delta x*/
   deel = 1;
   xcount=0;
   end;
xcount=xcount+1;
delta_x = delta_x + skp_bandsnelheid / 60 * 5;
if ts_registratie - lag(ts_registratie) GE 12 then do; deel=deel+1; xcount=0; end;
else do;
	/* weberekenen alle lags: opgelet in het begin zijn die van de vorige coil!!!!!!*/
    x0=delta_x;
    x1=lag(delta_x);
	x2=lag2(delta_x); x3=lag3(delta_x); x4=lag4(delta_x); xg=mean(of x0-x4);
	x5=lag5(delta_x); x6=lag6(delta_x); x7=lag7(delta_x); x8=lag8(delta_x); x9=lag9(delta_x);xg10=mean(of x0-x9);
 	y0=skp_pw_blauw1000;
	y1=lag(skp_pw_blauw1000);
	y2=lag2(skp_pw_blauw1000); y3=lag3(skp_pw_blauw1000); y4=lag4(skp_pw_blauw1000); yg=mean(of y0-y4);
 	y5=lag5(skp_pw_blauw1000); y6=lag6(skp_pw_blauw1000); y7=lag7(skp_pw_blauw1000); y8=lag8(skp_pw_blauw1000); y9=lag9(skp_pw_blauw1000); yg10=mean(of y0-y9);
	blauwwaarde_helling = (y0-y1)/(x0-x1);
	/*hier zorgen we ervoor - met xcount - dat we geen lags van de vorige coil meenemen*/
	if xcount GE 5 then do;
		teller = (x0-xg)*(y0-yg)+(x1-xg)*(y1-yg)+(x2-xg)*(y2-yg)+(x3-xg)*(y3-yg)+(x4-xg)*(y4-yg);
		noemer = (x0-xg)**2+(x1-xg)**2+(x2-xg)**2+(x3-xg)**2+(x4-xg)**2;
    	blauwwaarde_helling5 = teller/noemer;
		end;
	if xcount GE 10 then do;
		teller = (x0-xg10)*(y0-yg10)+(x1-xg10)*(y1-yg10)+(x2-xg10)*(y2-yg10)+(x3-xg10)*(y3-yg10)+(x4-xg10)*(y4-yg10)+(x5-xg10)*(y5-yg10)
				+(x6-xg10)*(y6-yg10)+(x7-xg10)*(y7-yg10)+(x8-xg10)*(y8-yg10)+(x9-xg10)*(y9-yg10);
		noemer = (x0-xg10)**2+(x1-xg10)**2+(x2-xg10)**2+(x3-xg10)**2+(x4-xg10)**2+(x5-xg10)**2+(x6-xg10)**2+(x7-xg10)**2+(x8-xg10)**2+(x9-xg10)**2;
    	blauwwaarde_helling10 = teller/noemer;
		end;
    end;
run;
proc sql; 
create table skp3_pol_helling_2 as select cl_n, ts_be_skp, skp_pasnr, deel, min(ts_registratie) as tmin format=datetime17., max(ts_registratie) as tmax format=datetime17.,
		                              avg(blauwwaarde_helling) as blauwwaarde_helling, avg(blauwwaarde_helling5) as blauwwaarde_helling5, avg(blauwwaarde_helling10) as blauwwaarde_helling10
from skp3_pol_helling_1
group by  cl_n, ts_be_skp, skp_pasnr, deel;
quit;
proc sql; 
create table skp3_pol_helling_3 as select cl_n, ts_be_skp, skp_pasnr, max(deel) as skp_aantalpol,
		                              avg(blauwwaarde_helling) * 1000 as skp_pol_blauwwaarde_helling,
									  avg(blauwwaarde_helling5) * 1000 as skp_pol_blauwwaarde_helling5,
									  avg(blauwwaarde_helling10) * 1000 as skp_pol_blauwwaarde_helling10
from skp3_pol_helling_1
group by  cl_n, ts_be_skp, skp_pasnr;
quit;


proc sql; create table skp_helling as select A.*, B.* from skp3_helling_3 A  LEFT JOIN skp3_pol_helling_3 B ON A.cl_n = B.cl_n and A.ts_be_skp = B.ts_be_skp and a.skp_pasnr = B.skp_pasnr; quit;

proc sql; create table skp5 as select A.*, B.* from skp41 A LEFT JOIN skp_helling B ON A.cl_n = B.cl_n and A.ts_be_skp = B.ts_be_skp and A.skp_pasnr= B.skp_pasnr; quit;
proc sort; by ts_be_skp; run;



/*ALLES VERNIEUWEN STAP 2: data pscad.skp1_pv_summary; set skp5; run; */
/*data pscad.skp1_pv_per_pas_summary; set skp5; run;*/
/*ALLES VERNIEUWEN STAP 3: HIERNA STOPPEN EN LAATSTE PROC APPEND NIET UITVOEREN */




/*append data
  force zorgt ervoor dat je een warning krijgt als er nieuwe kolommen zijn:
WARNING: Variable ts_be_skp has format 'DATETIME16.'n on the BASE data set and format 'DATETIME19.'n on the DATA data set. 'DATETIME16.'n used.
WARNING: Variable pol_middencoil_Mean was not found on BASE file. The variable will not be added to the BASE file.
WARNING: Variable pol_middencoil_StdDev was not found on BASE file. The variable will not be added to the BASE file.
WARNING: Variable pol_middencoil_P1 was not found on BASE file. The variable will not be added to the BASE file.
WARNING: Variable pol_middencoil_P5 was not found on BASE file. The variable will not be added to the BASE file.
WARNING: Variable pol_middencoil_P10 was not found on BASE file. The variable will not be added to the BASE file.
WARNING: Variable pol_middencoil_P90 was not found on BASE file. The variable will not be added to the BASE file.
WARNING: Variable pol_middencoil_P95 was not found on BASE file. The variable will not be added to the BASE file.
WARNING: Variable pol_middencoil_P99 was not found on BASE file. The variable will not be added to the BASE file.

*/

proc append base=pscad.Skp1_pv_per_pas_summary data= skp5 force;
run;
proc sort; by ts_be_skp  skp_pasnr; run;

/*

proc sort data=scad.Skp1_pv_summary; by ts_be_skp; run;

*/
/* om nieuwe kokommen toe te voegen --> sql statement doen

proc sql; create table scad.Skp1_pv_summary2 as select A.*, B.* from scad.skp1_pv_summary A LEFT JOIN  SKP5  B
on A.sjr_cl = B.sjr_cl
and A.cl_n = B.cl_n
and A.dch_n = B.dch_n
and A.bew_vn = B.bew_vn
and A.ts_be_skp = B.ts_be_skp;
quit;

*/
