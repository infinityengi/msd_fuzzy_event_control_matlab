% pole_place_design.m
% State feedback via pole placement
[A,B,C,D,params] = msd_model(1,1,10);

% desired closed loop poles
desired_poles = [-5 -6]; % choose faster than open loop
K = place(A,B,desired_poles); % state feedback gain

% closed loop system
Acl = A - B*K;
sys_cl = ss(Acl,B,C,D);

% step response
t = 0:0.001:3;
[y,t,x] = step(sys_cl,t);

figure('Name','Pole placement step response','NumberTitle','off');
plot(t,y);
title('Closed loop step response with state feedback'); xlabel('Time seconds'); ylabel('Position');

% Save K for later
save('pole_place_K.mat','K','desired_poles');
fprintf('State feedback gain K = %s\n', mat2str(K,4));
