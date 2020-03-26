
%macro NIS_long2wide(ds=
					,ID_var=
					,var_ana=
					);

/*sort data by ID variable*/
	proc sort 	data= &ds.
				out= &ds._sort;
		by &ID_var.;
	run;

/*reshape a single variable from a long to a wide format
NOTE: new variables are hard-coded here
*/
	data wide_&ds.;
		set &ds._sort;
		by &ID_var.;

	/*list desired variables to be presented in the new data set in KEEP statement*/
		keep &ID_var. yr2004-yr2013;  

	/*retain the current values of the variables listed. If omitted, only the values of the 
	last var (i.e. yr2013) are placed in the new data set*/
		retain yr2004-yr2013;

	/*group the new variables in an array*/
		array yr_wide(2004:2013) yr2004-yr2013;
		if first.&ID_var.	then 
		do;
			do i= 2004 to 2013;
				yr_wide(i)=.;
			end;
		end;

	/*output values*/	
		yr_wide(year)= &var_ana.;
		if last.&ID_var. then output;
	run;  

%mend NIS_long2wide;
