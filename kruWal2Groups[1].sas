/***********************************************************************************
PROGRAM NAME 	: kruWal2Groups[1].sas 
DESCRIPTION 			:  compare means of 2 samples using Kruskal-Wallis test
PROGRAMMER 		: 	Lun-Hsien Chang
NOTE							: Only one CLASS variable can be specified
DATE CREATED 		: 16-Oct-2013
PATH							: C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\kruWal2Groups[1].sas
-------------------------------------------------------------------------------------------------------------
DATE 		Update
-------------------------------------------------------------------------------------------------------------
16-Oct-2013 output chi-square test result
-----------------------------------------------------------------------------------------------------------*/

/**************************************************************************************************
 Step 2: Kruskal-Wallis test
	WILCOXON produces Kruskal-Wallis test
	NOPRINT should have suppressed the display of all outputs but Results Viewer still pops up;
			also caused this log: File WORK._KRUSKALWALLISTEST_RFID_R1R2R3.DATA does not exist.
**************************************************************************************************/	

*CREATE blank tables to hold the output from each loop*;
data	means_&exp_name._01 
		kruWalTest_&exp_name._01;
		test='delete this observation';  ** ben - the first line of table will be missing.  I just add this note to remind you to delete this first row.;
run;

%macro kruWal2Groups(	data=, 
						var=, 
						groups=,
						group_num= );

proc sort data=&data.; by repeat exp_name replicate trt_group trt_label respType ;run;
%do i = 1 %to %eval(&group_num-1);
	%do j = %eval(&i + 1) %to &group_num;
		%do k = %eval(&j + 1) %to %eval(&group_num+1);	
			%put i=%scan(&groups,&i) j=%scan(&groups,&j) k=%scan(&groups,&i);
			
				proc sort data=&data. ; by repeat exp_name replicate trt_group trt_label respType; run;
				proc means data=&data. N mean stderr;
					title 'Mean and standard error';
					by 		repeat exp_name replicate trt_group trt_label respType;
					class 	repeat exp_name replicate trt_group trt_label respType;
					var &var.;
					ods output summary=	_summary_&exp_name.;	*temporary dataset, deleted at the end of code block*;
				run;

				data means_&exp_name._01; set	means_&exp_name._01 
												_summary_&exp_name.(in=a); 
					if a then do; 	*exp_name="&exp_name";
									*hive="&hive";
									test='Basic measure'; end;
					if test=:'delete' then delete;
				run; 

				proc sort data=&data.; 
					by repeat exp_name replicate trt_group respType; 
				run; /*sort again to make sure BY-groups of sort similar to BY-groups in the proc*/ 

				proc npar1way data=&data. wilcoxon;		
					where	trt_label in ("%scan(&groups,&i)" "%scan(&groups,&j)" "%scan(&groups,&k)" );
/*NOTE: additional semicolon needed, then-condition is a complete statement, needing a semicolon. 2 in total*/
					/*%if &exclude_censored.=Y %then where cenValue=0; ;*/
					by		repeat exp_name replicate trt_group respType;
/*can specify only one CLASS variable, which the group*/
					class	trt_label;
				   	var &var.;
					ods output KruskalWallisTest= 	_KruskalWallisTest_&exp_name.; /*temporary dataset, deleted at the end of code block*/
				run;

				data kruWalTest_&exp_name._01; 
					set	kruWalTest_&exp_name._01 
						_KruskalWallisTest_&exp_name.(in=a); 
					length exp_name $10. group_1 group_2 group_3 $7. data $32.; *exclude_censored $20.;
					if a then do; 	*exp_name="&exp_name";
									*hive="&hive";
									test='Kruskal-Wallis Test';
									data="&data";
									group_1="%scan(&groups,&i)"; group_2="%scan(&groups,&j)"; group_3="%scan(&groups,&k)"; 
									*exclude_censored="&exclude_censored.";
						end;
/*error: second condition replaced by the first*/
					/*%if &exclude_censored.=Y %then %do; exclude_censored="exclude censored bees"; %end;
					%else %do; exclude_censored="include all bees"; %end;*/

					if test=:'delete' then delete;
					format exp_name $10. group_1 group_2 group_3 $7. data $32.; *exclude_censored $20.;
				run; 
		%end;
	%end;
%end;
%mend kruWal2Groups;
