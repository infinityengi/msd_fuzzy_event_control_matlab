function fuzzy = ts_fuzzy_build(rules, params)
% ts_fuzzy_build constructs TS fuzzy model from local linearizations
% rules vector of rule centers for x1 axis
% returns struct with fields Ai Bi centers and membership function handles

nRules = numel(rules);
fuzzy.rules = cell(1,nRules);
for i = 1:nRules
    x1c = rules(i);
    % compute linearization numerically around [x1c,0]
    x_eq = [x1c; 0];
    % compute A numerically by finite difference
    delta = 1e-6;
    % evaluate dynamics for small perturbations
    f0 = dynamics(x_eq, 0, params);
    % perturb x1
    f_x1 = dynamics([x1c+delta; 0], 0, params);
    f_x2 = dynamics([x1c; delta], 0, params);
    A_num = [(f_x1 - f0)/delta, (f_x2 - f0)/delta];
    B_num = (dynamics(x_eq, 1e-6, params) - f0)/1e-6;
    fuzzy.rules{i}.A = A_num;
    fuzzy.rules{i}.B = B_num;
    fuzzy.centers(i) = x1c;
    % gaussian membership with sigma set from rule spacing
    if i == 1
        if nRules == 1
            sigma = 1;
        else
            sigma = abs(rules(2)-rules(1))/2;
        end
    else
        sigma = abs(rules(i) - rules(max(1,i-1)))/2;
    end
    fuzzy.rules{i}.mu = @(x1) exp(-((x1 - x1c).^2)/(2*sigma^2));
end

    function out = dynamics(x,u,prm)
        out = zeros(2,1);
        out(1) = x(2);
        out(2) = -(prm.khat/prm.m)*(1 + prm.a^2 * x(1)^2) * x(1) - (prm.c/prm.m)*x(2) + (1/prm.m)*u;
    end
end
