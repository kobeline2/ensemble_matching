function rain = readD4pdf(p)

% 2.d4PDF雨量データの読み込み
datFiles = dir(fullfile(p.d4pdfFolder, p.filename));
nDatFile = length(datFiles);
rain = zeros(nDatFile, p.h); 
for i = 1:nDatFile
    rain(i, :) = readmatrix(fullfile(p.d4pdfFolder, datFiles(i).name));
end

end