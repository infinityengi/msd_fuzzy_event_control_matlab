% phase6_nonlinear_sim.m
params.m = 1; params.c = 2; params.khat = 8; params.a = 0.3;
% simulate open loop from x0
x0 = [-1; 0.5];
tspan = 0:0.001:5;
u_fun = @(t,x) 0; % zero input
x = zeros(2,numel(tspan));
x(:,1) = x0;
for idx = 1:numel(tspan)-1
    t = tspan(idx);
    u = u_fun(t,x(:,idx));
    dx = nonlinear_msd(t,x(:,idx),u,params);
    x(:,idx+1) = x(:,idx) + 0.001*dx;
end

% Compare to linearized around zero with A B from msd_model using khat
[A,B,C,D,~] = msd_model(params.m, params.c, params.khat);
sys_lin = ss(A,B,C,D);

figure('Name','Nonlinear vs linear','NumberTitle','off');
plot(tspan, x(1,:)); hold on;
[y_lin,~] = initial(sys_lin, x0, tspan);
plot(tspan,y_lin,'--');
legend('Nonlinear position','Linearized position');
xlabel('Time seconds'); ylabel('Position');
title('Comparison linearized and nonlinear open loop');
