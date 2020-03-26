/*#######################################################################################################################;
* filename: homogeneity_of_variance.sas
* author: 	Chang
* path: 	"C:\Now\(Project) RFID_r3_Homing_r1\Ben analysis\macros_chang\homogeneity_of_variance.sas"
* purpose: 	test for homogeneity of variable variance
* Null hypothesis: variance equal among populations (reject this if p value < 0.05)
* Note:		only Bartlett's test is output. It looks nicer.
------------------------------------------------------------------------------------------------------------------------------
Date		Update
-------------------------------------------------------------------------------------------------------------------------------
02Mar2015	Analysed respVar (see section
03Jan2014	macro written. Analysed log10_hSpeed and homing_speed 
-----------------------------------------------------------------------------------------------------------------------------*/

/*create blank dataset to hold output of hov test of more than one variable*/;
data hovBartlett; reminder='delete this observation'; run; ** ben - the first line of table will be missing.  I just add this note to remind you to delete this first row.;

%macro hov	(	data=,
				by_groups=,
				classVar=,
				var=,
				popLevels=);

		/*step 1: sort data*/
		proc sort data=&data.; by &by_groups.; run;

		/*step 2: output tests of homogeneity of variance*/
		proc glm data= &data.;
			by &by_groups.;
			class &classVar.;
			model &var.	= &popLevels. / ss3 ; 					    /*compare variance of age among 3 groups*/
			MEANS &popLevels. / hovtest= BARTLETT hovtest=obrien ; 
		    ods output HOVFTest=	_hovObrien_&var.;				/*O'Brien's test*/
			ods output Bartlett=	_hovBartlett_&var.;				/*Bartlett's test*/
		run;

		/*step 3: reorder Bartlett's test*/;
		data hovBartlett; 
			retain test data Dependent Effect Source &by_groups. DF ChiSq ProbChisq;
			set 	hovBartlett
					_hovBartlett_&var.(in=a);
			if a then do; 	test='Bartlett'; data="&data"; end;
			if reminder=:'delete' then delete; 
			format ChiSq 5.3 ProbChisq pValue5.3;
		run;

%mend hov;


