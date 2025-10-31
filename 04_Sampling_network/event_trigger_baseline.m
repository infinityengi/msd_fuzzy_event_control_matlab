% event_trigger_baseline.m
[A,B,C,D,params] = msd_model(1,1,10);
K = [20 6];
h = 0.01;
[Phi,Gamma] = zoh_discretize(A,B,h);

N = 1000;
x = zeros(2,N);
x(:,1) = [1;0];
x_sent = zeros(2,N);
x_last_sent = x(:,1);
delta = 0.05; % threshold
transmissions = zeros(1,N);

for k = 1:N-1
    % check trigger condition in continuous analog this is sampled check
    if norm(x(:,k) - x_last_sent) > delta
        x_last_sent = x(:,k);
        transmissions(k) = 1;
    end
    u = -K * x_last_sent;
    x(:,k+1) = Phi * x(:,k) + Gamma * u;
end

figure('Name','Event trigger baseline','NumberTitle','off');
plot((0:N-1)*h, x(1,:));
hold on;
plot(find(transmissions)*h, x(1,transmissions==1),'ro');
legend({'Position','Transmission instants'}); % fixed
xlabel('Time seconds'); ylabel('Position');
title('Event triggered control baseline');
