% this code get the data from MODIS MOD04 dataset based on the code get_infor_MOD04.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Ã£â‚??Ã£â‚??Ã£â‚??Ã£â‚??Ã£â‚?
clear
clc 
% 
%set the indexs for variables your want
%the indiex includes the group ID and SDS ID which can be found in the outputfile of get_infor_MOD04.m 
%for the MOD04 data, the group ID for Longitude and Latitude is 1,1
% and other variables are 1,2, therefore, WAntedInex stores the SDS of your want variables
WantedIndex=[];
WantedIndex(1)=2;
nvar=length(WantedIndex);
% set the region you want
lon_east=110.0; 
lon_west=100.0;
lat_south=40.0;
lat_north=30.0;
%----------------------------------------

%------------------------------------
foldpath='E:\DATA\MOD04\';
outputpath='';

for iyy=2000:2015  % year loop 
	yearstr=num2str(iyy,'%4.4i');
    outfile=strcat(outputpath,yearstr,\*.txt');
    outxt=fopen(outfile,'w');
    fprintf(outxt,'%s  ','year');
    fprintf(outxt,'%s  ','month');
    fprintf(outxt,'%s  ','day');
    fprintf(outxt,'%s  ','hour');
    fprintf(outxt,'%s  ','minute');                            	
    fprintf(outxt,'%s  ','lon');
    fprintf(outxt,'%s  ','lat');
	filenamex=strcat(foldpath,yearstr,'\*.hdf');
	allname=dir(filenamex);
	nf=length(allname);
	fileout=strcat(outputpath,yearstr,'.txt');
	filename=allname(1).name;
	filepath=strcat(foldpath,filename);
	head=hdfinfo(filepath);
	for iv=1:nvar % loop for the variables
		ind=WantedIndex(iv);
		varname=head.Vgroup.Vgroup(1,2).SDS(1,ind).Name;
        fprintf(outxt,'%s  ',varname);
    end
    fprintf(outxt,'%n ');
	for n=1:nf % loop for files
		filename=allname(n).name;
		yearstr=filename(11:14);
		iyear=str2num(yearstr);
		nsec=0;
		for iy=1993:(iyear-1);  %
			nday=365;
			if (mod(iy,4)==0 & mod(iy,100)~=0) || (mod(iy,400)==0) 
				nday=366;
			end
        	nsec=nsec+nday*24*60*60;
		end % loop 
		jdaystr=filename(15:17);
		hourstr=filename(19:20);
		minstr=filename(21:22);
		filepath=strcat(foldpath,filename);
		head=hdfinfo(filepath);
		% get the Longitude and Latitude 
		varname=head.Vgroup.Vgroup(1, 1).SDS(1,1).Name;
		lon=hdfread(filepath,varname);
		varname=head.Vgroup.Vgroup(1, 1).SDS(1,2).Name;
		lat=hdfread(filepath,varname);
		nx=head.Vgroup.Vgroup(1, 1).SDS(1,1).Dims(1,1).Size;
		ny=head.Vgroup.Vgroup(1, 1).SDS(1,1).Dims(2,1).Size;
		% get the time
 		varname=head.Vgroup.Vgroup(1,2).SDS(1,1).Name;
		seconds=hdfread(filepath,varname); %get the data!
		Scale_time=head.Vgroup.Vgroup(1,2).SDS(1,1).Attributes(1,5).Value; %
		add_offset_time=head.Vgroup.Vgroup(1,2).SDS(1,1).Attributes(1,6).Value; %	
		for iv=1:nvar % loop for the variables
			ind=WantedIndex(iv);
			varname=head.Vgroup.Vgroup(1,2).SDS(1,ind).Name;
			vardata=hdfread(filepath,varname); %get the data!
			Scale=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,5).Value; %
			add_offset=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,6).Value; %
			%%%%  NOTE: the real data is  vardata*Scale+add_offset 		
			valid_range=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,1).Value; % min and max
			defvalue=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,2).Value; % default value 
			for ix=1:nx % loop for lon
				for iy=1:ny % loop for lat
					if vardata(ix,iy) ~= defvalue & vardata(ix,iy)>= valid_range(1) & vardata(ix,iy)<= valid_range(2)  % condition for valid value
						if lon(ix,iy)<lon_east & lon(ix,iy)>lon_west %  west and east boundary
                    		if lat(ix,iy)<lat_north & lat(ix,iy)>lat_south % south and north boundary
                    			timesec=seconds(ix,iy)*Scale_time+add_offset_time; % seconds since 19930101 00:00:00 
                    			sec_year=timesec-nsec; %% seconds since this year 0101 00:00:00
                    			mydate=getdate(sec_year,iyear) %
                    			if iv==1
                    				fprintf(outxt,'%d  ',mydate(1));
    								fprintf(outxt,'%d  ',mydate(2));
    								fprintf(outxt,'%d  ',mydate(3));
    								fprintf(outxt,'%d  ',mydate(4));
    								fprintf(outxt,'%d  ',mydate(5));                            	
    								fprintf(outxt,'%f  ',lon(ix,iy));
    								fprintf(outxt,'%f  ',lat(ix,iy));


                            end % end north and south boundary
                    	end  % end west and east boundary 
                    end % end condition for valid value
                end % end loop for lat
            end % end loop for lon
        end % end loop for variables
    end  % end loop for files
end % end loop of year



