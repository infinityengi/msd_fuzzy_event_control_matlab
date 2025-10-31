% phase7_summary.m reproduces and prints key results
load('06_Event_triggered/phase7_results.mat','num_sent_sw','num_sent_conv');
fprintf('Summary Phase 7 results\n');
fprintf('Number of transmissions switched ETM %d\n', num_sent_sw);
fprintf('Number of transmissions conventional periodic %d\n', num_sent_conv);
plot_phase7_results('06_Event_triggered/phase7_results.mat');
