function [Phi,Gamma] = zoh_discretize(A,B,h)
% zoh_discretize compute discrete state matrix Phi and input matrix Gamma
% using matrix exponential integral
M = [A, B; zeros(size(B,2), size(A,1)+size(B,2))];
expM = expm(M*h);
Phi = expM(1:size(A,1),1:size(A,1));
Gamma = expM(1:size(A,1),size(A,1)+1:end);
end
