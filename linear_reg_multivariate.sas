/*********************************************************************************************************************
* filename		: linear_reg_multivariate.sas
* macro call	: %GLMMacro;
* author		: Xue 2007 Customizing Output for Regression Analyses Using ODS and the Data Step
* path			: "C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\linear_reg_multivariate.sas"
* purpose		: to be invoked in another macro %sum_glm  
* note			: 
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
31Mar2014	Xue has probably mistaken multiple regression for multivariate. 
	it should be "multiple" here as there is just one outcome var in the macro called. 
	However, it may be also used as a multivariate when specifying manova h=_all_ statement
28Mar2014	codes copied from Xue 2007
28Mar2014	program header copied from linear_reg_univariate.sas
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

%Macro GLMMacro(X0);
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
		keep N_of_Obs;

	data dRsq2; 
		set dRsq; 
		keep RSquare;

	data dNumR; 
		merge dNum2 dRsq2;

	data dPara2; 
		set dPara(rename=(Parameter=Variable Probt=P_Value));
		if _N_=1 then delete;
		CI_lower = estimate - 1.96 * stderr;
		CI_upper = estimate + 1.96 * stderr;
		drop Dependent tValue;

	data dGLMAll; set dPara2 dNumR; run;

%mend GLMMacro;
