/*===========================================================================================================
filename			:	SAS_to_space-separated_TXT.sas
modified from	:	SAS_to_tab-separated_TXT.sas
author				:	Chang
purpose			: 	export a single or a list of SAS data sets to space-separated txt files
date created		:	20171020
note					:	exported files have same names as the SAS data sets
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Date				Update
-----------------------------------------------------------------------------------------------------------------------------------------------------------
20171203	Added &outputFileNames
__________________________________________________________________________________________________________*/

%SYSMACDELETE SAS2spaceTXT_unlabelled;
%macro SAS2spaceTXT_unlabelled(inputLib=
															,inputFileNames=
															,outputFileNames=
															,outputDir=);
    %let n=%sysfunc(countw(&inputFileNames));
        %do i=1 %to &n;
            %let inputFileName = %scan(&inputFileNames,&i.);
			%let outputFileName= %scan(&outputFileNames.,&i.);
                proc export
                    data= &inputLib..&inputFileName.
                    outfile= "&outputDir.\&outputFileName..txt"
                    dbms= DLM
                    /*label*/
                    replace;
                    putnames= yes;
                run;
    %end;
%mend SAS2spaceTXT_unlabelled;
