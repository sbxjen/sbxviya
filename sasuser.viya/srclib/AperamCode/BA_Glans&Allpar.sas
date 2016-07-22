/*28-09-2015	peter	nieuw stuk code ingebouwd ivm skp_data */
/*20-06-2016    peter   teller tijdelijk toegevoegd: run dit prg; run daarna BA_5sec_skp_gaas_vervangen.sas en link dan*/
                         


%include 'R:\progs\connect.sas';
rsubmit;
%let aantaljaarterug = 4;
%let lbn = %str(QC);
endrsubmit;

*inspectiegegegevens downloaden;
RSUBMIT;
PROC SQL;
  CREATE TABLE data1 AS
  SELECT A.SJR_CL, A.CL_N,A.LN_PR,A.DCH_N,A.BEW_VN,A.K_BEW,
         YEAR(A.date_ts_be) AS jaar, MONTH(A.date_ts_be) As Maand, YEAR(A.date_ts_be) * 100 + MONTH(A.date_ts_be) as jaar_maand_bal,
         A.date_ts_be format=date9., A.ts_be,
         A.k_tstmat AS Toest, A.K_Afw As Afw, A.tt_dl_n,
         A.K_NM_ATP, A.K_ATP, A.K_NM_ATP || '.' || A.K_ATP AS Atype6,
         A.di, ROUND(A.di,0.1) AS dikte, A.br, ROUND(A.br,250) AS breedte, A.le, A.g,
         B.WRK_INSP, B.K_klasma as k_klasma_insp, B.reden_sh as reden_sh_insp, B.OM_QC_1 || " " || B.OM_QC_2 AS BAL_opmerking_QC,
         B.GLNS_TOP, B.GLNS_BOT,
		 B.KLRA_TB , B.KLRA_BB , B.KLRB_TB , B.KLRB_BB ,
         B.KLRA_TM , B.KLRA_BM , B.KLRB_TM , B.KLRB_BM ,
         B.GLNS_TB1, B.GLNS_TB2, B.GLNS_TB3,
         B.GLNS_TM1, B.GLNS_TM2, B.GLNS_TM3,
         B.GLNS_TE1, B.GLNS_TE2, B.GLNS_TE3,
         B.GLNS_BB1, B.GLNS_BB2, B.GLNS_BB3,
         B.GLNS_BM1, B.GLNS_BM2, B.GLNS_BM3,
         B.GLNS_BE1, B.GLNS_BE2, B.GLNS_BE3,
         /*vlakheden zijn tekstwaardes ...*/
         B.VLK_BEQC, B.VLK_MIQC, B.VLK_EIQC,
         B.VLK_BEMI, B.VLK_MIMI, B.VLK_EIMI,
         B.VLK_BENQ, B.VLK_MINQ, B.VLK_EINQ
  FROM &lbn..matm  (keep = sjr_cl cl_n dch_n a_dch hoog_dch bew_vn K_bew date_ts_be ts_be k_tstmat k_afw tt_dl_n K_nm_atp K_ATP di br le g ln_pr 
                    where=(ln_pr='BAL1' and intnx('year',today(),-&aantaljaarterug,'begin') and K_BEW NE '0910'
                    and K_ATP in ('0370','3041','3045','3161','4300','4360','4390','4410'))) A,
       &lbn..kwalm (where=(ln_pr = 'BAL1')) B
  WHERE A.CL_N = B.Cl_n
    AND a.sjr_cl = B.sjr_cl
    AND A.bew_vn = B.bew_vn
    AND A.dch_n = B.dch_n
    AND (A.a_dch = 0 or (A.dch_n = A.hoog_dch - A.a_dch));
  QUIT;

/*utilsatiecode + positie_plak meenemen;*/
proc sql;
create table data1 as select distinct A.*, B.* from data1 A LEFT JOIN &lbn..alggeg 
		(keep =  sjr_cl cl_n KD_positie_plak_1 
		 where=(KD_positie_plak_1 NE '')) B
ON A.cl_n = B.cl_n and A.sjr_cl = B.sjr_cl;
quit;
ENDRSUBMIT;

/*kanten ontdubbelen*/
rsubmit;
data data1a (drop = glns_top klr: glns:);
set data1;
kant = 'T';
glans= glns_top;
kleur_a = klra_tm; kleur_b = klrb_tm; 
kleur_a_begin = klra_tb; kleur_b_begin = klrb_tb;
glansB1 = glns_TB1; glansB2 = glns_TB2; glansB3 = glns_TB3;
glansM1 = glns_TM1; glansM2 = glns_TM2; glansM3 = glns_TM3;
glansE1 = glns_TE1; glansE2 = glns_TE2; glansE3 = glns_TE3;
/*0 wordt missing*/
output;
kant = 'B';
glans= glns_bot;
kleur_a = klra_bm; kleur_b = klrb_bm; 
kleur_a_begin = klra_bb; kleur_b_begin = klrb_bb;
glansB1 = glns_BB1; glansB2 = glns_BB2; glansB3 = glns_BB3;
glansM1 = glns_BM1; glansM2 = glns_BM2; glansM3 = glns_BM3;
glansE1 = glns_BE1; glansE2 = glns_BE2; glansE3 = glns_BE3;
output;
run;
endrsubmit;

/*verander alle nullen naar missing values en bereken glans01*/
rsubmit;
data data1b;
set data1a;
array nums _numeric_;
do over nums;
  if nums=0 then nums=.;
end;
/*correctie voor dochternummer en kleur (0 is hier wel een juiste waarde ...)*/
if dch_n = . then dch_n = 0;
/*ook correctie voor vlakheid*/
if vlk_QCsom = . then vlk_QCsom = 0;
if vlk_MIsom = . then vlk_MIsom = 0;
if vlk_NQsom = . then vlk_NQsom = 0;
if kleur_a = . and kleur_b GE 2 then kleur_a = 0;
/*berekening van binaire glans voor ev logistic regressie*/
glans01 = .; glansM201 = .;
if K_ATP in ('3041','3045','3161') then do;
    if glans GE 450 then glans01 = 1; else if glans LE 300 then glans01 = 0;
    if glansM2 GE 450 then glansM201 = 1; else if glansM2 LE 300 then glansM201 = 0;
    end;
else if K_ATP in ('4410','4300') then do;
    if glans GE 300 then glans01 = 1; else if glans LE 200 then glans01 = 0;
    if glansM2 GE 300 then glansM201 = 1; else if glansM2 LE 200 then glansM201 = 0;
    end;

/*bereken helling van de glanswaardes*/
/*y=ax+b --> a=[(x1-xg)(y1-yg)+...] / [(x1-xg)2+...]*/
glans_helling_Crm3=.;
if (100 LE glansB2 LE 999) and (100 LE glansM2 LE 999) and (100 LE glansE2 LE 999) then do;
  yg=(glansB2 + glansM2 + glansE2)/3;  
  xg=le/2000;
  glans_helling_Crm3 = ( (-xg)*(glansE2-yg) + (xg)*(glansB2-yg) ) / (2*xg*xg);
  end;

glans_QC_helling_Crm3=.;
if (100 LE glansB1 LE 999) and (100 LE glansM1 LE 999) and (100 LE glansE1 LE 999) then do;
  yg=(glansB1 + glansM1 + glansE1)/3;  
  xg=le/2000;
  glans_QC_helling_Crm3 = ( (-xg)*(glansE1-yg) + (xg)*(glansB1-yg) ) / (2*xg*xg);
  end;

glans_NQC_helling_Crm3=.;
if (100 LE glansB3 LE 999) and (100 LE glansM3 LE 999) and (100 LE glansE3 LE 999) then do;
  yg=(glansB3 + glansM3 + glansE3)/3;  
  xg=le/2000;
  glans_NQC_helling_Crm3 = ( (-xg)*(glansE3-yg) + (xg)*(glansB3-yg) ) / (2*xg*xg);
  end;

glans_avg_helling_Crm3=.;
if      (100 LE glansB1 LE 999) and (100 LE glansM1 LE 999) and (100 LE glansE1 LE 999) 
	and (100 LE glansB2 LE 999) and (100 LE glansM2 LE 999) and (100 LE glansE2 LE 999)
	and (100 LE glansB3 LE 999) and (100 LE glansM3 LE 999) and (100 LE glansE3 LE 999) then do;
  yg=(glansB1+glansB2+glansB3 + glansM1+glansM2+glansM3 + glansE1+glansE2+glansE3)/9;  
  xg=le/2000;
  glans_avg_helling_Crm3 = ( (-xg)*(mean(of glansE1 - glansE3) - yg) + (xg)*(mean(of glansB1 - glansB3) -yg) ) / (2*xg*xg);
  end;

run;
endrsubmit;

/*
PROC EXPORT DATA= remWORK.data1b
            OUTFILE= "L:\data\glansBAL.jmp"
            DBMS=JMP REPLACE;
RUN;
*/

*linken met gegevens bal uit bal1scad;
RSUBMIT;
PROC SQL;
  CREATE TABLE data2 AS
  SELECT A.*, b.vis_k_waarde_ist_av as k_waarde,
             b.vis_k_waarde_ist_sd as k_waarde_sd,
			 b.vis_k_waarde_ist_mn as k_waarde_mn,
			 b.vis_k_waarde_ist_mx as k_waarde_mx,
			 b.VIS_BANDSNELHEID_AV as snelheid,
			 b.VIS_BANDSNELHEID_SD as snelheid_sd,
			 b.VIS_BANDSNELHEID_MN as snelheid_mn,
			 b.VIS_BANDSNELHEID_MX as snelheid_mx,
			 b.d484_av as snelheid_bias,
			 b.d484_sd as snelheid_bias_sd,
			 b.d484_mn as snelheid_bias_mn,
			 b.d484_mx as snelheid_bias_mx,
             b.vis_band_dikte_huidig as dikte,
             b.band_breedte_huidig as breedte,
             b.lwt_o_remanenz_value_av as remanenz,
             b.lwt_o_remanenz_value_sd as remanenz_sd,
             b.lwt_o_remanenz_value_mx as remanenz_mx,
             b.lwt_o_remanenz_value_mn as remanenz_mn,
             b.vis_tractie_oven_ist_av/(b.vis_band_dikte_huidig * b.band_breedte_huidig) as tractie_m2,
             b.vis_tractie_oven_ist_av,
             b.VIS_T_REG_1A_IST_AV as T1,
             b.VIS_T_REG_2A_IST_AV as T2,
             b.VIS_T_REG_3A_IST_AV as T3,
             b.VIS_T_REG_4A_IST_AV as T4,
             b.VIS_T_REG_5A_IST_AV as T5,
             b.VIS_T_REG_6A_IST_AV as T6,
             b.VIS_T_1A_SOLL_AV as Ts1,
             b.VIS_T_2A_SOLL_AV as Ts2,
             b.VIS_T_3A_SOLL_AV as Ts3,
             b.VIS_T_4A_SOLL_AV as Ts4,
             b.VIS_T_5A_SOLL_AV as Ts5,
             b.VIS_T_6A_SOLL_AV as Ts6,
			 b.VIS_T_BAND_IST_AV as Tstatkoel,
			 b.VIS_011_CIT801_IST_AV as gldbh_T1,
			 b.VIS_012_CIT801_IST_AV as gldbh_T2,
			 b.VIS_026_CIT801_IST_AV as gldbh_eindsp,
             b.vis_druk_oven_ist_av as poven,
             b.dauwpunt_oven_ing_ist_av as dwp_oven,
             b.dwpunt_na_bandkl1_ist_av as dwp_bandkoel1,
             b.dwpunt_omkeerhuis_ist_av as dwp_omkeerhuis,
             b.vis_dwp_stat_koel_ist_av as dwp_statkoel,
             case when A.kant = 'T' then b.vis_t_jetcool_1a_ist_av
                  when A.kant = 'B' then b.vis_t_jetcool_1b_ist_av end as jet_T1,
             case when A.kant = 'T' then b.vis_t_jetcool_2a_ist_av
                  when A.kant = 'B' then b.vis_t_jetcool_2b_ist_av end as jet_T2,
             case when A.kant = 'T' then b.vis_t_jetcool_3a_ist_av
                  when A.kant = 'B' then b.vis_t_jetcool_3b_ist_av end as jet_T3,
             case when A.kant = 'T' then b.vis_t_jetcool_4a_ist_av
                  when A.kant = 'B' then b.vis_t_jetcool_4b_ist_av end as jet_T4,
             case when A.kant = 'T' then b.vis_jet1_top_v_ist_av
                  when A.kant = 'B' then b.vis_jet1_bot_v_ist_av end as jet_v1,
             case when A.kant = 'T' then b.vis_jet2_top_v_ist_av
                  when A.kant = 'B' then b.vis_jet2_bot_v_ist_av end as jet_v2,
             case when A.kant = 'T' then b.snelh_bkoel_vnt_3_top_av
                  when A.kant = 'B' then b.snelh_bkoel_vnt_3_top_av end as jet_v3,
             case when A.kant = 'T' then b.snelh_bkoel_vnt_4_top_av
                  when A.kant = 'B' then b.snelh_bkoel_vnt_4_top_av end as jet_v4,

			 b.vis_tractie_pass_ist_av  as tractie_pass,
			 b.trctie_slwgn_uitg_ist_av as tractie_slwgn_uit,
			 b.vis_tractie_oph_ist_av   as tractie_oph,
			 b.vis_i_srol4_rol1_ist_av   as i_srol41,
			 b.vis_i_srol4_rol2_ist_av   as i_srol42,
			 b.vis_i_srol5_rol1_ist_av   as i_srol51,
			 b.vis_i_srol6_rol1_ist_av   as i_srol61,
			 b.vis_i_srol6_rol2_ist_av   as i_srol62,
			 b.vis_i_srol7_rol1_ist_av   as i_srol71,
			 b.vis_i_srol7_rol2_ist_av   as i_srol72,
			 b.vis_i_srol8_rol1_ist_av   as i_srol81,
			 b.vis_i_srol8_rol2_ist_av   as i_srol82,

			 b.vis_ah2stat_av as H2stat,
             b.vis_ah2top_av as H2top,
             b.vis_ah2entr_av as H2entry,
             b.vis_ah2exit_av as H2exit,
             b.vis_h2_debiet_av as H2,
             b.vis_h2_debiet_sd as H2std,
             b.vis_v1_speed_av as v_droger,
             b.vis_temp_dansrol_av as Tdansrol,
             b.vis_O2_droger__ist_av as O2droger,
			 b.VIS_I_PAPIER_OPW1_IST_AV,
			 b.VIS_I_PAPIER_OPW1_IST_SD,
			 b.VIS_I_PAPIER_OPW2_IST_AV,
			 b.VIS_I_PAPIER_OPW2_IST_SD,
             (b.vis_oven_verbruik_H2_mx - b.vis_oven_verbruik_H2_mn) / (A.le * A.br/1000000) as oven_H2verbruik_m2
  FROM data1b A, &lbn..bal1scad 
	(keep =  date_ts_be Cl_n sys_jaar_coil bew_vn dochter_nr
			 vis_k_waarde_ist: VIS_BANDSNELHEID: d484: 
             vis_band_dikte_huidig
             band_breedte_huidig 
             lwt_o_remanenz_value_av lwt_o_remanenz_value_sd lwt_o_remanenz_value_mx lwt_o_remanenz_value_mn 
             vis_tractie_oven_ist_av
             vis_tractie_oven_ist_av
             VIS_T_REG_1A_IST_AV
             VIS_T_REG_2A_IST_AV
             VIS_T_REG_3A_IST_AV 
             VIS_T_REG_4A_IST_AV 
             VIS_T_REG_5A_IST_AV 
             VIS_T_REG_6A_IST_AV
             VIS_T_1A_SOLL_AV 
             VIS_T_2A_SOLL_AV 
             VIS_T_3A_SOLL_AV 
             VIS_T_4A_SOLL_AV 
             VIS_T_5A_SOLL_AV 
             VIS_T_6A_SOLL_AV 
			 VIS_T_BAND_IST_AV 
			 VIS_011_CIT801_IST_AV
			 VIS_012_CIT801_IST_AV
			 VIS_026_CIT801_IST_AV
             vis_druk_oven_ist_av 
             dauwpunt_oven_ing_ist_av
             dwpunt_na_bandkl1_ist_av
             dwpunt_omkeerhuis_ist_av
             vis_dwp_stat_koel_ist_av
             vis_t_jetcool_1a_ist_av
             vis_t_jetcool_1b_ist_av  
             vis_t_jetcool_2a_ist_av
             vis_t_jetcool_2b_ist_av 
             vis_t_jetcool_3a_ist_av
             vis_t_jetcool_3b_ist_av  
             vis_t_jetcool_4a_ist_av
             vis_t_jetcool_4b_ist_av  
             vis_jet1_top_v_ist_av
             vis_jet1_bot_v_ist_av  
             vis_jet2_top_v_ist_av
             vis_jet2_bot_v_ist_av  
             snelh_bkoel_vnt_3_top_av  
             snelh_bkoel_vnt_4_top_av

			 vis_tractie_pass_ist_av
			 trctie_slwgn_uitg_ist_av
			 vis_tractie_oph_ist_av
			 vis_i_srol4_rol1_ist_av
			 vis_i_srol4_rol2_ist_av
			 vis_i_srol5_rol1_ist_av
			 vis_i_srol6_rol1_ist_av
			 vis_i_srol6_rol2_ist_av
			 vis_i_srol7_rol1_ist_av
			 vis_i_srol7_rol2_ist_av
			 vis_i_srol8_rol1_ist_av
			 vis_i_srol8_rol2_ist_av

             vis_ah2stat_av 
             vis_ah2top_av 
             vis_ah2entr_av 
             vis_ah2exit_av 
             vis_h2_debiet_av        vis_h2_debiet_sd
             vis_v1_speed_av 
             vis_temp_dansrol_av 
             vis_O2_droger__ist_av 
			 VIS_I_PAPIER_OPW1_IST_AV VIS_I_PAPIER_OPW1_IST_SD VIS_I_PAPIER_OPW2_IST_AV VIS_I_PAPIER_OPW2_IST_SD
             vis_oven_verbruik_H2_mx vis_oven_verbruik_H2_mn
     where = (date_ts_Be GE intnx('year',today(),-&aantaljaarterug,'begin') )) B
  WHERE A.CL_N = B.Cl_n
    AND A.sjr_cl = put(B.sys_jaar_coil,4.0)
    AND A.bew_vn= B.bew_vn
    AND A.dch_n = B.dochter_nr;
  QUIT;
ENDRSUBMIT;

/*linken met aantal passen CRM3 en cw lp en nicolas en tom*/
/*OPGELET TABELLEN VAN NICOLAS EN TOM BEVATTEN MOEDER EN DOCHTER INDIEN OPGEDEELD AAN CRM3*/
rsubmit;
proc sql;
create table data3 as select A.*,B.*
from data2 A, &lbn..crm3 (where=(date_ts_be GE intnx('year',today(),-4,'begin'))) B
WHERE  A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n = B.dch_n
AND (A.bew_vn-1 = B.bew_vn
        or (A.dikte = round(B.di_m,0.1) and A.bew_vn-2 = B.bew_vn)
     );
quit;
endrsubmit;

/*linken met data nicolas*/
rsubmit;
proc sql;
create table data3a as select distinct A.*,B.BR_BE_bew, B.br_ei_bew, B.ts_be as TS_BE_CRM,
                                       year(datepart(B.ts_be)) * 100 + MONTH(datepart(B.ts_be)) As jaar_maand_crm
from data3 A LEFT JOIN 
     kw.crm3_data_coil (keep = ts_be_GLB br_be_bew br_ei_bew ts_be
                        where= (ts_be GE intnx('dtyear',today(),-&aantaljaarterug,'begin')) ) B
ON  A.ts_be = B.ts_be_GLB;
quit;
endrsubmit;

/*linken met crm_scad Tom*/
rsubmit;
proc sql;
create table data3b as select distinct A.*,
B.debiet_bk_kooi_P90,
B.debiet_bk_links_P90,
B.debiet_bk_rechts_P90,
B.snelhP_P90, B.snelhP_mean, B.snelhP_max, B.snelhP_stddev,
B.snelhV_P90, B.snelhV_mean, B.snelhV_max, B.snelhV_stddev,
B.T_links_P90,
B.T_rechts_P90,

B.T_olie_bk_P90, B.T_olie_bk_mean,
B.dia_H1_Min, /*voor koker vlpas*/
B.dia_H2_Min,/*voor koker lpas*/
B.pw_breedte,
B.pw4_tr_mean,
B.pw5_tr_mean,

B.debiet_bk_kooi_vlp_P90,
B.debiet_bk_links_vlp_P90,
B.debiet_bk_rechts_vlp_P90,
B.snelhP_VLP_MEAN, B.snelhP_VLP_STDDEV, B.snelhP_VLP_MIN, B.snelhP_VLP_MAX, B.snelhP_vlp_P90,
B.snelhV_VLP_MEAN, B.snelhV_VLP_STDDEV, B.snelhV_VLP_MIN, B.snelhV_VLP_MAX, B.snelhV_vlp_P90,
B.T_links_vlp_P90,
B.T_rechts_vlp_P90,

B.debiet_bk_kooi_vvlp_P90,
B.debiet_bk_links_vvlp_P90,
B.debiet_bk_rechts_vvlp_P90,
B.snelhP_VVLP_MEAN, B.snelhP_VVLP_STDDEV, B.snelhP_VVLP_MIN, B.snelhP_VVLP_MAX, B.snelhP_Vvlp_P90,
B.snelhV_VVLP_MEAN, B.snelhV_VVLP_STDDEV, B.snelhV_VVLP_MIN, B.snelhV_VVLP_MAX, B.snelhV_Vvlp_P90,
B.T_links_vvlp_P90,
B.T_rechts_vvlp_P90

from data3a A LEFT JOIN 
	&lbn..crm3_scad 
    (keep = 
	ts_be datum
	debiet_bk:
	snelhP:
	snelhV:
	T_links:
	T_rechts:

	T_olie_bk_P90 T_olie_bk_mean
	dia_H1_Min
	dia_H2_Min
	pw_breedte
	pw4_tr_mean
	pw5_tr_mean
	where=(ts_be GE intnx('dtyear',today(),-&aantaljaarterug,'begin') ) )B
ON  A.ts_be_crm = B.ts_be;
quit;
endrsubmit;
rsubmit;
data data3C;
set data3b;
*papierwikkelaar BAL goed zetten, we zeggen grootste stroom = wikkelaar actief;
if VIS_I_PAPIER_OPW1_IST_AV GE VIS_I_PAPIER_OPW2_IST_AV then BAL_papierhaspel = 1; else bal_papierhaspel=2;
CRM3_jaar = year(datepart(ts_be_crm));
CRM3_maand = month(datepart(ts_be_crm));
/*koker = vrij juist*/
koker_lp=.;
koker_vl=.;
if 600 LE dia_H1_min LE 680 then koker_lp=0;
else if 780 LE dia_H1_min LE 830 then koker_lp=1;
if 600 LE dia_H2_min LE 680 then koker_vl=0;
else if 780 LE dia_H2_min LE 830 then koker_vl=1;

/*papierwissel laatste pas*/
if pw4_tr_mean GE 0.1 and pw5_tr_mean GE 0.1 then papier_wissel_lp = 1; else papier_wissel_lp = 0;
/*berekening van afwijking van gevraagde snelheid op basis van 2014 = benadering (moet eigenlijk nog per type)*/
     if di LE 0.62 then do; deltaV_P90 = 830 - snelhV_P90; deltaV_mean = 830 - snelhV_mean; deltaV_max = 830 - snelhV_max; end;
else if di LE 0.82 then do; deltaV_P90 = 720 - snelhV_P90; deltaV_mean = 830 - snelhV_mean; deltaV_max = 830 - snelhV_max; end;
else if di LE 1.02 then do; deltaV_P90 = 650 - snelhV_P90; deltaV_mean = 650 - snelhV_mean; deltaV_max = 650 - snelhV_max; end;
else if di LE 1.32 then do; deltaV_P90 = 540 - snelhV_P90; deltaV_mean = 540 - snelhV_mean; deltaV_max = 540 - snelhV_max; end;
else if di LE 1.72 then do; deltaV_P90 = 450 - snelhV_P90; deltaV_mean = 450 - snelhV_mean; deltaV_max = 450 - snelhV_max; end;
else if di LE 2.02 then do; deltaV_P90 = 360 - snelhV_P90; deltaV_mean = 360 - snelhV_mean; deltaV_max = 360 - snelhV_max; end;
run;
proc sql;
create table data3c2 as select A.*,
             B.ln_pr_vr as CRM3_ln_pr_vr, B.ln_pr_vl as CRM3_ln_pr_vl from data3c A LEFT JOIN 
			 &lbn..matm (keep = sjr_cl cl_n dch_n ln_pr bew_vn date_ts_be ln_pr_vr ln_pr_vl  
                      where=(ln_pr = 'CRM3' and date_ts_be GE intnx('year',today(),-&aantaljaarterug,'begin') )) B
ON A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n = B.dch_n
AND A.bew_vn-1 = B.bew_vn;
quit;

/*deellijn toevoegen voor BS2*/
/*geen controle op dch_n
  13/05/2016: GEEFT 6 DUBBELS ==> vandaar minimum genomen*/
proc sql; create table data3c2a as select distinct A.*, min(B.OM_DLLN) as OM_DLLN from data3c2 A LEFT JOIN 
          kw.prodpstm (keep = sjr_cl cl_n dch_n bew_vn ln_pr OM_DLLN f_vvl_po where=(ln_pr = 'BS2' and f_vvl_po = ' ')) B
ON A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.bew_vn-2 = B.bew_vn
group by A.sjr_cl, A.cl_n, A.bew_vn;
quit;

data data3c2b (drop= OM_DLLN);
set data3c2a;
if substr(crm3_ln_pr_vr,1,3) = 'BS2' then  crm3_ln_pr_vr = 'BS2' || strip(OM_DLLN);
run;

proc sql;
create table data3c3 as select A.*,
             B.wrk_insp as wrk_crm3 from data3c2b A LEFT JOIN &lbn..kwalm (where=(ln_pr = 'CRM3')) B
ON A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n = B.dch_n
AND A.bew_vn-1 = B.bew_vn;
quit;

endrsubmit;

/*linken met cilinders nicolas*/
rsubmit;
proc sql;
create table data3d as select distinct A.*,
    B.kant_CRM3,
    B.K100_CILINDER_NUMMER,
    B.K100_AANTAL_CILINDERS_OP_COIL, K100_GEWALSTE_KM_SINDS_SLIJP,
    B.K100_SLIJP_MACHINE_LAATSTE_K100,
    B.K100_SLIJP_STEEN_LAATSTE_K100,
    B.K100_SLIJP_PROG_LAATSTE_K100,
	B.K100_ruwheid, B.K100_ruwheid_rz,
    B.K100_totale_afname,
    B.K100_totale_afname_K100,
    B.K100_totale_afname_K220,
    B.K100_aanstaande_uitbouw_reden,
    B.K100_uitbouw_reden_voor_slijp,
    (B.K100_stop_slijp_laatste_K100 - B.K100_start_slijp_laatste_K100) as K100_slijptijd_laatste_K100,
    (B.K100_stop_slijp_laatste_K220 - B.K100_start_slijp_laatste_K220) as K100_slijptijd_laatste_K220,
    B.K100_START_SLIJP_LAATSTE_K100,
    B.K220_totale_afname,
    B.K220_totale_afname_K100,
    B.K220_totale_afname_K220,
    B.K220_aanstaande_uitbouw_reden,
    B.K220_uitbouw_reden_voor_slijp,
    (B.K220_stop_slijp_laatste_K100 - B.K220_start_slijp_laatste_K100) as K220_slijptijd_laatste_K100,
    (B.K220_stop_slijp_laatste_K220 - B.K220_start_slijp_laatste_K220) as K220_slijptijd_laatste_K220,
    B.K220_START_SLIJP_LAATSTE_K100,
    B.K220_START_SLIJP_LAATSTE_K220,
	year(datepart( B.K220_START_SLIJP_LAATSTE_K220)) * 100 + month(datepart( B.K220_START_SLIJP_LAATSTE_K220)) as jaar_maand_slijp220,
    B.K220_CILINDER_NUMMER, 
    B.K220_aantal_cilinders_op_coil,
    B.K220_laatste_grindterm_ID, B.K100_LAATSTE_GRINDTERM_ID,
    B.K220_ruwheid, B.K220_ruwheid_rz, B.K220_hardheid,
    B.K220_totale_afname_K100, B.K220_totale_afname_K220, B.K220_totale_afname,
    B.K220_fabrikant,
    B.K220_slijp_steen_laatste_K100, B.K220_slijp_steen_laatste_K220,
    B.K220_slijp_prog_laatste_K100, B.K220_slijp_prog_laatste_K220,
    B.K220_slijper_laatste_K100, B.K220_slijper_laatste_K220,
    B.K220_slijp_machine_laatste_K100, B.K220_slijp_machine_laatste_K220,
    B.K220_gewalste_km_sinds_slijp, B.K220_aantal_wissels_sinds_slijp,
    B.aro_l_cilinder_nummer, B.aro_l_cilinder_partnum, B.aro_l_fabrikant, B.aro_l_gewalste_km_sinds_slijp, B.aro_l_cilinder_diameter,
    B.aro_r_cilinder_nummer, B.aro_r_cilinder_partnum, B.aro_r_fabrikant, B.aro_r_gewalste_km_sinds_slijp, B.aro_r_cilinder_diameter,
    B.TAP_L_GEWALSTE_KM_SINDS_SLIJP, B.TAP_R_GEWALSTE_KM_SINDS_SLIJP, B.TAP_L_CILINDER_NUMMER, B.TAP_R_CILINDER_NUMMER,
    B.DDR_L_GEWALSTE_KM_SINDS_SLIJP, B.DDR_R_GEWALSTE_KM_SINDS_SLIJP, B.DDR_L_CILINDER_NUMMER, B.DDR_R_CILINDER_NUMMER,
	B.TAP_L_hardheid, B.TAP_R_hardheid,
	B.TAP_L_ruwheid, B.TAP_R_ruwheid,
	B.TAP_L_ruwheid_Rz, B.TAP_R_ruwheid_Rz,
	B.TAP_L_SLIJP_MACH_LAATSTE_SLIJP,
	B.TAP_L_SLIJP_PROG_LAATSTE_SLIJP,
	B.TAP_L_SLIJP_STEEN_LAATSTE_SLIJP,
	(B.TAP_L_STOP_TIJD_LAATSTE_SLIJP - B.TAP_L_STOP_TIJD_LAATSTE_SLIJP) AS TAP_L_SLIJPTIJD,
	B.TAP_L_TOTALE_AFNAME,
	B.TAP_R_SLIJP_MACH_LAATSTE_SLIJP,
	B.TAP_R_SLIJP_PROG_LAATSTE_SLIJP,
	B.TAP_R_SLIJP_STEEN_LAATSTE_SLIJP,
	(B.TAP_R_STOP_TIJD_LAATSTE_SLIJP - B.TAP_R_STOP_TIJD_LAATSTE_SLIJP) AS TAP_R_SLIJPTIJD,
	B.TAP_R_TOTALE_AFNAME,
    B.DDR_L_CILINDER_DIAMETER, B.DDR_R_CILINDER_DIAMETER,
    B.SLEEP_CILINDER_DIAMETER, B.SLEEP_CILINDER_PARTNUM,
	B.DDR_L_ruwheid_Rz, B.DDR_L_ruwheid, B.DDR_R_ruwheid_Rz, B.DDR_R_ruwheid,
    B.SLEEP_ruwheid_Rz, B.SLEEP_ruwheid
from data3c3 A, 
     &lbn..Crm3_allcil_coil 
    (keep =
	date_ts_be ts_be
	kant_balbul
	dch_n
	kant_CRM3
    K100_CILINDER_NUMMER
	K100_CILINDER_PARTNUM
    K100_AANTAL_CILINDERS_OP_COIL
	K100_GEWALSTE_KM_SINDS_SLIJP
    K100_SLIJP_MACHINE_LAATSTE_K100
    K100_SLIJP_STEEN_LAATSTE_K100
    K100_SLIJP_PROG_LAATSTE_K100
    K100_totale_afname
    K100_totale_afname_K100
    K100_totale_afname_K220
	K100_ruwheid
	K100_ruwheid_rz
    K100_aanstaande_uitbouw_reden
    K100_uitbouw_reden_voor_slijp
    K100_stop_slijp_laatste_K100 
	K100_start_slijp_laatste_K100
    K100_stop_slijp_laatste_K220
	K100_start_slijp_laatste_K220
    K100_START_SLIJP_LAATSTE_K100
    K220_totale_afname
    K220_totale_afname_K100
    K220_totale_afname_K220
    K220_aanstaande_uitbouw_reden
    K220_uitbouw_reden_voor_slijp
    K220_stop_slijp_laatste_K100 
	K220_start_slijp_laatste_K100
    K220_stop_slijp_laatste_K220 
	K220_start_slijp_laatste_K220
    K220_START_SLIJP_LAATSTE_K100
    K220_START_SLIJP_LAATSTE_K220
    K220_CILINDER_NUMMER
	K220_CILINDER_PARTNUM
    K220_aantal_cilinders_op_coil
    K220_laatste_grindterm_ID
	K100_LAATSTE_GRINDTERM_ID
    K220_ruwheid
	K220_ruwheid_rz
	K220_hardheid
    K220_totale_afname_K100
	K220_totale_afname_K220
	K220_totale_afname
    K220_fabrikant
    K220_slijp_steen_laatste_K100
	K220_slijp_steen_laatste_K220
    K220_slijp_prog_laatste_K100
	K220_slijp_prog_laatste_K220
    K220_slijper_laatste_K100
	K220_slijper_laatste_K220
    K220_slijp_machine_laatste_K100
	K220_slijp_machine_laatste_K220
    K220_gewalste_km_sinds_slijp	
	K220_aantal_wissels_sinds_slijp
    aro_l_cilinder_nummer
	aro_l_cilinder_partnum
	aro_l_fabrikant
	aro_l_gewalste_km_sinds_slijp
	aro_l_cilinder_diameter
    aro_r_cilinder_nummer
	aro_r_fabrikant
	aro_r_cilinder_partnum
	aro_r_gewalste_km_sinds_slijp
	aro_r_cilinder_diameter
    TAP_L_GEWALSTE_KM_SINDS_SLIJP
    TAP_R_GEWALSTE_KM_SINDS_SLIJP
	TAP_L_CILINDER_NUMMER
	TAP_R_CILINDER_NUMMER
	TAP_L_hardheid
	TAP_R_hardheid
	TAP_L_ruwheid
	TAP_R_ruwheid
	TAP_L_ruwheid_Rz
	TAP_R_ruwheid_Rz

	TAP_L_SLIJP_MACH_LAATSTE_SLIJP
	TAP_L_SLIJP_PROG_LAATSTE_SLIJP
	TAP_L_SLIJP_STEEN_LAATSTE_SLIJP
	TAP_L_START_TIJD_LAATSTE_SLIJP TAP_L_STOP_TIJD_LAATSTE_SLIJP
	TAP_L_TOTALE_AFNAME

	TAP_R_SLIJP_MACH_LAATSTE_SLIJP
	TAP_R_SLIJP_PROG_LAATSTE_SLIJP
	TAP_R_SLIJP_STEEN_LAATSTE_SLIJP
	TAP_R_START_TIJD_LAATSTE_SLIJP TAP_R_STOP_TIJD_LAATSTE_SLIJP
	TAP_R_TOTALE_AFNAME

    DDR_L_GEWALSTE_KM_SINDS_SLIJP
	DDR_R_GEWALSTE_KM_SINDS_SLIJP
	DDR_L_CILINDER_NUMMER
	DDR_R_CILINDER_NUMMER
    DDR_L_CILINDER_DIAMETER 
	DDR_R_CILINDER_DIAMETER
    DDR_L_ruwheid
	DDR_R_ruwheid
    DDR_L_ruwheid_Rz
	DDR_R_ruwheid_Rz
    SLEEP_CILINDER_DIAMETER 
	SLEEP_CILINDER_PARTNUM
	SLEEP_ruwheid
	SLEEP_ruwheid_Rz
    where=(date_ts_be GE intnx('year',today(),-4,'begin'))) B
where A.ts_be_crm = B.ts_be
  and A.kant = B.kant_balbul
  and A.dch_n = B.dch_n;
quit;
endrsubmit;
rsubmit;
data data3e;
set data3d;
 if substr(aro_r_cilinder_partnum,1,1) eq '1'    then aro_r_lengt = 'lang';  else
 if substr(aro_r_cilinder_partnum,1,1) eq '2'    then aro_r_lengt = 'kort';  else aro_r_lengt = ' ';
 if substr(aro_l_cilinder_partnum,1,1) eq '1'    then aro_l_lengt = 'lang';  else
 if substr(aro_l_cilinder_partnum,1,1) eq '2'    then aro_l_lengt = 'kort';  else aro_l_lengt = ' ';
 if substr(aro_r_cilinder_partnum,5,4) eq '5815' then aro_r_soort = 'ampco'; else
 if substr(aro_r_cilinder_partnum,5,4) eq '5816' then aro_r_soort = 'staal'; else
 if substr(aro_r_cilinder_partnum,5,4) eq '5862' then aro_r_soort = 'fleece';else
 if substr(aro_r_cilinder_partnum,5,4) eq '5863' then aro_r_soort = 'fleece';else aro_r_soort = ' ';
 if substr(aro_l_cilinder_partnum,5,4) eq '5815' then aro_l_soort = 'ampco'; else
 if substr(aro_l_cilinder_partnum,5,4) eq '5816' then aro_l_soort = 'staal'; else
 if substr(aro_l_cilinder_partnum,5,4) eq '5862' then aro_l_soort = 'fleece';else
 if substr(aro_l_cilinder_partnum,5,4) eq '5863' then aro_l_soort = 'fleece';else aro_l_soort = ' ';
 K100_CILINDER_NUMMER4 = substr(K100_CILINDER_NUMMER,1,4);
 K220_CILINDER_NUMMER4 = substr(K220_CILINDER_NUMMER,1,4);
 ARO_L_CILINDER_NUMMER4 = substr(ARO_L_CILINDER_NUMMER,1,4);
 ARO_R_CILINDER_NUMMER4 = substr(ARO_R_CILINDER_NUMMER,1,4);
 TAP_L_CILINDER_NUMMER4 = substr(TAP_L_CILINDER_NUMMER,1,4);
 TAP_R_CILINDER_NUMMER4 = substr(TAP_R_CILINDER_NUMMER,1,4);
 DDR_L_CILINDER_NUMMER4 = substr(DDR_L_CILINDER_NUMMER,1,4);
 DDR_R_CILINDER_NUMMER4 = substr(DDR_R_CILINDER_NUMMER,1,4);
run;
endrsubmit;

/*linken met slijspteendiameter*/
rsubmit;
proc sql;
create table data3f as select distinct A.*, B.slijp_steen_begin_diameter AS K220_slijp_steen_diameter
from data3e A LEFT JOIN kw.Crm3_cil_slijp B
ON A.K220_laatste_grindterm_ID = B.grindingterm_ID;
quit;
endrsubmit;
rsubmit;
proc sql;
create table data3g as select distinct A.*, B.slijp_steen_begin_diameter AS K100_slijp_steen_diameter
from data3f A LEFT JOIN kw.Crm3_cil_slijp B
ON A.K100_laatste_grindterm_ID = B.grindingterm_ID;
quit;
endrsubmit;

/*CRM3 rampup toevoegen*/

%include 'r:\progs\BA_5sec_crm3_rampup.sas';
rsubmit;
proc sql; create table data3h as select distinct A.*, B.* from data3g A LEFT JOIN scad.crm3_pv_summary B
on A.cl_n = B.cl_n and A.ts_be = B.ts_be_glb;
quit;
endrsubmit;

rsubmit;
/*maak tussentabel met alles erin*/
/*klopt nog niet: veel te veel records ??*/
/*proc sql; create table crm3_per_pas as select A.*,B.* from &lbn..crm3pasm A, &lbn..crm3_werkcil_pas B
WHERE  A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n = B.dch_n
AND A.bew_vn = B.bew_vn
AND A.pas_vn = A.pas_vn;
quit;
*/
proc sql;
create table data4 as select A.*,
        B.DI as di_l, B.SNL_MM as snl_mm_l, B.FORCE/(B.di*A.br_ei_bew) as force_mm2_l, B.BACTEN/(B.di*A.br_ei_bew) as BACTEN_mm2_l,
        B.FORTEN/(B.di*A.br_ei_bew) as FORTEN_mm2_l, B.TORQUE/(B.di*A.br_ei_bew) as TORQUE_mm2_l,
        case when A.kant_CRM3 = 'T' then B.DIA_CILT
             when A.kant_CRM3 = 'B' then B.DIA_CILD end as DIA_CIL_l,
        case when A.kant_CRM3 = 'T' then B.DIA_CILT/B.dia_CILD
             when A.kant_CRM3 = 'B' then B.DIA_CILD/B.Dia_CILT end as DIA_CIL_verhouding_l,
        (B.dia_cilT - B.DIA_CILD) as dia_cil_delta_l
from data3h A, &lbn..crm3pasm B
WHERE  A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n = B.dch_n
AND A.bew_vn-1 = B.bew_vn
AND B.pas_vn = A.a_pas;
quit;

proc sql;
create table data5 as select A.*,
        B.DI as di_vl, B.SNL_MM as snl_mm_vl, B.FORCE/(B.di*A.br_ei_bew) as force_vl, B.BACTEN/(B.di*A.br_ei_bew) as BACTEN_vl,
        B.FORTEN/(B.di*A.br_ei_bew) as FORTEN_vl, B.TORQUE/(B.di*A.br_ei_bew) as TORQUE_vl,
        case when A.kant_CRM3 = 'T' then B.DIA_CILT
             when A.kant_CRM3 = 'B' then B.DIA_CILD end as DIA_CIL_vl,
        case when A.kant_CRM3 = 'T' then B.DIA_CILT/B.dia_CILD
             when A.kant_CRM3 = 'B' then B.DIA_CILD/B.Dia_CILT end as DIA_CIL_verhouding_vl,
        (B.dia_cilT - B.DIA_CILD) as dia_cil_delta_vl
from data4 A, &lbn..crm3pasm B
WHERE  A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n = B.dch_n
AND A.bew_vn-1 = B.bew_vn
AND B.pas_vn = A.a_pas-1;
quit;


proc sql;
create table data6 as select A.*,
        B.DI as di_vvl, B.SNL_MM as snl_mm_vvl, B.FORCE/(B.di*A.br_ei_bew) as force_vvl, B.BACTEN/(B.di*A.br_ei_bew) as BACTEN_vvl,
        B.FORTEN/(B.di*A.br_ei_bew) as FORTEN_vvl, B.TORQUE/(B.di*A.br_ei_bew) as TORQUE_vvl,
        case when A.kant_CRM3 = 'T' then B.DIA_CILT
             when A.kant_CRM3 = 'B' then B.DIA_CILD end as DIA_CIL_vvl,
        case when A.kant_CRM3 = 'T' then B.DIA_CILT/B.dia_CILD
             when A.kant_CRM3 = 'B' then B.DIA_CILD/B.Dia_CILT end as DIA_CIL_verhouding_vvl,
        (B.dia_cilT - B.DIA_CILD) as dia_cil_delta_vvl
from data5 A, &lbn..crm3pasm B
WHERE  A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n = B.dch_n
AND A.bew_vn-1 = B.bew_vn
AND B.pas_vn = A.a_pas-2;
quit;

proc sql;
create table data6a as select A.*,
        B.DI as di_vvvl, B.SNL_MM as snl_mm_vvvl, B.FORCE/(B.di*A.br_ei_bew) as force_vvvl, B.BACTEN/(B.di*A.br_ei_bew) as BACTEN_vvvl,
        B.FORTEN/(B.di*A.br_ei_bew) as FORTEN_vvvl, B.TORQUE/(B.di*A.br_ei_bew) as TORQUE_vvvl,
        case when A.kant_CRM3 = 'T' then B.DIA_CILT
             when A.kant_CRM3 = 'B' then B.DIA_CILD end as DIA_CIL_vvvl,
        case when A.kant_CRM3 = 'T' then B.DIA_CILT/B.dia_CILD
             when A.kant_CRM3 = 'B' then B.DIA_CILD/B.Dia_CILT end as DIA_CIL_verhouding_vvvl,
        (B.dia_cilT - B.DIA_CILD) as dia_cil_delta_vvvl
from data6 A, &lbn..crm3pasm B
WHERE  A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n = B.dch_n
AND A.bew_vn-1 = B.bew_vn
AND B.pas_vn = A.a_pas-3;
quit;


proc sql;
create table data7 as select A.*,
        B.DI as di_1, B.SNL_MM as snl_mm_1, B.FORCE/(B.di*A.br_be_bew) as force_1, B.BACTEN/(B.di*A.br_be_bew) as BACTEN_1,
        B.FORTEN/(B.di*A.br_be_bew) as FORTEN_1, B.TORQUE/(B.di*A.br_be_bew) as TORQUE_1,
        case when A.kant_CRM3 = 'T' then B.DIA_CILT
             when A.kant_CRM3 = 'B' then B.DIA_CILD end as DIA_CIL_1,
        case when A.kant_CRM3 = 'T' then B.DIA_CILT/B.dia_CILD
             when A.kant_CRM3 = 'B' then B.DIA_CILD/B.Dia_CILT end as DIA_CIL_verhouding_1,
        (B.dia_cilT - B.DIA_CILD) as dia_cil_delta_1
from data6a A, &lbn..crm3pasm B
WHERE  A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n = B.dch_n
AND A.bew_vn-1 = B.bew_vn
AND B.pas_vn = 1;
quit;
endrsubmit;

rsubmit;
data data8;
set data7;
if DIA_CIL_vl NE DIA_CIL_l  then cw_lp = 1; else cw_lp=0;
if DIA_CIL_vvl NE DIA_CIL_vl  then cw_vlp = 1; else cw_vlp=0;
if DIA_CIL_vvvl NE DIA_CIL_vvl  then cw_vvlp = 1; else cw_vvlp=0;
reductie_lp = (di_vl - di_l)/di_vl;
reductie_vlp = (di_vvl - di_vl)/di_vvl;
reductie_vvlp = (di_vvvl - di_vvl)/di_vvvl;
run;
endrsubmit;

/*fouten BAL toevoegen*/
rsubmit;
data fout1 (keep= cl_n sjr_cl dch_n ln_pr bew_vn repet K_ft knt_ft ft_levan ft_letot ft_mtot ft_mvan ft_zqc ft_znqc k_klasma);
set &lbn..kwaldetm (where=(ln_pr = 'BAL1' and K_ft IN 
										('PAMA','DEUK','AANH','BAAN','RIDI', 'SLI1','SLI2','MBRK','CDIG','CRCH','CBRK','POCH','POST','SLKR',
										 'ORPE','ROPI','RUW','DISC','SLKR','LAMI','BAAN','CRCH','CBRK','ORPE','ROPI','RUW','KRK','POST','DISC','CLBO','LIN4')
                                       and K_klasma GE '04' and sjr_cl GE '2010'));

run;
/*le toevoegen via matm*/
proc sql; create table fout2 as select A.*, B.br, B.le, B.ln_pr_vl
          from fout1 A LEFT JOIN 
			&lbn..matm 
			(keep = sjr_cl cl_n dch_n bew_vn ln_pr br le ln_pr_vl date_ts_be 
			 where=(date_ts_Be GE intnx('year',today(),-&aantaljaarterug,'begin') and ln_pr='BAL1')) B
ON  A.sjr_cl = B.Sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n = B.dch_n
AND A.bew_vn = B.bew_vn;
quit;
/*lengtes goed zetten*/
data fout3 (drop = K_ft br ft_levan ft_letot ft_mtot ft_mvan ft_zqc ft_znqc knt_ft k_klasma);
set fout2;
if ft_letot = 0 then ft_letot = le/1000;
ft_le = ft_letot - ft_levan;
if ft_mtot = 0 and ft_zqc=0 and ft_Znqc = 0 then ft_mtot=br;
if K_ft = 'PAMA' and k_klasma GE '04' then do; pama_kl45=1;  pama_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'PAMA' and k_klasma GE '05' then do; pama_kl5 =1;  pama_kl5_le =ft_letot-ft_levan; end;
if K_ft = 'DEUK' and k_klasma GE '04' then do; deuk_kl45=1;  deuk_kl45_le=ft_letot-ft_levan; deuk_kl45_rep=repet; end;
if K_ft = 'DEUK' and k_klasma GE '05' then do; deuk_kl5 =1;  deuk_kl5_le =ft_letot-ft_levan; deuk_kl5_rep= repet; end;
if K_ft = 'AANH' and k_klasma GE '04' then do; aanh_kl45=1;  aanh_kl45_le=ft_letot-ft_levan; aanh_kl45_rep=repet; end;
if K_ft = 'AANH' and k_klasma GE '05' then do; aanh_kl5 =1;  aanh_kl5_le =ft_letot-ft_levan; aanh_kl5_rep= repet; end;

if K_ft = 'AANH' and k_klasma GE '04' and repet = 4 then do; 								AANH4_kl45=1;   AANH4_kl45_le= ft_letot-ft_levan; end;
if K_ft = 'AANH' and k_klasma GE '05' and repet = 4 then do; 								AANH4_kl5 =1;   AANH4_kl5_le = ft_letot-ft_levan;  end;
if K_ft = 'AANH' and k_klasma GE '04' and repet = 5 then do; 								AANH5_kl45=1;   AANH5_kl45_le= ft_letot-ft_levan; end;
if K_ft = 'AANH' and k_klasma GE '05' and repet = 5 then do; 								AANH5_kl5 =1;   AANH5_kl5_le=  ft_letot-ft_levan;  end;
if K_ft = 'AANH' and k_klasma GE '04' and repet in (4,5) then do; 							AANH45_kl45=1;  AANH45_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'AANH' and k_klasma GE '05' and repet in (4,5) then do; 							AANH45_kl5=1;   AANH45_kl5_le= ft_letot-ft_levan; end;
if K_ft = 'AANH' and k_klasma GE '04' and repet = 6 then do; 								METF_kl45=1;    METF_kl45_le=  ft_letot-ft_levan; end;
if K_ft = 'AANH' and k_klasma GE '05' and repet = 6 then do; 								METF_kl5=1;     METF_kl5_le=   ft_letot-ft_levan; end;
if K_ft = 'AANH' and k_klasma GE '04' and (repet IN (7,8) or (7000 < repet < 9000)) then do;AANH78_kl45=1;  AANH78_kl45_le=ft_letot-ft_levan;  end;
if K_ft = 'AANH' and k_klasma GE '05' and (repet IN (7,8) or (7000 < repet < 9000)) then do;AANH78_kl5=1;   AANH78_kl5_le= ft_letot-ft_levan;  end;
if K_ft = 'AANH' and k_klasma GE '04' and (repet = 7 or (7000 < repet < 8000)) then do; 	AANH7_kl45=1;   AANH7_kl45_le= ft_letot-ft_levan;  end;
if K_ft = 'AANH' and k_klasma GE '05' and (repet = 7 or (7000 < repet < 8000)) then do; 	AANH7_kl5=1;    AANH7_kl5_le=  ft_letot-ft_levan;  end;
if K_ft = 'AANH' and k_klasma GE '04' and (repet = 8 or (8000 < repet < 9000)) then do; 	AANH8_kl45=1;   AANH8_kl45_le= ft_letot-ft_levan;  end;
if K_ft = 'AANH' and k_klasma GE '05' and (repet = 8 or (8000 < repet < 9000)) then do; 	AANH8_kl5=1;    AANH8_kl5_le=  ft_letot-ft_levan;  end;
if K_ft = 'AANH' and k_klasma GE '04' and (repet GE 10 and repet LE 3999)
   then do;
        if ( (ft_zqc le 25 and ft_zqc NE 0) or (ft_znqc LE 25 and ft_znqc NE 0) and ft_mtot=0 and ft_mvan = 0 )
           or ( (ft_mtot - ft_mvan) LE 25 and ft_mvan NE 0 and ft_mtot NE 0 and ft_zqc = 0 and ft_znqc = 0 )
        then do; /*AANH_PNT*/
             APNT_kl45=1; APNT_kl45_le=ft_letot-ft_levan; APNT_kl45_rep=repet;
             end;
        else do; /*AANH_BRD*/
             ABRD_kl45=1; ABRD_kl45_br = round(ft_mtot-ft_mvan,100); ABRD_kl45_le=ft_letot-ft_levan; ABRD_kl45_rep=repet;
             end;
   end;
if K_ft = 'AANH' and k_klasma GE '05' and (repet GE 10 and repet LE 3999)
   then do;
        if ( (ft_zqc le 25 and ft_zqc NE 0) or (ft_znqc LE 25 and ft_znqc NE 0) and ft_mtot=0 and ft_mvan = 0 )
           or ( (ft_mtot - ft_mvan) LE 25 and ft_mvan NE 0 and ft_mtot NE 0 and ft_zqc = 0 and ft_znqc = 0 )
        then do; /*AANH_PNT*/
             APNT_kl5=1;  APNT_kl5_le=ft_letot-ft_levan; APNT_kl5_rep=repet;
             end;
        else do; /*AANH_BRD*/
             ABRD_kl5=1; ABRD_kl5_br = round(ft_mtot-ft_mvan,100); ABRD_kl5_le=ft_letot-ft_levan; ABRD_kl5_rep=repet;
             end;
   end;

if K_ft = 'BAAN' and k_klasma GE '04' then do; 					baan_kl45=1; 	baan_kl45_le=ft_letot-ft_levan; 	baan_kl45_rep=repet; end;
if K_ft = 'BAAN' and k_klasma GE '05' then do; 					baan_kl5=1;  	baan_kl5_le= ft_letot-ft_levan; 	baan_kl5_rep=repet; end;
if K_ft = 'RIDI' and k_klasma GE '04' then do; 				  	ridi_kl45=1; 	ridi_kl45_le=ft_letot-ft_levan; 	ridi_kl45_rep=repet; end;
if K_ft = 'RIDI' and k_klasma GE '05' then do; 				  	ridi_kl5=1;  	ridi_kl5_le=ft_letot-ft_levan; 		ridi_kl5_rep=repet;  
																ridi_kl5_qc =ft_zqc;      ridi_kl5_nqc =ft_znqc;     end;
if K_ft = 'RIDI' and k_klasma GE '04' and repet NE 2 then do; 	ridi_kl45_ne2=1;ridi_kl45_ne2_le=ft_letot-ft_levan; ridi_kl45_ne2_rep=repet; end;
if K_ft = 'RIDI' and k_klasma GE '05' and repet NE 2 then do; 	ridi_kl5_ne2=1; ridi_kl5_ne2_le=ft_letot-ft_levan;  ridi_kl5_ne2_rep=repet; end;
if K_ft = 'RIDI' and k_klasma GE '04' and repet NE 3 then do; 	ridi_kl45_ne3=1;ridi_kl45_ne3_le=ft_letot-ft_levan; ridi_kl45_ne3_rep=repet; end;
if K_ft = 'RIDI' and k_klasma GE '05' and repet NE 3 then do; 	ridi_kl5_ne3=1; ridi_kl5_ne3_le=ft_letot-ft_levan;  ridi_kl5_ne3_rep=repet; end;
if K_ft = 'RIDI' and k_klasma GE '04' and repet not in (2,3) then do; 
																ridi_kl45_ne23=1; ridi_kl45_ne23_le=ft_letot-ft_levan; ridi_kl45_ne23_rep=repet; end;
if K_ft = 'RIDI' and k_klasma GE '05' and repet not in (2,3) then do; 
																ridi_kl5_ne23=1;  ridi_kl5_ne23_le=ft_letot-ft_levan; ridi_kl5_ne23_rep=repet; end;
if k_ft IN ('SLI1','SLI2') and k_klasma GE '04' then do; 		SLI_kl45=1;  	SLI_kl45_le=ft_letot-ft_levan; end;
if k_ft IN ('SLI1','SLI2') and k_klasma GE '05' then do; 		SLI_kl5=1;   	SLI_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'MBRK'  and k_klasma GE '04' then do; 				mbrk_kl45=1; 	mbrk_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'MBRK'  and k_klasma GE '05' then do; 				mbrk_kl5=1;   	mbrk_kl5_le=ft_letot-ft_levan; end;
if (K_ft = 'CDIG' or (K_FT = 'RIDI' and repet=2)) and k_klasma GE '04' then do; 
																cdig_kl45=1; 	cdig_kl45_le=ft_letot-ft_levan; end;
if (K_ft = 'CDIG' or (K_FT = 'RIDI' and repet=2)) and k_klasma GE '05' then do; 
																cdig_kl5=1; 	cdig_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'CBRK' and k_klasma GE '04' then do; 					cbrk_kl45=1;  	cbrk_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'CBRK' and k_klasma GE '05' then do; 					cbrk_kl5=1;   	cbrk_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'SLKR' and k_klasma GE '04' then do; 					slkr_kl45=1;  	slkr_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'SLKR' and k_klasma GE '05' then do; 					slkr_kl5=1;   	slkr_kl5_le=ft_letot-ft_levan; end;
if K_ft IN ('ORPE','RUW') and k_klasma GE '04' then do; 		orperuw_kl45=1; orperuw_kl45_le=ft_letot-ft_levan; end;
if K_ft IN ('ORPE','RUW') and k_klasma GE '05' then do; 		orperuw_kl5=1;  orperuw_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'ORPE' and k_klasma GE '04' then do; 					orpe_kl45=1; 	orpe_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'ORPE' and k_klasma GE '05' then do; 					orpe_kl5=1;  	orpe_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'ROPI' and k_klasma GE '04' then do; 					ropi_kl45=1; 	ropi_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'ROPI' and k_klasma GE '05' then do; 					ropi_kl5=1;  	ropi_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'LIN4' and k_klasma GE '04' then do; 					lin4_kl45=1; 	lin4_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'LIN4' and k_klasma GE '05' then do; 					lin4_kl5=1;  	lin4_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'RUW'  and k_klasma GE '04' then do; 					ruw_kl45=1;  	ruw_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'RUW'  and k_klasma GE '05' then do; 					ruw_kl5=1;   	ruw_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'KRK'  and k_klasma GE '04' then do; 					krk_kl45=1;  	krk_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'KRK'  and k_klasma GE '05' then do; 					krk_kl5=1;   	krk_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'POCH' and k_klasma GE '04' then do; 					poch_kl45=1; 	poch_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'POCH' and k_klasma GE '05' then do; 					poch_kl5=1;  	poch_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'POST' and k_klasma GE '04' then do; 					post_kl45=1; 	post_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'POST' and k_klasma GE '05' then do; 					post_kl5=1;  	post_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'CRCH' and k_klasma GE '04' then do; 					crch_kl45=1; 	crch_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'CRCH' and k_klasma GE '05' then do; 					crch_kl5=1;  	crch_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'DISC' and k_klasma GE '04' then do; 					disc_kl45=1; 	disc_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'DISC' and k_klasma GE '05' then do; 					disc_kl5=1;  	disc_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'CLBO' and k_klasma GE '04' then do; 					clbo_kl45=1; 	clbo_kl45_le=ft_letot-ft_levan; end;
if K_ft = 'CLBO' and k_klasma GE '05' then do; 					clbo_kl5=1;  	clbo_kl5_le=ft_letot-ft_levan; end;
if K_ft = 'LAMI' then do; lamiQC=ft_zqc; lamiNQC=ft_zNQC; end;
if knt_ft IN ('T','B') then do; kant = knt_ft; output; end;
   else if knt_ft in ('TB','BT') then do; kant = 'T'; output; kant='B'; output; end;
run;
/*tabel ineenklappen*/
proc sql;
create table fout4 as select distinct cl_n, sjr_cl, dch_n, ln_pr, bew_vn, kant, le,
sum(pama_kl45  ) as pama_kl45  			,max(pama_kl45_le  ) as pama_kl45_le  	,	
sum(pama_kl5   ) as pama_kl5   			,max(pama_kl5_le   ) as pama_kl5_le   		,
sum(deuk_kl45  ) as deuk_kl45  			,max(deuk_kl45_le  ) as deuk_kl45_le  		,	
sum(deuk_kl5   ) as deuk_kl5   			,max(deuk_kl5_le   ) as deuk_kl5_le   		,	avg(deuk_kl45_rep ) AS  deuk_kl45_rep,   
sum(aanh_kl45  ) as aanh_kl45  			,max(aanh_kl45_le  ) as aanh_kl45_le  		,	avg(deuk_kl5_rep  ) AS 	deuk_kl5_rep ,
sum(aanh_kl5   ) as aanh_kl5   			,max(aanh_kl5_le   ) as aanh_kl5_le   		,	avg(aanh_kl45_rep  ) AS	aanh_kl45_rep ,
sum(AANH4_kl45 ) as AANH4_kl45 			,max(AANH4_kl45_le ) as AANH4_kl45_le 		,	avg(aanh_kl5_rep  ) AS	aanh_kl5_rep ,	
sum(AANH4_kl5  ) as AANH4_kl5  			,max(AANH4_kl5_le  ) as AANH4_kl5_le  		,		
sum(AANH5_kl45 ) as AANH5_kl45 			,max(AANH5_kl45_le ) as AANH5_kl45_le 		,		
sum(AANH5_kl5  ) as AANH5_kl5  			,max(AANH5_kl5_le  ) as AANH5_kl5_le  		,		
sum(AANH45_kl45) as AANH45_kl45			,max(AANH45_kl45_le) as AANH45_kl45_le		,		
sum(AANH45_kl5 ) as AANH45_kl5 			,max(AANH45_kl5_le ) as AANH45_kl5_le 		,			
sum(METF_kl45  ) as METF_kl45  			,max(METF_kl45_le  ) as METF_kl45_le  		,		
sum(METF_kl5   ) as METF_kl5   			,max(METF_kl5_le   ) as METF_kl5_le   		,		
sum(AANH78_kl45) as AANH78_kl45			,max(AANH78_kl45_le) as AANH78_kl45_le		,		
sum(AANH78_kl5 ) as AANH78_kl5 			,max(AANH78_kl5_le ) as AANH78_kl5_le 		,		
sum(AANH7_kl45 ) as AANH7_kl45 			,max(AANH7_kl45_le ) as AANH7_kl45_le 		,		
sum(AANH7_kl5  ) as AANH7_kl5  			,max(AANH7_kl5_le  ) as AANH7_kl5_le  		,						
sum(AANH8_kl45 ) as AANH8_kl45 			,max(AANH8_kl45_le ) as AANH8_kl45_le 		,		
sum(AANH8_kl5  ) as AANH8_kl5  			,max(AANH8_kl5_le  ) as AANH8_kl5_le  		,		
sum(APNT_kl45  ) as APNT_kl45  			,max(APNT_kl45_le  ) as APNT_kl45_le  		,	avg(APNT_kl45_rep ) AS APNT_kl45_rep, 
sum(APNT_kl5   ) as APNT_kl5   			,max(APNT_kl5_le   ) as APNT_kl5_le   		,	avg(APNT_kl5_rep  ) AS APNT_kl5_rep , 	
sum(ABRD_kl45  ) as ABRD_kl45  			,max(ABRD_kl45_le  ) as ABRD_kl45_le  		,	avg(ABRD_kl45_br )  AS ABRD_kl45_br, avg(ABRD_kl45_rep ) AS ABRD_kl45_rep,
sum(ABRD_kl5   ) as ABRD_kl5   			,max(ABRD_kl5_le   ) as ABRD_kl5_le   		,	avg(ABRD_kl5_br  )  AS ABRD_kl5_br , AVG(ABRD_kl5_rep  ) AS ABRD_kl5_rep ,
sum(baan_kl45  ) as baan_kl45  			,max(baan_kl45_le  ) as baan_kl45_le  		,	avg(baan_kl45_rep ) AS baan_kl45_rep,
sum(baan_kl5   ) as baan_kl5   			,max(baan_kl5_le   ) as baan_kl5_le   		,	avg(baan_kl5_rep  ) AS baan_kl5_rep, 
sum(ridi_kl45  ) as ridi_kl45  			,max(ridi_kl45_le  ) as ridi_kl45_le  		,	avg(ridi_kl45_rep ) AS ridi_kl45_rep, 
sum(ridi_kl5   ) as ridi_kl5   			,max(ridi_kl5_le   ) as ridi_kl5_le   		,	avg(ridi_kl5_rep )  AS ridi_kl5_rep, 	
										 max(ridi_kl5_qc)    as ridi_kl5_qc         ,   max(ridi_kl5_nqc)    as ridi_kl5_nqc,            
sum(ridi_kl45_ne2) as ridi_kl45_ne2		,max(ridi_kl45_ne2_le) as ridi_kl45_ne2_le	,	avg(ridi_kl45_ne2_rep  ) AS	ridi_kl45_ne2_rep,  
sum(ridi_kl5_ne2 ) as ridi_kl5_ne2		,max(ridi_kl5_ne2_le ) as ridi_kl5_ne2_le	,	avg(ridi_kl5_ne2_rep   ) AS	ridi_kl5_ne2_rep ,  
sum(ridi_kl45_ne3) as ridi_kl45_ne3		,max(ridi_kl45_ne3_le) as ridi_kl45_ne3_le	,	avg(ridi_kl45_ne3_rep  ) AS	ridi_kl45_ne3_rep,  		
sum(ridi_kl5_ne3 ) as ridi_kl5_ne3		,max(ridi_kl5_ne3_le ) as ridi_kl5_ne3_le	,	avg(ridi_kl5_ne3_rep   ) AS	ridi_kl5_ne3_rep ,  
sum(ridi_kl45_ne23) as ridi_kl45_ne23	,max(ridi_kl45_ne23_le) as ridi_kl45_ne23_le,	avg(ridi_kl45_ne23_rep ) AS	ridi_kl45_ne23_rep, 	
sum(ridi_kl5_ne23) as ridi_kl5_ne23		,max(ridi_kl5_ne23_le) as ridi_kl5_ne23_le	,	avg(ridi_kl5_ne23_rep  ) AS	ridi_kl5_ne23_rep,  
sum(SLI_kl45  	) as SLI_kl45  			,max(SLI_kl45_le  	) as SLI_kl45_le  			,						
sum(SLI_kl5   	) as SLI_kl5   			,max(SLI_kl5_le   	) as SLI_kl5_le   			,		
sum(mbrk_kl45 	) as mbrk_kl45 			,max(mbrk_kl45_le 	) as mbrk_kl45_le 			,		
sum(mbrk_kl5   	) as mbrk_kl5   		,max(mbrk_kl5_le   	) as mbrk_kl5_le   	,				
sum(cdig_kl45 	) as cdig_kl45 			,max(cdig_kl45_le 	) as cdig_kl45_le 			,						
sum(cdig_kl5 	) as cdig_kl5 			,max(cdig_kl5_le 	) as cdig_kl5_le 			,		
sum(cbrk_kl45  	) as cbrk_kl45  		,max(cbrk_kl45_le  	) as cbrk_kl45_le  	,				
sum(cbrk_kl5   	) as cbrk_kl5   		,max(cbrk_kl5_le   	) as cbrk_kl5_le   	,				
sum(slkr_kl45  	) as slkr_kl45  		,max(slkr_kl45_le  	) as slkr_kl45_le  	,				
sum(slkr_kl5   	) as slkr_kl5   		,max(slkr_kl5_le   	) as slkr_kl5_le   	,				
sum(orperuw_kl45) as orperuw_kl45		,max(orperuw_kl45_le) as orperuw_kl45_le		,		
sum(orperuw_kl5 ) as orperuw_kl5 		,max(orperuw_kl5_le ) as orperuw_kl5_le 		,		
sum(orpe_kl45 	) as orpe_kl45 			,max(orpe_kl45_le 	) as orpe_kl45_le 			,		
sum(orpe_kl5  	) as orpe_kl5  			,max(orpe_kl5_le  	) as orpe_kl5_le  			,		
sum(ropi_kl45 	) as ropi_kl45 			,max(ropi_kl45_le 	) as ropi_kl45_le 			,		
sum(ropi_kl5  	) as ropi_kl5  			,max(ropi_kl5_le  	) as ropi_kl5_le  			,	
sum(lin4_kl45 	) as lin4_kl45 			,max(lin4_kl45_le 	) as lin4_kl45_le 			,		
sum(lin4_kl5  	) as lin4_kl5  			,max(lin4_kl5_le  	) as lin4_kl5_le  			,		
sum(ruw_kl45  	) as ruw_kl45  			,max(ruw_kl45_le  	) as ruw_kl45_le  			,		
sum(ruw_kl5   	) as ruw_kl5   			,max(ruw_kl5_le   	) as ruw_kl5_le   			,	
sum(krk_kl45  	) as krk_kl45  			,max(krk_kl45_le  	) as krk_kl45_le  			,		
sum(krk_kl5   	) as krk_kl5   			,max(krk_kl5_le   	) as krk_kl5_le   			,		
sum(poch_kl45 	) as poch_kl45 			,max(poch_kl45_le 	) as poch_kl45_le 			,		
sum(poch_kl5  	) as poch_kl5  			,max(poch_kl5_le  	) as poch_kl5_le  			,		
sum(post_kl45 	) as post_kl45 			,max(post_kl45_le 	) as post_kl45_le 			,		
sum(post_kl5  	) as post_kl5  			,max(post_kl5_le  	) as post_kl5_le  			,		
sum(crch_kl45 	) as crch_kl45 			,max(crch_kl45_le 	) as crch_kl45_le 			,		
sum(crch_kl5  	) as crch_kl5  			,max(crch_kl5_le  	) as crch_kl5_le  			,		
sum(disc_kl45 	) as disc_kl45 			,max(disc_kl45_le 	) as disc_kl45_le 			,		
sum(disc_kl5  	) as disc_kl5  			,max(disc_kl5_le  	) as disc_kl5_le  			,	
sum(clbo_kl45 	) as clbo_kl45 			,max(clbo_kl45_le 	) as clbo_kl45_le 			,		
sum(clbo_kl5  	) as clbo_kl5  			,max(clbo_kl5_le  	) as clbo_kl5_le  			,			
max(lamiQC) as lamiQC, 			max(lamiNQC) as lamiNQC
                  from fout3
                  group by cl_n, sjr_cl, dch_n, ln_pr, bew_vn, kant;
quit;

endrsubmit;

rsubmit;
proc sql; create table data9 as select A.*, B.* from data8 A LEFT JOIN fout4 B
ON A.sjr_cl = B.sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n =b.dch_n
AND A.bew_vn = B.bew_vn
AND A.kant = B.kant;
quit;

/*uitgewalste deuk en zo berekenen later in data10*/


endrsubmit;


/*PAMA & CRBL & SLKR ingave aan SKP1 toevoegen*/
rsubmit;
data foutskp1 (keep= cl_n sjr_cl dch_n ln_pr bew_vn pama45_skp pama5_skp papl45_skp papl5_skp ripa45_skp ripa5_skp crbl45_skp crbl5_skp slkr_skp_klas);
set &lbn..kwaldetm (where=(ln_pr = 'SKP1' and sjr_cl GE '2010'));
/* opgelet: we nemen alleen de fouten --> gaat later voor missings zorgen!*/
pama45_skp = 0; pama5_skp=0;
papl45_skp = 0; papl5_skp=0;
ripa45_skp = 0; ripa5_skp=0;
crbl45_skp = 0; crbl5_skp=0;
slkr_skp_klas = 0;
if K_ft = 'PAMA' and K_klasma GE '05' then pama5_skp=1; 
if K_ft = 'PAMA' and K_klasma GE '04' then pama45_skp=1; 
if K_ft = 'PAPL' and K_klasma GE '05' then papl5_skp=1; 
if K_ft = 'PAPL' and K_klasma GE '04' then papl45_skp=1; 
if K_ft = 'RIPA' and K_klasma GE '05' then ripa5_skp=1; 
if K_ft = 'RIPA' and K_klasma GE '04' then ripa45_skp=1; 
if K_ft = 'CRBL' and K_klasma GE '05' then crbl5_skp=1; 
if K_ft = 'CRBL' and K_klasma GE '04' then crbl45_skp=1; 
if K_FT = 'SLKR' then do;
  if K_Klasma EQ '01' then slkr_skp_klas = 1;
  if K_Klasma EQ '04' then slkr_skp_klas = 4;
  if K_Klasma EQ '05' then slkr_skp_klas = 5;
  end;
run;
/*tabel ineenklappen*/
proc sql;
create table foutskp2 as select distinct cl_n, sjr_cl, dch_n, ln_pr, bew_vn, 
                  sum(pama5_skp) as pama5_skp, sum(pama45_skp) as pama45_skp,
                  sum(papl5_skp) as papl5_skp, sum(papl45_skp) as papl45_skp,
                  sum(ripa5_skp) as ripa5_skp, sum(ripa45_skp) as ripa45_skp,
				  sum(crbl5_skp) as crbl5_skp, sum(crbl45_skp) as crbl45_skp,
				  avg(slkr_skp_klas ) as slkr_skp_klas 
                  from foutskp1
                  group by cl_n, sjr_cl, dch_n, ln_pr, bew_vn;
quit;
endrsubmit;

/*link is niet perfect omwille van dochternbummer; dit worden missings*/
rsubmit;
proc sql; create table data91 as select A.*, B.* from data9 A LEFT JOIN foutskp2 B
ON A.sjr_cl = B.sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n =b.dch_n
AND A.bew_vn+1 = B.bew_vn; /*enkel volgende lijn*/
quit;
endrsubmit;


/*PAMA's van SL60/STL1 toevoegen ENKEL voor routings SKP1-STL1/SL60 OF KW1-STL1/SL60*/
rsubmit;
data fout_sl60_stl1 (keep= cl_n sjr_cl dch_n ln_pr bew_vn pama45_sl60stl1 pama5_sl60stl1 papl45_sl60stl1 papl5_sl60stl1 
														  ripa45_sl60stl1 ripa5_sl60stl1 crbl45_sl60stl1 crbl5_sl60stl1);
set &lbn..kwaldetm (where=(ln_pr IN ('SL60','STL1') and sjr_cl GE '2010'));
pama45_sl60stl1 = 0; pama5_sl60stl1=0;
papl45_sl60stl1 = 0; papl5_sl60stl1=0;
ripa45_sl60stl1 = 0; ripa5_sl60stl1=0;
crbl45_sl60stl1 = 0; crbl5_sl60stl1=0;
if K_ft = 'PAMA' and K_klasma GE '05' then pama5_sl60stl1=1; 
if K_ft = 'PAMA' and K_klasma GE '04' then pama45_sl60stl1=1; 
if K_ft = 'PAPL' and K_klasma GE '05' then papl5_sl60stl1=1; 
if K_ft = 'PAPL' and K_klasma GE '04' then papl45_sl60stl1=1; 
if K_ft = 'RIPA' and K_klasma GE '05' then ripa5_sl60stl1=1; 
if K_ft = 'RIPA' and K_klasma GE '04' then ripa45_sl60stl1=1; 
if K_ft = 'CRBL' and K_klasma GE '05' then crbl5_sl60stl1=1; 
if K_ft = 'CRBL' and K_klasma GE '04' then crbl45_sl60stl1=1; 
run;
/*tabel ineenklappen*/
proc sql;
create table fout_sl60_stl1_2 as select distinct cl_n, sjr_cl, dch_n, ln_pr, bew_vn, 
                  sum(pama5_sl60stl1) as pama5_sl60stl1, sum(pama45_sl60stl1) as pama45_sl60stl1,
                  sum(papl5_sl60stl1) as papl5_sl60stl1, sum(papl45_sl60stl1) as papl45_sl60stl1,
                  sum(ripa5_sl60stl1) as ripa5_sl60stl1, sum(ripa45_sl60stl1) as ripa45_sl60stl1,
				  sum(crbl5_sl60stl1) as crbl5_sl60stl1, sum(crbl45_sl60stl1) as crbl45_sl60stl1
                  from fout_sl60_stl1
                  group by cl_n, sjr_cl, dch_n, ln_pr, bew_vn;
quit;
/*linken met matm voor vorige lijn*/
proc sql;
create table fout_sl60_stl1_3 as select A.*, round(B.di,0.1) as dikte_sl60stl1, round(B.br,250) as sl60stl1_breedte, B.ln_pr_vr as sl60stl1_ln_pr_vr, B.ln_pr_vl as sl60stl1_ln_pr_vl
from fout_sl60_stl1_2 A LEFT JOIN &lbn..matm (keep= sjr_Cl cl_n dch_n bew_vn di br ln_pr ln_pr: where=(ln_pr in ('SL60','STL1'))) B   
ON A.sjr_cl = B.sjr_cl
AND A.cl_n = B.cl_n
AND A.dch_n =b.dch_n
AND A.bew_vn = B.bew_vn;
quit;
endrsubmit;

/*link is niet perfect omwille van dochternummer; dit worden missings*/
rsubmit;
proc sql; create table data92 as select A.*, B.* from data91 A LEFT JOIN fout_sl60_stl1_3 (where=(sl60stl1_ln_pr_vr in ('KW1','SKP1'))) B
ON A.sjr_cl = B.sjr_cl
AND A.cl_n = B.cl_n
AND A.dikte=B.dikte_sl60stl1
AND ((B.bew_vn between A.bew_vn+2 and A.bew_vn+3) or sl60stl1_ln_pr_vr = 'KW1') ;
quit;
endrsubmit;

/*file uitkuisen*/
rsubmit;
data data10 (drop = ts_kr us_kr ts_wz us_we ts_kr_sa ts_wz_sa
                    K_FI_cl K_FI_ln F_tpap F_cilpol F_breuk LE_deft le_defb le_defe
                    a_pasth t_pr t_prth wtd po
                    a_def tl_cl1 - tl_cl5
                    f_lstk dia_kok
					pama5_skp 
					pama45_skp
					papl5_skp 
					papl45_skp
					ripa5_skp 
					ripa45_skp);
set data92 ;
verhouding_tpr_tprth = t_pr/t_prth;
/*dubels door ineenklappen eruit: if sli5 GE 1 then sli5 = 1; else sli5=0;*/
if pama_kl45   GE 1 then  pama_kl45  	=1; else  pama_kl45  	=	0;		
if deuk_kl45   GE 1 then  deuk_kl45  	=1; else  deuk_kl45  	=	0;		
if deuk_kl5    GE 1 then  deuk_kl5   	=1; else  deuk_kl5   	=	0;		
if aanh_kl45   GE 1 then  aanh_kl45  	=1; else  aanh_kl45  	=	0;		
if aanh_kl5    GE 1 then  aanh_kl5   	=1; else  aanh_kl5   	=	0;		
if AANH4_kl45  GE 1 then  AANH4_kl45 	=1; else  AANH4_kl45 	=	0;		
if AANH4_kl5   GE 1 then  AANH4_kl5  	=1; else  AANH4_kl5  	=	0;		
if AANH5_kl45  GE 1 then  AANH5_kl45 	=1; else  AANH5_kl45 	=	0;		
if AANH5_kl5   GE 1 then  AANH5_kl5  	=1; else  AANH5_kl5  	=	0;		
if AANH45_kl45 GE 1 then  AANH45_kl45	=1; else  AANH45_kl45	=	0;		
if AANH45_kl5  GE 1 then  AANH45_kl5 	=1; else  AANH45_kl5 	=	0;		
if METF_kl45   GE 1 then  METF_kl45   	=1; else  METF_kl45   	=	0;		
if METF_kl5    GE 1 then  METF_kl5    	=1; else  METF_kl5    	=	0;		
if AANH78_kl45 GE 1 then  AANH78_kl45 	=1; else  AANH78_kl45 	=	0;		
if AANH78_kl5  GE 1 then  AANH78_kl5  	=1; else  AANH78_kl5  	=	0;		
if AANH7_kl45  GE 1 then  AANH7_kl45  	=1; else  AANH7_kl45  	=	0;		
if AANH7_kl5   GE 1 then  AANH7_kl5   	=1; else  AANH7_kl5   	=	0;		
if AANH8_kl45  GE 1 then  AANH8_kl45  	=1; else  AANH8_kl45  	=	0;		
if AANH8_kl5   GE 1 then  AANH8_kl5   	=1; else  AANH8_kl5   	=	0;		
if APNT_kl45   GE 1 then  APNT_kl45   	=1; else  APNT_kl45   	=	0;		
if APNT_kl5    GE 1 then  APNT_kl5    	=1; else  APNT_kl5    	=	0;		
if ABRD_kl45   GE 1 then  ABRD_kl45   	=1; else  ABRD_kl45   	=	0;		
if ABRD_kl5    GE 1 then  ABRD_kl5    	=1; else  ABRD_kl5    	=	0;		
if baan_kl45   GE 1 then  baan_kl45   	=1; else  baan_kl45   	=	0;		
if baan_kl5    GE 1 then  baan_kl5    	=1; else  baan_kl5    	=	0;		
if ridi_kl45   GE 1 then  ridi_kl45   	=1; else  ridi_kl45   	=	0;		
if ridi_kl5    GE 1 then  ridi_kl5    	=1; else  ridi_kl5    	=	0;		
if ridi_kl45_ne2  GE 1 then ridi_kl45_ne2	 =1; else ridi_kl45_ne2	 =0;	
if ridi_kl5_ne2   GE 1 then ridi_kl5_ne2	 =1; else ridi_kl5_ne2	 =0;	  
if ridi_kl45_ne3  GE 1 then ridi_kl45_ne3	 =1; else ridi_kl45_ne3	 =0;		
if ridi_kl5_ne3   GE 1 then ridi_kl5_ne3	 =1; else ridi_kl5_ne3	 =0;	  
if ridi_kl45_ne23 GE 1 then ridi_kl45_ne23	 =1; else ridi_kl45_ne23 =0; 	
if ridi_kl5_ne23  GE 1 then ridi_kl5_ne23	 =1; else ridi_kl5_ne23	 =0;	
if SLI_kl45  	 GE 1 then  SLI_kl45  		 =1; else SLI_kl45  	 =0;	
if SLI_kl5   	 GE 1 then  SLI_kl5   		 =1; else SLI_kl5   	 =0;	
if mbrk_kl45 	 GE 1 then  mbrk_kl45 		 =1; else mbrk_kl45 	 =0;	
if mbrk_kl5   	 GE 1 then  mbrk_kl5   		 =1; else mbrk_kl5   	 =0;
if cdig_kl45 	 GE 1 then  cdig_kl45 		 =1; else cdig_kl45 	 =0;	
if cdig_kl5 	 GE 1 then  cdig_kl5 		 =1; else cdig_kl5 		 =0;	
if cbrk_kl45  	 GE 1 then  cbrk_kl45  		 =1; else cbrk_kl45  	 =0;
if cbrk_kl5   	 GE 1 then  cbrk_kl5   		 =1; else cbrk_kl5   	 =0;
if slkr_kl45  	 GE 1 then  slkr_kl45  		 =1; else slkr_kl45  	 =0;
if slkr_kl5   	 GE 1 then  slkr_kl5   		 =1; else slkr_kl5   	 =0;
if orperuw_kl45  GE 1 then  orperuw_kl45	 =1; else orperuw_kl45	 =0;	
if orperuw_kl5   GE 1 then  orperuw_kl5 	 =1; else orperuw_kl5 	 =0;	
if orpe_kl45 	 GE 1 then  orpe_kl45 		 =1; else orpe_kl45 	 =0;	
if orpe_kl5  	 GE 1 then  orpe_kl5  		 =1; else orpe_kl5  	 =0;	
if ropi_kl45 	 GE 1 then  ropi_kl45 		 =1; else ropi_kl45 	 =0;	
if ropi_kl5  	 GE 1 then  ropi_kl5  		 =1; else ropi_kl5  	 =0;	
if lin4_kl45 	 GE 1 then  lin4_kl45 		 =1; else lin4_kl45 	 =0;	
if lin4_kl5  	 GE 1 then  lin4_kl5  		 =1; else lin4_kl5  	 =0;	
if ruw_kl45  	 GE 1 then  ruw_kl45  		 =1; else ruw_kl45  	 =0;	
if ruw_kl5   	 GE 1 then  ruw_kl5   		 =1; else ruw_kl5   	 =0;	
if krk_kl45  	 GE 1 then  krk_kl45  		 =1; else krk_kl45  	 =0;	
if krk_kl5   	 GE 1 then  krk_kl5   		 =1; else krk_kl5   	 =0;	
if poch_kl45 	 GE 1 then  poch_kl45 		 =1; else poch_kl45 	 =0;	
if poch_kl5  	 GE 1 then  poch_kl5  		 =1; else poch_kl5  	 =0;	
if post_kl45 	 GE 1 then  post_kl45 		 =1; else post_kl45 	 =0;	
if post_kl5  	 GE 1 then  post_kl5  		 =1; else post_kl5  	 =0;	
if crch_kl45 	 GE 1 then  crch_kl45 		 =1; else crch_kl45 	 =0;	
if crch_kl5  	 GE 1 then  crch_kl5  		 =1; else crch_kl5  	 =0;	
if disc_kl45 	 GE 1 then  disc_kl45 		 =1; else disc_kl45 	 =0;	
if disc_kl5  	 GE 1 then  disc_kl5  	 	 =1; else disc_kl5  	 =0;
if clbo_kl45 	 GE 1 then  clbo_kl45 		 =1; else clbo_kl45 	 =0;	
if clbo_kl5  	 GE 1 then  clbo_kl5  	 	 =1; else clbo_kl5  	 =0;


/*uitgewalste deuk of deuk laatste pas*/
if deuk_kl45  GE 1 and abs(deuk_kl45_rep - dia_cil_l*3.141592) LE 15 then deuk_kl45_lp  =1; else  deuk_kl45_lp 	=	0;		
if deuk_kl45  GE 1 and abs(deuk_kl45_rep - dia_cil_l*3.141592) > 15 then  deuk_kl45_u  =1; else  deuk_kl45_u  	=	0;
if deuk_kl5   GE 1 and abs(deuk_kl5_rep - dia_cil_l*3.141592) LE 15 then deuk_kl5_lp  	=1; else  deuk_kl5_lp 	=	0;		
if deuk_kl5   GE 1 and abs(deuk_kl5_rep - dia_cil_l*3.141592) > 15 then  deuk_kl5_u  	=1; else  deuk_kl5_u  	=	0;

/*juiste kant bepalen van (uitgewalste) DEUK
  OPGELET DIT IS BIJ BENADERING !!!!!!!!!!!*/
deuk_kl5corr5 = 0;
deuk_kl5corr10 = 0;
format deuk_kl5corr5pas deuk_kl5corr5pas $4.;

if deuk_kl5   GE 1 then do;
	if abs(deuk_kl5_rep - dia_cil_l*3.141592) LE 5 					 then do; deuk_kl5corr5  	=1; deuk_kl5corr5pas = 'lp'; end;
	if abs(deuk_kl5_rep - di_vl/di_l *   dia_cil_vl*  3.141592) LE 5 then do; deuk_kl5corr5  	=1; deuk_kl5corr5pas = 'vl'; end;
	if abs(deuk_kl5_rep - di_vvl/di_l *  dia_cil_vvl* 3.141592) LE 5 then do; deuk_kl5corr5  	=1; deuk_kl5corr5pas = 'vvl'; end;
	if abs(deuk_kl5_rep - di_vvvl/di_l * dia_cil_vvvl*3.141592) LE 5 then do; deuk_kl5corr5  	=1; deuk_kl5corr5pas = 'vvvl'; end;

	if abs(deuk_kl5_rep - dia_cil_l*3.141592) LE 10 				  then do; deuk_kl5corr10  	=1; deuk_kl5corr10pas = 'lp'; end;
	if abs(deuk_kl5_rep - di_vl/di_l *   dia_cil_vl*  3.141592) LE 10 then do; deuk_kl5corr10  	=1; deuk_kl5corr10pas = 'vl'; end;
	if abs(deuk_kl5_rep - di_vvl/di_l *  dia_cil_vvl* 3.141592) LE 10 then do; deuk_kl5corr10  	=1; deuk_kl5corr10pas = 'vvl'; end;
	if abs(deuk_kl5_rep - di_vvvl/di_l * dia_cil_vvvl*3.141592) LE 10 then do; deuk_kl5corr10  	=1; deuk_kl5corr10pas = 'vvvl'; end;

end; 

breedte_surplus = br-breedte-lamiQC-lamiNQC;

/*missings door link op dch, krijgen nu mogelijks PAMA = 0 !!!!!!!!!!!!!!!!!!!!!*/
/*we moeten deze stap doen om de missings (geen fouten) op 0 te krijgen, anders problemen met analyse*/
if pama5_skp  GE 1 then pama5_skp1  = 1; else pama5_skp1  = 0; 
if pama45_skp GE 1 then pama45_skp1 = 1; else pama45_skp1 = 0;
if papl5_skp  GE 1 then papl5_skp1  = 1; else papl5_skp1  = 0;
if papl45_skp GE 1 then papl45_skp1 = 1; else papl45_skp1 = 0;
if ripa5_skp  GE 1 then ripa5_skp1  = 1; else ripa5_skp1  = 0;
if ripa45_skp GE 1 then ripa45_skp1 = 1; else ripa45_skp1 = 0;

/*we doen hier geen else om enkel de coils te hebebn die door SL60/STL1 zijn gegaan*/
if pama5_sl60stl1  GE 1 then pama5_sl60stl1  = 1; *else pama5_sl60stl1  = 0; 
if pama45_sl60stl1 GE 1 then pama45_sl60stl1 = 1; *else pama45_sl60stl1 = 0;
if papl5_sl60stl1  GE 1 then papl5_sl60stl1  = 1; *else papl5_sl60stl1  = 0;
if papl45_sl60stl1 GE 1 then papl45_sl60stl1 = 1; *else papl45_sl60stl1 = 0;
if ripa5_sl60stl1  GE 1 then ripa5_sl60stl1  = 1; *else ripa5_sl60stl1  = 0;
if ripa45_sl60stl1 GE 1 then ripa45_sl60stl1 = 1; *else ripa45_sl60stl1 = 0;
run;
endrsubmit;




/*glans SKP toevoegen*/
/*8/5/2014 de flag knt_bb moet van de dochters komen omdat die op de moeders altijd T is
  vandaar dat we de distinct doen en a_dch=0 nemen (enkel de dochters)
  de order by is blijkbaar nodig om enkele dubbels te vermijden
 (bv 34155020 2x in data10, 2x in data11 met link op dochters, maar 4x in data 11 zoals nu*/
rsubmit;
proc sql;
create table data11 as select distinct A.*, B.ts_be as ts_be_skp1, B.ts_ei as ts_ei_skp1, (B.ts_ei - B.ts_be) As Skp_tijd,
											year(B.date_ts_be)*100+month(B.date_ts_be) As jaar_maand_skp,
											B.knt_BB as knt_bb_skp1, B.wrk_n as wrk_n_skp1
from data10 A LEFT JOIN 
	&lbn..matm 
	(keep = sjr_cl cl_n dch_n bew_vn ln_pr a_dch ts_be ts_ei date_ts_be knt_bb wrk_n 
     where=(ln_pr = 'SKP1' and date_ts_Be GE intnx('year',today(),-&aantaljaarterug,'begin'))) B
ON A.sjr_cl = B.sjr_cl
AND A.cl_n = B.cl_n
AND A.bew_vn+1 = B.bew_vn
AND B.a_dch = 0
ORDER by A.sjr_cl, A.cl_n, A.dch_n, A.bew_vn, A.ts_be;
quit;

data data12;
set data11;
if knt_bb_skp1 = 'T' then kant_balskp = 'B'; else kant_balskp = 'T';
if knt_bb_skp1 = 'T' then ondw_skp=0; else ondw_skp=1;
SKP_jaar = year(datepart(ts_be_skp1));
SKP_maand = month(datepart(ts_be_skp1));
run;
endrsubmit;
rsubmit;
data glans_skp (keep = sjr_cl cl_n ln_pr bew_vn_skp1 dch_n_skp1 k_bew_skp1 wrk_insp_skp1 di_insp1 di_insp2 di_insp3
                  glansT glansT_B glansT_M glansT_E glansT_apas glansT1_B glansT1_M glansT1_E
                  glns_om1 - glns_om3);
set &lbn..kwalm (where=(ln_pr = 'SKP1' and sjr_cl GE '2010'));
bew_vn_skp1 = bew_vn;
dch_n_skp1 = dch_n;
k_bew_skp1 = k_bew;
wrk_insp_skp1 = wrk_insp;
di_insp1 = di_1;
di_insp2 = di_2;
di_insp3 = di_3;

glansT=glns_top;
/*glans na 1 pas indien beschikbaar
  = altijd linkse kolom, maar enkel als pasnr=1*/
if glns_TB1 GE 100 AND compress(glns_om1) = '1' then do;
    glansT1_B=glns_TB1;
    glansT1_M=glns_TM1;
    glansT1_E=glns_TE1;
    end;
/*glans na laatste pas + aantal passen*/
if glns_TB3 GE 100 then do;
    glansT_B=glns_TB3;
    glansT_M=glns_TM3;
    glansT_E=glns_TE3;
    if compress(glns_om3) GE '5' then glansT_apas=0+compress(glns_om3); else glansT_apas=5;
    end;
else if glns_TB2 GE 100 then do;
    glansT_B=glns_TB2;
    glansT_M=glns_TM2;
    glansT_E=glns_TE2;
    if compress(glns_om2) GE '3' then glansT_apas=0+compress(glns_om2); else glansT_apas=3;
    end;
else do;
    glansT_B=glns_TB1;
    glansT_M=glns_TM1;
    glansT_E=glns_TE1;
    if compress(glns_om1) GE '1' then glansT_apas=0+compress(glns_om1); else glansT_apas=1;
    end;
run;
endrsubmit;
rsubmit;
proc sql;
create table data13 as select A.* , B.* from data12 A LEFT JOIN glans_skp B
ON  A.sjr_cl = B.sjr_cl
AND A.cl_n = B.cl_n
AND A.bew_vn+1 = B.bew_vn_skp1
AND A.dch_n = B.dch_n_skp1
AND A.kant = A.kant_balskp;
quit;
endrsubmit;





/*opkuisen en berekenen interessante velden*/
rsubmit;
data data14 ;
set data13;
if di < 0.75 or (di < 1.25 and di_be < 2.75) then koker2 = 1; else koker2 = 0;
if substr(compress(pw_breedte),1,1) = "7" then pw_breedte2 = 700;
else if substr(compress(pw_breedte),1,1) = "7" then pw_breedte2 = 800;
else if substr(compress(pw_breedte),1,2) = "10" then pw_breedte2 = 1020;
else if substr(compress(pw_breedte),1,2) = "12" then pw_breedte2 = 1260;
else if substr(compress(pw_breedte),1,2) = "14" then pw_breedte2 = 1400;
else if substr(compress(pw_breedte),1,2) = "15" then pw_breedte2 = 1500;
else pw_breedte2 = .;
atype=k_nm_atp !! k_atp;
dikte_begin = round(di_be,0.1);
red = round(di_be,0.1) !! ' -> ' !! strip(dikte);
reductie = 100*(di_be - di)/di_be;
if (br_be_bew - breedte) in (18,19,20) then voorgeslit_1820 = 1;
else if 35 <= (br_be_bew - breedte) <= 70 then voorgeslit_1820 = 0;
else voorgeslit_1820 = .;
di_be_di_ei = dikte_be !! ' ' !! dikte;
dagen_crmbal = ts_be - ts_be_crm;
dagen_skpbal = ts_be_skp1 - ts_be;
if glansT LE 100 or glansT GE 1250 then glansT = .;
if glansT_apas = 0 or glansT_apas GE 10 then glansT_apas = .;
if kleur_b LE 1 or kleur_b GE 8 then kleur_b = .;
if glans LE 50 or glans GE 1250 then glans = .;
if glans_M2 LE 50 or glans_M2 GE 1250 then glans_M2 = .;

run;
endrsubmit;



/*analyse & me toevoegen*/
/*me*/
rsubmit;
proc sql;
create table data15 as select A.*, B.str_02a1 as s02, B.brk_a1 as Rm, B.vln_a1 as A , B.Krl , B.hrd_a1 as hardheid
from data14 A LEFT JOIN &lbn..teststm (where=(K_afw = '30')) B
ON A.sjr_cl = B.sjr_cl
AND A.cl_n = B.cl_n
and A.tt_dl_n = B.tt_dl_n
and round(A.di,0.20)= round(B.di,0.20);
quit;
/*analyse moet uit analchem komen anders hebben we die pas als me bepaald zijn = te laat*/
proc sql;
create table data151 as select distinct A.*, 
                B.ch_c_kw as c, B.ch_mn_kw as mn , B.ch_p_kw as p , B.ch_s_kw as s , B.ch_si_kw as si, B.ch_cr_kw as cr,
                B.ch_ni_kw as ni, B.ch_mo_kw as mo , B.ch_cu_kw as cu , B.ch_ti_kw as ti,
                B.ch_co_kw as co, B.ch_n2_kw as n, B.ch_al_kw as al , B.ch_df_gi as df, B.kaltenh, B.ch_bf_kw, B.ch_an_kw, 
				B.ch_14_kw as Nb, B.ch_15_kw as Pb, B.ch_16_kw as Sn, B.ch_18_kw as B, B.ch_19_kw as Ca
from data15 A LEFT JOIN &lbn..analchem B
ON A.sjr_cl = B.sjr_cl
AND A.cl_n = B.cl_n;
quit;
endrsubmit;

/*gloeicurve, k-waard + geleidbaarheid ontvetting + eindspoeling toevoegen*/
/*wegens probleem met &lbn..bal1 lezen we tijdelijk uit kw.bal1*/
rsubmit;
proc sql; create table data16 as select A.*, B.* from data151 A LEFT JOIN 
		kw.bal1 (keep = gl_krv KWRD: gl_otv: gl_ei: sjr_cl cl_n dch_n bew_vn ) B
on A.sjr_cl = B.sjr_cl
and A.cl_n = B.cl_n
and A.dch_n = B.dch_n
and A.bew_vn = B.bew_vn;
quit;
endrsubmit;

/*rsubmit;
proc sql; create table data16 as select A.*, B.* from data151 A LEFT JOIN 
		kw.bal1 (keep = gl_krv KWRD: gl_otv: gl_ei: sjr_cl cl_n dch_n bew_vn date_ts_be
				 where = (date_ts_Be GE intnx('year',today(),-4,'begin') )) B
on A.sjr_cl = B.sjr_cl
and A.cl_n = B.cl_n
and A.dch_n = B.dch_n
and A.bew_vn = B.bew_vn;
quit;
endrsubmit;
*/

/*ordergegevens van strengste klasse toevoegen*/
rsubmit;
data haffek1;
set &lbn..histaffect (keep = cl_n sjr_cl dch_n bew_vn ln_pr kl_n bs_n it_n ID_N_BST VN_BBIT ref_oper_opera where=(ln_pr = 'BAL1'));
run;
endrsubmit;


rsubmit;
%let node=amse-dwh-prd-bi.appliarmony.net 1473;
options comamid = tcp remote = node;    
%let tcpsec = ARMONY\SYS-SAS.maiaP@ssw0rd; 
signon node;

libname remwork remote server=node slibref=work;
libname remuser server=node slibref=sasuser;

rsubmit;
  %let node2=amse-dwh-prd-bi.appliarmony.net 1473;
  options comamid = tcp remote = node2;    
  %let tcpsec = ARMONY\SYS-SAS.maiaP@ssw0rd; 
  signon node2;

  libname biwork remote server=node2 slibref=work;
  libname biuser server=node2 slibref=sasuser;

  libname DETORD     "u:\ARCELORDWH\Ordering\detail_tables";
  libname DocFlow    "u:\arcelordwh\Documents_Flow";
  libname DETINV     "u:\ARCELORDWH\Invoicing\detail_tables";
endrsubmit;
libname biwork server=node slibref=biwork;
libname biuser server=node slibref=biuser;

libname DETORD  server=node slibref=detord;
libname DocFlow server=node slibref=DocFlow;
libname DETINV  server=node slibref=DETINV;
endrsubmit;

libname DETORD  server=node slibref=detord;
libname DocFlow server=node slibref=DocFlow;
libname DETINV  server=node slibref=DETINV;

rsubmit;
proc sql;
CREATE table haffek2 AS select distinct A.*, B.*
  FROM haffek1 A LEFT JOIN detord.ordering_general
							(keep = 
							order_ref_oper_opera order_nr order_item_nr
							order_cust_nr_sold_to_party order_cust_name_sold_to_party
							order_application 
							order_segment_desc
							order_market_desc
							order_application_desc
							order_plant
							order_finish_surface_family
							where = (order_plant = 'GK01' /*and order_finish_surface_family = '2R'*/)) B
  on  A.ref_oper_opera = B.order_ref_oper_opera;
QUIT;
proc sql;
create table haffek2a as select A.*, B.* from haffek2 A LEFT JOIN cd_dwh.item (keep = item_nr_opera id id_bs sjr_b it_n bs_n id_nr_bst K_end K_endbst K_klasma kl_n) B
ON A.id_n_bst= B.id_nr_bst and ('00000'||A.kl_n) = B.kl_n and A.bs_n  = B.bs_n and A.it_n = B.it_n;
quit;
/*hou de RANDOM APPLICATIE OVER (of de strengste klasse ??) en ook klas1*/
data haffek2b;
set haffek2a;
ran=ranuni(2563);
/*rimex opvolging*/
if kl_n = '59799' then rimex = 1; else rimex=0;
/*rational opvolging*/
if kl_n IN ('00138','08457','59991') and order_application  = 'S04M02AP12' then rational=1; else rational = 0;
if substr(k_klasma,1,1) = '1' or substr(k_klasma,2,1) = '1' then klas1 = 1; else klas1=0;
run;
/*eerste waarde*/
proc sort data=haffek2b; by sjr_cl cl_n bew_vn dch_n ran; run;
data haffek31;
set haffek2b (drop=klas1);
by sjr_cl cl_n bew_vn dch_n ran;
if first.sjr_cl or first.cl_n or first.bew_vn or first.dch_n then output;
run;
/*voor klas 1, rational, rimex: max*/
proc sql; create table haffek32 as select sjr_cl, cl_n, bew_vn, dch_n, max(klas1) as klas1, max(rimex) as rimex, max(rational) as rational from haffek2b group by sjr_cl, cl_n, bew_vn, dch_n; quit;
/*samenzetten*/
proc sql; create table haffek3 as select A.*, B.* from haffek31 A,haffek32 B 
where A.sjr_cl=B.sjr_cl and A.cl_n = B.cl_n and A.bew_vn = B.bew_vn and A.dch_n = B.dch_n; 
quit;
endrsubmit;



rsubmit;
proc sql; create table data17 as select A.*, B.* from data16 a LEFT JOIN haffek3 B
on A.sjr_cl = B.sjr_cl
and A.cl_n = B.cl_n
and A.dch_n = B.dch_n
and A.bew_vn = B.bew_vn;
quit;
endrsubmit;

/*BUL3 parameters toevoegen*/
%include 'r:\progs\bul3_parameters.sas';

rsubmit;
proc sort data=data1;
by sjr_cl cl_n dch_n ts_be_bul3;
run;
endrsubmit;
rsubmit;
data data2;
format ts_be_bul3 datetime19.;
set data1;
if lag(cl_n)=cl_n and lag(dch_n)=dch_n then delete;
luchtY_P50 = median(luchtY01-luchtY13);
gasY_p50= median(gasY01-gasY13);
gas_P50=median(gas01-gas13);
lambda_P50 = median(l01-l13);
if v06 - v_mn06 GE 5 then bul3_glr6_elbu5 = 1; else bul3_glr6_elbu5 = 0;
run;
/*ruwheden BUL3 toevoegen*/
proc sql; create table data3 as SELECT A.*, B.WRK_INSP AS BUL_wrk_insp, B.rwh_top, B.rwh_bot, B.rwh_rz_top, B.rwh_rz_bot, B.hrd As BUL3_hardheid
          FROM 	data2 A LEFT JOIN &lbn..kwalm (keep = cl_n sjr_cl dch_n bew_vn hrd WRK_INSP rwh: ln_pr where=(LN_PR = 'BUL3' AND rwh_top < 10 AND rwh_bot < 10)) B
          ON A.sjr_cl=B.sjr_cl
          AND A.dch_n = B.dch_n
          AND A.bew_vn = B.bew_vn
          AND A.cl_n = B.cl_n;
quit; 
/*vorige lijn en volgende lijn BUL3 toevoegen*/
proc sql; create table data4 as select A.*, B.ln_pr_vr as BUL3_ln_pr_vr, B.ln_pr_vl as BUL3_ln_pr_vl  from data3 A LEFT JOIN &lbn..matm (keep=cl_n sjr_cl dch_n bew_vn ln_pr: where=(ln_pr = 'BUL3')) B
          ON A.sjr_cl=B.sjr_cl
          AND A.dch_n = B.dch_n
          AND A.bew_vn = B.bew_vn
          AND A.cl_n = B.cl_n;
quit; 
/*afhaspel en ophaspel nummers toevoegen*/
proc sql; create table data5 as select A.*, B.ophasp_n AS BUL3_ophaspel, B.afhasp_n as BUL3_afhaspel  from data4 A LEFT JOIN &lbn..bulm (keep=cl_n sjr_cl dch_n bew_vn ln_pr: afhasp_n ophasp_n where=(ln_pr = 'BUL3')) B
          ON A.sjr_cl=B.sjr_cl
          AND A.dch_n = B.dch_n
          AND A.bew_vn = B.bew_vn
          AND A.cl_n = B.cl_n;
quit; 
endrsubmit;
rsubmit;
proc sql;
create table data18 (drop= rwh_top rwh_bot rwh_rz_top rwh_rz_bot) as select distinct A.*, B.*,
				case when A.kant = 'T' then b.rwh_top
                     when A.kant = 'B' then b.rwh_bot end as BUL3_Ra,
				case when A.kant = 'T' then b.rwh_rz_top
                     when A.kant = 'B' then b.rwh_rz_bot end as BUL3_Rz
from data17 A LEFT JOIN data5 B
on A.sjr_cl = B.sjr_cl
and A.cl_n = B.cl_n
and round(A.di_be,1) = round(B.dikte,1);
quit;
endrsubmit;

/*warmwals parameters toevoegen*/
rsubmit;
data wwca /*(keep=  sjr_cl cl_n ID_oven  DUUR_TEMP_B1150 descaling fl_tunnel_vwals cylinder_nr_r1_top cylinder_nummer_r1_bot
                  temp_voorplak temp_uit_einds code_sproeikoeling temp_ophaspelen ID_haspel cilkooi1 cilkooi5 cilkooi6 ts_eindstraat)*/;
set &lbn..wwua (where=(year(datepart(ts_eindstraat)) GE 2010));
cilkooi1 = input(SUBSTR(ID_CYLINDER_TOP_1,3,1) !! SUBSTR(ID_CYLINDER_BOT_1,3,1),2.0);
cilkooi5 = input(SUBSTR(ID_CYLINDER_TOP_5,3,1) !! SUBSTR(ID_CYLINDER_BOT_5,3,1),2.0);
cilkooi6 = input(SUBSTR(ID_CYLINDER_TOP_6,3,1) !! SUBSTR(ID_CYLINDER_BOT_6,3,1),2.0);
if fl_descaling_exit not IN ('N','',' ','.') or fl_descaling_vwals not IN ('N','',' ','.') then descaling=1; else descaling=0;
run;
endrsubmit;

rsubmit;
proc sql;
create table data19 as select A.*, B.* from data18 A LEFT JOIN wwca B on A.sjr_cl = B.sjr_cl and A.cl_n = B.cl_n;
quit;
endrsubmit;

/*tijdelijk ingebouwd*/
rsubmit;
data data20;
set data19;
if datepart(TS_BE_CRM) GE '09MAY2015'd and datepart(TS_BE_CRM) LE '09JUN2015'd then doorwalsen=0; else doorwalsen = 1;
if order_cust_nr_sold_to_party = '0000100052' and order_application = 'S04M02AP12' and Atype6 = '90.3045' then rational = 1; else rational = 0;
if K_ATP in ('4300','4410') then do;
	if K_waarde_mn = 0 or remanenz_mx GE 75 then ferr_fust = 1; else ferr_fust = 0;
    if K_waarde < 20 or remanenz_mx GE 55 or remanenz_sd GE 7.5 then ferr_uitg = 1; else ferr_uitg = 0;
	end;
if K_ATP in ('3041','3045','3161') then do;
	if K_waarde_mn = 0 then aust_fust = 1; else aust_fust = 0;
	if K_waarde_mn > 0 and K_waarde_mn LE 5 then aust_uitg = 1; else aust_uitg = 0; 
	end;

/*berekende b-waarde*/
b_calc = 2.35 + 0.226*mn+0.01635*br/1000*snelheid;

/*periodes BAL*/
     if (datepart(ts_be) GE '13JAN2016'd and datepart(ts_be) LE '18FEB2016'd) then periode = 'H2 debiet +50m3/uur      ';
else if (datepart(ts_be) GE '19JAN2016'd and datepart(ts_be) LE '21JAN2016'd) then periode = 'H2 max 150m3/uur vrieskou';
else if (datepart(ts_be) GE '22JAN2016'd and datepart(ts_be) LE '27JAN2016'd) then periode = 'H2 debiet +50m3/uur';
else if (datepart(ts_be) GE '28JAN2016'd and datepart(ts_be) LE '04FEB2016'd) then periode = 'bypas mogelijks op max';
else if (datepart(ts_be) GE '10FEB2016'd and datepart(ts_be) LE '12FEB2016'd) then periode = 'bypas 180m3/uur';
else if (datepart(ts_be) GE '13FEB2016'd and datepart(ts_be) LE '19FEB2016'd) then periode = 'bypass op 100m3/uur';
else if (datepart(ts_be) GE '20FEB2016'd) then periode = 'bypass UIT';
else periode = '';

run;
proc sort data=data20;
by ts_be;
run;
endrsubmit;

PROC EXPORT DATA= remWORK.data20
            OUTFILE= "L:\data\BA_all.jmp"
            DBMS=JMP REPLACE;
RUN;




/*stilstandscodes 
  teller #coils sinds bandbreuk*/
/*
proc sql; 
create table crmbb as select A.*, B.* from qc.matm (keep = sjr_cl cl_n dch_n bew_vn ln_pr ts_be dl_n_lei dl_n_leu where=(ln_pr='CRM3' and dl_n_lei = dl_n_leu)) A
LEFT JOIN qc.stlpstm (keep = sjr_cl cl_n ln_pr bew_vn dch_n k_stil where=(ln_pr = 'CRM3' and k_stil='2201')) B
ON A.sjr_cl = B.sjr_cl
and A.cl_n = B.cl_n
and A.bew_vn = B.bew_vn;
quit;
proc sort data=crmbb;
by ts_be;
run;
data crmbb2;
set crmbb;
by ts_be; 
retain tellerbb;
if _N_ = 1 then tellerbb=0;
if k_stil = '2201' then tellerbb = 0; else tellerbb = tellerbb+1;
run;

proc sql; create table data21 as select A.*,B.tellerbb from remwork.data20 A LEFT JOIN crmbb2 B
ON A.sjr_cl = B.sjr_cl
and A.cl_n = B.cl_n
and A.dch_n = B.dch_n
and A.bew_vn-1 = B.bew_vn;
quit;

PROC EXPORT DATA= data21
            OUTFILE= "L:\data\BA_all2.jmp"
            DBMS=JMP REPLACE;
RUN;
*/





/*eventueel SKP data toevoegen*/
/*OPGELET: kiezen voor SKP per pas of algemeen*/
rsubmit;
data skp_data;
set scad.Skp1_pv_summary ;
/*set scad.SKP1_pv_per_pas_summary;*/
by ts_be_skp;
retain skp_cil_B_km skp_cil_T_km skp_pol_sinds_cw;
if lag(skp_wls_cil_B_mean) = skp_wls_cil_B_mean then do;
		skp_cil_B_km = skp_cil_B_km + skp_pasnr_P99 * le/1000;        
		end;
 		else do;
		skp_cil_B_km = 0;
		end;
if lag(skp_wls_cil_T_mean) = skp_wls_cil_T_mean then do;
		skp_cil_T_km = skp_cil_T_km + skp_pasnr_P99 * le/1000;        
		if pol_P99 NE . then skp_pol_sinds_cw = skp_pol_sinds_cw + pol_P99;
		end;
 		else do;
		skp_cil_B_km = 0;
		skp_pol_sinds_cw = 0;
		end;
if lag(K_tstmat) in ('2DA','2BA') then skp_vorige_coil_BA = 1; else  skp_vorige_coil_BA =0;
if lag(K_tstmat) in ('2D','2B')   then skp_vorige_coil_2B = 1; else  skp_vorige_coil_2B =0;
if lag(substr(K_atp,1,1))='4'     then skp_vorige_coil_ferriet = 1; else  skp_vorige_coil_ferriet =0;
if lag(K_tstmat) in ('2DA','2BA') or lag(substr(K_ATP,1,1)) = '4' then skp_vorige_coil_BA_of_ferriet = 1; else  skp_vorige_coil_BA_of_ferriet =0;
run;
proc sort data=skp_data; by ts_be_skp; run;

proc sql;
create table data21 as select distinct A.*, B.* from data20 A LEFT JOIN skp_data  B
ON A.ts_be_skp1 = B.ts_be_skp
and A.kant = A.kant_balskp;
quit;
endrsubmit;

/*berekende waardes*/
rsubmit;
data data22;
set data21;
/*contactlengte Lp = (Rcil * (dikte_in - dikte_uit) - (dikte_in-dikte_uit)^2/4)^1/2
  stel verlenging = 0.2%
                   = (D/2 * 0.998 * di - (0.998*di/2)^2)^(1/2) */
contactlengte = (skp_wls_diam_cil_B_Mean  / 2 * 0.998 * di - (0.998 * di / 2 )**2)**(0.5);  

contactlengte_omkrl_median = (skp_wls_diam_cil_B_Mean  / 2 * (1-skp_wls_verlenging_median/100) * di - ((1-skp_wls_verlenging_median/100) * di / 2 )**2)**(0.5); 
contactlengte_omkrl_P95 = (skp_wls_diam_cil_B_Mean  / 2 * (1-skp_wls_verlenging_P95/100) * di - ((1-skp_wls_verlenging_P95/100) * di / 2 )**2)**(0.5); 
contactlengte_laser_median = (skp_wls_diam_cil_B_Mean  / 2 * (1-skp_wls_verlenging_laser_median/100) * di - ((1-skp_wls_verlenging_laser_median/100) * di / 2 )**2)**(0.5); 
contactlengte_laser_P95 = (skp_wls_diam_cil_B_Mean  / 2 * (1-skp_wls_verlenging_laser_P95/100) * di - ((1-skp_wls_verlenging_laser_P95/100) * di / 2 )**2)**(0.5); 

/*verchroomde cilinder SKP*/
     if skp_wls_cil_B_P90 = 7 and (ts_be_skp1 GE '03SEP2015:00:00:00'dt and ts_be_skp1 LE '14SEP2015:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 7 and (ts_be_skp1 GE '21OCT2015:00:00:00'dt and ts_be_skp1 LE '27OCT2015:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 7 and (ts_be_skp1 GE '05DEC2015:00:00:00'dt and ts_be_skp1 LE '10DEC2015:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 9 and (ts_be_skp1 GE '19DEC2015:00:00:00'dt and ts_be_skp1 LE '06JAN2015:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 9 and (ts_be_skp1 GE '14JAN2016:00:00:00'dt and ts_be_skp1 LE '26JAN2016:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 7 and (ts_be_skp1 GE '27JAN2016:00:00:00'dt and ts_be_skp1 LE '31JAN2016:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 9 and (ts_be_skp1 GE '06FEB2016:00:00:00'dt and ts_be_skp1 LE '11FEB2016:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 7 and (ts_be_skp1 GE '18FEB2016:00:00:00'dt and ts_be_skp1 LE '20FEB2016:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 9 and (ts_be_skp1 GE '25FEB2016:00:00:00'dt and ts_be_skp1 LE '04MAR2016:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 7 and (ts_be_skp1 GE '09MAR2016:00:00:00'dt and ts_be_skp1 LE '13FEB2016:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 9 and (ts_be_skp1 GE '18MAR2016:00:00:00'dt and ts_be_skp1 LE '21MAR2016:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 9 and (ts_be_skp1 GE '30MAR2016:00:00:00'dt and ts_be_skp1 LE '31MAR2016:23:59:59'dt) then SKP_Cr_cil = 1; 

else if skp_wls_cil_B_P90 = 7 and (ts_be_skp1 GE '15APR2016:00:00:00'dt and ts_be_skp1 LE '16APR2016:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 9 and (ts_be_skp1 GE '28APR2016:00:00:00'dt and ts_be_skp1 LE '04MAY2016:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 9 and (ts_be_skp1 GE '11MAY2016:00:00:00'dt and ts_be_skp1 LE '12MAY2016:23:59:59'dt) then SKP_Cr_cil = 1; 
else if skp_wls_cil_B_P90 = 7 and (ts_be_skp1 GE '25MAY2016:00:00:00'dt and ts_be_skp1 LE '25MAY2016:23:59:59'dt) then SKP_Cr_cil = 1; 

else SKP_Cr_cil = 0; 

/*berekening contactkracht (N/mm) en walskracht (Ton) ifv bolvorm*/
/* t = tafellengte = 1620mm
   L = Lengte ts lagers = 2210mm
   E = 210000
   I = Pi/64 * Diameter^4
   contactkracht = bol/(t/2) * (L/2) * 384 * E * I * 1/br * 1/(8L^3-4L*br^2+br^3)
   walskracht = contactkracht * br / 1000
*/


/*stabilseer variantie van targets*/
log_bcalc = log(b_calc);
log_helling10 = log(skp_pw_blauwwaarde_helling10);
log_kleurb = log(kleur_b);
kleur_b_trans_minx2 = (-1) * kleur_b**(-2);
log_polmiddencoilP95=log(pol_middencoil_P95);
logpolP95=log(pol_P95);
run;
endrsubmit;

/*ontvetting toevoegen*/
libname r 'r:\data';
proc sql; create table remwork.data23 as select A.*, B.* from remwork.data22 A LEFT join r.ont3 B ON A.date_ts_be = B.datum; quit;

/*output sas viya*/
/*
libname lsv 'L:\data SAS Viya';
data lsv.BA_all_skp_ont;
set remwork.data23;
run;
*/

/*output globaal*/

 PROC EXPORT DATA= remwork.data23
            OUTFILE= "L:\data\BA_all_skp_ont.jmp"
            DBMS=JMP REPLACE;
RUN;
 PROC EXPORT DATA= remwork.data23
            OUTFILE= "R:\data\BA_all_skp_ont.jmp"
            DBMS=JMP REPLACE;
RUN;

/*output per pas*/
/*PROC EXPORT DATA= remWORK.data23
            OUTFILE= "L:\data\BA_all_skp_pas.jmp"
            DBMS=JMP REPLACE;
RUN;*/


/*zet file op dm server*/
rsubmit;
libname sdata 'x:\emdata';
endrsubmit;
rsubmit;
data sdata.glansbalall;
set data22;
/*if pol_P99 = . then delete;
if pol_middencoil_P99 LE 300 then TARGET_300 = 0; else target_300 = 1;
*/
/*OUTPUT CRITERIA*/
if K_ATP in ('3041','3045','3161')and datepart(ts_be) GE '01JAN2015'd and skp_pw_blauwwaarde_helling10 NE . then output;
run;
endrsubmit;

