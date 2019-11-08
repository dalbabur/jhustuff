global const
const.alpha0 = .216;
const.n = 2;
const.alpha = 216;
const.beta = 5;

M.tetR =0;
M.numdacl =0;
M.lacI =0;

P.tetR =0;
P.numdacl =0;
P.lacI =0;

t = linspace(0,400,100000);
delta_t = 400/length(t);
M_out = zeros(3,length(t));
P_out = zeros(3,length(t));

M_temp = 0;
P_temp = 0;
P_rep = 0;

for k = 1:length(t)

        M_temp = M.tetR; 
        P_temp = P.tetR;
        P_rep = P.lacI; 
        [M_temp,P_temp] = rungekutta_repressilator(M_temp,P_temp,P_rep,@ode_M,@ode_P,delta_t);
        M_out(1,k) = M_temp; 
            P_out(1,k) = P_temp; 
        M.tetR = M_temp;
        P.tetR = P_temp; 
        
        M_temp = M.numdacl; 
        P_temp = P.numdacl;
        P_rep = P.tetR; 
        [M_temp,P_temp] = rungekutta_repressilator(M_temp,P_temp,P_rep,@ode_M,@ode_P,delta_t);
        M_out(2,k) = M_temp; 
        P_out(2,k) = P_temp; 
        M.numdacl = M_temp;
        P.numdacl = P_temp; 
        
        M_temp = M.lacI; 
        P_temp = P.lacI;
        P_rep = P.numdacl; 
        [M_temp,P_temp] = rungekutta_repressilator(M_temp,P_temp,P_rep,@ode_M,@ode_P,delta_t);
        M_out(3,k) = M_temp; 
        P_out(3,k) = P_temp; 
        M.lacI = M_temp;
        P.lacI = P_temp; 
  
    
end

hold on 
plot(t,M_out(1,:),'--r');
plot(t,M_out(2,:),'-b');
plot(t,M_out(3,:),'-g');
xlabel('time(hr)');
ylabel('number of molecules');


function [M_out,P_out] = rungekutta_repressilator(M_temp,P_temp,P_rep,ode_M,ode_P,delta_x)
k11 = ode_M(M_temp,P_rep);
k12 = ode_P(M_temp,P_temp);
k21 = ode_M(M_temp+k11*delta_x/2,P_rep);
k22 = ode_P(M_temp+k11*delta_x/2,P_temp+k12*delta_x/2);
k31 = ode_M(M_temp+k21*delta_x/2,P_rep);
k32 = ode_P(M_temp+k21*delta_x/2,P_temp+k22*delta_x/2);
k41 = ode_M(M_temp+k31*delta_x,P_rep);
k42 = ode_P(M_temp+k31*delta_x,P_temp+k32*delta_x);
M_out = M_temp+delta_x/6 * (k11+2*k21+2*k31+k41);
P_out = P_temp+delta_x/6 * (k12+2*k22+2*k32+k42);
% display([k1,k2,k3,k4]);
end

function dm_t = ode_M(M_temp,P_rep)
global const

dm_t = - M_temp + const.alpha/(1 + P_rep^(const.n)) + const.alpha0;

end

function dp_t = ode_P(M_temp,P_temp)
global const

dp_t = - const.beta*(P_temp - M_temp);

end