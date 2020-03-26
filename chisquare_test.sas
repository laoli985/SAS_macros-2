/*********************************************************************************************************************
* filename		: chisquare_test.sas
* programmer	: Chang
* path				: "C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\chisquare_test.sas"
* purpose			: create 2 or 3-way contingency tables, Chisquare test 
* note				: flexibile with BY statement, WEIGHT statement and layer variable
* note				: requires at least a 2 way table
* note				: output from each loop appends to a specified dataset. So more variables analysed,
				 		 longer the dataset is
* note				: chisq test result to be completed	 
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
24Mar2014	reanalysed summary count data in EDvolume_03_ana.sas. Macro worked perfectly well
24Mar2014	appended frequency data from each macro invokation to data set cTab_count
24Mar2014	appended percent data from each macro invokation to data set cTab_percent
22Mar2014	analysed summary count data in EDvolume_03_ana.sas. Macro worked perfectly well
22Mar2014	SECTION define global macro variables copied from EDvolume_03_ana.sas 
22Mar2014	program header copied from summary_stat.sas
22Mar2014	original codes copied from rfidR3_homingR1_03b_anaHoming[1].sas
-----------------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION:	define global macro variables
-----------------------------------------------------------------------------------------------------------------------
macro 						Description 
-----------------------------------------------------------------------------------------------------------------------
data							name of the data set to be analysed	
group_process	=Y 	if group processing is needed. Otherwise leave it blank
by_groups				BY groups
layerVar					layer variable if creating a 3 way contingency table  
rowVar						specify variable to be displayed vertically in the table 
colVar						column variable to be displayed horizontally in the table 
test							test=chisq if running a Chi-square test
summarised				summarised=Y if data have been summarised. Leave it blank if not		
weight_var				specify WEIGHT statement
---------------------------------------------------------------------------------------------------------------------*/

/*step01:	create blank tables to hold frequency data and percent data from contingency tables from 
each loop*/
data 	cTab_count cTab_percent; run;

/*step02:	output a contingency table and chisquare test result*/
%macro chiSqTest(	data=, 
					group_process=,
					by_groups=,
					layerVar=,
					rowVar=,
					colVar=,
					test=,
					summarised=,
					weight_var=);

	%if &layerVar^= %then %let layerVar=&layerVar*; 
	%put &layerVar; 
	/*If layerVar may not be present, won't get stuck coz of the '*' in front of row variable*/

	proc sort data=&data.; by &by_groups.; run;
	
	proc freq data=&data.;
		%if &group_process.=Y % then by &by_groups.;; 
		/*NOTE: additional semicolon needed (i.e., 2 semicolons here)*/
		
		table &layerVar.&rowVar.*&colVar. / &test. nocol norow missing; 
		/*put no star before row variable*/

		%if &summarised.=Y % then weight &weight_var.;;
		/*NOTE: additional semicolon needed*/

		ods output CrossTabFreqs=	_cTab_&rowVar._&colVar.;
		/*output a contingency table*/
		ods output ChiSq=			_chiS_&rowVar._&colVar.;
		/*output chisquare test result*/
	run;

/*step0:	group contingency table with 2 columns- column variable and its levels */
	data cTab_&rowVar._&colVar.(drop= _TYPE_ _TABLE_ Missing &rowVar. &colVar.);
		retain Table variable var_level &colVar._rev Frequency Percent;		
		set _cTab_&rowVar._&colVar.;
		length variable $10. &colVar._rev $7. var_level $15.;
		variable="&rowVar.";
		/*fill blanks with 'total' in variable and */ 
		if &colVar.='' 	then do; &colVar._rev=	'total'; end; else &colVar._rev=	&colVar.;
		if &rowVar.='' then do; var_level=		'total'; end; else var_level=		&rowVar.;
		format Frequency comma9.;
		percent=	round(percent, 0.01);
run; 

/*step03:	transpose frequency*/
proc sort data=	cTab_&rowVar._&colVar.; by variable var_level; run;
proc transpose 	data=	cTab_&rowVar._&colVar.
				out=	cTab_&rowVar._&colVar._a1_wide;
	by variable var_level;
	id &colVar._rev;
	var Frequency;
run;

/*step03a:	append frequency data*/
data cTab_count(drop= reminder _LABEL_);
	set cTab_count 
		cTab_&rowVar._&colVar._a1_wide; 
run;

/*step04:	transpose percent*/
proc sort data=	cTab_&rowVar._&colVar.; by variable var_level; run;
proc transpose 	data=	cTab_&rowVar._&colVar.
				out=	cTab_&rowVar._&colVar._a2_wide;
	by variable var_level;
	id &colVar._rev;
	var percent;
run;

/*step04a:	append percent data*/
data cTab_percent(drop= reminder _LABEL_);
	set cTab_percent 
		cTab_&rowVar._&colVar._a2_wide; 
run;

%mend chiSqTest;
