/* "Hello World" in SAS */ 
data _null_; 
	put 'Hello world from ' _threadid_= ' on ' _hostname_=; 
run;

cas mysess sessopts=(caslib="casuser" nworkers=2) uuidmac=uuid;

%put &=uuid.;

libname mycas cas caslib="casuser";

/* "Hello World" in CAS */ 
data _null_ / sessref=mysess; 
	put 'Hello world from ' _threadid_= ' on ' _hostname_=; 
run;