/*********************************************************************************************************************
* filename		: def_groupingVar.sas 
* programmer	: Chang
* date created	: 20160814
* ref					: http://analytics.ncsu.edu/sesug/2012/CT-27.pdf 
* purpose			: build repetitive define statements for grouping variable column 
* how to use 	: use this macro for grouping variable column which print only first occurrence (duplicated rows shown as blanks)
* note				: flexibile format= , only for display type define statement
------------------------------------------------------------------------------------------------------------------------------
Date				Update
-------------------------------------------------------------------------------------------------------------------------------
20180122	Added isFmt=, cFmt=		
20160814 	Modified from def_display[1].sas
-----------------------------------------------------------------------------------------------------------------------------*/

%macro def_group(	cVar		/*character variable*/
									,option					/*option= order : duplicated rows shown as blank, SAS will reorder your data */
																/*option= group : duplicated rows shown as blank, SAS doesn't reorder your data */
									,cName				/*name of the character variable*/	
									,isFmt=N				/*apply a format to the variable or not*/	 
									,cFmt=					/*which format*/	
									,cWide=25pt		/*cell width*/
									,headerAlign=center 	/*alignment of header text in a column: left, center, right*/
									,colAlign=right 			/*alignment of content in a column: left, center, right, d (decimal point) */
									,marginRight=0
									,background=white 		/*color of background in a column*/
									,foreground=black		/*color of foreground (i.e. font color) in a column*/
									);

	define	&cVar.	/	&option. "&cName."  order=data 
		%if &isFmt.=Y %then 
			%do;
				format= &cFmt.
				/*style(column)={just=left cellwidth= &cWide.}*/
				style(header)={just=&headerAlign.}
				style(column)={just=&colAlign. cellwidth= &cWide. rightmargin=&marginRight. background=&background. foreground=&foreground.};	/*replace order with &option. in the future*/
			%end;
		%else
			%do;
				style(header)={just=&headerAlign.}
				/*style(column)={just=left cellwidth= &cWide.}*/ /*replace order with &option. in the future*/
				style(column)={just=&colAlign. cellwidth= &cWide. rightmargin=&marginRight. background=&background. foreground=&foreground.};
			%end;
	
%mend def_group;
