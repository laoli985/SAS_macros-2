*********************************************************
* KRUSKAL WALLIS ANALYSIS WITH MULTIPLE COMPARISONS;    *
* Alan C Elliott and Linda S. Hynan                     *
* alan.elliott@utsouthwestern.edu                       *
* www.alanelliott.com/kw    (for latest version)        *
* Version 10-15-2010                                    *
*********************************************************;
*********************************************************;
* DEFINE THE DATA SET TO USE                            *
* GROUPS MUST BE LABELED 1 to N                         *
*********************************************************;
* CHANGE FILE PATH TO MATCH YOUR SITUATION;
%INCLUDE "C:\SASMACRO\KW_MC.SAS";

DATA NPAR;
INPUT HOSPITAL $ IRN @@;
DATALINES;
1 1.68 1 1.69 1 1.70 1 1.70 1 1.72 1 1.73 1 1.73 1 1.76 
2 1.71 2 1.73 2 1.74 2 1.74 2 1.78 2 1.78 2 1.80 2 1.81
3 1.74 3 1.75 3 1.77 3 1.78 3 1.80 3 1.81 3 1.84 
4 1.71 4 1.71 4 1.74 4 1.79 4 1.81 4 1.85 4 1.87 4 1.91
;
*********************************************************
* DEFINE REQUIRED VARIABLES FOR THE MACRO               *
*********************************************************;
%LET NUMGROUPS=4;
%LET DATANAME=NPAR;
%LET OBSVAR=IRN;
%LET GROUP=HOSPITAL;
%LET ALPHA=0.05;
* OPTIONALLY DEFINE A TITLE;
Title 'Kruskal-Wallis Tied Ranks';

*****************************************************************
*invoke the KW_MC macro                                         *
*****************************************************************;
ODS HTML STYLE=STATISTICAL;
   %KW_MC(source=&DATANAME, groups=&NUMGROUPS, obsname=&OBSVAR, gpname=&GROUP, SIG=&ALPHA);
   run;
ods HTML close;
