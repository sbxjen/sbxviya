*;
libname insaslib "/tmp/viya/" access=readonly;
libname ousaslib "/tmp/v94/";
*;

%let walsen = d382=0 and d324 ge 200 and d522+d523 ge 150; *d341+d342 ge 150; /* Mode Polijsten (1=Actief) AND Bandsnelheid > 200 m/min AND Druk wals AZ + BZ > 150 ton */ 

proc sort data=ousaslib.skp1allplusKeys nodupkey;
	by cl_n bew_vn dch_n ts_registratie;
run;

data ousaslib.skp1walsplusKeys;
	set ousaslib.skp1allplusKeys;
	by cl_n bew_vn dch_n ts_registratie;
	retain _deel _x _pol _walsen 0;	/* New Key = cl_n, bew_vn, dch_n, _deel (na Polijsten) */
										/* _x = #m this coil has been rolled so far */
										/* _pol = #s Polijsten (voor deel) */
	if first.dch_n then do;				/* New coil */
		_deel 	= 0;
		_x 	= 0;
		_walsen	= 0;
	end;
	if ( d382=0 and d324 ge 200 and d522+d523 ge 150 ) then 
		do;
			*put "walsen";
			if (not _walsen) then do;	/* New deel */
				*put "not _walsen";
				_walsen = 1;
				_deel = _deel + 1;
			end;
			_dx = d324/60 * 5;			/* \Delta_x = Bandsnelheid (m/s) * 5s */ 
			_x = _x + _dx;		
			_dd524 = (d524 - lag(d524)) / _dx;
			/* These are the 5" observations we want to keep in skp1walsplusKeys */
			output;
			*put "output";
		end;
	else 
		do;
			*put "not walsen";
			if _walsen then do;			/* New Polijsten */
				*put "_walsen";
				_walsen = 0;
				_pol = 0;
			end;
			if d382 then do;
				_pol = _pol + 5;		/* Polijsten + 5s */
			end;
		end;
	drop _walsen _dx;
	*keep cl_n bew_vn dch_n ts_registratie d324 d382 d341 d342 d522 d523 d524 _deel _x _pol _dd524;
run;



/* end of program */