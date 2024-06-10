function rain = readD4pdf(p)
% READD4PDF - Read D4PDF data
%   This function reads the D4PDF data.
%   p: configuration parameters
%   rain: D4PDF data
%
datFiles = dir(fullfile(p.d4pdfFolder, p.filename));
datFiles = datFiles(~startsWith({datFiles.name}, '.')); % remove hidden files
nDatFile = length(datFiles);
rain = zeros(nDatFile, p.h); 
for i = 1:nDatFile
    rain(i, :) = readmatrix(fullfile(p.d4pdfFolder, datFiles(i).name));
end

end