/*===========================================================================================================
filename		:	left_join.sas
author			:	Chang
path				: 	
purpose		: 	left join
date created	:	20160531
note				:	limited to just one merging key
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Date				Update
20161102		NOTE: Line generated by the invoked macro "LEFTJOIN".
3                                                      order by &orderVar. ;
                                                       -----
                                                       180
ERROR 180-322: Statement is not valid or it is used out of proper order.
-----------------------------------------------------------------------------------------------------------------------------------------------------------
__________________________________________________________________________________________________________*/

%sysmacdelete leftJoin;

%macro leftJoin( table_out=
							,table_L=
							,table_R=
							,yn_orderData=
							,mergeKey_L=
							,mergeKey_R=							
							,orderVar= );
	proc sql; 
		create table &table_out. as
		select 	a.* ,b.*
			from &table_L. as a 
						left join
					 &table_R. as b
	/*with order by statement*/
				%if &yn_orderData.=Y %then 
					%do;
						on a.&mergeKey_L.=	b.&mergeKey_R.;
							order by &orderVar. ;;
					%end; 
	/*without order by statement*/
				%else %if &yn_orderData. not =Y %then 
					%do;
						on a.&mergeKey_L.=	b.&mergeKey_R.	;;
					%end;
	quit;
%mend leftJoin;
