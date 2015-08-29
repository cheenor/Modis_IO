clc;
clear;
secs=24*60*60*32+5;
year=1999;
mydate=getdate(secs,year);
mydate
varout={};
varout{1}=fopen('E:\test1.txt','w');
varout{2}=fopen('E:\test2.txt','w');
fprintf(varout{1},'%s  ','a');
fprintf(varout{2},'%s  ','b');
fclose(varout{1});
fclose(varout{2});
