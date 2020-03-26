/*********************************************************************************************************************
* filename		: all_csv_to_1_sasFile.sas 
* programmer	: Chang
* date created	: 20160913
* ref					: https://communities.sas.com/t5/Base-SAS-Programming/Help-merging-multiple-CSV-files-to-a-dataset/m-p/184825/highlight/false#M35092
* purpose			: Read all CSV files in a folder and combine them as a single SAS file
* how to use 	: 
* note				: CSV files must have same data structure, number of variables
* 						: proc import uses wrong informats causing long variables to be truncated. This macro is NOT in use! 
------------------------------------------------------------------------------------------------------------------------------
Date			Update
-------------------------------------------------------------------------------------------------------------------------------
20160923	this file is replaced by all_CSV_to_1CSV.R
-----------------------------------------------------------------------------------------------------------------------------*/
%SYSMACDELETE allCSV_to_1SAS;

%macro allCSV_to_1SAS(dir= /*path of the folder that contains CSV files with same data structure*/
											,out= /*name of output file, specified by libref.dataset */
											);
	/* Make sure output ds does not exist ;*/
	proc delete data=&out; run;
	* Read list of filenames and generate PROC IMPORT and PROC APPEND for each one ;
	filename code temp ;
	data _null_ ;
		infile "dir ""&dir\*.csv"" /b" pipe truncover;
		input filename $256.;
		file code ;
		put 'proc import datafile="&dir\' filename +(-1) '" out=onefile replace;'
			/ 'guessingrows=32767;' /*change default scanning first 20 rows to determine variable length, which truncates variables*/
	    	/ 'run;'
	    	/ "proc append base=&out data=onefile FORCE; run;"
	  		;
	run;

* Run the generated code ;
%inc code / source2 ;
%mend allCSV_to_1SAS ;

/*history of calling this macro*/
/*Macro call
------------------------------------------------------------------------------------------------------------
20160913	
%allCSV_to_1SAS(	dir=D:\Now\library_genetics_epidemiology\slave_NU\NU_analytical_output\binary01_modelFits
								,out=out._binary01_modelFits);
%allCSV_to_1SAS(	dir=D:\Now\library_genetics_epidemiology\slave_NU\NU_analytical_output\binary02_parameters
								,out=out._binary02_parameters);
%allCSV_to_1SAS(	dir=D:\Now\library_genetics_epidemiology\slave_NU\NU_analytical_output\binary03_ACE
								,out=out._binary03_ACE);

------------------------------------------------------------------------------------------------------------*/
