/*===========================================================================================================
filename		:	SAS_to_CSV_unlabelled.sas
author			:	Chang
path				: 	
purpose		: 	export a single or a list of SAS data sets to CSV files
date created:	20160529
note				:	exported CSV files have same names as the SAS data sets
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Date				Update
-----------------------------------------------------------------------------------------------------------------------------------------------------------
20160703	replaced libname with inputLib. Left inputIib= unspecified
20160529	modified from %do_export
__________________________________________________________________________________________________________*/

%SYSMACDELETE SAS2CSV_unlabelled;
%macro SAS2CSV_unlabelled(inputLib=, list=);
    %let n=%sysfunc(countw(&list));
        %do i=1 %to &n;
            %let val = %scan(&list,&i);
                proc export
                    data= &inputLib..&val.
                    outfile= "&proj_dir.\&data_export.\&val..csv"
                    dbms= CSV
                    /*label*/
                    replace;
                    putnames= yes;
                run;
    %end;
%mend SAS2CSV_unlabelled;
