function save_figure(figHandle, filenameBase)
% save_figure Save figure to PNG and PDF
% Inputs
%  figHandle figure handle
%  filenameBase full path without extension
if nargin < 1
    figHandle = gcf;
end
if ~ischar(filenameBase) && ~isstring(filenameBase)
    error('filenameBase must be string');
end

% ensure directory exists
[folder,~,~] = fileparts(filenameBase);
if ~exist(folder,'dir')
    mkdir(folder);
end

% save png
pngfile = [char(filenameBase) '.png'];
print(figHandle, pngfile, '-dpng', '-r300');

% save pdf
pdffile = [char(filenameBase) '.pdf'];
set(figHandle, 'PaperPositionMode', 'auto');
print(figHandle, pdffile, '-dpdf', '-bestfit');

fprintf('Saved figure to %s and %s\n', pngfile, pdffile);
end
