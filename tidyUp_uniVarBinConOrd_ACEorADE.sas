/*===========================================================================================================
filename			:	tidyUp_uniVarBinConOrd_ACEorADE.sas
modified from	:	rename_variables_list.sas
author				:	Chang, LH
modified from	:
date created		:	20161006
path					: 	
purpose			:	tidy up modelling result from univariate ACE or ADE using OpenMx
Note					:	input files must contain same number and names of variables
--------------------------------------------------------------------------------------------------------------------------------------------
Date				Update
20161109		added CorD_CI, which takes value from C_CI or D_CI. 
					Use CorD_CI if ACE and ADE are combined into one table
					Use C_CI and D_CI if ACE and ADE are exported to separate tables
20161006	moved this function from NU_003b_load_data_CSV.sas
--------------------------------------------------------------------------------------------------------------------------------------------
________________________________________________________________________________________________________*/

%SYSMACDELETE prettify_uniVar_ACEorADE;

%macro prettify_uniVar_ACEorADE(ACEorADE=, inFile=,outFile=);

	data &outFile.;

	/*--------conditionally reorder columns for 1st condition-----*/
	/*note: value should not be in quotes (e.g. = "ACE" won't work)*/
    %if &ACEorADE. = ACE %then
        %do;			
			retain method depVar comparison2 mxStatusCode A A_CI CorD_CI E_CI ep df diffdf minus2LL diffLL AIC p; 
			length A_CI CorD_CI E_CI $20. comparison2 $11.;
			set &inFile.;			
		%end;
	/*--------conditionally reorder columns for 2nd condition-----*/
    %else %if &ACEorADE. = ADE %then
        %do;			
			retain method depVar comparison2 mxStatusCode A A_CI CorD_CI E_CI ep df diffdf minus2LL diffLL AIC p; 
			length A_CI CorD_CI E_CI $20. comparison2 $11.;
			/*CE is actually DE. Exclude DE because we never fit a univariate DE model*/
			set &inFile.(where= (comparison not= "CE")) ; 
		%end;
		method="&ACEorADE.";
	 /*combine reference model and model to fit against reference model*/
		if comparison not="" 	then comparison2= comparison ;
		else if comparison ="" 	then comparison2=base; /*copy ACE or ADE to blank field*/
		drop base comparison;

		/*-------------------combine estimate, lower bound, upper bound for A--------------------------*/	
		if A not=0 then 
			A_CI= CAT(put(A,4.2), ' ( ', put(Alb,4.2),  '-'	, put(Aub,4.2), ' )');			
		else if A=0 then A_CI="";
		/*-------------------combine estimate, lower bound, upper bound for C or D--------------------------*/	
		%if &ACEorADE. = ACE %then
        	%do;
				if 			C not=0 then C_CI= CAT(put(C,4.2), ' ( ', put(Clb,4.2),  '-'	, put(Cub,4.2), ' )')	;
				else if 	C =0 then C_CI="";
				CorD_CI=C_CI; /*when combing ACE with ADE, use this variable*/
			%end;

	   %else %if &ACEorADE. = ADE %then
        	%do;
				if 			D not=0 then D_CI= CAT(put(D,4.2), ' ( ', put(D_lowerBound,4.2),  '-'	, put(D_upperBound,4.2), ' )')	;
				else if 	D =0 then D_CI="";
				CorD_CI=D_CI; /*when combing ACE with ADE, use this variable*/
			%end;
		/*-------------------combine estimate, lower bound, upper bound for E--------------------------*/	
		if E not=0 then 
			E_CI= CAT(put(E,4.2), ' ( ', put(Elb,4.2),  '-'	, put(Eub,4.2), ' )');
		else if E =0 then E_CI="";

		/*convert character data to numeric data
		Note: whatever has NA is read as character variables. Damn*/
		
		format minus2LL diffLL AIC 7.2  p 8.3;
	run;

%mend prettify_uniVar_ACEorADE;

/*----------------------------------------------------This is the end of this program------------------------------------------------*/
