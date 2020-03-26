/*********************************************************************************************************************
* filename		: def_display_alignDecimalCenter.sas
* programmer	: Chang, Tristan Tang
* path				: 
* purpose			: 	build repetitive define statements to display values
* date created	:	20170131
* how to use 	: call this macro in the proc report where a define statement should go
* note				: flexibile format= , only for display type define statement
------------------------------------------------------------------------------------------------------------------------------
Date			Update
-------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------*/
%SYSMACDELETE displayAlignDeciCenter;

%macro displayAlignDeciCenter(	cVar=		/*character variable*/	
					,cName=					/*name of the character variable*/	
					,isFmt=N					/*apply a format to the variable or not*/	 
					,cFmt=					/*which format*/	
					,cWide=25pt		/*cell width*/
					,headerAlign=center /*alignment of header text in a column: left, center, right*/
					,colAlign=center 	/*center align content in a column*/					
					);

	define	&cVar.	/	display	"&cName." 	
		%if &isFmt.=Y %then 
			%do;
					format= &cFmt.
					style(header)={just=&headerAlign.}
					style(column)={just=&colAlign. cellwidth= &cWide. asis=on}	; /*ASIS=on Specifies that leading spaces
 and line breaks will be honored  allowing for user controlled indentatio*/
			%end;
		%else	
			%do;
					style(header)={just=&headerAlign.}
					style(column)={just=&colAlign. cellwidth= &cWide. asis=on } ;
			%end; 
%mend displayAlignDeciCenter;
