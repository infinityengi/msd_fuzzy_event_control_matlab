% phase9_report.m
% Generate a PDF report summarizing Phase 9 results
% The script attempts to publish a MATLAB live script if available
% Fallback is to generate a simple LaTeX file and ask user to compile it

clearvars; close all;
figdir = fullfile(pwd,'08_Experiments_and_plots','figures');
load(fullfile(figdir,'phase9_analysis.mat'),'T','unique_delta','unique_delta_active','mat');

% Option A use MATLAB publish if you prefer a simple html or pdf
try
    % create a short live script style publish input programmatically
    publishfile = fullfile(pwd,'08_Experiments_and_plots','phase9_publish.m');
    fid = fopen(publishfile,'w');
    fprintf(fid,'%% Phase 9 Summary Publish Script\n');
    fprintf(fid,'%% Auto generated. Run publish to generate html or pdf.\n');
    fprintf(fid,'disp(''Phase 9 summary'');\n');
    fprintf(fid,'T = load(''%s'');\n', fullfile(figdir,'phase9_analysis.mat'));
    fprintf(fid,'disp(''See figures in the figures folder'');\n');
    fclose(fid);
    opts.format = 'pdf';
    opts.outputDir = fullfile(pwd,'08_Experiments_and_plots','report');
    if ~exist(opts.outputDir,'dir'), mkdir(opts.outputDir); end
    fprintf('Publishing pdf report using MATLAB publish\n');
    publish(publishfile, opts);
    fprintf('Report published to %s\n', opts.outputDir);
    return;
catch err
    warning('Publish failed or not available using fallback LaTeX approach');
end

% Option B fallback produce a LaTeX file and save it
latexfile = fullfile(pwd,'08_Experiments_and_plots','phase9_report.tex');
fid = fopen(latexfile,'w');
fprintf(fid,'\\documentclass[11pt]{article}\n');
fprintf(fid,'\\usepackage{graphicx}\\usepackage{booktabs}\\usepackage{hyperref}\n');
fprintf(fid,'\\begin{document}\n');
fprintf(fid,'\\section*{Phase 9 Summary}\n');
fprintf(fid,'This report summarizes the experiment results. Figures are in the figures folder.\n');
fprintf(fid,'\\subsection*{Summary Table}\n');
fprintf(fid,'The experiment table is saved as a CSV file and can be inspected.\n');
fprintf(fid,'\\subsection*{Figures}\n');
fprintf(fid,'\\begin{figure}[ht]\n\\centering\n');
fprintf(fid,'\\includegraphics[width=0.8\\textwidth]{%s}\n', fullfile('figures','msse_vs_trate.png'));
fprintf(fid,'\\caption{Performance versus communication cost}\n\\end{figure}\n');
fprintf(fid,'\\end{document}\n');
fclose(fid);
fprintf('LaTeX report created at %s\n', latexfile);
fprintf('If you have pdflatex installed run pdflatex on the tex file to create a PDF\n');
