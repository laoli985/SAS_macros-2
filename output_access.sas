/*inputlib, inputdata, outputlib, outputdata*/
%macro output_access2(inputlib=
						,inputdata=
						,outputlib 
						,outputdata=
						,database=);

	*libname here "&dir_db.\&database";
		/*clear a workbook in Excel or a table in Access*/
		proc sql; 
			drop table &outputlib..&outputdata.; 
		quit;

	  	data &outputlib..&outputdata.; 
			set &inputlib..&inputdata.; 
		run;
	*libname here clear;
%mend output_access2;
