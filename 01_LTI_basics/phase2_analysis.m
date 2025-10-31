% phase2_analysis.m
% LTI analysis for MSD model
[A,B,C,D,params] = msd_model(1,1,10);

% eigenvalues and modal parameters
eigA = eig(A);
omega_n = sqrt(params.k/params.m);
zeta = params.c/(2*sqrt(params.k*params.m));
fprintf('Eigenvalues of A: %s\n', mat2str(eigA,6));
fprintf('Natural frequency omega_n: %.4f Hz rad per second\n', omega_n);
fprintf('Damping ratio zeta: %.4f\n', zeta);

% controllability and observability
Ctrb = ctrb(A,B);
Obsv = obsv(A,C);
rankCtrb = rank(Ctrb);
rankObsv = rank(Obsv);
fprintf('Controllability rank %d Observability rank %d\n', rankCtrb, rankObsv);

% Bode and Nyquist
sys = ss(A,B,C,D);
figure('Name','Bode and Nyquist','NumberTitle','off');
tiledlayout(1,2);
nexttile;
bode(sys); title('Bode plot');
grid on;
nexttile;
nyquist(sys); title('Nyquist plot');
grid on;
