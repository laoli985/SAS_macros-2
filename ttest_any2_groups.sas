/*===========================================================================================================
filename		:	ttests_any2_groups.sas
author			:	Chang
path				: 	
purpose		: 	compute a T test between any 2 groups. 
date created:	20160529
ref 				:	ODS Tables Produced by PROC TTEST
						https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_ttest_a0000000130.htm
note				:	&groups.	can contain a period
						group_3 will be blank in the output. Don't delete group_3; otherwise, an error
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Date				Update
-----------------------------------------------------------------------------------------------------------------------------------------------------------
20160529	analysed age_EQEND, SPHERE_sum, PSYCH6, SOMA6 in NU_004_create_tables.sas
20160529	attempted placing the were statement as parameter but couldn't make it.
20160529	ttest result from this macro is the same as the result from 3 proc ttest.
20160529	modified from kruWal2Groups[1].sas
__________________________________________________________________________________________________________*/


*CREATE blank tables to hold the output from each loop*;
data	ttest Equality;
		test='delete this observation';  ** ben - the first line of table will be missing.  I just add this note to remind you to delete this first row.;
run;

%sysmacdelete ttest_any2groups;

%macro ttest_any2groups(
						data_in=,
						var=, 
						groups=,
						group_num=);
	
	%do i = 1 %to %eval(&group_num-1);
		%do j = %eval(&i + 1) %to &group_num;
			%do k = %eval(&j + 1) %to %eval(&group_num+1);	

/*the default delimiters for %scan() include a period. Specify space as the only delimiter using %str( ) here*/			
				%put i=%scan(&groups,&i,%str( )) j=%scan(&groups,&j,%str( )) k=%scan(&groups,&i,%str( ));
					proc ttest 
						data=&data_in.;
						where SPHERE_sum not=. AND 
						 			oracle_table in ("%scan(&groups,&i,%str( ))" "%scan(&groups,&j,%str( ))" "%scan(&groups,&k,%str( ))" )	;
					    class oracle_table;
					    var &var.;
						ods output TTests = 	_ttests;
						ods output Equality=	_Equality;
					run;

					data ttest;
						length test $50. Variable group_1 group_2 group_3 $15. ; /*length must be set >= oracle table names*/
						set 	ttest 
								_ttests(in=a); 
						if a then 
							do;
								test='Ttest';
								group_1="%scan(&groups,&i,%str( ))"; 
								group_2="%scan(&groups,&j,%str( ))"; 
								group_3="%scan(&groups,&k,%str( ))"; 
							end;;
						if test=:'delete' then delete;
						format test $50. Variable group_1 group_2 group_3 $15. ; /*kept same as the length statement*/
					run;

					data Equality;
						length test $50. Variable group_1 group_2 group_3 $15. ; /*length must be set >= oracle table names*/
						set 	Equality
								_Equality(in=a);
						if a then 
							do;
								test='Tests for equality of variance';
								group_1="%scan(&groups,&i,%str( ))"; 
								group_2="%scan(&groups,&j,%str( ))"; 
								group_3="%scan(&groups,&k,%str( ))"; 
							end;;
						if test=:'delete' then delete;
						if probF < 0.05 then Variances='Unequal'; 
						else if probF >= 0.05 then Variances='Equal';
						format test $50. Variable group_1 group_2 group_3 $15.;  /*kept same as the length statement*/	
					run;

					proc sql; create table ttest_a as
						select 	a.Variable 	,a.ProbF,	a.group_1, a.group_2, a.group_3
									,b.Variances	,b.tValue	,b.DF	,b.Probt
							from 	Equality as a, ttest as b /*inner join*/
								where 	a.Variable=b.Variable and
											a.Variances=b.Variances	and
											a.group_1=b.group_1 and
											a.group_2=b.group_2 and
											a.group_3=b.group_3	
									;
					quit;						
			%end;
		%end;
	%end;
%mend ttest_any2groups;

/*history of calling this macro*/
/*Date			Macro call
------------------------------------------------------------------------------------------------------------
20160529	%ttest_any2groups(	data_in=out._summary	
														,var=age_EQEND 
														,groups=%NRStr(NU.NULOG NU.NULOG2 NU.NULOG3)
														,group_num=3
													);
					%ttest_any2groups(	data_in=out._summary	
														,var= SPHERE_sum 
														,groups=%NRStr(NU.NULOG NU.NULOG2 NU.NULOG3)
														,group_num=3
													);
					%ttest_any2groups(	data_in=out._summary	
														,var= PSYCH6
														,groups=%NRStr(NU.NULOG NU.NULOG2 NU.NULOG3)
														,group_num=3
													);
					%ttest_any2groups(	data_in=out._summary	
														,var= SOMA6
														,groups=%NRStr(NU.NULOG NU.NULOG2 NU.NULOG3)
														,group_num=3
													);
-------------------------------------------------------------------------------------------------------------*/
		
/*----------------------------------------------------This is the end of this program-----------------------------------------------------------------*/
/*proc ttest 
	data=out._summary(where=(SPHERE_sum not=. and oracle_table in ('NU.NULOG' 'NU.NULOG2')));
    class oracle_table;
    var age_EQEND;
	ods output TTests= _TTests_a;
	ods output Equality= _Equality_a;
run;


proc ttest 
	data=work._summary(where=(SPHERE_sum not=. and oracle_table in ('NU.NULOG2' 'NU.NULOG3')));
    class oracle_table;
    var age_EQEND;
	ods output TTests= _TTests_b;
run;

proc ttest 
	data=work._summary(where=(SPHERE_sum not=. and oracle_table in ('NU.NULOG' 'NU.NULOG3')));
    class oracle_table;
    var age_EQEND;
	ods output TTests= _TTests_c;
run;*/

