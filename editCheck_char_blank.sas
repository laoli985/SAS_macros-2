/*********************************************************************************************************************
* filename			: editCheck_char_blank.sas
* programmer	: Chang, Tristan Tang
* purpose			: identify character data that should not contain missing values but found to have missing values
* how to use 		: run the macro once per variable
* note				:  
------------------------------------------------------------------------------------------------------------------------------
Date				Update
-------------------------------------------------------------------------------------------------------------------------------
06Oct2014	changed "Page" to "page"
06Oct2014	removed blank between page and page number
01Oct2014	deleted code that display value of the missing character data, as blank is blank
26Sep2014	program header copied from "editCheck_numeric_blank.sas"
-----------------------------------------------------------------------------------------------------------------------------*/
/*output character data containing missing values*/
%macro charBlank(	var=			/*type variable used in the conditional processing, either annotated one or newly created */
								,page=		/*type 2-digit CRF page No. */
								,section=	/*macro reference not in quote (e.g. &CRFheader06.)*/
								,varname=/*paste variable name printed on the CRF, should be readable to sponsors*/
								,rule=		/*type rule number in the DVP*/
								);
	if &var.='' then do;	
		CRF_page=		"page&page.";
		CRF_section=	"&section.";
		query=	"The &varname. should not be left blank.";
		rule= &rule. ;
		output;
	end;
%mend charBlank;
/*-------------------------------------------copy me and modify me------------------------------------------*/
/* should not be left blank*/
/*%charBlank(var= 
					,page=		
					,section=	 
					,varname= 
					,rule=		
				  );
*/
