% pid_baseline.m
[A,B,C,D,params] = msd_model(1,1,10);
sys = ss(A,B,C,D);

% Design PID based on classical tuning or trial values
Kp = 350; Ki = 300; Kd = 10; % start values, tune as needed
Cpid = pid(Kp,Ki,Kd);

T = feedback(Cpid*sys,1); % unity feedback on position
t = 0:0.001:2;
[y,t] = step(T,t);

figure('Name','PID response','NumberTitle','off');
plot(t,y); title('PID controller step response'); xlabel('Time seconds'); ylabel('Position');

% Suggest performance metrics
overshoot = (max(y)-1)*100;
fprintf('PID overshoot percent approx %g\n', overshoot);
