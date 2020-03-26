/*********************************************************************************************************************
* filename			: editCheck_numeric_blank.sas
* programmer	: Chang, Tristan Tang
* purpose			: output numeric data that should not contain missing values but found to have missing values
* how to use 		: run the macro once per variable
* note				: character data need to be converted to numeric before this macro can be applied to it 
------------------------------------------------------------------------------------------------------------------------------
Date				Update
-------------------------------------------------------------------------------------------------------------------------------
06Oct2014	changed "Page" to "page"
26Sep2014	program header copied from "def_display[1].sas"
-----------------------------------------------------------------------------------------------------------------------------*/
/*output numeric variables, including dates, that contain missing values*/
%macro	NumBlank(	var=			/*variable used in the conditional processing, may be newly created variable or annotated variable name*/
									,ovar=		/*Original variable (annotated variable name on CRF)*/
									,page=		/*page number on the CRF, type 'xx' with no gap between page and xx*/
									,section=	/*section title on the CRF*/
									,varname= /*variable name printed on the CRF, should be readable to sponsors*/
									,rule=		/*rule number in the DVP*/
									);
	if &var.= . then do;
		CRF_page= 		"page&page.";
		CRF_section=	"&section.";
		query=	"The &varname. ("||compress(&ovar.,'')||") should not be left blank. Please check the
 &varname.. ";
		rule= &rule.;
		output;
	end;
%mend NumBlank;

/*--------------------------------------------calling the macro--------------------------------------------------------*/
/*Start Date¡¨ and ¡§End Date of EGFR-TKI administraion should not be blank*/
/*%NumBlank(	var= 	
						,ovar=
						,page=						
						,section=&CRFheader.	
						,varname=
						,rule=general02			
					);
*/
