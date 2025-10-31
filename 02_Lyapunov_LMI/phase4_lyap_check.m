[A,B,C,D,params] = msd_model(1,1,10);

Q = eye(2);
P = lyap(A',Q);
eigsP = eig(P);
fprintf('Eigenvalues of P: %s\n', mat2str(eigsP,6));

sys = ss(A,B,C,D);
t = 0:0.001:3;
x0 = [1;0];
[~,~,x] = initial(sys,x0,t);

V = sum((x * P) .* x, 2);  % correct vectorized computation

figure('Name','Lyapunov function decay','NumberTitle','off');
plot(t,V);
title('V(t) = x^T P x'); xlabel('Time seconds'); ylabel('V');
