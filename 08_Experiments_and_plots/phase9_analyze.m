% phase9_analyze.m
% Load phase9_summary.mat compute tables produce plots and save figures
clearvars; close all;
load('phase9_summary.mat','results','tvec','attack');

% create folders for figures and tables
figdir = fullfile(pwd,'08_Experiments_and_plots','figures');
if ~exist(figdir,'dir'), mkdir(figdir); end

% aggregate into table
n = numel(results);
delta = zeros(n,1); delta_active = zeros(n,1); alpha = zeros(n,1);
msse = zeros(n,1); settling = zeros(n,1); tr_count = zeros(n,1); tr_rate = zeros(n,1); u_energy = zeros(n,1);
for i = 1:n
    delta(i) = results(i).delta;
    delta_active(i) = results(i).delta_active;
    alpha(i) = results(i).alpha;
    msse(i) = results(i).msse;
    settling(i) = results(i).settling_time;
    tr_count(i) = results(i).transmission_count;
    tr_rate(i) = results(i).transmission_rate;
    u_energy(i) = results(i).control_energy;
end

T = table(delta, delta_active, alpha, msse, settling, tr_count, tr_rate, u_energy);
writetable(T, fullfile(figdir,'experiment_table.csv'));

% Plot MSSE versus transmission rate
figure('Name','MSSE vs Transmission rate','NumberTitle','off');
scatter(tr_rate, msse, 80, 'filled');
xlabel('Transmission rate per second'); ylabel('MSSE');
title('Performance versus communication cost');
grid on;
save_figure(gcf, fullfile(figdir,'msse_vs_trate'));

% Heatmap of transmission count for grid of delta and delta active for alpha fixed small
unique_delta = unique(delta);
unique_delta_active = unique(delta_active);
mat = NaN(numel(unique_delta_active), numel(unique_delta));
for i = 1:numel(unique_delta)
    for j = 1:numel(unique_delta_active)
        sel = (delta == unique_delta(i)) & (delta_active == unique_delta_active(j));
        if any(sel)
            mat(j,i) = mean(tr_count(sel));
        end
    end
end

figure('Name','Transmission count heatmap','NumberTitle','off');
imagesc(unique_delta, unique_delta_active, mat);
colorbar; xlabel('delta'); ylabel('delta active');
title('Average transmission count across alpha values');
save_figure(gcf, fullfile(figdir,'transmission_heatmap'));

% Plot example trajectory for a chosen run
example_run = 5;
figure('Name','Example trajectory','NumberTitle','off');
subplot(2,1,1);
plot(tvec, results(example_run).x(1,:)); hold on;
plot(tvec(results(example_run).sent_idx), results(example_run).x(1,results(example_run).sent_idx), 'ro');
xlabel('Time seconds'); ylabel('Position');
title('Example position and transmission instants');
subplot(2,1,2);
plot(tvec, results(example_run).u);
xlabel('Time seconds'); ylabel('Control input');
title('Example control signal');
save_figure(gcf, fullfile(figdir,'example_trajectory'));

% Save the table and some summary metrics
save(fullfile(figdir,'phase9_analysis.mat'),'T','unique_delta','unique_delta_active','mat');
fprintf('Analysis complete Figures saved to %s\n', figdir);
