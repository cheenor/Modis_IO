% this code get the data from MODIS MOD04 dataset based on the code get_infor_MOD04.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Ã£â�??Ã£â�??Ã£â�??Ã£â�??Ã£â�?
clear;
clc ;
% 
%set the indexs for variables your want
%the indiex includes the group ID and SDS ID which can be found in the outputfile of get_infor_MOD04.m 
%for the MOD04 data, the group ID for Longitude and Latitude is 1,1
% and other variables are 1,2, therefore, WAntedInex stores the SDS of your want variables
WantedIndex=[];
WantedIndex(1)=11;
nvar=length(WantedIndex);
% set the region you want
lon_east=110.5; 
lon_west=106.5;
lat_south=33.5;
lat_north=35.5;
regionname='Guanzhong';
%----------------------------------------

%------------------------------------
foldmodis='G:\AOD\MOD04_3Km\';
outputpath='G:\AOD\domain_Mean\';

for iyy=2000:2000  % year loop 
    yearstr=num2str(iyy,'%4.4i')                               
    filenamex=strcat(foldmodis,yearstr,'\*.hdf');
    allname=dir(filenamex);
    nf=length(allname);
    foldpath=strcat(foldmodis,yearstr,'\');
    fileout=strcat(outputpath,regionname,'_',yearstr,'_monthly_mean.txt');
    iwhead=0;
    outxt=fopen(fileout,'w');
    fprintf(outxt,'%s  ','year');
    fprintf(outxt,'%s  ','month');
%    fprintf(outxt,'%s  ','day');
%    fprintf(outxt,'%s  ','hour');
%    fprintf(outxt,'%s  ','minute'); 
    sumon=zeros(nvar);
    icount=zeros(nvar);
    idate=zeros(nvar);
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
        try
            head=hdfinfo(filepath);
        catch
            head='';
        end
        if length(head.Vgroup.Vgroup)>1
            if iwhead==0
                for iv=1:nvar % loop for the variables
                    ind=WantedIndex(iv);
                    varname=head.Vgroup.Vgroup(1,2).SDS(1,ind).Name;
                    fprintf(outxt,'%s  ',varname);
                end
                fprintf(outxt,'%\n ');
                iwhead=iwhead+1;
            end                
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
                ixy=0;
                sumvar=0.;
                for ix=1:nx-1 % loop for lon
                    for iy=1:ny-1 % loop for lat                                          
                        if vardata(ix,iy) ~= defvalue && vardata(ix,iy)>= valid_range(1) && vardata(ix,iy)<= valid_range(2)  % condition for valid value
                            if lon(ix,iy)<lon_east && lon(ix,iy)>lon_west %  west and east boundary
                                if lat(ix,iy)<lat_north && lat(ix,iy)>lat_south % south and north boundary
                                    vardata(ix,iy)=vardata(ix,iy)*Scale+add_offset; % the real value of the data
                                    timesec=seconds(ix,iy)*Scale_time+add_offset_time; % seconds since 19930101 00:00:00 
                                    sec_year=timesec-nsec; %% seconds since this year 0101 00:00:00
                                    mydate=getdate(sec_year,iyear); %
                                    sumon(iv)=sumon(iv)+vardata(ix,iy); 
                                    icount(iv)=icount(iv)+1;
                                    if idate(iv)==0
                                        cdate=mydate;
                                        idate(iv)=idate(iv)+1;
                                    elseif idate(iv)>0
                                        if cdate(1) ==mydate(1) && cdate(2) ~=mydate(2)  % && cdate(5) ~= mydate(5)
                                            if iv==1 
                                                fprintf(outxt,'%d  ',cdate(1));
                                                fprintf(outxt,'%d  ',cdate(2));
%                                                fprintf(outxt,'%d  ',mydate(3));
%                                                fprintf(outxt,'%d  ',mydate(4));
%                                                fprintf(outxt,'%d  ',mydate(5));                                
                                                if icount(iv)>0 
                                                    sumon(iv)=sumon(iv)/icount(iv); 
                                                    icount(iv)=0;
                                                    idate(iv)=0;
                                                    sumon(iv)=0.;
                                                end
                                                fprintf(outxt,'%f  ',sumon(iv));
                                                if nvar==1
                                                    fprintf(outxt,'%\n');   
                                                end
                                            elseif iv<nvar
                                                if icount(iv)>0 
                                                    sumon(iv)=sumon(iv)/icount(iv);
                                                    icount(iv)=0;
                                                    idate(iv)=0;
                                                    sumon(iv)=0.;
                                                end
                                                fprintf(outxt,'%f  ',sumon(iv));
                                            elseif iv==nvar && nvar>1
                                                if icount(iv)>0
                                                    sumon(iv)=sumon(iv)/icount(iv);
                                                    icount(iv)=0;
                                                    idate(iv)=0;
                                                    sumon(iv)=0.;
                                                end
                                                fprintf(outxt,'%f  ',sumon(iv));
                                                fprintf(outxt,'\n');
                                            end % end if iv
                                            cdate=mydate;
                                        end  % end if cdate VS mydate
                                    end % end if idate
                                end % end north and south boundary
                            end  % end west and east boundary 
                        end % end condition for valid value
                    end % end loop for lat
                end % end loop for lon
            end % end loop for variables
        end  % end loop for files
    end % end length(head)
    fclose(outxt);
end % end loop of year



