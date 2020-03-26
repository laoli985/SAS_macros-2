
/*this macro is not expected to be called outside this file. Just an example*/

data class; set sashelp.class; run;

%macro duplicate_var_SQL(outputlib=work
						,list=
						);
/*this part contain code that is not duplication*/
proc sql noprint;
	create table &outputlib.._test as 
		select 	*
				
/*this part generates duplicated text*/
	%let n=%sysfunc(countw(&list));
		%do i=1 %to &n;
        	%let val = %scan(&list,&i);
				,mean(&val.) as s_&val.
		%end;
			from class;
quit;
%mend duplicate_var_SQL;

%duplicate_var_SQL(list= Weight Height);
