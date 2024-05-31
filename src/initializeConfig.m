function p = initializeConfig(pathConfig)

%1.パラメータの設定
json = fileread(pathConfig);
p = jsondecode(json);
p.d4pdfFolder = fullfile(p.d4pdfFolder, p.basin, [num2str(p.h), 'hours']);
p.amedasFolder = fullfile(p.amedasFolder, p.basin, [num2str(p.h), 'hours']);
p.ensFolder = fullfile(p.ensFolder, p.basin,...
    [num2str(p.h), 'hours'],...
    sprintf('%04d%02d%02d%02d00', p.startY, p.startM, p.startD, p.startH));

end