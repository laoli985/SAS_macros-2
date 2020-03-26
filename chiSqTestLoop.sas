/***********************************************************************************
PROGRAM NAME : chiSqTestLoop.sas *
DESCRIPTION :  create continegency tables and chi-square test
PROGRAMMER : 	Lun-Hsien Chang*
DATE CREATED : 13-Oct-2013
-------------------------------------------------------------------------------------------------------------
DATE 		Update
-------------------------------------------------------------------------------------------------------------
13-Oct-2013 output chi-square test result
-----------------------------------------------------------------------------------------------------------*/
*CREATE blank tables to hold the output from each loop*;
*NOTE: if you delete these two datasets manually, rerun %macro_list so first iteration won't be altered for unknown reasons*;
data	fate_&exp_name._01
		fate_&exp_name._02;  
	test='delete this observation';  ** ben - the first line of table will be missing.  I just add this note to remind you to delete this first row.;
run;

*VISUALISE shows how the macro below loops thru all the possible *;
data _loops_&exp_name.; 
	groups='ace ctrlAM met'; group_num=3; /*change groups and group_num when needed*/
	do i=1 to (group_num-1);  
		do j= i+1 to group_num ; 
			do k= j+1 to (group_num+1);
				var1=scan(groups,i);
				var2=scan(groups,j);
				var3=scan(groups,k);
				output;
			end;
		end;
	end;
run;

*MACRO to loop thru the groups specified*;
%macro chiSqTestLoop(data=, groups=, group_num=, byVar=);
	proc sort data=&data;
		by &byVar;
	run;	
	%do i = 1 %to %eval(&group_num-1);
		%do j = %eval(&i + 1) %to &group_num;
			%do k = %eval(&j + 1) %to %eval(&group_num+1);	
				%put i=%scan(&groups,&i) j=%scan(&groups,&j) k=%scan(&groups,&i);
				proc freq data=&data ;
					where	trt_label in ("%scan(&groups,&i)" "%scan(&groups,&j)" "%scan(&groups,&k)" ) and 
							FD_name in ('lost' 'orientation' 'foraging');
					by &byVar;
/*use numeric as row and column variable so won't be sorted alphabetically*/
                    tables trt_order*FD_order_rev / chisq nopercent norow nocol missprint;

					ods output CrossTabFreqs= _CrossTabFreqs&exp_name.; /*output contingency table*/
					ods output ChiSq= _ChiSq_&exp_name.; /*output ChiSquare test result*/

				run;
/*append contingency tables to this dataset*/
				data fate_&exp_name._01; set fate_&exp_name._01 
											 _CrossTabFreqs&exp_name.(in=a); /*temporary dataset, deleted at the end of code block*/
					length group_1 group_2 group_3 $7.;
					if a then do; 	*exp_name="&exp_name";
									*hive="&hive";
									test='Contingency table';
									data="&data";
									group_1="%scan(&groups,&i)"; group_2="%scan(&groups,&j)"; group_3="%scan(&groups,&k)"; end;
					if test=:'delete' then delete;
					format group_1 group_2 group_3 $7.;
				run;
/*append chisquare test result to this dataset*/
				data fate_&exp_name._02; set fate_&exp_name._02 
											 _ChiSq_&exp_name.(in=a); /*temporary dataset, deleted at the end of code block*/
					length group_1 group_2 group_3 $7.;
					if a then do; 	*exp_name="&exp_name";
									*hive="&hive";
									test='Chi-square test';
									data="&data";
									group_1="%scan(&groups,&i)"; group_2="%scan(&groups,&j)"; group_3="%scan(&groups,&k)"; end;
					if test=:'delete' then delete;
					format group_1 group_2 group_3 $7.;
				run; 
			%end;
		%end;
	%end;
%mend chiSqTestLoop;
