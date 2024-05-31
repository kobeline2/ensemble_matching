function [nMember] = matchingEnsemble(p, centRain)

% 10.アンサンブル予測雨量の読み込み + 分類
% 初期時刻を対象期間の開始時刻に設定
Y = p.startY;
M = p.startM;
D = p.startD;
H = p.startH;
tmpDate = datetime(Y, M, D, H, 00, 00);

nWindow = 15*2-p.h/12+1;
ensIdx = zeros(1, 51); 
nMember = zeros(p.nCluster, nWindow); 


for initTimeNum = 1:nWindow % 初期時刻
    % 初期時刻の文字列の作成
    initTime = sprintf('%04d%02d%02d%02d00', Y, M, D, H');
    
    for mem = 1:51 % アンサンブル予測のメンバー(通常はmem = 1:51)   
        fn = fullfile(p.ensFolder,...
            sprintf('%s_%s_%03d.dat', p.basin, initTime, mem));
        ensRain = readmatrix(fn); % アンサンブル雨量の読み込み
        for i = 1:p.nCluster
            % (1)ユークリッド距離
            % d4PDFの各クラスターの重心とアンサンブルの間の距離を計算
            d(i) = norm(centRain(i,:)'-ensRain); 
            % (2)ウォード法
            % d(i) = sqrt((2*nnz(idx==i))/(1+nnz(idx==i)))*norm(centRain(i,:)'-ensRain); % d4PDFの各クラスターとアンサンブルの間の距離をウォード法で計算
        end
        % アンサンブルが分類されたクラスター番号を取得
        [mind, ensIdx(mem)] = min(d); 
    end
    % 各クラスターに分類されたメンバー数を格納
    for i = 1:p.nCluster
        nMember(i, nWindow+1-initTimeNum) = nnz(ensIdx==i); 
    end

    % 初期時刻の更新(-12h)
    tmpDate = tmpDate - hours(12);
    Y = tmpDate.Year;
    M = tmpDate.Month;
    D = tmpDate.Day;
    H = tmpDate.Hour;
end

plotMatchingResult(initTime, nWindow, nMember)

end