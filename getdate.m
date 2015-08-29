function mydate=getdate(secs,year); 
    % the day number for everymonth
    dayscl=24*60*60;
    nmday=[];
    for im=1:12
        nmday(im)=31;
    end
    nmday(4)=30;
    nmday(6)=30;
    nmday(9)=30;
    nmday(11)=30;
    nmday(2)=28;
    if (mod(year,4)==0. && mod(year,100)~=0. ) || (mod(year,400)==0.)
        nmday(2)=29;
    end
%
    msec1=0;
    msec2=0;
    msec0=0;
    for im=1:11
        msec1=msec1+nmday(im)*dayscl;
        msec2=msec1+nmday(im+1)*dayscl;
        msec0=msec1-nmday(im)*dayscl;
        if secs>msec1 && secs <= msec2 
            mon=im+1;
            sec_dd=secs-msec1;
            break;
        elseif secs>msec0 && secs<= msec1
            mon=im;
            sec_dd=secs-msec0;
            break;
        end
    end
    dd=fix(sec_dd/dayscl);
    sec_hh=mod(sec_dd,dayscl);
    hh=    fix(sec_hh/3600);
    sec_mm=mod(sec_hh,3600);
    mm=fix(sec_mm/60);
    ss=mod(sec_mm,60);
    % results
    mydate(1)=year;
    mydate(2)=mon;
    mydate(3)=dd;
    mydate(4)=hh;
    mydate(5)=mm;
    mydate(6)=ss;

           