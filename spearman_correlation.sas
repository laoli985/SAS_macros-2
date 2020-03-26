/*#######################################################################################################################;
* filename: spearman_correlation.sas
* author: 	Chang
* path: 	"C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\spearman_correlation.sas"
* purpose: 	Spearman rank correlation (1) between 2 non-parametric variables (2) between one categorical and one continuous
			variable
* Note: 	(1) codes here are for correlation betwen a single Y (var1) and different Xs (var2). All output to a single dataset 
        	(2) attempt to rename variables created two sets of duplicated columns so I used label instead 	
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
11Mar2014	add section header
11Mar2014	analysed correlation between EDvolume and day_low_temp
04Jan2014	add retain to reorder columns. working
02Jan2014	analysed correlation between log10_homing speed and 5 other factos	
-----------------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION spearman correlation
-----------------------------------------------------------------------------------------------------------------------
data	description
-----------------------------------------------------------------------------------------------------------------------
spCorr	CREATE a blank tables to accumulate output from each loop
_spCorr	temporary data set for storing output of each loop
---------------------------------------------------------------------------------------------------------------------*/

/*step 1: create a blank data set*/
data spCorr;
	 test='delete this observation';  ** ben - the first line of table will be missing.  I just add this note to remind you to delete this first row.;
run;

%macro spearmanCorr (	data=, 
						by_groups=, 
						var1=, 
						var2=);
/*step 2: sort data*/
	proc sort data= &data.; by &by_groups.; run;

/*step 3: perform spearman correlation*/
	proc corr data=&data. SPEARMAN;
		by &by_groups.;
	   	var &var1. &var2. ;
		ods output SpearmanCorr = _spCorr; 
   	run;

/*step 4: reorder columns so grouping var go left and stat results go right*/
	data spCorr; 
		retain data test Variable &by_groups. &var1. P&var1. sigCorr; 
		length Variable $30.;
		set	spCorr 
				_spCorr(where= (Variable= "&var2." ) 					/*double quote to get value*/
								keep= &by_groups. Variable &var1. P&var1. in=a);/*no quoted macro for macro variables*/ 
		if a then do; test='spearman correlation '; data="&data."; end;
		if P&var1. < 0.05 then sigCorr='Y'; else sigCorr='';
		if test=:'delete' then delete;
		label &var1.='spCorrCoef' P&var1.='pValue';
		format &var1. 5.3 P&var1. pValue6.4; 		
	run;

%mend spearmanCorr;
