/*********************************************************************************************************************
* filename		: linear_reg_summary.sas
* macro call	: ;
* author		: Xue 2007 Customizing Output for Regression Analyses Using ODS and the Data Step
* path			: "C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\linear_reg_summary.sas"
* purpose		: output linear regression summary  
* note			: 
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
31Mar2014	reg coefficient=0, missing parameter estimate both seen from this macro and self-written proc glm
28Mar2014	replaced ODS PDF with ODS RTF
28Mar2014	codes copied from Xue 2007
28Mar2014	program header copied from linear_reg_multivariate.sas
-----------------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION:	define macro variables
-----------------------------------------------------------------------------------------------------------------------
macro 			description 
-----------------------------------------------------------------------------------------------------------------------
Dat				Dataset Name, Exp: work.finaldata
Response		Continuous Dependent Variable
Predictor		List of Independent Variables. 
Type= 			Uni- or Multi-variate Analysis, only can enter: Uni or Multi
tabFolder		folder path where tables are output, specified outside this macro
---------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION:	define purposes and output data sets in each step
-----------------------------------------------------------------------------------------------------------------------
step	output			purposes 
-----------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------*/

/*********************************************
*Generate Output File with ODS and PROC PRINT*
*********************************************/
%macro sum_glm(	Dat=, 
				Response=, 
				Predictor=, 
				Type= );

	*FORMAT procedure for traffic lighted p-value output;
	proc format; 
		value pf 
			0-0.01		="red" 
			0.01-0.05	="orange" 
			0.05-0.2	="green" 
			other		="";

	options nocenter nodate nonumber missing=' ';

	data dGLMAll; set _NULL_; run;

	*Use DO-WHILE loop to separate the predictor variables and invoke the GLMMacro;
	%let I=0;
	%do %while (%scan(&Predictor, &I+1, %str( )) ne %str( ));
		%let I=%eval(&I+1);
	%end;

	%if &Type=Uni %then %do;
		%do Z=1 %to &I;
			%GLMMacro_Uni(%scan(&Predictor, &Z, %str( )))
		%end;
	%end;

	%if &Type=Multi %then %do;
		%GLMMacro(&Predictor)
	%end;

	*Use PRINT procedure and ODS to generate the output file;
	/*ods pdf style=journal 
			startpage=no 
			/*file="&folder..\&Type.variate linear.pdf";*/
			*file="C:\Now\project2014_healthInsurance_taiwan\file_jenyuWang\test.pdf";
	ods rtf body="&tabFolder..\&Response._&Type.variate_linear.rtf" 
			style=journal 
			startpage=never 
			bodytitle;

	proc print data=	dGLMAll 
						split=' ' 
						noobs Style(HEADER) = {font_weight=bold};

		label 	Variable=	'Variable Name' 
				Estimate=	'Regression Coefficient'
				P_Value=	'P Value' 
				CI_lower=	'Lower CI' 
				CI_upper=	'Upper CI' 
				N_of_Obs=	'Sample Size' 
				RSquare=	'R Square';
		var Variable N_of_Obs RSquare Estimate StdErr CI_lower CI_upper;
		var P_Value / style={foreground=pf.};
		format Estimate StdErr P_Value CI_lower CI_upper 5.3 RSquare 4.2;
		title1 "&Type.variate Generalized Linear Model on &Response";
		title2 "Data folder=&abFolder";
		title3 'Predictors are either continuous or coded as 0/1 categorical(ref=0)';
	run;
*	ods pdf close; 
	ods rtf close;

%mend sum_glm;
