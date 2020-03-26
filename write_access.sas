%let outputlib=	C:\access_databases;

/*note: local macro variable outputlib reads value from the global macro variable outputlib*/
%macro write_access(inputlib=WORK
					,inputdata=
					
					,outputtable=
					,database=);
	libname write "&outputlib.\&database.";
		proc sql; 
			drop table write.&outputtable.; 
		quit;

	  	data write.&outputtable.; 
			set &inputlib..&inputdata.; 
		run;
	libname write clear;
%mend write_access;

/*An example of how to call this macro*/
/*%write_access(inputdata= test
			,outputtable= test
			,outputlib=		
			,database= &database);
*/
