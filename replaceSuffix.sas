/* Replacing Suffix on Selected Variables */
%macro	replacesuffix(lib,dsn,start,end,oldsuffix,newsuffix); 
	proc contents data=&lib..&dsn.; 
		title 'before renaming'	; 
	run; 

	data temp; 
		set &lib..&dsn.; 
	run; 

%LET ds=%SYSFUNC(OPEN(temp,i)); 
%let ol=%length(&oldsuffix.); 
%do i=&start %to &end; 
 	%let dsvn&i=%SYSFUNC(VARNAME(&ds,&i)); 
 	%let l=%length(&&dsvn&i); 
	 %let vn&i=%SUBSTR(&&dsvn&i,1,%EVAL(&l-&ol))&newsuffix.; 
%end; 

data &lib..&dsn.;
	set temp; 
	%do i=&start	%to &end; 
		&&vn&i=&&dsvn&i; 
		drop &&dsvn&i; 
	%end; 
	%let rc=%SYSFUNC(CLOSE(&ds)); 

	proc contents data=&lib..&dsn.; 
		title ' Replacing Suffix on Selected variables '; 
	run; 
%mend replacesuffix; 

*%replacesuffix(WORK,E,2,4,after,Try4); 
