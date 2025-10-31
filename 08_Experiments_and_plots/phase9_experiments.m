% phase9_experiments.m
% Run a battery of experiments for switched ETM and LMI designed fuzzy controllers
% The script runs a parameter sweep, saves raw results to phase9_summary.mat
% Usage: run this script from project root

clearvars; close all; rng(0);

addpath(genpath(fullfile(pwd,'06_Event_triggered')));
addpath(genpath(fullfile(pwd,'02_Lyapunov_LMI')));
addpath(genpath(fullfile(pwd,'05_Nonlinear_fuzzy')));

% Simulation base configuration
t0 = 0; tf = 10; h = 0.01; tvec = t0:h:tf;
params.m = 1; params.c = 2; params.khat = 8; params.a = 0.3;

% Prepare attack schedule baseline
Fmin = 0.6; Fmax = 1.2; epsilon1 = 0.1; epsilon2 = 0.8;
attack = deception_attack_schedule(tvec, Fmin, Fmax, epsilon1, epsilon2, params);

% Build fuzzy and LMI gains if not present
if ~exist('02_Lyapunov_LMI/phase8_lmi_solution.mat','file')
    fprintf('LMI solution not found. Running LMI design now\n');
    run('02_Lyapunov_LMI/phase8_ts_lmi_design.m');
end
load('02_Lyapunov_LMI/phase8_lmi_solution.mat','K','fuzzy');

% Parameter sweeps
delta_values = [0.005, 0.01, 0.02, 0.05];
delta_active_values = [0.05, 0.1, 0.2, 0.4];
alpha_values = [0, 0.01, 0.05];

% Prepare storage
idx = 0;
results = struct();
for di = 1:numel(delta_values)
    for dai = 1:numel(delta_active_values)
        for ai = 1:numel(alpha_values)
            idx = idx + 1;
            params_etm.delta = delta_values(di);
            params_etm.delta_active = delta_active_values(dai);
            params_etm.alpha = alpha_values(ai);
            params_etm.force_on_mode_change = true;
            params_etm.prev_mode = attack.mode(1);

            % Run the Phase 8 style simulation with LMI gains
            fprintf('Running sim number %d of %d\n', idx, numel(delta_values)*numel(delta_active_values)*numel(alpha_values));

            % Initialize
            N = numel(tvec);
            x = zeros(2,N); x(:,1) = [-1.5; 0.3];
            x_last_sent = x(:,1);
            u = zeros(1,N);
            sent_idx = false(1,N);

            for k = 1:N-1
                % compute blended gain from K and current last sent
                x_for_control = x_last_sent;
                mu = zeros(1,numel(fuzzy.centers));
                for i = 1:numel(fuzzy.centers)
                    mu(i) = fuzzy.rules{i}.mu(x_for_control(1));
                end
                w = mu / (sum(mu)+1e-9);
                Kblend = zeros(1,2);
                for i = 1:numel(fuzzy.centers)
                    Kblend = Kblend + w(i) * K{i};
                end
                u(k) = -Kblend * x_for_control;

                % attack scaling
                s_raw = attack.sigma_raw(:,k);
                if attack.mode(k) == 1
                    scale = sqrt(epsilon1) * max(norm(x(:,k)), 1e-6) / (norm(s_raw)+1e-9);
                else
                    scale = sqrt(epsilon2) * max(norm(x(:,k)), 1e-6) / (norm(s_raw)+1e-9);
                end
                sigma_k = scale * s_raw;
                x_hat_k = x(:,k) + sigma_k;

                % decide send
                [sendFlag, ~] = switched_etm_decision(x_hat_k, x_last_sent, attack.mode(k), params_etm);
                if sendFlag
                    x_last_sent = x_hat_k;
                    sent_idx(k) = true;
                end

                % plant update
                dx = nonlinear_msd(tvec(k), x(:,k), u(k), params);
                x(:,k+1) = x(:,k) + h*dx;
                params_etm.prev_mode = attack.mode(k);
            end

            % compute metrics
            time = tvec;
            msse = trapz(time, sum(x.^2,1)) / (time(end) - time(1));
            settling_time = compute_settling_time(time, x);
            transmission_count = sum(sent_idx);
            transmission_rate = transmission_count / (time(end) - time(1));
            control_energy = trapz(time, u.^2);

            % store
            results(idx).delta = params_etm.delta;
            results(idx).delta_active = params_etm.delta_active;
            results(idx).alpha = params_etm.alpha;
            results(idx).msse = msse;
            results(idx).settling_time = settling_time;
            results(idx).transmission_count = transmission_count;
            results(idx).transmission_rate = transmission_rate;
            results(idx).control_energy = control_energy;
            results(idx).x = x;
            results(idx).u = u;
            results(idx).sent_idx = sent_idx;
        end
    end
end

% Save results
save('phase9_summary.mat','results','tvec','attack');
fprintf('Experiments completed and saved to phase9_summary.mat\n');

% helper nested function
function ts = compute_settling_time(time, x)
    % compute time when norm x enters and stays within 2 percent of final
    xr = sqrt(sum(x.^2,1));
    final_val = mean(xr(end-50:end));
    tol = 0.02 * max(1, abs(final_val));
    idx = find(xr <= tol, 1, 'first');
    if isempty(idx)
        ts = NaN;
    else
        ts = time(idx);
    end
end
