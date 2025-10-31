% lqr_design.m
[A,B,C,D,params] = msd_model(1,1,10);

% LQR design
Q = diag([100 1]); R = 1; % tune these
[K,S,e] = lqr(A,B,Q,R);
Acl = A - B*K;
sys_lqr = ss(Acl,B,C,D);

% Compare LQR versus pole placement
load('pole_place_K.mat','K','desired_poles');
sys_pp = ss(A - B*K, B, C, D);

t = 0:0.001:3;
[y_lqr,~] = step(sys_lqr,t);
[y_pp,~] = step(sys_pp,t);

figure('Name','Controller comparison','NumberTitle','off');
plot(t,y_pp,'--', t,y_lqr,'-');
legend('Pole placement','LQR'); xlabel('Time seconds'); ylabel('Position');
title('Pole placement versus LQR step response');

% Save LQR data
save('lqr_results.mat','K','S','e','Q','R');
