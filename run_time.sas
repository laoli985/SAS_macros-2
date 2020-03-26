/*********************************************************************************************************************
* filename		: run_time.sas
* example call	: %AlgTest(TestPGM=C:\Method1.txt, 
							cycles=2
							Log=C:\log\);
* path			: "C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\run_time.sas"
* author		: Patten 2003
* reference		: http://www2.sas.com/proceedings/sugi28/113-28.pdf	
* purpose		: Repeatedly runs SAS code, combining run times and reports average usage.
* date created	: 16Apr2014	
* note			: This macro doesn't perform error checking. Make sure a SAS file is working before invoking this macro.
* note			: 
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
16Apr2014	code pasted from Patten 2003 Run Time Comparison Macro
16Apr2014	program header copied from summary_stat.sas
-----------------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION:	define macro parameters
-----------------------------------------------------------------------------------------------------------------------
parameter 	description 
-----------------------------------------------------------------------------------------------------------------------
TestPGM 	Location of a SAS file you want to develop run time statistics for. 
	It must contain complete working SAS code steps. 
Cycles 		Number of times to cycle over code. 
Log 		Location for log files. There is one log file per cycle. If you ask for 10 cycles you will get 10 log files
---------------------------------------------------------------------------------------------------------------------*/

/**********************************************************************************************************************
*SECTION:	purpose in each step
-----------------------------------------------------------------------------------------------------------------------
step	output			purposes 
-----------------------------------------------------------------------------------------------------------------------
01		
02		
03		
04		
05		
06		
---------------------------------------------------------------------------------------------------------------------*/

%macro AlgTest(TestPGM=
				,Cycles=
				,Log=);
/*step01:	indicate file path for SAS program to test and for log files*/
filename TestPGM "&TestPGM";
Libname OutCPU "&Log";

/*step02:	Cycle over desired number of test runs*/
options stimer /*STIMER option writes real time and CPU time to the SAS log*/
		notes; /*NOTES option specifies that SAS write notes to the SAS log*/
%do i=1 %to &Cycles;
/*PROC PRINTTO redirects SAS log to a file*/
	proc printto 	log="&Log.log&i..tst" 
					new; /*NEW option rewrites any existing log file. If omitted, SAS would append to the file if it existed.*/
	run;
/*load code to test with %include*/	
	%include TestPGM;
	proc printto; run; 

/*step03:	Read test log and parse for CPU time*/
/*Step is the current SAS step */
/*Note is the Note for the current step*/
/*cpu is the cpu for the current step */
/*real is the wall time for the current step*/

	data Cpu (keep=Step Note Cpu Real);
		length 	code $5
				Note $200;
		retain Note;
/*step04:	point to log file created with printto above*/
		infile "&Log.log&i..tst" missover;

/*step05:	input code and check for NOTE: so we can set Note variable*/
		input @1 code $Upcase5. @;
		if code='NOTE:' then input @7 Note & $ @;

/*step06:	now check for cpu/real code and input time. note that the first step is associated with printto so we skip it*/
		input @7 code $Upcase4. @;
		if code = 'REAL' then do;
			input 	@16 Real 15.2 /
					@16 Cpu  15.2;
			step+1;
			if Real =. Then Real=0;
			if Cpu 	=. Then Cpu	=0;
			if step>1 then output;
		end;
	run;

/*step07:	Append to new dataset we must delete if already exists*/
	%if &i=1 %then %do;
		proc delete data=OutCPU.FinalCPU;
		run;
	%end;
	proc append data=Cpu 
				base=OutCPU.FinalCPU;
	run;
%end;

/*step08:	Finally, process for final report*/
	proc means data=OutCpu.FinalCPU mean noprint nway;
		var Cpu Real;
		id Note;
		class step;
		output 	out	=	Test(drop=_type_ _freq_)
				mean=;
	run;

	proc print data=Test noobs;
		title1 "Average CPU times (Seconds)";
		title2 "Cycles=&cycles";
		title3 "For => &TestPGM";
		sum Cpu Real;
	run;
%mend AlgTest;

/*step0:	*/
/*step0:	*/
/*step0:	*/
/*step0:	*/
/*step0:	*/
/*step0:	*/
