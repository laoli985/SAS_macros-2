/*********************************************************************************************************************
* filename			: def_sort.sas 
* modified from	: def_display[1].sas
* programmer		: Chang, LH
* path					: 
* reference			: http://support.sas.com/resources/papers/proceedings11/090-2011.pdf	
* purpose				: build repetitive define statements that sort data with 4 choices
* how to use 		: call this macro in the proc report where a define statement should go
* note					: flexibile format= , only for display type define statement
------------------------------------------------------------------------------------------------------------------------------
Date				Update
-------------------------------------------------------------------------------------------------------------------------------
20161009	sortType=internal prints twin modelling submodels in these orders
					(1) ACE AE CE E (2) ADE AE E 
20161009	program header copied from "def_display[1].sas"
-----------------------------------------------------------------------------------------------------------------------------*/

%macro def_sort(	cVar		/*character variable*/	
					,cName					/*name of the character variable*/
					,sortType				/*sorting options: internal, data, formatted or freq*/
					,isFmt					/*apply a format to the variable or not*/	
					,cFmt					/*which format*/	
					,cWide=25pt		/*cell width*/	
					);

	define	&cVar.	/ 
				order order=&sortType. /*ORDER=internal Sorts by a variable’s unformatted value*/
														/*ORDER=FORMATTED Sorts by a variable’s formatted values (default in SAS)*/
						 								/*ORDER=DATA Sorts in the order that the variable values are encountered in the data set*/
														/*ORDER=FREQ Sorts by frequency counts of the variable values*/	
 				"&cName."											
				%if &isFmt.=Y %then 						
					%do;											
							format= &cFmt.
							style(header)={just=left}
							style(column)={just=left cellwidth= &cWide.}	;
					%end;
				%else	
					%do;
							style(header)={just=left}
							style(column)={just=left cellwidth= &cWide.} ;
					%end; 
%mend def_sort;
