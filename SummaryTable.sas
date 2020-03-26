/*URL: http://www.lexjansen.com/pharmasug/2006/applicationsdevelopment/ad13.pdf*/
%macro SummaryTable(DATA=,
										 ROW= ,
										 RTYPE= ,
										 COL= ,
										 TEST= ,
										 PCT= ,
										 RTFFILE= ,
										 TITLE= ,
										 PAGE=,
										 PGS=); 

%LET J=1;
%LET ROWJ=%UPCASE(%SCAN(&ROW,&J));
%DO %WHILE(%LENGTH(&ROWJ) > 0);
	 %LET RTYPEJ=%UPCASE(%SCAN(&RTYPE,&J));
	 %LET TESTJ=%UPCASE(%SCAN(&TEST,&J));
	 %VAR1(DATA=&DATA.
				, ROW=&ROWJ.
				, COL=&COL.
				, RTYPE=&RTYPEJ.
				, TEST=&TESTJ.
				, TABLE=&TABLE.);
	%LET J=%EVAL(&J + 1);
	%LET ROWJ=%UPCASE(%SCAN(&ROW,&J));
%END; 

%MACRO VAR1(DATA=, ROW=, RTYPE=, COL=, TEST=, TABLE=_STORE); 
	%IF &RTYPE.= CONT %THEN 
		%DO;
 			%CONT_FILE(DATA=&DATA., ROW=&ROW.,COL=&COL.);
 		%END;
	%ELSE %IF &RTYPE.=CATE %THEN 
		%DO;
 			%CATE_FILE(DATA=&DATA., ROW=&ROW.,COL=&COL.);
 		%END; 
%MEND;

%IF &FREQTEST.=CHISQ %THEN 
	%DO ;
		 ODS OUTPUT "CHI-SQUARE TESTS"=CHISQ;
			 PROC FREQ DATA=DATA0 ;
				 TABLES &ROW. * &COL. / NOROW NOCOL NOPERCENT &FREQTEST.;
			 RUN;
		 ODS OUTPUT CLOSE;
	%END ;

%IF %UPCASE(&TEST.)= CHISQ %THEN 
	%DO;
		 DATA _PVALUE(KEEP=PVALUE TEST);
			 SET CHISQ;
			 IF STATISTIC="CHI-SQUARE" THEN 
				DO;
					PVALUE=PROB;
					TEST='P';
					OUTPUT;
					STOP;
				END;
		  RUN;
	%END; 

%mend;
