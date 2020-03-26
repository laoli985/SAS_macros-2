/*#######################################################################################################################;
* filename: delete_all_user-defined_global_macro_variables.sas
* author: 	http://support.sas.com/kb/26/154.html
* dir: 		"C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\SAS_macros_chang"
* purpose: 	Delete all user-defined macro variables from the global symbol table
* Note: 	(1) 
        	(2) 
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
19May2015	file created. Successfully deleted all global macro variables in file import_data.sas
-----------------------------------------------------------------------------------------------------------------------------*/

%macro delGlobalMacroVars;
  data vars;
    set sashelp.vmacro;
  run;

  data _null_;
    set vars;
    temp=lag(name);
    if scope='GLOBAL' and substr(name,1,3) ne 'SYS' and temp ne name then
      call execute('%symdel '||trim(left(name))||';');
  run;

%mend delGlobalMacroVars;
