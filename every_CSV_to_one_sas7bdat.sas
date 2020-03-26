/*********************************************************************************************************************
* filename		: every_CSV_to_one_sas7bdat.sas
* programmer	: Chang
* date created	: 20161219
* ref					: https://communities.sas.com/t5/Base-SAS-Programming/Help-merging-multiple-CSV-files-to-a-dataset/m-p/184825/highlight/false#M35092
* purpose			: read all CSV files in a folder and save them as one SAS file using the CSV file name
* note				: CSV files must have same data structure, number of variables
* warning			: longest file name shouldn't exceed 32 characters. Copy file name 

ruller 32:
12345678901234567890123456789012
r_2VarACE_DisoIRTr_DisoIRTr_01_mxStatus_paramEsti (too long)
r_2VarACE_DirDir_01_mxCode_pEsti (32okay)
r_2VarACE_S6r_S6r_01_mxStatus_paramEsti (too long)
r_2VarACE_S6rS6r01_mxCode_parEsti (okay)
3VaACE_P6rS6rAFr_1_modelFits (28 okay)
3VaACE_P6rS6rAFr_2_modelCholACE (31 okay)
3VarACE_5_mAE_sig_stP_proVaria (30)
------------------------------------------------------------------------------------------------------------------------------
Date			Update
-------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------*/

%sysmacdelete every_CSV_to_1_sas7bdat;
%macro every_CSV_to_1_sas7bdat(	dirInput=
															,dirOutput=);

*filename fileDir "D:\Now\library_genetics_epidemiology\slave_NU\NU_analytical_output_twinModelResults_1Var\*.csv";
filename fileDir "&dirInput.\*.csv";

/*extract file paths from a specified directory*/
data &dirOutput..fileList;
	length filename fname $256;
	retain filename;
	infile fileDir filename=fname eov=eov end=end;
	input;
/*count number of obs in each file*/
	lines + 1;
	if eov or end then do;
		lines + end;
		output;
	end;
	if _n_ eq 1 or eov then do;
		filename=fname;
		eov =0;
		lines =0;
	end;
run;

/*get file names from the full paths*/
data &dirOutput..fileList2; 
	retain fileWithExtID fileWithExtension fileWithoutExtID fileWithoutExtension;
	length fileWithExtension fileWithoutExtension $40 fileWithExtID $13 fileWithoutExtID $16;
	set &dirOutput..fileList;
/*extract file names from path*/
	fileWithExtension=scan(filename,-1,"\");  /*file names with file extension*/
	fileWithoutExtension=scan(fileWithExtension,1,"."); 		/*file names without file extension*/
    rownum=_N_;
/*create ID for file names with extension and file names without extension*/
	fileWithExtID=cats('fileWithExt',compress(rownum));	 
	fileWithoutExtID=cats('fileWithoutExt',compress(rownum));	
run;

%local countLastFile	;
	data _null_; 
		set &dirOutput..fileList2;
		call symput(fileWithExtID,fileWithExtension);			/*&&file&iter corrsponds to filename*/
		call symput(fileWithoutExtID,fileWithoutExtension);
	run;	

/*count number of files in the directory*/
	proc sql noprint;
        select count(*) into : countLastFile
        	from &dirOutput..fileList2 ;
    quit;

	%put  The last row is &countLastFile ; /*22, correct!*/

/*loop through each obs reading a corresponding csv file*/
    %do i= 1 %to &countLastFile. ;
		%put The input directory is &dirInput\&&fileWithExt&i	;

		%put The output file name is &&fileWithoutExt&i.;

		proc import datafile= "&dirInput\&&fileWithExt&i." /**/
							out=&dirOutput..&&fileWithoutExt&i.
							 DBMS= csv
							replace;
				guessingrows=32767;
				getnames=yes;
                datarow=2;
		run;
	%end;

%mend;

/*history of calling this macro*/
/*Macro call
------------------------------------------------------------------------------------------------------------
20161219
%every_CSV_to_1_sas7bdat(
	dirInput= D:\Now\library_genetics_epidemiology\slave_NU\NU_analytical_output_twinModelResults_1Var
	,dirOutput=tem);
%every_CSV_to_1_sas7bdat(
	dirInput= D:\Now\library_genetics_epidemiology\slave_NU\NU_analytical_output_twinModelResults_2Var
	,dirOutput=tem);

------------------------------------------------------------------------------------------------------------*/
