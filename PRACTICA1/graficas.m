set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultLineLineWidth',1.25) % LineWidth
set(groot,'defaultAxesFontSize',20) % Fontsize

w_1D =[2.892143E+02;...        
     2.892143E+02;...         
     2.499072E+03;...         
     7.003414E+03;...         
     7.003414E+03;...         
     1.774390E+04;...         
     1.774390E+04;...         
     2.689623E+04;...         
     2.976960E+04;...         
     2.976960E+04  ];
w_2D = [  2.974520E+02;...  
         2.974520E+02;...  
         2.528463E+03;...  
         5.178675E+03;...  
         5.178676E+03;...  
         7.067173E+03;...  
         7.067174E+03;...  
         8.172753E+03;...  
         9.905650E+03;...  
         9.905662E+03 ];
f_1D=w_1D/2/pi;
f_2D = w_2D/2/pi;
error = abs(f_2D-f_1D)./f_2D*100;

x=linspace(1, 10, 10);

figure(1)
hold on
grid on
plot(x, f_1D, Color='b')
plot(x, f_2D, Color='r')
plot(1, 47.7172, Marker="+", Color='k')
plot(2, 47.7172, Marker="+", Color='k')
plot(3, 397.77, Marker="+", Color='k')

legend('1D', '2D')
xlabel('Frequency index', 'Interpreter','latex')
ylabel('$$f$$ [Hz]', 'Interpreter','latex')
xlim([1,10])
hold off

figure(2)
hold on
grid on
plot(x, error, Color='k')
xlabel('Frequency index', 'Interpreter','latex')
ylabel('Error [\%]', 'Interpreter','latex')
xlim([1,10])
hold off 

WW=[f_1D, f_2D, error]

A=latex(sym(WW))

%%
w0=727.437;
WW = 20;

A = 4.5*9.81;
g = 0.015;
t= linspace(1, 100000, 1000);
n=0;
% q_p=zeros(length(t), 5);
freqs=[5, 25, 50, 75, 100];

    n=n+1
        
    WW= 2*pi*100;
    q_p = (A)* WW^2/ (w0^2 *sqrt(((1 - (WW/w0)^2)^2) + ((2*g*(WW/w0))^2))) 


figure(5)
hold on
grid on
plot(t, sin(2*pi*t), Color='b')
plot(1:10000, q_p(:,2), Color='r')
plot(1:10000, q_p(:,3), Color='g')
plot(1:10000, q_p(:,4), Color='y')
plot(t, 3.2681E-4 *sin(2*pi*t*100), Color='k')


legend('5', '25', '50', '75', '100')
xlabel('t', 'Interpreter','latex')
ylabel('$$q$$ [Hz]', 'Interpreter','latex')
xlim([1,10])
hold off

fid = readmatrix("EJEMPLO2\SINUSOIDAL\pto30.txt")

