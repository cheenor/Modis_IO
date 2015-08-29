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
foldpath='E:\DATA\MOD04\';
filenamex=strcat(foldpath,'*.hdf');
allname=dir(filenamex);
nf=length(allname);
for n=1:nf
	filename=allname(n).name;
	yearstr=filename(11:14);
	iyear=str2num(yearstr);
	nsec=0;
	for iy=1993:(iyear-1);
		nday=365;
		if (mod(iy,4)==0 & mod(iy,100)~=0) || (mod(iy,400)==0) 
			nday=366;
		end
        nsec=nsec+nday*24*60*60;
	end	
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
	for iv=1:nvar
		ind=WantedIndex(iv);
		varname=head.Vgroup.Vgroup(1,2).SDS(1,ind).Name;
		vardata=hdfread(filepath,varname); %get the data!
		Scale=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,5).Value; %
		add_offset=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,6).Value; %
%%%%  NOTE: the real data is  vardata*Scale+add_offset 		
		valid_range=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,1).Value; % min and max
		defvalue=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,2).Value; % default value 
		for ix=1:nx
			for iy=1:ny
				if vardata(ix,iy) ~= defvalue & vardata(ix,iy)>= valid_range(1) & vardata(ix,iy)<= valid_range(2) 
					if lon(ix,iy)<lon_east & lon(ix,iy)>lon_west %  west and east boundary
                    	if lat(ix,iy)<lat_north & lat(ix,iy)>lat_south % south and north boundary
                    		timesec=seconds(ix,iy)*Scale_time+add_offset_time; % seconds since 19930101 00:00:00 
                    		sec_year=timesec-nsec;

                    	end
                    end
                end
            end
        end
    end
end



