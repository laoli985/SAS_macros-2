/*============================================================================
filename		:	rename_variables.sas
author			:	Chang
date created	:	20160531
NOTE			: 		
purpose		: 	rename SPHERE12 variables with a common prefix and a numeric suffix
						convert character variables to numeric
--------------------------------------------------------------------------------------------------------------------------------
Date				Update
--------------------------------------------------------------------------------------------------------------------------------
20170509	replaced 99 with numeric missing values
20170505	added input statement to convert renamed variables from char to numeric
_________________________________________________________________________________*/

%macro renameVar(libname=
								, dset=
								,oldVarNames=
								, newVarPrefix=	);

%let n=%sysfunc(countw(&oldVarNames))	;

	proc datasets 	library=&libname. 
							memtype=data 
							nolist;
 		modify &dset. ;
 		rename 
			%do i=1 %to &n.;
  				%scan(&oldVarNames.,&i.)= _&newVarPrefix._&i.
 			%end;
 			;
	quit;

	/*convert every SPHERE variable from character to numeric*/	
		data &libname..&dset.;	
			set &libname..&dset.;
			%do i=1 %to &n.	;				
				&newVarPrefix._&i.=input(_&newVarPrefix._&i.,best.)	;
				drop _&newVarPrefix._&i.	;
			%end; 
		run;	
	/*replace 99 with missing values*/

		data &libname..&dset.;
			set &libname..&dset.;	
			array measure_numeric &newVarPrefix._1 - &newVarPrefix._&n. ;
        		do i=1 to dim(measure_numeric);
            		if measure_numeric(i)=99 then measure_numeric(i)=.	;
        		end;
			drop i;
 		run ;
%mend renameVar;
