*  MACRO:        Compare_baseline_characteristics 
*  DESCRIPTION:  Compares baseline characteristics by a specified variable  
*  SOURCE:       CSCC, UNC at Chapel Hill 
*  PROGRAMMER:   Polina Kukhareva 
*  DATE:         05/13/2013 
*  LANGUAGE:     SAS VERSION 9.3 
*******************************************************************; 
/*Name of the data set containing initial data, e.g. rq.simcox */
/*data set containing results, e.g. data_out1*/
/*by variable, e.g. treatment*/
/*List of variables to be included in a table separated by blanks*/
/*List of ALL the categorical variables separated by blanks*/
/*List of ALL the variables for which we estimate median and IQR*/
/*Footnote which appears in the rtf file */
/*Title which appears in the rtf file*/
/*Characters which will appear in the name of rtf file, e.g. 
bc_macro_1*/
%macro Compare_baseline_characteristics( 
				_DATA_IN= 
				,_DATA_OUT= 
				,_GROUP= 
				,_CHARACTERISTICS=  
				,_CATEGORICAL=_no_categorical_variables  
				,_COUNTABLE=_ no_countable_variables 
				,_FOOTNOTE=%str(&sysdate, &systime -- produced by macro Compare_baseline_characteristics) 
				,_TITLE1=Compare_baseline_characteristics Macro 
				,_NUMBER= bc_macro_1)/ minoperator; 
 
options 	nodate 
				mprint 
				pageno=1 
				mergenoby=warn 
				MISSING=' ' 
				validvarname=upcase;
 
%let		_CHARACTERISTICS=	%upcase(&_CHARACTERISTICS); 
%put	_CHARACTERISTICS= &_CHARACTERISTICS; 

%let 	_CATEGORICAL=			%upcase(&_CATEGORICAL); 
%put 	_CATEGORICAL= 			&_CATEGORICAL; 

%let 	_COUNTABLE=				%upcase(&_COUNTABLE); 
%global count_1 count_2 count_3 count_4 count_5 count_6 count_7 count_8 count_overall; 

proc format; 
   value pvalue_best 
      	0-<0.1=[pvalue5.3]  
      	Other=[5.2] ; 
run; 
 
/*Producing a work data set*/ 
data baseline_characteristics_ds; 
   set &_DATA_IN; 
      length categorical_group $100; 
      if Vtype(&_GROUP)='C' then categorical_group=&_GROUP; 
      else categorical_group=strip(input(&_GROUP, best12.)); 
      if missing(&_GROUP) then delete; 
run; 
 
proc sort data=baseline_characteristics_ds; 
   by categorical_group; 
run; 
 
proc sql; 
   select distinct categorical_group into :distinct_groups separated by '~' 
      from baseline_characteristics_ds; 
   quit;
 
%let number_of_distinct_groups= %eval(%sysfunc(countw(%str(&distinct_groups),~)));
 
%do i=1 %to &number_of_distinct_groups;  
   %let categorical_group_&i=%scan(&distinct_groups,&i,~); 
      proc sql; 
      	select count (*) into :count_&i 
			from baseline_characteristics_ds  
				where categorical_group="&&categorical_group_&i"; 
	  quit; 

	%let count_&i=&&count_&i; 
%end; 

proc sql; 
   select count (*) into :count_overall 
	from baseline_characteristics_ds; 
quit; 

%let count_overall=&count_overall; 

/*Creating an empty data set to append some observations later*/ 
data table2; 
   length 	label $ 100 
				variable $ 40 
				%do i=1 %to &number_of_distinct_groups; 
					column_&i $ 200 
				%end; 
				column_overall $200 
				pvalue 8
		; 
run; 
 
/*We are iterating through all the predictors in given order to compare their values 
between excluded and included data sets*/ 
%do  all_count=1 %to %sysfunc(countw(&_CHARACTERISTICS)); 
   %let CHECK_VAR=%scan(&_CHARACTERISTICS, &all_count,%str( )); 
   %let CHECK_VAR=%UNQUOTE(&CHECK_VAR); 
/*We calculate number, percentage and p-value using chi-square test for 
categorical predictors*/    
   %if &CHECK_VAR in &_categorical %then 
		%do; 
/*getting p-values*/ 
		      proc freq data=baseline_characteristics_ds; 
		         table categorical_group*&CHECK_VAR/chisq; 
		         output out=p pchi; 
		      run; 
		      %if (%sysfunc(exist(work.p)))=0 %then 
				%do; 
			         data p; 
			            length p_pchi pvalue 8.; 
			         run; 
      			%end; 
			      data p; 
			         set p(keep=p_pchi rename=(p_pchi=pvalue)); 
			      run; 
/*getting percentages*/ 
      %do i=1 %to &number_of_distinct_groups;  
         proc sql; 
            create table part1_&i as 
            select a.&CHECK_VAR as label1, 
            strip(put(count(a.&CHECK_VAR),8.0))||' ('||strip(put(count(a.&CHECK_VAR)/Subtotal,percent8.0))||')' as column_&i 
            	from baseline_characteristics_ds as a,  
            			(select count(&CHECK_VAR) as Subtotal 
							from baseline_characteristics_ds 
            					where categorical_group="&&categorical_group_&i") 
            		where ^missing(&CHECK_VAR) and categorical_group="&&categorical_group_&i" 
            			group by a.&CHECK_VAR ; 
         quit; 
      %end;
 
      proc sql; 
         create table part1_overall as 
            select a.&CHECK_VAR. as label1
					, strip(put(count(a.&CHECK_VAR),8.0))||' ('||strip(put(count(a.&CHECK_VAR)/Subtotal,percent8.0))||')' as column_overall 
            	from baseline_characteristics_ds as a,  
            			(select count(&CHECK_VAR) as Subtotal 
							from baseline_characteristics_ds) 
            		where ^missing(&CHECK_VAR) 
            			group by a.&CHECK_VAR ; 
      quit;
 
      data part1 (drop=label1); 
         length label $100; 
         merge %do i=1 %to &number_of_distinct_groups; part1_&i %end; part1_overall; 
         by label1; 
         if Vtype(label1)='C' then label=label1; 
         else label=put(label1, 8.0); 
      run;  

	data part1; 
         set part1; 
         length label $100; 
         label='- '||strip(label); 
         variable="&CHECK_VAR"; 
    run; 

    proc sql; 
		create table part1 as 
			select * from part1, p; 
	quit; 

/*getting label*/ 
      proc TRANSPOSE DATA=baseline_characteristics_ds (OBS=1 KEEP=&CHECK_VAR) 
OUT=VARLABL; 
         var &CHECK_VAR; 
      run; 
      /* checking existence of the variable label */ 
      data _null_; 
           dsid=open('VARLABL'); 
           check_VARLABL=varnum(dsid,'_Label_'); 
            call symput('check_label',put(check_VARLABL,best.)); 
      run; 
      data VARLABL; 
         length _label_ $40; 
         set VARLABL; 
          %if &check_label=0 %then %do; _Label_=' '; %end; 
      run;   
      /* merging p-values and labels */ 
      data part2; 
         set p; 
         set VARLABL (keep=_name_  _Label_ rename=(_Label_=label _name_=variable)); 
      run; 
 
      data add; set part2 part1; run; 
 
      proc append BASE=table2 DATA=add force; run; 
 
   %end; 
   /*We calculate median, IQR and p-value using Kruskal-Wallis test for median for not 
normally distributed continuous predictors*/    
   %else %if &CHECK_VAR in &_countable %then %do; 
      /*getting p-value*/ 
      proc npar1way data=baseline_characteristics_ds wilcoxon; 
         var &CHECK_VAR; 
         class categorical_group; 
         output out=p Wilcoxon; 
      run; 
      /*getting median and IQR*/ 
      proc univariate data=baseline_characteristics_ds noprint; 
         var &CHECK_VAR; 
         output out=IQR pctlpts= 25 50 75 pctlpre=&CHECK_VAR.; 
         by categorical_group; 
      run; 
      proc univariate data=baseline_characteristics_ds noprint; 
         var &CHECK_VAR; 
         output out=IQR_overall pctlpts= 25 50 75 pctlpre=&CHECK_VAR.; 
      run; 
      data IQR;  
         format tval $50.; 
         set iqr (where =(^missing(categorical_group))) IQR_overall; 
         length IQR_group $100; 
         tval="{"||(strip(put(&CHECK_VAR.50,5.1)))||' (' 
         ||strip(put(&CHECK_VAR.25,5.1))||', '||strip(put(&CHECK_VAR.75,5.1))||')}'; 
         drop &CHECK_VAR.50 &CHECK_VAR.25 &CHECK_VAR.75; 
         %do i=1 %to &number_of_distinct_groups; 
            if categorical_group="&&categorical_group_&i" then IQR_group="column_&i"; 
         %end; 

   if missing(IQR_group) then IQR_group="column_overall"; 
      run; 
      /*getting label*/ 
      proc transpose data=IQR out=median_p_trans; id IQR_group; var tval; run; 
 
      proc transpose DATA=baseline_characteristics_ds(OBS=1 KEEP=&CHECK_VAR) 
OUT=VARLABL; 
      run; 
      /* checking existence of the variable label */ 
      data _null_; 
         dsid=open('VARLABL'); 
         check_VARLABL=varnum(dsid,'_Label_'); 
         call symput('check_label',put(check_VARLABL,best.)); 
      run; 
      data VARLABL; 
         length _label_ $40; 
         set VARLABL; 
         %if &check_label=0 %then %do; _Label_=' '; %end; 
      run; 
 
      data add; 
         set median_p_trans 
            (keep=%do i=1 %to &number_of_distinct_groups; column_&i %end; 
column_overall);  
         set p (keep=P_KW rename=(P_KW=pvalue));  
         set VARLABL (keep=_name_ _Label_ rename=(_Label_=label _name_=variable)); 
      run; 
      proc append BASE=table2 DATA=add force; 
      run; 
   %end; 
   /*We calculate mean, standard deviation and p-value using T-test for continuous 
predictors*/    
   %else %do; 
   /*getting mean and std*/ 
      %do i=1 %to &number_of_distinct_groups;  
         proc sql; 
            create table part1_&i 
            as select catx(' ','{', put(mean(&CHECK_VAR), 8.1), 
            ' \u0177\~ ',put(sqrt(var(&CHECK_VAR)),8.1),'}') as column_&i 
            from baseline_characteristics_ds  
            where categorical_group="&&categorical_group_&i"; 
            quit; 
      %end; 
      proc sql; 
         create table part1_overall 
         as select catx(' ','{', put(mean(&CHECK_VAR), 8.1),' \u0177\~ ', 
         put(sqrt(var(&CHECK_VAR)),8.1),'}') as column_overall 
         from baseline_characteristics_ds; 
      quit; 
      /* getting p-value*/ 
      ods output OverallANOVA=p(keep= dependent source probf where=(source='Model') 
         rename=(probf=pvalue dependent=variable)); 
      proc anova data=baseline_characteristics_ds; 
         class categorical_group; 
            model  &CHECK_VAR=categorical_group; 
      run; quit; 
      ods output close; 
      /*getting label*/ 
      proc transpose DATA=baseline_characteristics_ds (OBS=1 KEEP=&CHECK_VAR) 
OUT=VARLABL; 
      run; 
      /* checking existence of the variable label */ 
      data _null_; 

 dsid=open('VARLABL'); 
         check_VARLABL=varnum(dsid,'_Label_'); 
         call symput('check_label',put(check_VARLABL,best.)); 
      run; 
      data VARLABL; 
         length _label_ $40; 
         set VARLABL; 
         %if &check_label=0 %then %do; _Label_=' '; %end; 
      run; 
      data add; 
         %do i=1 %to &number_of_distinct_groups; set part1_&i;%end; 
         set part1_overall; 
         set p (keep=pvalue);  
         set VARLABL (keep=_name_ _Label_ rename=(_Label_=label _name_=variable)); 
      run; 
      proc append BASE=table2 DATA=add force; run; 
   %end; 
   proc datasets lib=work memtype=data; delete p ; run; quit; 
%end; 
data &_DATA_OUT; 
   set table2; 
run; 
 
/*Printing table 1 in rtf destination*/ 
title1 j=center height=12pt font="Times Roman" "&_TITLE1"; 
title2 j=center height=12pt font="Times Roman" "Table 1. Comparison of baseline characteristics by &_GROUP"; 
footnote1 J=left height=9pt font="TIMES ROMAN" "{Note: Values expressed as n(%), mean 
± standard deviation or median (25\super th}{, 75\super th }{percentiles)}"; 
footnote2 J=left height=9pt font="TIMES ROMAN"  
"Note: P-value comparisons across &_GROUP categories are based on chi-square test of 
homogeneity for categorical variables; p-values for continuous variables are based on 
ANOVA or Kruskal-Wallis test for median"; 
footnote3 J=right height=9pt font="TIMES ROMAN" &_FOOTNOTE; 
 
ods listing close; 
ods rtf file="&_NUMBER._&_Group..rtf" style=analysis bodytitle; 
ods rtf startpage=NO; 
%let st=style(column)=[just=center vjust=bottom font_size=8.5 pt] 
        style(header)=[just=center font_size=8.5 pt]; 
proc report data=table2 nowd ; 
   column label variable  ("&_GROUP" column_overall  
   %do i=1 %to &number_of_distinct_groups; column_&i %end;)  pvalue; 
   define label / 'variable label' display  
      style(column)=[just=left vjust=bottom font_size=8.5 pt]  
      style(header)=[just=center font_size=8.5 pt]; 
   define variable / 'variable name' display  
      style(column)=[just=left vjust=bottom font_size=8.5 pt]  
      style(header)=[just=center font_size=8.5 pt]; 
   define column_overall / "Overall / N=&count_overall" display &st; 
   %do i=1 %to &number_of_distinct_groups;  
      define column_&i / "&&categorical_group_&i / N=&&count_&i" display &st; 
   %end; 
   define pvalue / 'P-value' display format=pvalue_best. &st; 
run; 
ods rtf exclude all; 
 
proc datasets 	lib=work 
						memtype=data; 
	delete 	table2 
				baseline_characteristics_ds ;  
run; 
quit; 

ods rtf close; 
ods listing; 
footnote; 
title; 

%mend Compare_baseline_characteristics; 
