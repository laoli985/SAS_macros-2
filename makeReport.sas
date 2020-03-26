/*******************************************************************************
PROGRAM NAME 	:	makeReport.sas
FILE LOCATION	:	"C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\makeReport.sas" 		 
DESCRIPTION 	:	create reports with differing number of columns
PROGRAMMER 		:	Chris Speck
REFERENCE		:	http://analytics.ncsu.edu/sesug/2012/RI-13.pdf
DATE CREATED 	: 	19-Oct-2013
NOTE			:	(1) this macro requires that datasets are pre-programmed, sorted, 
					variable labels become the column headers in the final report
					(2) &dirRTF needs to be defined outside this macro
**********************************************************************************************************************/
/*------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
04Jan2015	replaced "&ds.rpt0" with "&ds_rpt0" so output rtf file has correct file extension 
20Mar2014	changed typos underscore copied from pdf to period
18Mar2014	reformatted program header, added section to define global macro variables
------------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION:	define global macro variables
-----------------------------------------------------------------------------------------------------------------------
macro		description 
-----------------------------------------------------------------------------------------------------------------------
DS 			Dataset from which output is based. 
VARS 		Variables to be presented in output, in left-to-right order
WIDTH 		Column widths of variables. Should match order of VARS or be missing
AUTOFIT		Flag for auto-fitting columns in output
TTL 		Title associated with output (e.g. Adverse Events)
HEADR 		Text appearing above variables in output
WHERE 		Criteria with which to subset DS. Default=1 (e.g. where= safety='Y')
dirRTF		Specify outside the macro parameter with respect to location of the report RTF  
---------------------------------------------------------------------------------------------------------------------*/

%macro MakeReport (ds=, vars=, width=, autofit=, ttl=, headr=, where=1);
	%global define ls empty;
	%let ls=125;
	%let empty=N;
***************************
Step 1: Sub-setting data
***************************;
data &ds.rpt0(keep=&vars.);
	retain &vars.;
	set &ds. (where=(&where.));
run;

************************************************************
Step 2: Setting macro variable EMPTY to Y and adding blank
observations if no observations match criteria.
************************************************************;
data &ds.rpt0;
	if nobs>0 then stop;
	call symput("empty","Y");
	output;
	stop;
	modify &ds.rpt0 nobs=nobs;
run;
***********************************************************************
Step 3: Collecting metadata from the SASHELP view VCOLUMN. Assigning
WIDTH according to macro parameters.
***********************************************************************;
data &ds.rpt1 (keep=name label width);
	set sashelp.vcolumn (where=(memname="%upcase(&ds.rpt0)"));
	%if &width. ne %then %do;
		width=put(scan("&width.",_n_),3.);
	%end;

	%else %if %upcase(&autofit.)=Y %then %do;
		%let varcount	=%sysfunc(countw(&vars.));
		%let width		=%eval((&ls - &varcount)/&varcount);
		width=put(&width., 3.);
	%end;
run;

******************************************************************
Step 4a: Building define statements within a macro variable using PROC SQL
******************************************************************;
proc sql noprint;
	select 'define ' || cats(name) || ' / display left "' || cats(label) ||
	'" width=' || cats(width)
	into :define separated by '; '
	from &ds.rpt1;
quit;

%let define=&define%str(;);
******************************************************************
Step 4b: Building define statements within a macro variable using PROC SQL, using ODS to produce RTFs
******************************************************************;
/*proc sql noprint;
	select 'define ' || cats(name) || ' / display left "' || cats(label) ||
	'" style(column)=[cellwidth=' || cats(width) || '%]'
	into :define separated by '; '
	from &ds.rpt1;
quit;
%let define=&define%str(;); */
*********************************************************************************************
Step 5: Printing Report
*********************************************************************************************;
ods escapechar = '~'; /*To implant formatting codes wherever text is displayed through inline formatting, first step is to select a symbol that you will not be using 
						elsewhere in your report. Some popular choices seem to be “~” and “^”.*/
option nodate nonumber orientation=portrait;
ods rtf file = "&dirRTF.\&ds_rpt0.rtf" bodytitle;

title &ttl.;
proc report data=&ds.rpt0 nowd split='|' missing headskip ls=&ls spacing=1;
	column ("&headr." &vars.);
	&define;
	%if &empty=Y %then %do;
		compute before;
		line @1 "No observations match criteria.";
		endcomp;
	%end;
run;

%mend MakeReport;
