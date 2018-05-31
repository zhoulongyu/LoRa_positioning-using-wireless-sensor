%信标节点位于直角三角形顶点的仿真
clc
clear all
%A,B,C为三个选定的信标节点,节点坐标已知(为便于防真及验证,代码中采用的等边三角形)
for t = 1:5
    A = [0,0];
    B = [0,50];
    C = [50,0];
    nums = [A(1),A(2),B(1),B(2),C(1),C(2)];
    p = min(nums);  %p = 0
    q = max(nums);  %q = 50
    L = sqrt((A(1)-C(1))^2+(A(2)-C(2))^2);  %A--->C The distance is 50m
    m = 5;
    %生成在[p,q]上满足均匀分布的随机数矩阵
    %即生成一组m行2列的有可能落在等边三角形区域内的坐标
    numbox = p+(q-p)*rand(m,2);%生成在0-50之间的随机数
    
    %计数初值,最终根据计算将随机生成的点中落在等边三角形区域内的坐标存放于新的矩阵
    n = 1;
    for i = 1:m
        dA(i) = sqrt((numbox(i,1)-A(1))^2+(numbox(i,2)-A(2))^2);
        dB(i) = sqrt((numbox(i,1)-B(1))^2+(numbox(i,2)-B(2))^2);
        dC(i) = sqrt((numbox(i,1)-C(1))^2+(numbox(i,2)-C(2))^2);
        %将确实在等边三角形区域内的坐标存入P_position矩阵
        if (dA(i)<=L) & (dB(i)<=L) & (dC(i)<=L)
            P_position(n,1) = numbox(i,1);
            P_position(n,2) = numbox(i,2);
            n = n+1;
        end
    end
    %N为随机生成的点中落在等边三角形区域内的点(测试点)的个数
    N = n-1
    if N == 0
        disp('所取的随机坐标无一落在等边三角形内,请增大m值重新运行程序.')
        return
    end

    %计算测试点离三个顶点的实际距离
    %dis为N行3列的矩阵,用于存放N个测试点分别到等边三角形三个顶点A,B,C的实际距离
    for i = 1:N
        dis(i,1) = sqrt((P_position(i,1)-A(1))^2+(P_position(i,2)-A(2))^2);
        dis(i,2) = sqrt((P_position(i,1)-B(1))^2+(P_position(i,2)-B(2))^2);
        dis(i,3) = sqrt((P_position(i,1)-C(1))^2+(P_position(i,2)-C(2))^2);
    end

    %根据函数Distance计算测试点离三个顶点的测试距离(考虑了衰减及环境误差等)
    %dis_test为N行3列的矩阵,用于存放N个测试点分别到等边三角形三个顶点A,B,C的测试距离
    a = 7; %由RSSI计算T-R距离时使用的参数
    for i = 1:N
        dis_test(i,1) = Distance(dis(i,1),a);
        dis_test(i,2) = Distance(dis(i,2),a);
        dis_test(i,3) = Distance(dis(i,3),a);
    end
    
    %根据函数Triangle及求得的测试距离进行定位
    %P_calculate为N行2列的矩阵,用于存放定位后的N个坐标
    for i = 1:N
        P_temp = Triangle(A,B,C,dis_test(i,1),dis_test(i,2),dis_test(i,3));
        P_calculate(i,1) = P_temp(1);
        P_calculate(i,2) = P_temp(2);
    end

    %由于测试距离相比真实距离有误差,三角计算中的两圆有可能无交点,导致方程无实根.
    %于是P_calculate中会出现虚数.在测试中虚数无实际意义,因此取其实部存放于另一矩阵
    for i = 1:N
        P_calculate_real(i,1) = real(P_calculate(i,1));
        P_calculate_real(i,2) = real(P_calculate(i,2));
    end

    %对比测试点的定位坐标与实际坐标之间的误差
    P_position;
    P_calculate;
    P_calculate_real;
    %计算定位结果与真实坐标之间的距离误差平均值e_average(测试点等概率)
    e_sum = 0;
    for i = 1:N
        e = sqrt((P_calculate_real(i,1)-P_position(i,1))^2+(P_calculate_real(i,2)-P_position(i,2))^2);
        e_sum = e_sum+e;
    end
    e_average = e_sum/N;
    e_average_percent = e_average/L;
    
    e_average_box(t) = e_average
    e_average_percent_box(t) = e_average_percent
end

x = [1:5:25];
e_average_box(t) = e_average;
y = e_average_box(t);
plot(x,y,'b-')