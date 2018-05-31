%将接收信号强度转化为距离
%发射信号经衰减到达接收端,根据接收信号的强弱计算T-R距离

%接收功率Pr本应由实际测量而得
%但在没有实验设备的情况下,也可以利用假定的未知节点得出模拟测量值
%方法为:根据假定的未知节点位置,各信标节点得到精确的接收功率
%在此基础上加上高斯随机变量作为环境干扰,将此接收功率作为Pr的测量值
%再将Pr的测量值作为RSSI来求出T-R距离

%将区域划分为若干个邻的三角形,将信标节点分别置于三角形的顶点
%也可以说是将传感器节点随意但尽量均匀地投放在区域中,经过自身定位后作为信标节点
%未知节点向周围发射定位信号,各信标节点接收后利用RSSI测距算法得到它们距未知节点的距离
%从这些距离中选取三个最小的距离,将其对应的信标节点作为选定信标节点
%以保证未知节点在选定信标节点构成的三角形内部
%以下程序中的T-R距离都指的是选定信标节点与未知节点的距离

function [r] = Distance(d,a)

   PtW = 10e2; %单位是W。
    Pt = 10*log10(PtW); %单位是dB  %发射功率
    f = 4.33*10^8; %载频,单位是Hz
    n = 3.1; %路径损耗指数
    d0 = 1; %近地参考距离,单位是m
    %d = 100*sqrt(13) %选定信标节点与未知节点之间的精确T-R距离,单位是m
    c = 3*10^8; %光速,单位是m/s
    lamida = c/f; %波长,单位是m
    Gt = -10;Gr = -10;L = 1; %Gt为发射天线增益;Gr为接收天线增益;L为与传播无关的系统损耗因子(不小于1)

    %PL0为近地参考距离的路径损耗
    %PrW = PtW*Gt*Gr*lamida^2/((4*pi)^2*d0^2*L) %单位是W
    %PL0 = 10*log10(Pt/Pr) %单位是dB
    PL0 = -10*log10(Gt*Gr*lamida^2/((4*pi)^2*d0^2*L)); %单位是dB
    Pr0 = Pt-PL0; %单位是dB   the receive power

    %PL为精确T-R距离的路径损耗;Pr为信标节点的接收功率
    PL = PL0+10*n*log10(d/d0); %单位是dB
    Pr = Pt - PL; %单位是dB
    PrW = 10^(Pr/10); %单位是W
    
    %RSSI为接收信号强度指示,此处为包含高斯随机变量的接收功率
    %Xn为零均值的高斯分布随机变量,标准差为cigema
    %PrG为加上高斯随机变量的接收功率,利用它来模拟接收功率的测量值,单位是dB
    cigema = 3; %单位是dB
    N = 5e3;
    Xn = normrnd(0,cigema,N,1);  % R＝normrnd(MU,SIGMA,m,n)： 生成m×n形式的正态分布的随机数矩阵。
    X = mean(Xn); %均值
    PrG = Pr+X; %单位是dB
    PrGW = 10^(PrG/10); %单位是W
    RSSI = PrGW; %单位是W
    
    %r为求出的T-R距离;a为参数,随距离范围而改变
    %RSSI ＝ a*(1/r)^2
    %a = 7; %在所选信标节点的距离范围内,经反复测试,此参数较为合适
    r = 1/sqrt(RSSI/a);
end