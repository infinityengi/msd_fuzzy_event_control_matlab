% observer_design.m
[A,B,C,D,params] = msd_model(1,1,10);

% assume only position y = C x measured
% design state feedback K from previous
load('lqr_results.mat','K');

% observer gain design choose observer poles 5 times faster
observer_poles = eig(A - B*K)*5; % heuristic scale
L = place(A', C', observer_poles)'; % observer gain

% simulate combined system
Acl = A - B*K;
Aaug = [A-B*K B*K; zeros(size(A)) A-L*C];
% better to simulate with full estimator states explicitly
% implement simulation with x and xhat
t = 0:0.001:3;
x = zeros(2,numel(t));
xhat = zeros(2,numel(t));
u = zeros(1,numel(t));
x(:,1) = [1;0]; xhat(:,1) = [0;0];
for idx = 1:numel(t)-1
    y = C*x(:,idx);
    u(:,idx) = -K*xhat(:,idx);
    xdot = A*x(:,idx) + B*u(:,idx);
    xhatdot = A*xhat(:,idx) + B*u(:,idx) + L*(y - C*xhat(:,idx));
    x(:,idx+1) = x(:,idx) + 0.001*xdot;
    xhat(:,idx+1) = xhat(:,idx) + 0.001*xhatdot;
end

figure('Name','Observer estimation error','NumberTitle','off');
plot(t, x(1,:),'k', t, xhat(1,:),'r--');
legend('True position','Estimated position'); xlabel('Time seconds'); ylabel('Position');
title('Observer performance');

err = max(abs(x(1,:) - xhat(1,:)));
fprintf('Max estimation error in position: %g\n', err);
