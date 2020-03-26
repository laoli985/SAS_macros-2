/*********************************************************************************************************************
* filename			: editCheck_range.sas
* programmer	: Chang, Tristan Tang
* purpose			: output numeric data that should have been within reason ranges
* how to use 		: run the macro once per variable
* note				: 
* date creatd		: 01Oct2014	
------------------------------------------------------------------------------------------------------------------------------
Date				Update
-------------------------------------------------------------------------------------------------------------------------------
06Oct2014	changed "Page" to "page"
01Oct2014	program header copied from "editCheck_numeric_blank.sas"
-----------------------------------------------------------------------------------------------------------------------------*/
/*output numeric data that is not within a reasonable range */
%macro rangeCheck(	var=			/*variable used in the conditional processing, may be newly created variable or annotated variable name*/
									,ovar=		/*Original variable (annotated variable name on CRF)*/
									,page=		/*page number on the CRF, type 'xx' with no gap between page and xx*/
									,section=	/*section title on the CRF*/
									,varname= /*variable name printed on the CRF, should be readable to sponsors*/
									,rule=		/*text corresponding to a particular rule number in the DVP*/
									,unit=		/*unit text of the data*/	
									,upper=		/*upper bound of the reasonable range*/
									,lower=		/*lower bound of the reasonable range*/
								);
	if &var. not=. then do;
		if &var. > &upper. or &var. < &lower. then do;
			CRF_page= 		"page&page.";
			CRF_section=	"&section.";
			query= "The &varname. ("||compress(&ovar.,'')||") should be between &lower. and &upper. &unit.. Please check the &varname.. ";
			rule= &rule.;
			output;
		end;
	end;	
%mend rangeCheck;
