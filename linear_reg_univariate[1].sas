/*********************************************************************************************************************
* filename		: linear_reg_univariate.sas
* macro call	: %GLMMacro_Uni;
* author		: Xue 2007 Customizing Output for Regression Analyses Using ODS and the Data Step
* path			: "C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\linear_reg_univariate.sas"
* purpose		: to be invoked in another macro %sum_glm  
* note			: 
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
28Mar2014	codes copied from Xue 2007
28Mar2014	program header copied from summary_stat.sas
-----------------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION:	define macro variables
-----------------------------------------------------------------------------------------------------------------------
macro 			description 
-----------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION:	define purposes and output data sets in each step
-----------------------------------------------------------------------------------------------------------------------
step	output			purposes 
-----------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------*/

%Macro GLMMacro_Uni(X0);
/*Use ODS in GLM procedure to generate datasets containing model fitting statistics*/
proc glm data=&Dat;
	model &Response =&X0 /solution;
	/*class &class_var.;*/
	ods output ParameterEstimates=	dPara;
	ods output NObs=				dNum;
	ods output FitStatistics=		dRsq;
quit;

/*Use DATA steps to generate final dataset dGLMAll for future output*/
data dNum2; 
	set dNum(rename=(NObsUsed=N_of_Obs)); 
	if _N_=1 then delete;
	length _Variable $25.; 
	_Variable="&X0"; 
	keep _Variable N_of_Obs;

data dPara2; 
	set dPara; 
	if _N_=1 then delete;
	length _Variable $25.; 
	_Variable=Parameter; 
	drop Dependent tValue Parameter;

data dRsq2; 
	set dRsq;
	length _Variable $25.; 
	_Variable="&X0"; 
	keep _Variable RSquare;
run;

proc sort data=dRsq2; by _Variable;
proc sort data=dPara2; by _Variable;
proc sort data=dNum2; by _Variable;

data dPara3; 
	merge dPara2 dRsq2 dNum2; 
	by _Variable; 
run;

data dGLMAll; 
	set dGLMAll dPara3(rename=(Probt=P_Value));
	CI_lower = estimate - 1.96 * stderr;
	CI_upper = estimate + 1.96 * stderr;
	Variable=_Variable;
run; 

%mend GLMMacro_Uni;
