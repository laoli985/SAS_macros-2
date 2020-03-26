/*===========================================================================================================
filename			:	rename_variables_list.sas
author				:	Chang, LH
modified from	:
date created		:	20160928
path					: 	
purpose			:	rename variables with a list of user-defined variable names
--------------------------------------------------------------------------------------------------------------------------------------------
Date				Update
--------------------------------------------------------------------------------------------------------------------------------------------
________________________________________________________________________________________________________*/

%macro renameVarByList(libname=
								,dataSetName=
								,oldVarNames=
								, newVarNames=
								);
	proc datasets 	library=&libname. 
							memtype=data nolist	;
 		modify &dataSetName. ;
		/*write rename old1=new1 old2=new2... by a do loop. Don't end these option with semicolons*/
 		rename 
			%do i=1 %to %sysfunc(countw(&oldVarNames));				
  				%scan(&oldVarNames.,&i.)= %scan(&newVarNames.,&i.)
 			%end;
 			; /*the end of the rename statement here*/
	quit;
%mend renameVarByList;

/*----------------------------------------------------This is the end of this program------------------------------------------------*/
