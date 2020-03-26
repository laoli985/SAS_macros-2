/*********************************************************************************************************************
* filename		: linear_reg_multivariate[1].sas
* macro call	: %GLMMacro_byGroups;
* author		: Xue 2007 Customizing Output for Regression Analyses Using ODS and the Data Step
* path			: "C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\linear_reg_multivariate.sas"
* purpose		: to be invoked in another macro %sum_glm  
* note			: 
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
09Apr2014	replace CI_lower and CI_upper with CI95 (format=6.3)
31Mar2014	added BY statement. 
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

%Macro GLMMacro_byGroups(X0);

proc sort data=&Dat.; by &by_groups.; run;

/*Use ODS in GLM procedure to generate datasets containing model fitting statistics*/
	proc glm data=&Dat;
		model &Response =&X0 /solution;
		%if &group_process.=Y % then by &by_groups.;;
		/*NOTE: additional semicolon needed (i.e., 2 semicolons here)*/

		ods output ParameterEstimates=	dPara;
		ods output NObs=				dNum;
		ods output FitStatistics=		dRsq;
	quit;

/*Use DATA steps to generate final dataset dGLMAll for future output*/
	data dNum2; 
		set dNum(rename=(NObsUsed=N_of_Obs));
		if _N_=1 then delete; 
		keep %scan(&by_groups.,1) %scan(&by_groups.,2) N_of_Obs;

	/*If layerVar may not be present, won't get stuck coz of the '*' in front of row variable*/

	data dRsq2; 
		set dRsq; 
		keep %scan(&by_groups.,1) %scan(&by_groups.,2) RSquare;

	data dNumR; 
		merge dNum2 dRsq2;
		%if &group_process.=Y % then by &by_groups.;;

	data dPara2; 
		set dPara(rename=(Parameter=Variable Probt=P_Value));
		if _N_=1 then delete;
		CI_lower	= estimate - 1.96 * stderr;
		CI_lower2	= put(round(CI_lower, 0.01),6.3);
		CI_upper	= estimate + 1.96 * stderr;
		CI_upper2	= put(round(CI_upper, 0.01),6.3);
		CI95		= CI_lower2||' to '||CI_upper2;
		drop Dependent tValue CI_lower CI_lower2 CI_upper CI_upper2;

	data dGLMAll; 
		set dPara2 dNumR;
		%if &group_process.=Y % then by &by_groups.;; 
	run;

%mend GLMMacro_byGroups;
