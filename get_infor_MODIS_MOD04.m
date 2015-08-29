% this code get the basic information from MODIS MOD04 dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ã€??ã€??ã€??ã€??ã€?
clear
clc 
% 
filename='E:/DATA/MOD04_3K.A2000055.0515.006.2014307170648.hdf';
head=hdfinfo(filename);
fileOut=strcat('E:/DATA/MOD04_3K_Info.txt');
outxt=fopen(fileOut,'w');
fprintf(outxt,'%s  ','Name');
fprintf(outxt,'%s  ','Group_ID');
fprintf(outxt,'%s  ','SDS_ID');
fprintf(outxt,'%s  ','Size');
fprintf(outxt,'%s  ','Scale');
fprintf(outxt,'%s  ','add_offset');
fprintf(outxt,'%s  ','valid_range');                            	
fprintf(outxt,'%s  ','unit');
fprintf(outxt,'%s\n','');

%Get lon and lat
for ind=1:2
	vname=head.Vgroup.Vgroup(1, 1).SDS(1, ind).Name;
	nx=head.Vgroup.Vgroup(1, 1).SDS(1, ind).Dims(1,1).Size;
	ny=head.Vgroup.Vgroup(1, 1).SDS(1, ind).Dims(2,1).Size;
	strxy=strcat(num2str(nx),'X',num2str(ny));
	defvalue=head.Vgroup.Vgroup(1, 1).SDS(1, ind).Attributes(1,2).Value;
	Scale=head.Vgroup.Vgroup(1, 1).SDS(1, ind).Attributes(1,5).Value;
	add_offset=head.Vgroup.Vgroup(1, 1).SDS(1, ind).Attributes(1,6).Value;
	minv=head.Vgroup.Vgroup(1, 1).SDS(1, ind).Attributes(1,1).Value(1);
	maxv=head.Vgroup.Vgroup(1, 1).SDS(1, ind).Attributes(1,1).Value(2);
	valid_range=strcat(num2str(minv),'_to_',num2str(maxv));
	unit=head.Vgroup.Vgroup(1, 1).SDS(1, ind).Attributes(1,4).Value;
	fprintf(outxt,'%s  ',vname);
	fprintf(outxt,'%s  ','1,1');
	fprintf(outxt,'%s  ',strcat('1,',num2str(ind)));
	fprintf(outxt,'%s  ',strxy);
	fprintf(outxt,'%f  ',Scale);
	fprintf(outxt,'%f  ',add_offset);
	fprintf(outxt,'%s  ',valid_range);                            	
	fprintf(outxt,'%s  ',unit);
	fprintf(outxt,'%s\n','');
end
nvar=length(head.Vgroup.Vgroup(1, 2).SDS());
for ind=1:nvar
	vname=head.Vgroup.Vgroup(1, 2).SDS(1,ind).Name;
	strxy=''
	ndm=length(head.Vgroup.Vgroup(1, 2).SDS(1, ind).Dims(:,1))
	for idm=1:ndm
		j=head.Vgroup.Vgroup(1, 2).SDS(1, ind).Dims(idm,1).Size;
		if idm==1
			strxy=num2str(j)
		else
			strxy=strcat(strxy,'X',num2str(j));
		end
	end
	defvalue=head.Vgroup.Vgroup(1, 2).SDS(1, ind).Attributes(1,2).Value;
	Scale=head.Vgroup.Vgroup(1, 2).SDS(1, ind).Attributes(1,5).Value;
	add_offset=head.Vgroup.Vgroup(1, 2).SDS(1, ind).Attributes(1,6).Value;
	minv=head.Vgroup.Vgroup(1, 2).SDS(1, ind).Attributes(1,1).Value(1);
	maxv=head.Vgroup.Vgroup(1, 2).SDS(1, ind).Attributes(1,1).Value(2);
	valid_range=strcat(num2str(minv),'to',num2str(maxv) );
	unit=head.Vgroup.Vgroup(1, 2).SDS(1, ind).Attributes(1,4).Value;
	fprintf(outxt,'%s    ',vname);
	fprintf(outxt,'%s    ','1,2');
	fprintf(outxt,'%s    ',strcat('1,',num2str(ind)));
	fprintf(outxt,'%s    ',strxy);
	fprintf(outxt,'%f    ',Scale);
	fprintf(outxt,'%f    ',add_offset);
	fprintf(outxt,'%s    ',valid_range);                            	
	fprintf(outxt,'%s    ',unit);
	fprintf(outxt,'%s\n','');
end
fclose(outxt)