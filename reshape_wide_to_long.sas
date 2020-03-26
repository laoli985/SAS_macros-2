/*********************************************************************************************************************
* filename	:	reshape_wide_to_long.sas
* author		:	Chang
* path			: 	K:\SAS_macros_chang\reshape_wide_to_long.sas
* purpose		: 	reshape wide format data to long format with 2 variables- varName and varValue
* NOTE		: 	(1) length varName must be longer than longest variable to reshape
						(2) obs output dataset is (number of variables to reshape)*(obs in input dataset)
------------------------------------------------------------------------------------------------------------------------------
Date				Update
-----------------------------------------------------------------------------------------------------------------------------------------------------------
20160524	this file is modified from K:\SAS_lessons\example_wide_to_long.sas
-----------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*data wide; 
	set sashelp.class(drop=sex);
run;
*/
%SYSMACDELETE wide2long;
%macro wide2long(data_in=
								,keep1=
								,where1=
								,varList= /*variables to reshape from wide to long*/								
								,data_out=
								,keep2= 								);
	
	%let n= %sysfunc(countw(&varList.));
	
	data &data_out.	; 
		length varName $ 30	;
		set &data_in.(keep=&keep1.	where=(&where1.))	;
		array oldVar {*} &varList.	;
			%do varIndex=1 %to &n.	;
				%let varName=  %scan(&varList., &varIndex.)	;
					varName= "&varName."	;
					varValue= oldVar(&varIndex.)	;
				output;
			%end;
		keep &keep2.;
		format varName $30.;
	run;

%mend wide2long;

/*history of calling this macro*/
/*Date		Macro call
------------------------------------------------------------------------------------------------------------
20161109		%let keepVarGp01= famID ID ZYGOSITY ;
%let keepVarGp02= AnxDep6Final_theta_13 AnxDep6Final_theta_13_15 AnxDep6Final_theta_15_17 AnxDep6Final_theta_17 PSYCH6_IRT	;
%let keepVarGp03= Fatigue6Final_theta_13 Fatigue6Final_theta_13_15 Fatigue6Final_theta_15_17 Fatigue6Final_theta_17 SOMA6_IRT	;
%let keepVarGp04= IRT_affectDisorders IRT_subsUseDisorder	;
%wide2long(data_in= out._SPNU_diag_SPbins_a 	#3118 observations read
					,keep1=  &keepVarGp01. &keepVarGp02. &keepVarGp03. &keepVarGp04.
					,where1= %str(ZYGOSITY in ('1' '2' '3' '4' '5' '6'))
					,varList= &keepVarGp02. &keepVarGp03. &keepVarGp04.
					,data_out= out._SPNU_diag_SPbins_long #37416 observations and 5 variables
					,keep2= famID ID ZYGOSITY varName varValue	);

20160524	%wide2long(data_in=out.nu_nulog_pooled_d
										,keep1=oracle_table famID ID ENDSTAT SPHERE_sum PSYCH6 SOMA6
										,where1=%str(ENDSTAT=1 and SPHERE_sum not=.)
										,varList= SPHERE_sum PSYCH6 SOMA6
										,data_out=out.nu_nulog_pooled_e
										,keep2= oracle_table famID ID ENDSTAT varName varValue
										);
-------------------------------------------------------------------------------------------------------------*/
