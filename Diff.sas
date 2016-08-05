proc expand data=sashelp.usecon(rename=(DURABLES=x)) out=out method=none;
   id date;
   convert x = x_lag2   / transformout=(lag 2);
   convert x = x_lag1   / transformout=(lag 1);
   convert x;
   convert x = x_lead1  / transformout=(lead 1);
   convert x = x_lead2  / transformout=(lead 2);
   convert x = x_movave / transformout=(movave 3);
   convert x = x_dif1   / transformout=(dif 1);
run;

/* voorwaartse differentiatie: slechte manier                  */
/* slecht want ondersteunt geen by-groepen zonder extra coding */
/* beter is: x_voorwaartsdif1 = x - x_lead1                    */

data a;
set sashelp.usecon(keep=date durables);
set sashelp.usecon(keep=date durables rename=(durables=x) firstobs=2);
x_voorwaartsdif1 = durables - x;
run;
/* end of program */

