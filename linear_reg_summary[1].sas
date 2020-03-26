/*********************************************************************************************************************
* filename		: linear_reg_summary[1].sas
* macro call	: ;
* author		: Xue 2007 Customizing Output for Regression Analyses Using ODS and the Data Step
* path			: "C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\linear_reg_summary[1].sas"
* purpose		: output linear regression summary  
* note			: 
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
31Mar2014	added BY groups that can take 0- 2 BY var. 
	Output same as results not from macro but when BY variables are absent, 1, or 2
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
%macro sum_glm_byGroups(	Dat= 
							,group_process=
							,by_groups=
							,Response= 
							,Predictor= 
							,Type= );

	*FORMAT procedure for traffic lighted p-value output;
	proc format; 
		value pf 
			0-0.01		="red" 
			0.01-0.05	="orange" 
			0.05-0.2	="green" 
			other		="";

	options nocenter 
			nodate 
			nonumber
			missing=' '
			orientation=portrait /*orientation=landscape if wide one to be used*/
			;

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
		%GLMMacro_byGroups(&Predictor)
	%end;

	*Use PRINT procedure and ODS to generate the output file;
	ods rtf body="&tabFolder..\&Type.LinearReg_by=&by_groups._y=&Response..rtf" 
			style=journal 
			startpage=never 
			bodytitle;

	proc print data=	dGLMAll 
						split=' ' 
						noobs Style(HEADER) = {font_weight=bold};

		label 	Variable=	'Variable Name' 
				Estimate=	'Regression Coefficient'
				P_Value=	'P value' 
				CI95=		'95% CI' 
				N_of_Obs=	'Sample Size' 
				RSquare=	'R Square';
		var %scan(&by_groups.,1) %scan(&by_groups.,2) Variable N_of_Obs RSquare Estimate StdErr CI95;
		var P_Value / style={foreground=pf.};
		format Estimate StdErr P_Value RSquare 4.2;
		title1 "&Type.variate Generalized Linear Model on &Response";
		title2 "Data folder=&tabFolder.";
		title3 'Predictors are either continuous or coded as 0/1 categorical(ref=0)';
	run;
	ods rtf close;

%mend sum_glm_byGroups;
