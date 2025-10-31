% phase1_simulate.m
% Build msd model and simulate step impulse and free response
savepath = fullfile(pwd,'01_LTI_basics','phase1_results.mat');

% Model parameters
m = 2; c = 1; k = 10;
[A,B,C,D,params] = msd_model(m,c,k);

% Create state space and transfer function
sys_ss = ss(A,B,C,D);
sys_tf = tf(1,[m c k]);

% Simulation settings
t = 0:0.001:5; % time vector

% Step response
[y_step,t_step,x_step] = step(sys_ss,t);

% Impulse response
[y_imp,t_imp] = impulse(sys_ss,t);

% Free response from initial condition
x0 = [1; 0]; % initial displacement
[y_free,t_free,x_free] = initial(sys_ss,x0,t);

% Save results
save(savepath,'A','B','C','D','params','sys_ss','sys_tf',...
    't','y_step','t_step','y_imp','t_imp','y_free','t_free','x_free','x0');

% Plotting
figure('Name','Phase1 Responses','NumberTitle','off');
tiledlayout(2,2);

nexttile;
plot(t_step,y_step);
title('Step response position');
xlabel('Time seconds'); ylabel('Position meters');

nexttile;
plot(t_imp,y_imp);
title('Impulse response position');
xlabel('Time seconds'); ylabel('Position meters');

nexttile;
plot(t_free,y_free);
title('Free response from initial displacement');
xlabel('Time seconds'); ylabel('Position meters');

nexttile;
plot(x_free(:,1),x_free(:,2));
title('Phase portrait');
xlabel('Position x1'); ylabel('Velocity x2');

% also verify tf and ss match at some frequency or time points
% Quick numeric check
y_tf_step = step(sys_tf,t);
err = max(abs(y_step(:) - y_tf_step(:)));
fprintf('Max difference between ss step and tf step outputs: %g\n', err);
