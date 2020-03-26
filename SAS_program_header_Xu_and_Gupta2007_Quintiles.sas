/*====================================================================*
Program Name  		:  v_t_base_
Path                			:  /study/analysis/final/tablm Language    :  SAS V9.1.3 
Program Language		:
Operating System    	:  SunOS 5.9 
___________________________________________________________________________
Purpose             		: 
Run Dependencies    : None 
Macro Calls   
	Internal          		: %run_rpt 
  	External          		: %maptab, %GETFRQ %GETSTAT 
Files  
  Input             			:
  Output            		: /study/analysis/final/tables/validation/program/v_t_base_dmg.lst 
Program Flow        	: 
     1. Get data from source datasets. 
     2. Inside %run_rpt, apply stratacd condition and call above two macro for analysis items 
     3. Print out similar layout format to manually look at the difference  
Macro Assumptions   : 
Macro Parameters		: 
____________________________________________________________________________   
Version History
Version     Date             Programmer    	Description
-------    	---------        	---------------		---------------		
 1.0        11SEP2006     linfeng       		Creation
=====================================================================*
