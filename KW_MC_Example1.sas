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
INPUT RACE BMI@@;
x=bmi-18;
DATALINES;
1 32 1 30.1 1 27.6 1 26.2 1 28.2
2 26.4 2 23.1 2 23.5 2 24.6 2 24.3
3 24.9 3 25.3 3 23.8 3 22.1 3 23.4
;
*********************************************************
* DEFINE REQUIRED VARIABLES FOR THE MACRO               *
*********************************************************;
%LET NUMGROUPS=3;
%LET DATANAME=NPAR;
%LET OBSVAR=BMI;
%LET GROUP=RACE;
%LET ALPHA=0.05;
* OPTIONALLY DEFINE A TITLE;
Title 'Kruskal-Wallis Example from Zar p 197';
Title2 'With equal sample sizes for each group';

*****************************************************************
*invoke the KW_MC macro                                         *
*****************************************************************;
ODS HTML STYLE=STATISTICAL;
   %KW_MC(source=&DATANAME, groups=&NUMGROUPS, obsname=&OBSVAR, gpname=&GROUP, sig=&alpha);
   run;
ods HTML close;
