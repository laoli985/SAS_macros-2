/*********************************************************************************************************************
* filename		: surveymeans.sas
* macro call	: %surveymeans_NIS;
* author		: Chang
* path			: "C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\SAS_macros_chang\surveymeans.sas"
* ref: 
http://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_surveyfreq_sect021.htm
http://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_surveyfreq_sect023.htm
------------------------------------------------------------------------------------------------------------------------------
Date				Update
-------------------------------------------------------------------------------------------------------------------------------
20150812	removed default parameter from &where_options.
20150721	added &outputlib
20150711	analysed NIS_05_descriptive_statistics.sas. Results identical to estimates from non-macro code
20150711	program header copied from NIS_surveymeans.sas
-----------------------------------------------------------------------------------------------------------------------------*/
%macro NIS_surveyfreq (ds=						
											,by_var= 			
											,cluster= 			HOSPID
											,strata= 			NIS_STRATUM	
											,weight= 			TRENDWT
											,tables_var=
											,tables_options=	nowt nostd nototal		
											,yn_class= 			No
											,class=
											,yn_domain= 		No
											,domain=
											,outputObject=		OneWay
											,output_ds=
											,outputlib=
											,keep_var=
											,where_options=
											);
/*prevent result viewer window from popping up*/
ods html close;
ods listing close;

/*calculate national estimates for numeric variables*/
	proc surveyfreq data= &ds. ;
		by		&by_var.;
		cluster	&cluster.;
		strata	&strata.;		
		weight	&weight.;
		tables	&tables_var. / &tables_options.;
		%if &yn_class.=Y % then class &class.;;
		%if &yn_domain.=Y % then domain &domain.;;

/*output statistics to a temporary data set*/
		ods output &outputObject. = &output_ds.;

/*keep desired variables in the output data set*/
	data &outputlib..&output_ds._keep; 
		set &output_ds. (	keep=	&keep_var.
							where=	(&where_options.) 
						);
	run;
	
/*delete the temporary data set*/
	proc datasets library=work;
		delete &output_ds.;
	run;
	quit;

%mend NIS_surveyfreq;		
