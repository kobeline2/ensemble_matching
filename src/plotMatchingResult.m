function plotMatchingResult(initTime, nWindow, nMember)
% 11.ヒートマップの作成
% 日時ベクトルの作成
dt = datetime(str2double(initTime(1:4)),str2double(initTime(5:6)), ...
    str2double(initTime(7:8)),str2double(initTime(9:10)),00,00,'Format','MM/dd HH');
for i = 1:nWindow
    dt(i+1) = dt(i) + 1/2; % +12h
end
dt = char(dt(1:end-1));

% ヒートマップの作成(large)
figure('Position',[300 200 900 450]) % 3列目が幅，4列目が高さ
heat = heatmap(nMember, "Colormap", jet, "ColorLimits", [0 51]);
heat.XLabel = 'Initial Time';
heat.YLabel = 'Cluster Number';
heat.XDisplayLabels = dt;
heat.FontSize = 14; %8;

% ヒートマップの作成(small)
figure('Position',[1300 200 500 250]) % 3列目が幅，4列目が高さ
heat = heatmap(nMember,"Colormap",jet,"ColorLimits",[0 51]);
heat.XLabel = 'Initial Time';
heat.YLabel = 'Cluster Number';
heat.XDisplayLabels = dt;
heat.FontSize = 8;

end