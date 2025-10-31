% phase4_lmi_design.m
% Solve LMI for common P and Y for two modes
addpath(genpath('../')); % adjust path if needed
% Check that YALMIP exists
if exist('yalmip','file') ~= 2 && exist('yalmip','builtin') ~= 1
    error('YALMIP not found. Please install YALMIP and add to path');
end

m = 1; k = 10;
A1 = [0 1; -k/m -0.5/m];
A2 = [0 1; -k/m -3/m];
B = [0; 1/m];

n = size(A1,1);
P = sdpvar(n,n);
Y1 = sdpvar(1,n,'full');
Y2 = sdpvar(1,n,'full');

eps = 1e-5;
F1 = A1*P + B*Y1;
F2 = A2*P + B*Y2;

Constraints = [P - eps*eye(n) >= 0, F1 + F1' <= -eps*eye(n), F2 + F2' <= -eps*eye(n)];
options = sdpsettings('verbose',1,'solver','sdpt3');
sol = optimize(Constraints,[],options);

if sol.problem == 0
    Pval = value(P);
    Y1val = value(Y1);
    Y2val = value(Y2);
    K1 = Y1val / Pval;
    K2 = Y2val / Pval;
    fprintf('Found feasible K1 K2\n');
    disp(K1); disp(K2);
else
    disp('LMI infeasible or solver error');
    sol.info
end
