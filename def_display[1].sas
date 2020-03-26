/*********************************************************************************************************************
* filename		: def_display[1].sas
* programmer	: Chang, Tristan Tang
* path				: 
* purpose			: build repetitive define statements to display values
* how to use 	: call this macro in the proc report where a define statement should go
* note				: flexibile format= , only for display type define statement
* Reference		: https://communities.sas.com/t5/SAS-Procedures/How-do-I-Change-the-color-of-column-headers-under-an-across/td-p/289833
------------------------------------------------------------------------------------------------------------------------------
Date			Update
-------------------------------------------------------------------------------------------------------------------------------
20190311		Added 2 parameters header_background_color, header_font_color for changing header background color and header font color
20180415	Added 2 parameters for specifying the background and foreground of a column
09Sep2014	regenerated tables using this macro
05Sep2014	Tristan Tang reorganised revised the code and solved the problem that width didn't change as specified
04Sep2014	Left-aligned headers and columns (just=left in both style(header) and style(column)
22Aug2013	this macro called in "Olsaa_dataList_03a_table06b.sas"
22Aug2014	codes modified from "HPV_L_Kit.sas"
22Aug2014	program header copied from "chisquare_test.sas"
-----------------------------------------------------------------------------------------------------------------------------*/
%SYSMACDELETE def_display;

%macro def_display(	cVar=			/*A character variable to display*/	
					,cName=						/*Display the character variable in this name*/	
					,isFmt=N						/*Apply a format to the variable or not*/	 
					,cFmt=							/*If Y, which format name to use?*/	
					,header_background_color=white /*Specify background color for column headers, if not white*/
					,header_font_color=black /*Specify font color for column headers, if not black*/
					,cWide=25pt				/*Cell width*/
					,headerAlign=center 	/*Alignment of header text in a column: left, center, right*/
					,colAlign=right 			/*Alignment of content in a column: left, center, right, d (decimal point) */
					,marginRight=0
					,background=white 		/*color of background in a column*/
					,foreground=black		/*color of foreground (i.e. font color) in a column*/
					);
/*Define options for the DEFINE statement*/
	define	&cVar.	/	display	"&cName." 	
		%if &isFmt.=Y %then 
			%do;
					format= &cFmt.
			%end;
		style(header)={just=&headerAlign. background=&header_background_color. color=&header_font_color.}
		style(column)={just=&colAlign. cellwidth= &cWide. rightmargin=&marginRight. background=&background. foreground=&foreground.};
%mend def_display;


*%macro def_display(	cVar=			/*character variable*/	
					,cName=						/*name of the character variable*/	
					,isFmt=N						/*apply a format to the variable or not*/	 
					,cFmt=							/*which format*/	
					,cWide=25pt				/*cell width*/
					,headerAlign=center 	/*alignment of header text in a column: left, center, right*/
					,colAlign=right 			/*alignment of content in a column: left, center, right, d (decimal point) */
					,marginRight=0
					,background=white 		/*color of background in a column*/
					,foreground=black		/*color of foreground (i.e. font color) in a column*/
					);

	/*define	&cVar.	/	display	"&cName." 	
		%if &isFmt.=Y %then 
			%do;
					format= &cFmt.
					style(header)={just=&headerAlign.}
					style(column)={just=&colAlign. cellwidth= &cWide. rightmargin=&marginRight. background=&background. foreground=&foreground.};
			%end;
		%else	
			%do;
					style(header)={just=&headerAlign.}
					style(column)={just=&colAlign. cellwidth= &cWide. rightmargin=&marginRight. background=&background. foreground=&foreground.};
			%end; 
%mend def_display;
*/
