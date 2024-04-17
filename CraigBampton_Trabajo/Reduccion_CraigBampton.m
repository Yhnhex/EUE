M = [1 0 0 0 0 0 0 0 ;
     0 1 0 0 0 0 0 0 ;
     0 0 1 0 0 0 0 0 ;
     0 0 0 1 0 0 0 0 ;
     0 0 0 0 5 0 0 0 ;
     0 0 0 0 0 10 0 0 ;
     0 0 0 0 0 0 10 0 ;
     0 0 0 0 0 0 0 10 ];

k = 100000 ; 
K = [k -k 0 0 0 0 0 0 ;
    -k 2*k 0 0 0 -k 0 0  ;
     0 0 k -k 0 0 0 0 ;
     0 0 -k 2*k 0 -k 0 0 ;
     0 0 0 0 5*k -5*k 0 0 ;
     0 -k 0 -k -5*k 17*k -10*k 0 ;
     0 0 0 0 0 -10*k 30*k -20*k ;
     0 0 0 0 0 0 -20*k 20*k];
 
% Reordenamos en orden (Xb = X8, Xi = X1-X7)

Kii = K(1:7,1:7);
Kij = K(1:7,8);
Kji = K(8,1:7);
Kjj = K(8,8);
Mii = M(1:7,1:7);
Mij = M(1:7,8);
Mji = M(8,1:7);
Mjj = M(8,8);

K_t = [Kjj Kji ;
       Kij Kii]
M_t = [Mjj Mji ;
       Mij Mii]

%% TRANSFORMACION CB

    %% MODOS RESTRINGUDOS (CONSTRAINTS MODES)
    
Phi_s = [1 ; -inv(Kii)*Kij];
    
    %% MODOS INTERIORES CON FRONTERA FIJA (INTERIOR MODES)

[Phi_ip, D] = eig(inv(Mii)*Kii)

for i = 1:7
    omega(i) = sqrt(D(i,i))
    f(i) = omega(i)/(2*pi())
end
[f,I]= sort(f)
 
for i =1:7
    Phi_ip_ord(:,i) = Phi_ip(:,I(i));
end

Phi_i = [zeros(1,7) ;
         Phi_ip_ord]; % Matriz de modos fijos     

% La matriz de CB queda:

Phi_CB = [Phi_s Phi_i];

% Transformar matrices de masa y rigidez:

M_CB = abs(Phi_CB'*M_t*Phi_CB);
K_CB = abs(Phi_CB'*K_t*Phi_CB);

% Matriz de factores de participación y masas generalizadas

L = M_CB(2:end,1);
mg = M_CB(2:end,2:end);

% Masas modales efectivas
for i =1:7
   M_eff(i) = (L(i)^2)/mg(i,i);
end
    
    
    
    
    
