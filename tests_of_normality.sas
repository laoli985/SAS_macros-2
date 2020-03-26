/*===========================================================================================================
filename	:	tests_of_normality.sas
author		:	Chang
path			: 	"C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\tests_of_normality.sas"
purpose	: 	tests of normality of continuous variables
ref 			:	ODS tables for PROC UNIVARIATE 
						http://support.sas.com/resources/papers/proceedings11/249-2011.pdf
note			:	after data transformation, it is best if skewness is <1 and kurtosis is reduced. Kurtosis is a measure of whether the data are heavy-tailed or light-tailed relative to a normal distribution
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Date				Update
-----------------------------------------------------------------------------------------------------------------------------------------------------------
20160628	deleted BY statement. Use tests_of_normality_byGroup.sas if group processing is needed
20140312	added noprint to PROC UNIVARIATE before option normal (not working if placed after normal) to suppress default
					listing of stat and charts in the results viewer, which causes SAS to stop responding if lots of BY groups 
20140102	macro written. Analysed log10_hSpeed 
______________________________________________________________________________________________________________________________*/

/*step01: create a blank tables to hold the output from each loop*/
data work.normal; run;

%SYSMACDELETE normality;
%macro normality	(	data_in= ,var= );

/*perform test for normality for a continuous variable*/
	proc univariate	data= &data_in.
								NORMAL; /*requests tests for normality that include a series of goodness-sof-fit tests based on the empirical distribution function*/
								/*NOPRINT;*/ /*suppresses all the tables of descriptive statistics that the PROC UNIVARIATE statement creates*/
		var &var.; 
		ods output TestsForNormality= 	_normality_&var.; /*output result of normality test*/
		ods output Moments=					_moments_&var.;	/*get skewness and kurtosis*/				
	run;
	
	/*---------------------------------------------------------------horizontally combine wanted statistics--------------------------------------------------------------------------*/
	data _normal; 
		length varName $20	; /*if work on several variable, set lenght to the longest one*/
		merge  _normality_&var.(	keep= varName Stat Test pValue 
													where=(Test in ('Kolmogorov-Smirnov'))
												 )
					_moments_&var.(keep= varName Label1 nValue1 
												where= (Label1 in ('N'))
												rename= (nValue1=N)
												)
					_moments_&var.(keep= varName Label1 nValue1 
												where= (Label1 in ('Skewness'))
												rename= (nValue1=Skewness)
												)
					_moments_&var.	(keep= varName Label2 nValue2 
												where= (Label2 in ('Kurtosis'))
												rename=(nValue2=Kurtosis) 												
												);
		format Stat 5.3 pValue pValue5.3 N comma6.	Skewness 5.3 Kurtosis 5.3;
		drop Label1 Label2;
	run;

	/*append normality test results from each macro invocation*/; 
	data normal; 
		set 	normal _normal;  
	run;

%mend normality;

/*history of calling this macro*/
/*Date			Macro call
------------------------------------------------------------------------------------------------------------
20160628	%normality	(data_in= out.twin_nonMisSPHERE,	var= PSYCH6);
					%normality	(data_in= out.twin_nonMisSPHERE,	var= PSYCH6_IRT);
					%normality	(data_in= out.twin_nonMisSPHERE,	var= PSYCH6_ln);
					%normality	(data_in= out.twin_nonMisSPHERE,	var= SPHERE_sum);
					%normality	(data_in= out.twin_nonMisSPHERE,	var= SPHERE12_IRT);
					%normality	(data_in= out.twin_nonMisSPHERE,	var= SPHERE_sum_ln);
					%normality	(data_in= out.twin_nonMisSPHERE,	var= SOMA6);
					%normality	(data_in= out.twin_nonMisSPHERE,	var= SOMA6_IRT);
					%normality	(data_in= out.twin_nonMisSPHERE,	var= SOMA6_ln);

20160524	%normality	(var= score);
					%normality	(var= score_ln);
					%normality	(var= score_log);
					%normality	(var= score_exp);
					%normality	(var= score_sqrt);
					%normality	(var= score_curt);
------------------------------------------------------------------------------------------------------------*/
