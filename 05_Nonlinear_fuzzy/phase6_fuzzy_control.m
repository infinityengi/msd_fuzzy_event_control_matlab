% phase6_fuzzy_control.m
params.m = 1; params.c = 2; params.khat = 8; params.a = 0.3;
rules = [-2 0 2]; % centers for x1
fuzzy = ts_fuzzy_build(rules, params);

% design local controllers for each Ai Bi using LQR
nRules = numel(fuzzy.centers);
Ks = cell(1,nRules);
for i = 1:nRules
    Ai = fuzzy.rules{i}.A;
    Bi = fuzzy.rules{i}.B;
    Q = diag([100 1]); R = 1;
    Ks{i} = lqr(Ai, Bi, Q, R);
end

% simulate fuzzy closed loop
tspan = 0:0.001:6;
x = zeros(2, numel(tspan));
x(:,1) = [-1.5; 0.2];
for idx = 1:numel(tspan)-1
    x1 = x(1,idx);
    % compute membership weights
    mu = zeros(1,nRules);
    for i = 1:nRules
        mu(i) = fuzzy.rules{i}.mu(x1);
    end
    w = mu / sum(mu);
    % blended gains
    Kblend = zeros(1,2);
    for i = 1:nRules
        Kblend = Kblend + w(i) * Ks{i};
    end
    u = -Kblend * x(:,idx);
    dx = nonlinear_msd(tspan(idx), x(:,idx), u, params);
    x(:,idx+1) = x(:,idx) + 0.001*dx;
end

figure('Name','Fuzzy control','NumberTitle','off');
plot(tspan, x(1,:));
title('Fuzzy TS controlled nonlinear msd'); xlabel('Time seconds'); ylabel('Position');
