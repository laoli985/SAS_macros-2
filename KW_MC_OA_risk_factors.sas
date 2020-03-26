*********************************************************
* KRUSKAL WALLIS ANALYSIS WITH MULTIPLE COMPARISONS;    *
* Alan C. Elliott and Linda S. Hynan                    *
* alan.elliott@utsouthwestern.edu                       *
* www.alanelliott.com/kw    (for latest version)        *
* Version 10-15-2010                                    *
*********************************************************;
***************************************************************************
* SAS® macro to perform multiple comparisons after a Kruskal-Wallis Test  *
***************************************************************************;
*create an empty dataset for housing output from proc npar1way*;
data kw_overall; run;

%macro KW_MC(source=, groups=, obsname=, gpname=, sig=);

*sort data *;
proc sort data=&DATANAME; 
	by genTypeOrder genType scoreType;
run;

* PERFORM THE STANDARD KRUSKAL WALLIS TEST;
PROC NPAR1WAy data=&DATANAME. wilcoxon; output out=KW_MC_TMP5;
	by genTypeOrder genType scoreType ;	
    CLASS &gpname;
    VAR &OBSNAME;
	ods output KruskalWallisTest= 	_KW_overall;
RUN;

data kw_overall; set _KW_overall; run ;

* Rank the input data froum the source file;
proc sort data=&source;by &gpname;run;
proc rank  data=&source out=KW_MC_TMP6 ties=mean ;
     var &OBSNAME;
     ranks obsrank;
run;
* Determin if there are tied ranks;
proc freq data=KW_MC_TMP6 order=freq ;
  tables obsrank/out=KW_MC_TMP7;
run;
* Create macro variable named &ISTIES; 
data _null_;
    if _N_=1 then set KW_MC_TMP7;
    maxtied=count;
    IF MAXTIED gt 1 then TIED=1;ELSE TIED=0;
    CALL SYMPUT('ISTIES',TIED);
run;

* calculate SUMT as per Zar formula 10.42;
proc freq noprint data=KW_MC_TMP6; table obsrank/out=KW_MC_TMP4 sparse;
run;
data KW_MC_TMP4;set KW_MC_TMP4;
     retain t;
     t=sum(t, (count**3 -count));
     keep t;
run;
data KW_MC_TMP4;
     set KW_MC_TMP4 end=eof;
     N=1;
     if (eof) then  output;
run;
*calculate and output the ranksums; 
proc means noprint sum n mean data=KW_MC_TMP6;
     output out=rankmeans n=n sum=ranksum mean=rankmean;var obsrank;
     by &gpname;
run;

proc sort data=rankmeans;by rankmean;run;

data rankmeans;set rankmeans;
     label gp ="Rank for Variable &OBSNAME";
run;

data KW_MC_TMP5;set KW_MC_TMP5;
     _label_="Rank for Variable &OBSNAME";
     keep _label_ p_kw;
run;

proc transpose data=rankmeans
	out=KW_MC_TMP5 prefix=MEAN;
	var rankmean;
	run;
data KW_MC_TMP5;set KW_MC_TMP5;
    N=_N_;
	keep n mean1-mean&groups; 
run;

proc transpose data=rankmeans
	out=KW_MC_TMP6 prefix=n;
	var n;
	run;
data KW_MC_TMP6;set KW_MC_TMP6;
     N=_N_;
     keep n n1-n&groups; 
run;

proc transpose data=rankmeans
	out=KW_MC_TMP7 prefix=gp;
	var &gpname;
	run;
data KW_MC_TMP7;set KW_MC_TMP7;
    N=_N_;
    keep n gp1-gp&groups; 
run;

data transposed;
     merge KW_MC_TMP5 KW_MC_TMP6 KW_MC_TMP7 KW_MC_TMP4;
     by n;
run;

data tmp4;set transposed;
     format msg $53.;
     sumt=t; 
     iputrejectmessage=0; 
     msg="Do not test";*set length of variable; 
     msg="Reject";
     array ranksum(*) mean1-mean&groups; 
     array na(*) n1-n&groups;
     array lab(*) gp1-gp&groups;
     array q05(20);
	 array pair(20,20);
	 * Check to see if all group  ns are equal;
	 notequal=0;
	 do i=1 to &groups	;
	     if na(1) ne na(i) then notequal=1;
	 end;
	 * if there are ties, use the notequal version of the comparisons;
     tmp=&isties;
	 if tmp eq 1 then notequal=1;
     * The array q05() contains the table values (alpha=0.05)
       for the q statistic k groups (as in the Zar Table B.15;
	 * If samples sizes are equal, as in Zar table B.5 in Zar (q distribution);
	 * For either case, q values are derived from SAS probability functions;
	 ALPHA=&sig;
     Q05(1)=.;
	 * For the case of UNequal sample sizes, like ZAR table B.15;
     DO K=2 to 20;
        PQ=1-ALPHA/(K*(k-1));
		Q05(K)=PROBIT(PQ);
     end;
	 xx= Q05(3); 
	 * For the case of EQUAL samples sizes or tied ranks -- Like ZAR Table B.5;
     if notequal=0 then 
	     DO K=2 to 20;
		    PQ =1-ALPHA;
            q05(k)=probmc("RANGE", .,PQ,64000,k); 
        end;
	 nsum=0;       
     do i=1 to &groups;
        nsum=nsum+na(i);
     end;
     icompare=&groups;
     qcrit=q05(icompare);
     * print out the multiple comparison results table;
     file print;
     gp="&gpname";
	 if notequal=1 then 
	    do;
        put @5 "Group sample sizes not equal, or some ranks tied. Performed Dunn's test, alpha=" alpha;
		end;
		else do ;
        put @5 "Group sample sizes are equal. Performed Nemenyi test, alpha=" alpha;
	    end;
	 put ' ';
     put @5 'Comparison group = ' "&gpname";
     put '  ';
     put '    Compare   Diff      SE        q         q(' "&sig" ')    Conclude';
     put '    ------------------------------------------------------------';
     iskiprest=0;
     * as the table is constructed, determine the correct Conclude message;
	 do i=icompare to 1 by -1;
        do j=1 to i;
		   pair(i,j)=0; *0=not yet tested, 1=reject 2=accept 3= skip;
        end;
     end; 
     do i=icompare to 1 by -1;
        do j=1 to i;
           if i ne j then do;
		      if notequal=0 then 
			  do;
			    * Zar formula 11.22;
			    rs1=ranksum(i)*na(1);
	            rs2=ranksum(j)*na(1);
				se=round(sqrt((na(1)*(na(1)*&groups)*(na(1)*&groups+1))/12),.01);
			  end;
			  else do;
			    rs1=ranksum(i);
	            rs2=ranksum(j);
			     * Zar formula 11.28;
	             setmp=(   ((nsum*(nsum+1))/12) -(SUMT/ (12*(nsum-1))  ))*( (1/na(i))+ (1/na(j)) );
	             se=round(sqrt(setmp),.01);
			  end;
	          diff=round(rs1-rs2,.01);
              q=round((rs1-rs2)/se,.01);
			  if pair(i,j) ne 3 then do;
			  if (q gt qcrit) and (pair(i,j) ne 2) then pair(i,j)=1; * REJECT;
              if q le qcrit then do;
	               pair(i,j)=2;
				   if (i-j) ge 2 then do; 
			   	      do k=j to (i-1); do l=(k+1) to i;
					    if icompare ne 1 then do;
						   if (pair(l,k) ne 2) and (l ne k) then pair(l,k)=3;* set to not test;
						end;
				      end;end;	 
				   end;
			  end;
			  end;
			  if pair(i,j)=1 then msg='Reject';
              if pair(i,j)=2 then msg='Do not reject';
			  if pair(i,j)=3 then msg='Do not reject (within non-sig. comparison)';
			  if pair(i,j)=3 then iputrejectmessage=1; 
			  if pair(i,j) le 2 then 
                     put @5 lab(i) 'vs' @11 lab(j) @ 15 diff @25 se @35 q @45 qcrit 6.3 @55 msg ;
			  if pair(i,j)=3 then
                     put @5 lab(i) 'vs' @11 lab(j) @15 msg;
            end;
         end;
     end;
	 if iputrejectmessage=1 then do;
        put '  ';
	    put '    Note: "Do not reject (within non-sig. comparison)" indicates that any comparison';
	    put '    within the range of a non-significant comparison must also be non-significant.';
	 end;
	 put '  ';
     put '    Reference: Biostatistical Analysis, 4th Edition, J. Zar, 2010.';
run;
%mend KW_MC;

