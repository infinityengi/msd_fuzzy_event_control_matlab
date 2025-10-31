% phase8_apply_and_test.m
% Load computed gains and run switched ETM simulation to validate

clearvars; clc;

% Load LMI designed gains, fuzzy TS model, and plant parameters
load('02_Lyapunov_LMI/phase8_lmi_solution.mat','K','fuzzy','params');

% Simple check that K number equals fuzzy rules
nRules = numel(K);
if nRules ~= numel(fuzzy.centers)
    error('Mismatch number of K and fuzzy rules');
end

% Add helper functions if needed
addpath('../06_Event_triggered');

%% Simulation setup
t0 = 0; tf = 10; h = 0.01; tvec = t0:h:tf;
N = numel(tvec);

% Attack parameters
Fmin = 0.6; Fmax = 1.2; epsilon1 = 0.1; epsilon2 = 0.8;

% Precompute attack schedule for full simulation
attack = deception_attack_schedule(tvec, Fmin, Fmax, epsilon1, epsilon2, params);

% Initialize states, controls, and ETM
x = zeros(2,N); x(:,1) = [-1.5; 0.3];
x_last_sent = x(:,1);
u = zeros(1,N);
sent_idx = false(1,N);
etm_params.delta = 0.01; 
etm_params.delta_active = 0.2; 
etm_params.alpha = 0.0;
etm_params.prev_mode = attack.mode(1);

%% Simulation loop
for k = 1:N-1
    mode_k = attack.mode(k);
    
    % Compute blended control using last transmitted state
    x_for_control = x_last_sent;
    mu = zeros(1,nRules);
    for i = 1:nRules
        mu(i) = fuzzy.rules{i}.mu(x_for_control(1));
    end
    w = mu / (sum(mu)+1e-9);  % normalize
    Kblend = zeros(1,2);
    for i = 1:nRules
        Kblend = Kblend + w(i) * K{i};
    end
    u(k) = -Kblend * x_for_control;

    % Apply attack using precomputed sigma
    s_raw = attack.sigma_raw(:,k);  
    if mode_k == 1
        scale = sqrt(epsilon1) * max(norm(x(:,k)), 1e-6) / (norm(s_raw)+1e-9);
    else
        scale = sqrt(epsilon2) * max(norm(x(:,k)), 1e-6) / (norm(s_raw)+1e-9);
    end
    sigma_k = scale * s_raw;
    x_hat_k = x(:,k) + sigma_k;

    % Switched ETM decision
    [sendFlag, ~] = switched_etm_decision(x_hat_k, x_last_sent, mode_k, etm_params);
    if sendFlag
        x_last_sent = x_hat_k;
        sent_idx(k) = true;
    end

    % Nonlinear plant update (Euler integration)
    dx = nonlinear_msd(tvec(k), x(:,k), u(k), params);
    x(:,k+1) = x(:,k) + h * dx;

    % Update previous mode for ETM
    etm_params.prev_mode = mode_k;
end

%% Post-processing
num_sent = sum(sent_idx);
fprintf('Number of transmissions with LMI designed gains: %d\n', num_sent);

% Save results
save('phase8_test_results.mat','tvec','x','u','sent_idx','num_sent');

%% Plot results
figure('Name','Phase8 test','NumberTitle','off');

% Position with transmission instants
subplot(2,1,1);
plot(tvec, x(1,:),'b','DisplayName','Position'); hold on;
plot(tvec(sent_idx), x(1,sent_idx),'ro','MarkerSize',4,'DisplayName','Transmissions');
xlabel('Time (seconds)'); ylabel('Position');
title('Position and transmission instants');
legend('Location','best');

% Control signal
subplot(2,1,2);
plot(tvec, u,'k','DisplayName','Control u');
xlabel('Time (seconds)'); ylabel('u');
title('Control signal');
legend('Location','best');
