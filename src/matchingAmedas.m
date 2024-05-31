function [mind, amedasIdx, nash] = matchingAmedas(p, centRain)

% 9.アメダス雨量の読み込み + 分類 + Nash係数を計算
d    = zeros(1, p.nCluster); % distance
nash = zeros(1, p.nCluster); 
% アメダス雨量の読み込
fn = fullfile(p.amedasFolder,...
              sprintf('%s_%04d%02d%02d%02d00.dat',...
              p.basin, p.startY, p.startM, p.startD, p.startH'));
amedasRain = readmatrix(fn);

for i = 1:p.nCluster
    % (1)ユークリッド距離
    d(i) = norm(centRain(i,:)'- amedasRain); % d4PDFの各クラスターの重心とアメダスの間の距離を計算
    % (2)ウォード法
    % d(i) = sqrt((2*nnz(idx==i))/(1+nnz(idx==i)))*norm(centRain(i,:)'-amedasRain); % d4PDFの各クラスターとアメダスの間の距離をウォード法で計算
    % Nash係数
    bunsi = norm(amedasRain-centRain(i,:)')^2;
    bunbo = norm(amedasRain-mean(amedasRain))^2;
    nash(i) = 1 - bunsi/bunbo; % Nash係数を計算
end
[mind, amedasIdx] = min(d); % アメダスが分類されたクラスター番号を取得


end