function [sendFlag, reason] = switched_etm_decision(xk, x_last, mode_k, params)
% switched_etm_decision decides if state xk should be sent
% Inputs
%  xk current state vector at sample k
%  x_last last transmitted state vector
%  mode_k 1 for sleeping 2 for active
%  params struct with fields delta delta_active alpha force_on_mode_change prev_mode
% Outputs
%  sendFlag logical whether to send
%  reason string short explanation

% default parameters
if ~isfield(params,'delta'); params.delta = 0.01; end
if ~isfield(params,'delta_active'); params.delta_active = 0.1; end
if ~isfield(params,'alpha'); params.alpha = 0.0; end
if ~isfield(params,'force_on_mode_change'); params.force_on_mode_change = true; end
if ~isfield(params,'prev_mode'); params.prev_mode = mode_k; end

e = xk - x_last;
norm_e2 = e' * e;
norm_x2 = xk' * xk + 1e-9; % avoid zero division

sendFlag = false;
reason = 'none';

% Force send at mode transitions if enabled
if params.force_on_mode_change && mode_k ~= params.prev_mode
    sendFlag = true;
    reason = 'mode change';
    return;
end

if mode_k == 1
    if norm_e2 >= params.delta * norm_x2
        sendFlag = true;
        reason = 'sleeping trigger';
    end
else
    if norm_e2 >= params.delta_active * norm_x2 + params.alpha
        sendFlag = true;
        reason = 'active trigger';
    end
end
end
