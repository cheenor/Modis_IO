% this code get the data from MODIS MOD04 dataset based on the code get_infor_MOD04.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%脙拢芒鈥??脙拢芒鈥??脙拢芒鈥??脙拢芒鈥??脙拢芒鈥?
clear;
clc; 
% 
%set the indexs for variables your want
%the indiex includes the group ID and SDS ID which can be found in the outputfile of get_infor_MOD04.m 
%for the MOD04 data, the group ID for Longitude and Latitude is 1,1
% and other variables are 1,2, therefore, WAntedInex stores the SDS of your want variables
WantedIndex=[]; % 声明数组
WantedIndex(1)=11;  % 给数组指定的元素赋值  ，每个元素指的是数组的每个变量
nvar=length(WantedIndex); % 数组的总长度，下面的循环要用到
% set the region you want
lon_east=110.0; 
lon_west=100.0;
lat_south=40.0;
lat_north=30.0;  % 显示区域的大小
% -------------- core box of Guanzhong -----------
lonbox=[106.5, 110.5];
latbox=[33.5,35.5];   %关中地区的经纬度范围
%------ box of Guanzhong ---------------------
loncentbox=[106.5,110.5,110.5,106.5,106.5];
latcentbox=[35.5,35.5,33.5,33.5,35.5];  %图中用矩形标注的区域
%-- set the contour levels you want--------------------------------------
%vlev=[0.1,0.2,0.3,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.5];
%%---------------------------------------------------------
vlev=0.0:0.05:2;  % vlev是一个数组，等间隔，最小是0 ，最大2，间隔是0.05
nl=length(vlev);  % vlev长度
colors=colormap(jet);  % matlab中 默认的色标卡jet的颜色设定，默认为64种颜色
mymap=colormap(jet(nl)); % 取得jet色标卡 分为nl种颜色的设置
%----------上面是设定等值线的数值，目前没有用到
foldpath0='G:\AOD\MOD04_3Km\'; % 数据路径
picout='G:\AOD\PIC\';  % 图片保存路径
for iyy=2008:2015  % 年份循环
	yearstr=num2str(iyy,'%4.4i') %年份（整数）转为字符串， 用于文件名以及图片上的说明文字
	filenamex=strcat(foldpath0,yearstr,'\*.hdf'); % 文件的路径 ，文件名*.hdf
    foldpath=strcat(foldpath0,yearstr,'\'); %每年文件的路径（不含文件名）
	allname=dir(filenamex); % 获取文件夹下所有hdf格式的文件名
	nf=length(allname); % 文件个数
% ---- read the china shape data---------
	chinashp='E:\DATA\China_shp\1\bou2_4p'; % 中国地图shape文件的路径
	chinamap=shaperead(chinashp);  %  读取地区shape文件，
	ncx=[chinamap(:).X]; % 获取地图信息
	ncy=[chinamap(:).Y]; % 获取地图信息
%---------------------------------------
	for n=1:nf
		filename=allname(n).name; % 文件名
		yearstr=filename(11:14);  % 获取文件名中第11到14个字符，并存储在yearstr里
		jdaystr=filename(15:17);
		hourstr=filename(19:20);
		minstr=filename(21:22);
		filepath=strcat(foldpath,filename); % 链接文件所在文件夹和文件名 得到文件的全路径
        try
            head=hdfinfo(filepath); 
        catch
            head=''
        end  % 从try到这里，是保证在有文件损坏不能正确打开的情况下，程序不会断掉
            % 具体： 当文件损坏时，head=hdfinfo(filepath)会出现错误，这是程序不报错，而是执行carch 后面的语句
% get the Longitude and Latitude 
        if length(head)>1
            varname=head.Vgroup.Vgroup(1, 1).SDS(1,1).Name; % 变量名 这个具体要结合数据的具体结构来确定
            lon=hdfread(filepath,varname); % 读取变量
            varname=head.Vgroup.Vgroup(1, 1).SDS(1,2).Name;
            lat=hdfread(filepath,varname);
            nx=head.Vgroup.Vgroup(1, 1).SDS(1,1).Dims(1,1).Size;
            ny=head.Vgroup.Vgroup(1, 1).SDS(1,1).Dims(2,1).Size;
% get the time
            varname=head.Vgroup.Vgroup(1,2).SDS(1,1).Name;
            seconds=hdfread(filepath,varname); %get the data!
            Scale_time=head.Vgroup.Vgroup(1,2).SDS(1,1).Attributes(1,5).Value; %
            add_offset_time=head.Vgroup.Vgroup(1,2).SDS(1,1).Attributes(1,6).Value; %
% -----
            ind=11;
            varname=head.Vgroup.Vgroup(1,2).SDS(1,ind).Name;
            vardata=hdfread(filepath,varname); %get the data!
            Scale=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,5).Value; %
            add_offset=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,6).Value; %
%%%%  NOTE: the real data is  vardata*Scale+add_offset 
%        vardata=vardata*Scale+add_offset ;
            valid_range=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,1).Value; % min and max
            defvalue=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,2).Value; % default value 
            igz=0; % 关中地区有数据的点 
            for ix=1:nx;  
                for iy=1:ny;
                    if vardata(ix,iy)>valid_range(1)&& vardata(ix,iy)<valid_range(2) && vardata(ix,iy)~=defvalue
                        if lon(ix,iy)>lonbox(1) && lon(ix,iy)<lonbox(2) && lat(ix,iy)>latbox(1) && lat(ix,iy)<latbox(2)		    
                            igz=igz+1;
                        end
                    end
                end
            end % 这部分检查核心的关中地区有多少个数据
            %
            if igz>0 %关中地区至少有一个数据
                timestr=['Y',yearstr,'D',jdaystr,' ',hourstr,':',minstr]; % []连接字符串，和strcat的区别是，strcat会先去掉也每个字符串右边的空格，再连接
                datestrs=strcat(yearstr,jdaystr,hourstr,minstr); % strcat 连接字符串
                for iv=1:nvar
                    clf; % 清除画图窗口
                    ind=WantedIndex(iv); % 变量的指示，根据数据结构得到
                    varname=head.Vgroup.Vgroup(1,2).SDS(1,ind).Name;
                    vardata=hdfread(filepath,varname); %get the data!
                    Scale=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,5).Value; %
                    add_offset=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,6).Value; %
%%%%  NOTE: the real data is  vardata*Scale+add_offset 
%        vardata=vardata*Scale+add_offset ;
                    valid_range=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,1).Value; % min and max
                    defvalue=head.Vgroup.Vgroup(1,2).SDS(1,ind).Attributes(1,2).Value; % default value 
                    vardata(vardata<valid_range(1) | vardata>valid_range(2) )=NaN;
                    vardata(vardata==defvalue)=NaN;
                    vardata=vardata*Scale+add_offset;
                    x1=min(min(vardata)); % 最小值
                    x2=max(max(vardata)); % 最大值
                    if x1~=x2 % 如果数组的最大值和最小值是相等的，说明数组是等值的
%----------------  plotting data on the map ------------------------------------------------
                        figure(1);%打开画图窗口，代号为1
                        m_proj('Lambert','lon',[105 115],'lat',[30 40]); % 设定地图的区域 105-110， 30-40
                        m_contourf(lon,lat,vardata,'LineStyle','none') %,vlev) % ,clev); %%    [CS,H] = M_CONTOURF(...) returns contour matrix C as described in 
												%    CONTOURC and a vector H of handles to PATCH objects (for use by CLABEL).
                        caxis([0.2 2]); % 色彩显示范围
%                       colormap(mymap);
                        hh=colorbar('eastoutside','Position',[0.9,0.4,0.03,0.5]); %色标，东边，位置为[0.9,0.4,0.03,0.5]，左下角为0，0， 右上角为1，1
                        hold on; 
                        m_plot(ncx,ncy,'color','k'); % 画地图
                        m_line(loncentbox,latcentbox,'linewidth',2,'color','r'); % 画框框，线条宽度为2 颜色为‘r’ 红色
                        m_grid;	% 转化为地图格点	
                        titlestr=['MOD04_3K ',varname,' ',timestr]; % 图上的title
                        titlestr=strrep(titlestr,'_','\_'); % 把_ 换成为\_ ,  _前不加\表示下标
                        title(titlestr,'fontsize',14); % 写标题， 字体大小为14 pionts
                        picpath=[picout,'MOD04_3K_',varname,'_',datestrs,'.png']; % 输出图片的全路径
                        print(1,'-dpng','-r300',picpath); % 输出图片，-dpng 表示输出png格式，-r300 表示输出图片质量，分辨率为300dpi
                        close(figure(1)); % 关闭画图窗口1
                    end
                end
            end
        end    
    end
end



