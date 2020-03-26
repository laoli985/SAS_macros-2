/*********************************************************************************************************************
* filename		: summary_stat.sas
* macro call		: %summary(ds=, by_groups=, var=);	 			
* author			: Chang
* path				: "C:\SAS_macros_chang\summary_stat.sas"
* purpose			: create descriptive statistics for countinuous variables
* note				: this macro requires that numeric variables be reshaped into 2 BY-variables
* note				: BY-variables should be same attribute, otherwise convert to character before invoking macro
------------------------------------------------------------------------------------------------------------------------------
Date				Update
-------------------------------------------------------------------------------------------------------------------------------
04Jan2015	called by C:\Now\project2014_healthInsurance_taiwan\file_jenyuWang\EDvolume_03_ana.sas
10Apr2014	step05: reorder variables with RETAIN
10Apr2014	step04: replaced repetitive rounding statement with array sumStat
28Mar2014	added explanation SECTIONs macro variable, purposes and output data sets at each step 
24Mar2014	collected output from each macro invocation into a single data set summary_all
24Mar2014	added (in=a) to the temporary data set, keeping it the same as Ben's codes
21Mar2014	program header copied from tests_of_normality.sas
-----------------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION:	define macro variables
-----------------------------------------------------------------------------------------------------------------------
macro 			description 
-----------------------------------------------------------------------------------------------------------------------
ds					name of the data set to be analysed	
by_groups	BY groups
var				numeric variables to be summarised
---------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION:	define purposes and output data sets in each step
-----------------------------------------------------------------------------------------------------------------------
step	output						purposes 
-----------------------------------------------------------------------------------------------------------------------
01	summary_all			collect output from each macro invocation
02									sort data in an order of BY variable
03	_summary_&var.	output summary statistics to the temporary data set 
04	summary_&var.		round summary stat to 2 decimal places, drop automatically generated label columns
05	summary_all			collect output stat from each macro invocation, rename BY variables so output can be stacked
06	summary_all_a		customise layout, minimise style-adjusting work in MS Word 
---------------------------------------------------------------------------------------------------------------------*/

/*step01: create a blank tables to hold the output from each loop*/
data summary_all; 
	test='delete this observation';
run;

%macro summary(	ds=,
									by_groups=,
									var=	
								);
/*step02: sort data*/
	proc sort data=&ds.; by &by_groups.; run;

/*step03: create summary statistics*/
	/*for variables that follow or don't follow a normal distribution*/
	proc summary data= &ds.; 

/*PROC SUMMARY doesn't output to results viewer, saving my time to suppress the default*/
/*maxdec= effective if stat key words are in PROC SUMMARY statement. But SAS calculated default five stat even when wanted
stat keywords were specified. fuck*/
		by &by_groups.;
		var &var.;
	    output out		= 	_summary_&var.
	    	mean			=	mean_var		
			std				=	std_var		
			min				=	min_var		
			max				=	max_var		
			lclm				=	lclm_var		/*lower 95% confidence interval for mean*/
			uclm				=	uclm_var		/*upper 95% confidence interval for mean*/
			median			=	median_var	
			QRANGE	=	IQR_var		
		;
	run;

/*step04:	round variables and drop unsed variables*/
	data summary_&var.(drop= _TYPE_ _FREQ_ i); 
		set _summary_&var.;
		array sumStat{8} mean_var std_var min_var max_var lclm_var uclm_var median_var IQR_var;
		do i=1 to dim(sumStat);
			sumStat{i}= round(sumStat{i},0.01);
		end;
	run;	

/*step05:	collect output from each macro invocation*/
	data summary_all; 
		retain 	test		data	var_group1	var_group2	mean_var	std_var min_var
				 	max_var 	lclm_var 	uclm_var 	median_var	IQR_var; 
		set summary_all 
			summary_&var.(in=a);
		length var_group1 var_group2 $40.;
		if a then do;
			test='summary statistics';
			data="&ds.";
			/*replace 1st BY variable to a same-named variable "var_group1." */
			var_group1=	%scan(&by_groups.,1); 
			/*drop old variable*/
			drop %scan(&by_groups.,1);
			/*replace 2nd BY variable to a same-named variable "var_group2." */
			var_group2=	%scan(&by_groups.,2);
			/*drop old variable*/
			drop %scan(&by_groups.,2);
		end;
		if test=:'delete' then delete;
		format var_group1 var_group2 $20.;
	run;

/*step06:	reorder columns and keep distinct observations*/
proc sql; create table summary_all_a as
	select distinct test
						,data 																					label='dataSetName'
						,var_group1 																		label='var_group1'
						,var_group2 																		label='var_group2'
						,mean_var 														as	mean 		label='mean'
						,std_var 															as	SD 			label='SD'
						,(put(min_var,best.)||'-'||put(max_var,best.))	as range 		label='range'
						,(put(lclm_var,best.)||'-'||put(uclm_var,best.)) as CI95 		label='CI95'
						,median_var 													as median	label='median'
						,IQR_var															as IQR			label='IQR'
	from summary_all
		order by var_group1, var_group2;
quit;
		 
%mend summary;

