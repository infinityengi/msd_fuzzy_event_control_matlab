% phase5_packet_loss.m
[A,B,C,D,params] = msd_model(1,1,10);

K = [20 6];
h = 0.01;
[Phi,Gamma] = zoh_discretize(A,B,h);

N = 1000;
x = zeros(2,N);
x(:,1) = [1;0];
x_sent = zeros(2,N);
last_sent_state = x(:,1);
p_drop = 0.1; % probability of packet drop
rng(0);
for k = 1:N-1
    % packet sent at sampling instant k
    if rand() > p_drop
        last_sent_state = x(:,k); % controller receives state
        sent_flag = 1;
    else
        sent_flag = 0;
    end
    % controller computes control using last received state
    u = -K * last_sent_state;
    % discrete update
    x(:,k+1) = Phi * x(:,k) + Gamma * u;
    x_sent(:,k) = last_sent_state;
end

figure('Name','Packet loss effect','NumberTitle','off');
plot((0:N-1)*h, x(1,:));
title(sprintf('Packet loss probability p = %.2f', p_drop));
xlabel('Time seconds'); ylabel('Position');
