/*********************************************************************************************************************
* Filename		: import_export_single_files.sas 
* Modified fr	: all_csv_to_1_sasFile.sas
* Programmer	: Chang
* Date created	: 20190420
* Reference		: 
* Purpose			: 
* How to use 	: 
* Note				: CSV files must have same data structure, number of variables
* 						: proc import uses wrong informats causing long variables to be truncated. This macro is NOT in use! 
------------------------------------------------------------------------------------------------------------------------------
Date				Update
-------------------------------------------------------------------------------------------------------------------------------
20190420	%ImportATabSeparatedFile(input_file_path=  "D:\Now\library_genetics_epidemiology\GWAS\MR_ICC_GSCAN_201806\MR-PRESSO\result-tabulated\odds-ratio_exposure-UKB-CCPD-ESDPW-PYOS_outcome-ICC-CI_MR-sensitivity-analyses.tsv"
												,numb_rows=12
												,SAS_data_name=out.MR_sensitivity_results );
-----------------------------------------------------------------------------------------------------------------------------*/
%SYSMACDELETE ImportATabSeparatedFile;

/*Import a single file with tab-separated values (TSV)*/
%macro ImportATabSeparatedFile(input_file_path=  /*full path of a tsv file*/
														,numb_rows=
														,SAS_data_name= /*name of output file, specified by libref.dataset */
														);
	/*Assign the input file path to a short name*/
	filename input &input_file_path. 
					encoding="utf-8"	;
	/*Import the input file using PROC IMPORT*/
	proc import datafile=input
		out=&SAS_data_name. /*17 observations and 3 variables*/
		dbms=dlm			/*dbms=dlm for space or tab, dbms=csv for CSV*/
		replace;
		delimiter='09'x; 
		GUESSINGROWS=&numb_rows.;
	run;
	/*Output column names */
	proc contents 	data = &SAS_data_name. 
							noprint 
							out = &SAS_data_name._varname  (keep = name varnum);
	run;	
%mend ImportATabSeparatedFile ;

/*Import a single CSV file*/
%SYSMACDELETE ImportACommaSeparatedFile;
%macro ImportACommaSeparatedFile(input_file_path=  /*full path of a tsv file*/
														,numb_rows=
														,SAS_data_name= /*name of output file, specified by libref.dataset */
														);
	/*Assign the input file path to a short name*/
	filename input &input_file_path. 
					encoding="utf-8"	;
	/*Import the input file using PROC IMPORT*/
	proc import datafile=input
		out=&SAS_data_name. 
		dbms=csv			/*dbms=dlm for space or tab, dbms=csv for CSV*/
		replace;
		GUESSINGROWS=&numb_rows.;
	run;
	/*Output column names */
	proc contents 	data = &SAS_data_name. 
							noprint 
							out = &SAS_data_name._varname  (keep = name varnum);
	run;	
%mend ImportACommaSeparatedFile;

/*Export a SAS data set as a TSV file*/
%SYSMACDELETE ExportATabSeparatedFile;
%macro ExportATabSeparatedFile(SAS_data_name=
										 				 ,output_file_path=);
proc export data=&SAS_data_name.
				    outfile= "&output_file_path."
				    dbms=TAB
				    replace;
	putnames=YES; /*PUTNAMES=YES statement writes the SAS variables names as column names to the first row of the exported delimited file*/
run;

%mend ExportATabSeparatedFile;

/*Export a SAS data set as a CSV file*/
%SYSMACDELETE ExportACommaSeparatedFile;
%macro ExportACommaSeparatedFile(SAS_data_name=
																,output_file_path=);
proc export data=&SAS_data_name.
				    outfile= "&output_file_path."
				    dbms=csv
				    replace;
	putnames=YES; /*PUTNAMES=YES statement writes the SAS variables names as column names to the first row of the exported delimited file*/
run;

%mend ExportACommaSeparatedFile;




