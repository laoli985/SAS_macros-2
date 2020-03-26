/*===========================================================================================================
filename		:	CSV_to_SAS.sas
author			:	Chang
path				: 	
purpose		: 	convert a list of CSVs to separated SAS data sets same-named as the CSV files
date created:		20160531
note				:   users need to specify the output directory with a libname statement
						use %every_CSV_to_1_sas7bdat() rahter than %readCSV()
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Date				Update
-----------------------------------------------------------------------------------------------------------------------------------------------------------
20161223	some truncated values while reading the file r_2VarACE_03_corr_combined.csv
					%every_CSV_to_1_sas7bdat(), on the other hand, didn't have this problem.
__________________________________________________________________________________________________________*/

%sysmacdelete readCSV;
%macro readCSV(outLib
								,dir_in=
								,infile_list= 
								);

            %let n = %sysfunc(countw(&infile_list.)) ;
            %do i= 1 %to &n. ;
                %let file = %scan(&infile_list., &i.) ;              

                    proc import out=&outLib..&file.
                            datafile= "&dir_in.\&file..csv"
                            dbms=csv replace 
							;
                        getnames=yes;
                        datarow=2;
						GUESSINGROWS=32767;
                    run;
            %end;    
%mend readCSV;     

/*history of calling this macro*/
/*Date			Macro call
------------------------------------------------------------------------------------------------------------
20161223 %readCSV(outLib=out
					,dir_in= D:\Now\library_genetics_epidemiology\slave_NU\NU_analytical_output_twinModelResults_2Var  
					,infile_list= r_2VarACE_03_corr_combined );

20160531	libname NUcsv "&proj_dir.\&data_raw_csv." ;
					%readCSV(outLib=NUcsv
										,dir_in= K:\NU\NU_data_raw_csv
										,infile_list= 	twininf_resv nulog nulog2 nulog3 nuqst1w nuqst2w online1h1w 
										);
-------------------------------------------------------------------------------------------------------------*/

