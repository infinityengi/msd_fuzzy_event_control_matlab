function attack = deception_attack_schedule(tvec, Fmin, Fmax, epsilon1, epsilon2, params)
% deception_attack_schedule generates attack mode and attack signal
% Inputs
%   tvec vector of simulation times
%   Fmin minimal sleeping interval length in seconds
%   Fmax maximal active interval length in seconds
%   epsilon1 lower bound for sleeping energy ratio
%   epsilon2 upper bound for attack energy ratio in active mode
%   params struct with possible amplitude scaling fields
% Outputs
%   attack struct with fields
%     mode vector same length as tvec with values 1 for sleeping 2 for active
%     sigma matrix 2 by length tvec attack signal added to state x
% Notes
%   This function does not depend on the actual state x
%   The attack amplitude will be scaled later to meet energy relations

if nargin < 6
    params = struct();
end

N = numel(tvec);
mode = ones(1,N); % default sleeping
sigma = zeros(2,N);

% Build a queue like schedule with variable lengths
t = 0;
idx = 1;
rng(0); % reproducible schedule
while idx <= N
    % sleeping duration at least Fmin
    Tsleep = Fmin + rand()*Fmin; % random between Fmin and 2 Fmin
    Tand = min(idx + round(Tsleep / (tvec(2)-tvec(1))) - 1, N);
    mode(idx:Tand) = 1;
    idx = Tand + 1;
    if idx > N, break; end
    % active duration up to Fmax
    Tactive = min(Fmax, Fmin + rand()*Fmax);
    Tand = min(idx + round(Tactive / (tvec(2)-tvec(1))) - 1, N);
    mode(idx:Tand) = 2;
    idx = Tand + 1;
end

% build nominal sigma shapes that will be scaled later
for k = 1:N
    if mode(k) == 1
        % sleeping small amplitude slow variation
        sigma(:,k) = 0.05 * [tvec(k); 0.5*sin(0.5*tvec(k))];
    else
        % active stronger amplitude faster variation
        sigma(:,k) = 0.5 * [sign(sin(2*tvec(k))); 0.5*cos(1.5*tvec(k))];
    end
end

attack.mode = mode;
attack.sigma_raw = sigma;
attack.epsilon1 = epsilon1;
attack.epsilon2 = epsilon2;
end
