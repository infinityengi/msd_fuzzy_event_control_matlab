% phase0_env_check.m
% Check environment and create project folders
% Usage: run this script at project root

rng(0); % reproducible seed for any random experiments

% Project folders
folders = { ...
    '00_notes', ...
    '01_LTI_basics', ...
    '02_Lyapunov_LMI', ...
    '03_Control_design', ...
    '04_Sampling_network', ...
    '05_Nonlinear_fuzzy', ...
    '06_Event_triggered' ...
    };

for k = 1:numel(folders)
    if ~exist(folders{k}, 'dir')
        mkdir(folders{k});
        fprintf('Created folder: %s\n', folders{k});
    else
        fprintf('Folder exists: %s\n', folders{k});
    end
end

% Check for Control System Toolbox
hasCST = license('test', 'Control_Toolbox');
if hasCST
    fprintf('Control System Toolbox is available\n');
else
    warning('Control System Toolbox not found. Many functions will not run');
end

% Check YALMIP presence
if exist('yalmip', 'file') == 2 || exist('yalmip', 'builtin') || exist('yalmip', 'dir')
    fprintf('YALMIP appears installed\n');
else
    fprintf([ ...
        'YALMIP not found. To install YALMIP add it to MATLAB path. Example commands:\n' ...
        ' 1) Download YALMIP from https://users.chance.nl/johan/yalmip\n' ...
        ' 2) unzip and addpath(genpath(path_to_yalmip))\n' ...
        ' 3) savepath\n' ...
    ]);
end


% Check for CVX or SDPT3 if you plan to use them
if exist('sdpt3','file')
    fprintf('SDPT3 solver appears available\n');
else
    fprintf('solver not installed\n')
end

fprintf('Environment check complete\n');
