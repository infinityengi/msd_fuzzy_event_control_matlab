% phase7_switched_etm_sim.m
% Main simulation for switched ETM with deception attacks
% Simulate nonlinear plant with TS fuzzy controller
% Compare switched ETM versus conventional periodic sampling ETM

clearvars -except;
rng(0);

% simulation time
t0 = 0; tf = 10; h = 0.01; tvec = t0:h:tf;
N = numel(tvec);

% plant nonlinear parameters
params.m = 1; params.c = 2; params.khat = 8; params.a = 0.3;

% build fuzzy TS model with centers from Phase 6
rules = [-2 0 2];
fuzzy = ts_fuzzy_build(rules, params);

% design local LQR gains as in Phase 6
nRules = numel(fuzzy.centers);
Ks = cell(1,nRules);
for i = 1:nRules
    Ai = fuzzy.rules{i}.A;
    Bi = fuzzy.rules{i}.B;
    Q = diag([100 1]); R = 1;
    Ks{i} = lqr(Ai, Bi, Q, R);
end

% attack schedule
Fmin = 0.6; Fmax = 1.2; epsilon1 = 0.1; epsilon2 = 0.8;
attack = deception_attack_schedule(tvec, Fmin, Fmax, epsilon1, epsilon2, params);

% Initialize arrays
x = zeros(2,N); x(:,1) = [-1.5; 0.3];
x_sent = zeros(2,N);
x_last_sent_sw = x(:,1); % for switched ETM
x_last_sent_conv = x(:,1); % for conventional periodic sampling
u_sw = zeros(1,N);
u_conv = zeros(1,N);

% ETM parameters
etm_params.delta = 0.01; etm_params.delta_active = 0.2; etm_params.alpha = 0.0;
etm_params.prev_mode = attack.mode(1);

% conventional periodic controller sampling every Tsamp seconds
Tsamp = 0.05; Tsamp_steps = round(Tsamp / h); next_sample_idx = 1;

% logs
sent_idx_sw = false(1,N);
sent_idx_conv = false(1,N);

for k = 1:N-1
    t = tvec(k);
    % current mode
    mode_k = attack.mode(k);
    % compute blended control using last sent state for switched ETM
    % compute membership weights based on last sent state position
    x_for_control_sw = x_last_sent_sw;
    mu = zeros(1,nRules);
    for i = 1:nRules
        mu(i) = fuzzy.rules{i}.mu(x_for_control_sw(1));
    end
    w = mu / sum(mu);
    Kblend = zeros(1,2);
    for i = 1:nRules
        Kblend = Kblend + w(i) * Ks{i};
    end
    u_sw(k) = -Kblend * x_for_control_sw;
    % for conventional periodic control update
    if k >= next_sample_idx
        x_last_sent_conv = x(:,k);
        next_sample_idx = k + Tsamp_steps;
        sent_idx_conv(k) = true;
    end
    % compute control for conventional scheme
    mu_c = zeros(1,nRules);
    for i = 1:nRules
        mu_c(i) = fuzzy.rules{i}.mu(x_last_sent_conv(1));
    end
    w_c = mu_c / sum(mu_c);
    Kblend_c = zeros(1,2);
    for i = 1:nRules
        Kblend_c = Kblend_c + w_c(i) * Ks{i};
    end
    u_conv(k) = -Kblend_c * x_last_sent_conv;

    % build attack sigma scaled by current state norm to meet energy relation
    s_raw = attack.sigma_raw(:,k);
    % scale so sleeping amplitude roughly epsilon1 times state norm and active amplitude epsilon2 times state norm
    if attack.mode(k) == 1
        scale = sqrt(epsilon1) * max(norm(x(:,k)), 1e-6) / (norm(s_raw)+1e-9);
    else
        scale = sqrt(epsilon2) * max(norm(x(:,k)), 1e-6) / (norm(s_raw)+1e-9);
    end
    sigma_k = scale * s_raw;

    % measurement available at controller side is corrupted
    x_hat_k = x(:,k) + sigma_k;

    % Decide switched ETM sending decision
    [send_sw, reason] = switched_etm_decision(x_hat_k, x_last_sent_sw, mode_k, etm_params);
    if send_sw
        x_last_sent_sw = x_hat_k;
        sent_idx_sw(k) = true;
    end

    % plant update for both control schemes side by side
    % For simplicity simulate two parallel plants with same initial condition
    % Actually we update one plant using switched control to compare with periodic
    % Integrate nonlinear dynamics with Euler step
    dx = nonlinear_msd(t, x(:,k), u_sw(k), params);
    x(:,k+1) = x(:,k) + h * dx;
    % update previous mode
    etm_params.prev_mode = mode_k;
end

% post processing count transmissions
num_sent_sw = sum(sent_idx_sw);
num_sent_conv = sum(sent_idx_conv);

fprintf('Transmissions switched ETM %d conventional periodic %d\n', num_sent_sw, num_sent_conv);

% Save results
save('phase7_results.mat','tvec','x','u_sw','u_conv',...
    'sent_idx_sw','sent_idx_conv','attack','etm_params','num_sent_sw','num_sent_conv');

% Plot results
plot_phase7_results('phase7_results.mat');
