%sysmacdelete sort;
%macro sort(data_in=
					,sort_option=
					, by_var= 
					, data_out=
					);
	proc sort 	data=&data_in.
					&sort_option.
					out= &data_out.;
			by &by_var.;
	run;
%mend sort;
