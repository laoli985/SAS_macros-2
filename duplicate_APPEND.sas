/*********************************************************************************************************************
* filename	: duplicate_APPEND.sas
* macro call: %duplicate_append;
* author	: Chang
* folder	: C:\SAS_macros_chang\
* purpose	:	
* NOTE		: create empty data sets first when this macro is run alone 
* ref		: 
http://stackoverflow.com/questions/18667379/simple-iteration-through-array-with-proc-sql-in-sas
http://support.sas.com/resources/papers/proceedings11/113-2011.pdf
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
16Jul2015	generated 4 PROC APPEND blocks that are used in NIS_04_subset_DX_PR.sas. PROC COMPARE showed 
	consistency between data sets generated using this macro and data sets using 4 append procedures manually typed
16Jul2015	program header copied from NIS_surveyfreq.sas
-----------------------------------------------------------------------------------------------------------------------------*/

%macro duplicate_append(outputlib=
						,list=
						);

	%let n=%sysfunc(countw(&list));
		%do i=1 %to &n;
        	%let val = %scan(&list,&i);
				proc append base=&outputlib.._NIS_&val.
							data= &val.
							force;
				run;
		%end;
%mend duplicate_append;
