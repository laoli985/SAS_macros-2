/*===========================================================================================================
filename			:	SAS_to_tab-separated_TXT.sas
modified from	:	SAS_to_CSV_unlabelled.sas
author				:	Chang
purpose			: 	export a single or a list of SAS data sets to tab separated txt files
date created		:	20170620
note					:	exported files have same names as the SAS data sets
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Date				Update
-----------------------------------------------------------------------------------------------------------------------------------------------------------
__________________________________________________________________________________________________________*/

%SYSMACDELETE SAS2tabTXT_unlabelled;
%macro SAS2tabTXT_unlabelled(inputLib=, list=);
    %let n=%sysfunc(countw(&list));
        %do i=1 %to &n;
            %let val = %scan(&list,&i);
                proc export
                    data= &inputLib..&val.
                    outfile= "&proj_dir.\&data_export.\&val..txt"
                    dbms= tab
                    /*label*/
                    replace;
                    putnames= yes;
                run;
    %end;
%mend SAS2tabTXT_unlabelled;
