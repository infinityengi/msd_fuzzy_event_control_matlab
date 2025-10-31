function plot_phase7_results(matfile)
% plot_phase7_results plots the state control and transmission timeline
data = load(matfile);
t = data.tvec;
x = data.x;
u = data.u_sw;
sent = data.sent_idx_sw;
attack_mode = data.attack.mode;

figure('Name','Phase7 results overview','NumberTitle','off');
tiledlayout(3,1);

nexttile;
plot(t,x(1,:)); hold on;
plot(t(sent), x(1,sent),'ro','MarkerSize',4,'DisplayName','transmission');
xlabel('Time seconds'); ylabel('Position'); title('Position and transmission instants');
legend({'position','transmission'});  % fixed

nexttile;
plot(t,u);
xlabel('Time seconds'); ylabel('Control input'); title('Control input for switched ETM');

nexttile;
stairs(t, attack_mode);
xlabel('Time seconds'); ylabel('Mode'); title('Attack mode 1 sleeping 2 active');
ylim([0.5 2.5]);
end
