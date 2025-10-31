% phase8_ts_lmi_design.m
% Design TS fuzzy controller gains using LMIs and YALMIP
clearvars;
rng(0);

% load or build TS linearizations from Phase 6
params.m = 1; params.c = 2; params.khat = 8; params.a = 0.3;
rules = [-2 0 2];
fuzzy = ts_fuzzy_build(rules, params);
nRules = numel(fuzzy.centers);

% Collect Ai Bi
Ai = cell(1,nRules);
Bi = cell(1,nRules);
for i = 1:nRules
    Ai{i} = fuzzy.rules{i}.A;
    Bi{i} = fuzzy.rules{i}.B;
end

% yalmip variables
n = size(Ai{1},1);
P = sdpvar(n,n);
Y = cell(1,nRules);
for j = 1:nRules
    Y{j} = sdpvar(1,n,'full'); % row vector because single input
end

% Constraints list
Constraints = [];
eps = 1e-6;
Constraints = [Constraints, P >= eps * eye(n)];
for i = 1:nRules
    for j = 1:nRules
        M = Ai{i}*P + Bi{i}*Y{j};
        % LMI symmetric negative definite
        Constraints = [Constraints, M + M' <= -1e-3 * eye(n)];
    end
end

% solver settings
options = sdpsettings('solver','sdpt3','verbose',1);
disp('Solving LMI for TS fuzzy gains');
sol = optimize(Constraints,[],options);

if sol.problem == 0
    Pval = value(P);
    K = cell(1,nRules);
    for j = 1:nRules
        Yval = value(Y{j});
        K{j} = Yval / Pval;
        fprintf('Recovered K for rule %d : %s\n', j, mat2str(K{j},4));
    end
    save('phase8_lmi_solution.mat','Pval','K','fuzzy','params');
    fprintf('LMI feasible solution saved\n');
else
    warning('LMI solver reported problem code %d', sol.problem);
    sol.info
    return;
end
