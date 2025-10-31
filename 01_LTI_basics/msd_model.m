function [A,B,C,D,params] = msd_model(m,c,k)
% msd_model returns state space matrices for mass spring damper
% Inputs
%   m mass scalar
%   c damping scalar
%   k stiffness scalar
% Outputs
%   A B C D state space matrices
%   params struct with fields m c k

if nargin < 1 || isempty(m); m = 2; end
if nargin < 2 || isempty(c); c = 1; end
if nargin < 3 || isempty(k); k = 50; end

A = [0 1; -k/m -c/m];
B = [0; 1/m];
C = [1 0];
D = 0;

params.m = m;
params.c = c;
params.k = k;
end
