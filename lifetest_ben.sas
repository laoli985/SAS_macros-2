/***********************************************************************************
PROGRAM NAME : lifetest_ben.sas 
DESCRIPTION :  comparing two or 3 groups with log-rank test
PROGRAMMER : 	Ben Fanson
DATE CREATED : 19-Oct-2013
-------------------------------------------------------------------------------------------------------------
DATE 		Update
-------------------------------------------------------------------------------------------------------------
16-Oct-2013 output chi-square test result
-----------------------------------------------------------------------------------------------------------*/

*CREATE blank tables to hold the output from each loop*; * ben - set-up a blank table to add homtests into ... (run at the start of lifetest or when you want to delete table);
data	timeTo_summary_&exp_name.
		homTests_&exp_name.; 
	test='delete this observation'; 
run;

*GET log-rank test result between a treatment group and its control*;
%macro LIFETEST_ben( 	data=, 
						var=, 
						groups=, 
						group_num=);

proc sort data=&data; by exp_name replicate trt_group trt_label respType; run;

%do i = 1 %to %eval(&group_num-1);
	%do j = %eval(&i + 1) %to &group_num;
		%do k = %eval(&j + 1) %to %eval(&group_num+1);	

			proc sort data=&data ; by exp_name replicate trt_group trt_label respType ;	run;
				proc means data=&data N mean stderr;
					title 'Mean and standard error of age at first orientation, foraging and last record';
					by 		exp_name replicate trt_group trt_label respType;
					class 	exp_name replicate trt_group trt_label respType;
					var respVar;
					ods output summary=	_timeTo_summary_&exp_name.;	
				run;

			data timeTo_summary_&exp_name.; set	timeTo_summary_&exp_name.
														_timeTo_summary_&exp_name.(in=a); 
					if a then do; 	exp_name="&exp_name";
									hive="&hive";
									test='Basic measure'; end;
					if test=:'delete' then delete;
				run; 
			
			proc sort data=&data; by exp_name replicate trt_group respType; run;	/*make sure data will be sorted in the same order as required in the proc*/
			proc lifetest data=&data;
				where trt_label in ("%scan(&groups,&i)" "%scan(&groups,&j)" "%scan(&groups,&k)" );
				time &var*cenValue(1);
				by exp_name replicate trt_group respType;	
				strata trt_label;
				ods output HomTests=	_HomTests_&exp_name.;
			run;

			data homTests_&exp_name.; set	homTests_&exp_name. 
											_homTests_&exp_name.(in=a); ** ben - add in homog test info into the table for each run...;
				where test='Log-Rank';
				length exp_name $10. group_1 group_2 group_3 $7.;
				if a then do; 	*exp_name="&exp_name";
								*hive="&hive";
								data="&data";
								var="&var";
								group_1="%scan(&groups,&i)"; group_2="%scan(&groups,&j)"; group_3="%scan(&groups,&k)"; end;
				format exp_name $10. group_1 group_2 group_3 $7.;
			run; 
		%end;	
	%end;
%end;
%MEND LIFETEST_ben;

