/*===========================================================================================================
filename		:	SAS_to_CSV_with_label.sas
author			:	Chang
path				: 	
purpose		: 	export a single or a list of SAS data sets to CSV files
date created:	2016601
note				:	exported CSV files have same names as the SAS data sets
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Date				Update
-----------------------------------------------------------------------------------------------------------------------------------------------------------
20160529	modified from %do_export
__________________________________________________________________________________________________________*/

%macro SAS2CSV_label(libname=out, list=);
    %let n=%sysfunc(countw(&list));
        %do i=1 %to &n;
            %let val = %scan(&list,&i);
                proc export
                    data= &libname..&val.
                    outfile= "&proj_dir.\&data_pro.\&val..csv"
                    dbms= CSV
                    label
                    replace;
                    putnames= yes;
                run;
    %end;
%mend SAS2CSV_label;
