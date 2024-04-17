clear all;
close all;
clc;

set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultLineLineWidth',1.25) % LineWidth
set(groot,'defaultAxesFontSize',13) % Fontsize
newcolours = ['#000080'; "#EFB810"; '#C0392B'; '#28B463'; '#3498DB'; '#8E44AD'; '#FFA07A'; '#D748DF'; '#59D13D'; '#020202' ];
colororder(newcolours)


[M1,K1,nodes1] = ReadPunchFile_n('BEAM_1.pch',3);
[M2,K2,nodes2] = ReadPunchFile_n('BEAM_2.pch',3);

nret= 25;                   % Number of retained modes
w = 2*pi*(1:1:2000);        


n1 = length(nodes1);        % Number of nodes in beam 1
n2 = length(nodes2);        % Number of nodes in beam 2
M = zeros(length(M1)+length(M2)-1);
K = zeros(length(M1)+length(M2)-1);

% K AND M MATRIX OF THE FULL SYSTEM
M(1:n1, 1:n1) = M1;
M(n1:end, n1:end) = M2;
M(n1, n1) = M1(end, end) + M2(1, 1);

K(1:n1, 1:n1) = K1;
K(n1:end, n1:end) = K2;
K(n1, n1) = K1(end, end) + K2(1, 1);

% SEPARATION BTW BOUNDARY (f) AND INTERNAL (i) DOF
Mff = [M(1, 1),0; 0, M(end, end)];
Mfi = [M(1, 2:end-1); M(end, 2:end-1)];
Mif = [M(2:end-1, 1), M(2:end-1, end)];
Mii = M(2:end-1, 2:end-1);

Kff = [K(1, 1),0; 0, K(end, end)];
Kfi = [K(1, 2:end-1); K(end, 2:end-1)];
Kif = [K(2:end-1, 1), K(2:end-1, end)];
Kii = K(2:end-1, 2:end-1);

% K AND M MATRIX ORDERED
M_cb = [Mff Mfi;Mif Mii];
K_cb = [Kff Kfi; Kif Kii];


% BOUNDARY MODES
Phi_s = [eye(size(Kff,1)) ; -inv(Kii)*Kif];

% INTERIOR MODES
[Phi_ip, D] = eig(Mii\Kii);

omega_CB = zeros(1,109);
f_CB = zeros(1,109);
Phi_ip_ord = zeros(109,109);

% must order them to retain the desired ones when reducing the system
for i = 1:109
    omega_CB(i) = sqrt(D(i,i));
    f_CB(i) = omega_CB(i)/(2*pi());
end
[f_CB,I] = sort(f_CB);
 
for i =1:109
    Phi_ip_ord(:,i) = Phi_ip(:,I(i));
end

Phi_i = [zeros(2,109) ; Phi_ip_ord];



Phi_CB = [Phi_s Phi_i];      % FULL CB MATRIX, RESULTS MUST BE = TO FEM
Phi_CB = Phi_CB(:,1:nret);   % REDUCED CB MATRIX

% M AND K CB (nret x nret):
M_CB = abs(Phi_CB'*M_cb*Phi_CB);
K_CB = abs(Phi_CB'*K_cb*Phi_CB);


F_CB = zeros(n1+n2-1,1);       
F_CB(27) = -1;                   
F_CB = Phi_CB'*F_CB;

eta_CB = zeros(length(w),length(F_CB));   % SOLUTION VECTOR IN THE MODAL SPACE
q_CB = zeros(length(w),n1+n2-1);          % SOLUTION VECTOR IN THE PHYSICAL SPACE (DISPLACEMENTS)
v_RMS_CB = zeros(1,length(w));            % RMS VELOCITY OF THE REDUCED SYSTEM
v_CB = zeros(length(w),n1+n2-1-2);        % VELOCITY OF THE REDUCED SYSTEM

% IMPOSING BC TO THE CB SYSTEM
M_CB(1:2,:) = [];
M_CB(:,1:2) = [];
K_CB(1:2,:) = [];
K_CB(:,1:2) = [];
F_CB(1:2,:) = [];

for i = 1:length(w)
        eta_CB(i,:) = [0, 0, ((K_CB - (w(i)^2)*M_CB)\F_CB)'];  % CALCULUS OF THE SOLUTION VECTOR IN THE MODAL SPACE
        q_CB(i,:) = Phi_CB*eta_CB(i,:)';                       % BACK TO THE PHYSICAL SPACE
        v_CB(i,:) = q_CB(i,3:end).*w(i)/(2*pi)*1000;           
        v_RMS_CB(i) = log10(sqrt(sum(v_CB(i,:).^2)/(size(v_CB,2)))); 
end

%% FULL FEM

F = zeros(length(Kii),1);
F(25) = -1;

[avect, omega_2] = eig(Kii,Mii);
[d,ind] = sort(diag(omega_2));
omega_2_s = omega_2(ind,ind);
avect_s = avect(:,ind);
omega = real(sqrt(diag(omega_2_s(1:10,1:10))));
FREQ =  omega/(2*pi);
modos_p = avect_s(:,1:5);

q = zeros(length(w),length(F));
v = zeros(length(w),length(F));
v_RMS = zeros(1,length(w));

for i = 1:length(w)
        q(i,:) = (Kii - (w(i)^2)*Mii)\F;
        v(i,:) = q(i,:)*w(i)/(2*pi)*1000;
        v_RMS(i) = log10(sqrt(sum(v(i,:).^2)/length(F))); 
        error(i) = sqrt(sum((v(i,:)-v_CB(i, :)).^2)/length(F));
        error_2(i) = 10*(sqrt(sum(v(i,:).^2)/length(F))-sqrt(sum(v_CB(i,:).^2)/length(F)))/(sqrt(sum(v(i,:).^2)/length(F)));
end


%% PLOTS

M_b_1_3 = [89.1, 112, 141,178,224,282, 355, 447, 562, 708, 891, 1122, 1413, 1778, 2239, 2818];%;;, 3548, 4467, 5623, 7079, 8913, 11220];



figure(1)
hold on
grid on
plot(w/(2*pi),v_RMS_CB,'LineWidth',1.5)
% for i = 1:length(w)
%     xline(w(i),':','Color','r','LineWidth',1.5)
% end 
xlabel('$$f$$ [Hz]','Interpreter','latex')
ylabel('$$\log_{10}(V_{RMS})$$ ','Interpreter','latex')
hold off

figure(2)
hold on
grid on
plot(w/(2*pi),v_RMS,'LineWidth',1.5, Color='r')
% for i = 1:length(w)
%     xline(w(i),':','Color','r','LineWidth',1.5)
% end 
xlabel('$$f$$ [Hz]','Interpreter','latex')
ylabel('$$\log_{10}(V_{RMS})$$ ','Interpreter','latex')
hold off

figure(3)
hold on
grid on
plot(w/(2*pi), v_RMS,'r', 'LineWidth',1.5)

plot(w/(2*pi), v_RMS_CB,'b', 'LineWidth',1.5, LineStyle='--')
xline(1106, 'k', LineStyle='-.', LineWidth=0.5)

legend('FEM', 'Craig-Bampton','Interpreter','latex', 'Autoupdate', 'off')
colors = ["blue", "yellow"];

cc=1;
for i = 1:15
    if cc ==3
        cc=1;
    end
    x_ecl = [M_b_1_3(i), M_b_1_3(i+1), M_b_1_3(i+1), M_b_1_3(i)];
    y_ecl = [-1e20, -1e20, log10(max(v_RMS)), log10(max(v_RMS))];
    patch(x_ecl,10.^y_ecl, colors(cc),'EdgeColor','none','FaceAlpha',.2)
    cc = cc+1;
end

ylim([0,(max(v_RMS))])
xlim([0, 2000])
xlabel('$$f$$ [Hz]','Interpreter','latex')
ylabel('$$\log_{10}(V_{RMS})$$ ','Interpreter','latex')
hold off


figure(9)
hold on
grid on
plot(w/(2*pi), abs(v_RMS-v_RMS_CB)./v_RMS*100,'k', 'LineWidth',1.5)
xline(1106, 'r', LineStyle='-.', LineWidth=0.5)
yline(1, 'b', LineStyle=':')
xlabel('$$f$$ [Hz]','Interpreter','latex')
ylabel('$$Error$$ [\%] ','Interpreter','latex')
hold off
hold off

figure(10)
hold on
grid on
plot(w/(2*pi), log10(error_2),'k', 'LineWidth',1.5)
xline(1106, 'r', LineStyle='-.', LineWidth=0.5)
xlabel('$$f$$ [Hz]','Interpreter','latex')
ylabel('$$\log_{10}(E)$$ ','Interpreter','latex')
hold off
hold off


figure(11)
hold on
grid on
plot(linspace(0, 1.1, 111), [0,q(500, :),0]*1000,'k', 'LineWidth',1.5)
yline(0, LineStyle='-.', LineWidth=0.5)
xline(0.25, LineStyle='--', LineWidth=0.5,Color='r')
xline(0.5, LineStyle='--', LineWidth=0.5,Color='b')
xlabel('$$x$$ [m]','Interpreter','latex')
ylabel('$$q$$ [mm]','Interpreter','latex')
xlim([0, 1.1])
hold off
FREQ_CB = f_CB(1:10)';
ERROR = (FREQ-FREQ_CB)./FREQ;
A=[FREQ, FREQ_CB, ERROR]
tab = latex(sym(A))


%% FUNCTIONS



function [MASS,STIFFNESS,nodes] = ReadPunchFile_n(punchfile,dof)

%READUNCHFILE_ND Read Mass and Stiffness matrices from punch file generated by MSC Nastran.
%    [MASS,STIFFNESS,nodes] = ReadPunchFile_nD(punchfile,dof) reads data from a Nastran punch file
%    'punchfile' providing the MASS and STIFFNESS matrices on the degrees of freedom 'dof' ordered as the array 'nodes'
%    and for each node as ordered in 'dof'
%
%	 * IMPORTANT NOTE *
%	 Node numbers should be above 6 (1 from 6 reserved for degrees of freedom)
%
disp(['Reading Mass and Stiffness Matrices from file ' punchfile(1:find(punchfile=='.')-1)]);
% -------------------------------------------------------------------------
% FIND OUT THE START AND END OF THE MASS MATRIX SECTION
% -------------------------------------------------------------------------
file=textread(punchfile,'%s','delimiter','\n','whitespace','');
found_start = 0;
found_end = 0;
pos=0;
%
while found_start==0 || found_end==0
    pos=pos+1;
    if file{pos}(1)=='D'
        if file{pos}(1:12)=='DMIG*   MAAX'
            % First row of Mass Matrix section starts with 'DMIG*   MAAX'
            if found_start==0
                found_start=1;
                startline=pos;
            end
        end
        if file{pos}(1:12)=='DTI     TUG1';
            % First row AFTER Mass Matrix section starts with 'DMIG    VAX'
            found_end=1;
            endline=pos-1;
        end
    end
end

% READ OF THE MASS MATRIX SECTION
[col1,col2,col3,col4] = textread(punchfile,'%s%s%u%f',endline-startline+1,'delimiter',' ','headerlines',startline-1);
% For each data row and columns of the Mass Matrix are defined and stored
% into MASS
nodes_aux = col3(find(col3>6));
nodes = unique(nodes_aux);
Ndof = length(nodes)*length(dof);
MASS = zeros(Ndof,Ndof);
h1 = waitbar(0,'Reading mass matrix');
for p=1:length(col3),
   waitbar(p/length(col3),h1);
   if(ismember(col3(p),nodes)),

        % Start line for new node
        n=find(nodes==col3(p));
        row = length(dof)*(n-1)+find(dof==col4(p));
   else
        
        % Set of columns for previous node
        n=find(nodes==str2num(cell2mat(col2(p))));
        column = length(dof)*(n-1)+find(dof==col3(p));
        value=col4(p);
        MASS(row,column)=value;
        if row~=column,
            MASS(column,row)=value;
        end
   end
end
close(h1);
% FIND OUT THE START AND END OF THE STIFFNESS MATRIX SECTION
% -------------------------------------------------------------------------
file=textread(punchfile,'%s','delimiter','\n','whitespace','');
found_start = 0;
found_end = 0;
pos=0;
while found_start==0 || found_end==0,
    pos=pos+1;
    if file{pos}(1)=='D',
        if file{pos}(1:12)=='DMIG*   KAAX';
            % First row of Stiffness Matrix section starts with 'DMIG*   KAAX'
            if found_start==0,
                found_start=1;
                startline=pos;
            end
        end
        if file{pos}(1:12)=='DMIG    MAAX';
            % First row AFTER Stiffness Matrix section starts with 'DMIG    MAAX'
            found_end=1;
            endline=pos-1;
        end
    end
end
% READ OF THE STIFFNESS MATRIX FILE SECTION
[col1,col2,col3,col4] = textread(punchfile,'%s%s%u%f',endline-startline+1,'delimiter',' ','headerlines',startline-1);
% For each data row and columns of the Mass Matrix are defined and stored into STIFFNESS
STIFFNESS = zeros(Ndof,Ndof);
h2 = waitbar(0,'Reading stiffness matrix');
for p=1:length(col3),
   waitbar(p/length(col3),h2);
   if(ismember(col3(p),nodes)),

        % Start line for new node
        n=find(nodes==col3(p));
        row = length(dof)*(n-1)+find(dof==col4(p));
   else

        % Set of columns for previous node
        n=find(nodes==str2num(cell2mat(col2(p))));
        column = length(dof)*(n-1)+find(dof==col3(p));
        value=col4(p);
        STIFFNESS(row,column)=value;
        if row~=column,
            STIFFNESS(column,row)=value;
        end
   end
end
close(h2);
end

   