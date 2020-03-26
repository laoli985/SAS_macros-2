/*********************************************************************************************************************
* filename	: NIS_surveymeans.sas
* macro call	: %surveymeans_NIS;
* author		: Chang
* path			: "C:\SAS_macros_chang\NIS_surveymeans.sas"
* NOTE		: 	this macro generates an output data set with variables from &stat and &by_var	
						statistic keywords different from SAS spelling will get you caught at the last step
*ref: http://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_surveymeans_sect005.htm 
------------------------------------------------------------------------------------------------------------------------------
Date				Update
-------------------------------------------------------------------------------------------------------------------------------
20150813	moved keep from the end to the beginning of SAS data set name
20150721	added &outputlib
20150711	analysed NIS_05_descriptive_statistics.sas. Results identical to estimates from non-macro code
20150427	analysed data set NIS_2012_core in file SASLoad_NIS_master_program.sas
20150427	program header copied from linear_reg_multivariate.sas
-----------------------------------------------------------------------------------------------------------------------------*/

%macro surveymeans_NIS (ds=
											,stat=
											,var=
											,by_var= 		
											,weight= 	TRENDWT
											,cluster= 	HOSPID
											,strata= 	NIS_STRATUM
											,yn_class= 	No
											,class=
											,yn_domain= No
											,domain=
											,output_ds=
											,keep_var= &by_var. &stat.
											,outputlib=					
											);
/*prevent result viewer window from popping up*/
ods html close;
ods listing close;

/*sort the data first by variables similar to the by group in the next procedure*/
	proc sort data= &ds.;
		by		&by_var.;
	run;

/*calculate national estimates for numeric variables*/
	proc surveymeans data= &ds. &stat. ;
		by		&by_var.;
		var 	&var.;
		weight	&weight.;
		cluster	&cluster.;
		strata	&strata.;
	/*	%if &yn_class.=Y 		%then class &class.;;
		%if &yn_domain.=Y 	%then domain &domain.;;
	*/
/*output statistics to a temporary data set*/
		ods output Statistics= &output_ds.;
	run;

/*keep desired variables in the output data set*/
	data &outputlib..keep_&output_ds.; 
		set &output_ds. (keep= &keep_var.);
	run;
	
/*delete the temporary data set*/
	proc datasets library=work;
		delete &output_ds.;
	run;
	quit;

%mend surveymeans_NIS;		
