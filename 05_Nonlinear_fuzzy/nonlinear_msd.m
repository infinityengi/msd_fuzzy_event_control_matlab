function dx = nonlinear_msd(t,x,u,params)
% nonlinear_msd nonlinear msd dynamics used by ODE solvers
% x column 2 state vector
% u scalar control input
% params struct with fields m c khat a

m = params.m; c = params.c; khat = params.khat; a = params.a;
dx = zeros(2,1);
dx(1) = x(2);
dx(2) = -(khat/m)*(1 + (a^2)*(x(1)^2))*x(1) - (c/m)*x(2) + (1/m)*u;
end
