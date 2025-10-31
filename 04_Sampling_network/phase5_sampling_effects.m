% phase5_sampling_effects.m
[A,B,C,D,params] = msd_model(1,1,10);

% continuous state feedback from lqr earlier or simple K
K = [20 6]; % example feedback
Acl = A - B*K;
h_vals = [0.002, 0.01, 0.05, 0.1];

figure('Name','Sampling effects','NumberTitle','off');
for i = 1:numel(h_vals)
    h = h_vals(i);
    [Phi,Gamma] = zoh_discretize(A,B,h);
    % discrete closed loop
    Phi_cl = Phi - Gamma*K;
    % simulate discrete step response from x0
    N = 0:1:200;
    x = zeros(2,numel(N));
    x(:,1) = [1;0];
    for k = 1:numel(N)-1
        x(:,k+1) = Phi_cl * x(:,k);
    end
    subplot(2,2,i);
    plot(N*h, x(1,:));
    title(sprintf('h = %.3f s', h));
    xlabel('Time seconds'); ylabel('Position');
end
